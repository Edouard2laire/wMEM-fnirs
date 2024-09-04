function  simul_fnirs(tutorial_dir, reports_dir)
% tapping_fnirs: Script to PERFORM wMEM on the tapping dataset
% Dataset: https://osf.io/md54y/?view_only=0d8ad17d1e1449b5ad36864eeb3424ed 
% CORRESPONDING ONLINE TUTORIALS:
%     https://neuroimage.usc.edu/brainstorm/Tutorials/NIRSTORM
%
% INPUTS: 
%    - tutorial_dir: Directory where the sample_nirstorm.zip file has been downloaded
%    - reports_dir  : Directory where to save the execution report (instead of displaying it)

% @=============================================================================
% This function is part of the Brainstorm software:
% https://neuroimage.usc.edu/brainstorm
% 
% Copyright (c) University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Author: Edouard Delaire, 2024

% ===== FILES TO IMPORT =====
% Output folder for reports
if (nargin < 2) || isempty(reports_dir) || ~isdir(reports_dir)
    reports_dir = [];
end
% You have to specify the folder in which the tutorial dataset is unzipped
if (nargin == 0) || isempty(tutorial_dir) || ~file_exist(tutorial_dir)
    error('The first argument must be the full path to the tutorial dataset folder.');
end

% Processing options: 


sPipeline = struct( 'extraction_windows', [900, 1977], ...
                    'simulation_windows', [384, 1074], ...
                   'filter_type', 'FIR', ...
                   'filter_band', [0.005, 1.5], ...
                   'name', 'preproc');

SubjectName = 'sub-02';

participants_file           = fullfile(tutorial_dir, 'participants.tsv');
FidFile                     = fullfile(tutorial_dir, SubjectName, 'anat','T1w.json');
FSPath                      = fullfile(tutorial_dir, 'derivatives', 'FreeSurfer',SubjectName);
TissueSegmentationFile      = fullfile(tutorial_dir, 'derivatives', 'segmentation',SubjectName,'segmentation_5tissues.nii');

RawFile     = fullfile(tutorial_dir, SubjectName, 'nirs',sprintf('%s_ses-02_task-sleep_mod-nirs_run-02_sync.snirf',SubjectName));
FluenceDir  = fullfile(tutorial_dir, 'derivatives','Fluences', SubjectName);

% Check if the folder contains the required files
% if ~file_exist(RawFile)
%     error(['The folder ' tutorial_dir ' does not contain the folder from the file nirstorm_tutorial_2024.zip.']);
% end

sParticipant = readtable(participants_file, 'FileType','text');

% ===== CREATE PROTOCOL =====
ProtocolName = 'wMEM-nirs';

% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end

iProtocol = bst_get('Protocol', ProtocolName);
if isempty(iProtocol)
    % Create new protocol
    gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);
else
    % Load protocol
    gui_brainstorm('SetCurrentProtocol', iProtocol);
end


% Start a new report
bst_report('Start');

%% Part 1. Importing subject anatomical data
json = bst_jsondecode(FidFile);
sFid = process_import_bids('GetFiducials',json, 'voxel');

bst_process('CallProcess', 'process_import_anatomy', [], [], ...
    'subjectname', SubjectName, ...
    'mrifile',     {FSPath, 'FreeSurfer+Thick'}, ...
    'nvertices',   15000, ...
    'nas',         sFid.NAS, ...
    'lpa',         sFid.LPA, ...
    'rpa',         sFid.RPA, ...
    'ac',          sFid.AC, ...
    'pc',          sFid.PC, ...
    'ih',          sFid.IH);

[sSubject, iSubject]  = bst_get('Subject', SubjectName);

% % Import tissue segmentation
import_mri(iSubject, TissueSegmentationFile, '', 0, 0, 'segmentation_5tissues');
% 
% % Remesh skin to 10 000 vertices, iso-mesh
tess_remesh(sSubject.Surface(sSubject.iScalp).FileName ,10000 )
% 
% % Choose mid-surface as default cortical surface
iCortex = find(contains({sSubject.Surface.FileName},'tess_cortex_mid_low.mat'));
db_surface_default(iSubject, 'Cortex',iCortex);
panel_protocols('RepaintTree');
% 

% % Compute voronoi-interpolation
bst_process('CallProcess', 'process_nst_compute_voronoi', [], [], ...
    'subjectname',  SubjectName, ...
    'do_grey_mask', 1);



%% Part 2. Import functional data


sFile = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
                                    'subjectname',    SubjectName, ...
                                    'datafile',       {RawFile, 'NIRS-SNIRF'}, ...
                                    'channelreplace', 1, ...
                                    'channelalign',   1, ...
                                    'evtmode',        'value');


% Import head points 
% Note: already done since headpoints are included in the snirf file
% bst_process('CallProcess', 'process_headpoints_add', sFile, [], ...
%             'channelfile', {HeadpointsPath, 'ASCII_NXYZ'}, ...
%             'fixunits',    0.1, ...
%             'vox2ras',     0); % we are using fiducials define in headpoints 

% Remove headpoints bellow nasion
% Note: already done since headpoints are included in the snirf file
% process_headpoints_remove('RemoveHeadpoints', sFile.ChannelFile, 0) 

% Refine registration
% Note: already done since headpoints are included in the snirf file
% bst_process('CallProcess', 'process_headpoints_refine', sFile, []);

% Process: Snapshot: Sensors/MRI registration
bst_process('CallProcess', 'process_snapshot', sFile, [], ...
    'target',   1, ...  % Sensors/MRI registration
    'modality', 7, ...  % NIRS
    'orient',   1, ...  % left
    'Comment',  'NIRS/MRI Registration');

% Process: Extract time: [900.000s,1977.000s]
sFile = bst_process('CallProcess', 'process_extract_time', sFile, [], ...
    'timewindow', sPipeline.extraction_windows);

% Process: Add time offset: -900.00ms
sFile = bst_process('CallProcess', 'process_timeoffset', sFile, [], ...
    'info',      [], ...
    'offset',    -sPipeline.extraction_windows(1), ...
    'overwrite', 0);

% Process: Detect bad channels
sFile = bst_process('CallProcess', 'process_nst_detect_bad', sFile, [], ...
    'option_sci',                   0, ...
    'sci_threshold',                80, ...
    'power_threshold',              10, ...
    'option_coefficient_variation', 1, ...
    'coefficient_variation',        10, ...
    'option_remove_saturating',     0, ...
    'option_max_sat_prop',          10, ...
    'option_min_sat_prop',          10, ...
    'option_separation_filtering',  0, ...
    'option_separation',            [0, 5], ...
    'auxilary_signal',              3, ...  % Remove all
    'option_keep_unpaired',         0);

sRaw = sFile;

%% Part 3. Preprocessing

sRawdOD = bst_process('CallProcess', 'process_nst_dOD', sRaw, [], ...
    'option_baseline_method', 1, ...  % mean
    'timewindow',             []);

% Process: Motion Corrected (TDDR)
sPreproc_tmp = bst_process('CallProcess', 'process_nst_motion_correction', sRawdOD, [], ...
    'method',            'tddr', ...  %  Temporal Derivative Distribution Repair
    'option_event_name', 'motion', ...
    'option_smoothing',  0.99);

sPreproc_tmp = bst_process('CallProcess', 'process_bandpass', sPreproc_tmp, [], ...
        'sensortypes', 'NIRS', ...
        'highpass',    sPipeline.filter_band(1), ...
        'lowpass',     sPipeline.filter_band(2), ...
        'tranband',    0.005, ...
        'attenuation', 'relax', ...     % 40dB (relaxed)
        'ver',         '2019', ...      % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
sPreproc_tmp = bst_process('CallProcess', 'process_nst_remove_ssc', sPreproc_tmp, [], ...
    'SS_chan',                 'distance', ...  % Based on Names
    'SS_chan_name',            '', ...
    'separation_threshold_cm', 1.5);


sPreproc_tmp = bst_process('CallProcess', 'process_import_data_time', sPreproc_tmp, [], ...
'subjectname',   SubjectName, ...
'condition',     sprintf('%s_task-tapping_run-01_pipeline-%s',SubjectName,sPipeline.name), ...
'timewindow',    sPipeline.simulation_windows, ...
'split',         0, ...
'ignoreshort',   0, ...
'usectfcomp',    0, ...
'usessp',        0, ...
'freq',          [], ...
'baseline',      [], ...
'blsensortypes', 'NIRS');

sPreproc_tmp = bst_process('CallProcess', 'process_timeoffset', sPreproc_tmp, [], ...
    'info',      [], ...
    'offset',    -sPipeline.simulation_windows(1), ...
    'overwrite', 1);

sPreproc = sPreproc_tmp;

%% Estimate forward model and prepare simulation 

bst_process('CallProcess', 'process_nst_import_head_model', sPreproc, [], ...
    'data_source',               FluenceDir, ...
    'use_closest_wl',            0, ...
    'method',                    'geodesic_dist', ...  %  Geodesic (recommended)
    'smoothing_fwhm',            5, ...
    'use_all_pairs',             0, ...
    'normalize_fluence',         1, ...
    'force_median_spread',       0, ...
    'sensitivity_threshold_pct', 0);


% Process: Extract sensitivity surfaces from head model
sMaps = bst_process('CallProcess', 'process_nst_extract_sensitivity_from_head_model', sPreproc, [], ...
                                     'method',            'db_global', ...  % Linear
                                     'export_overlap',    1, ...
                                     'export_FOV',        1, ...
                                     'thresh_dis2cortex', 5);

% Save and display report
ReportFile = bst_report('Save', []);
if ~isempty(reports_dir) && ~isempty(ReportFile)
    bst_report('Export', ReportFile, reports_dir);
else
    bst_report('Open', ReportFile);
end

disp([10 'BST> tutorial_nirstorm: Done.' 10]);

end

