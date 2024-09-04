function  tapping_fnirs(tutorial_dir, reports_dir)
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


pipeline(1) = struct( 'filter_type', 'FIR', ...
                     'filter_band', [0.005, 0.1],...
                     'epoch_duration', [-10, 35],...
                     'name', 'strict');

pipeline(1).localize_continous = {'mne'};

pipeline(2) = struct( 'filter_type', 'FIR', ...
                     'filter_band', [0.005, 1.5],...
                     'epoch_duration', [-10, 35],...
                     'localize_continous','', ...
                     'name', 'liberal');           
pipeline(2).localize_continous =  {'mne', 'wMEM'};



SubjectName = 'sub-01';

participants_file           = fullfile(tutorial_dir, 'participants.tsv');
FidFile                     = fullfile(tutorial_dir, SubjectName, 'anat','T1w.json');
FSPath                      = fullfile(tutorial_dir, 'derivatives', 'FreeSurfer/',SubjectName);
TissueSegmentationFile      = fullfile(tutorial_dir, 'derivatives', 'segmentation',SubjectName,'segmentation_5tissues.nii');
scoutPath                   = fullfile(tutorial_dir, 'derivatives', 'segmentation',SubjectName,'scout_hand.annot');

RawFile     = fullfile(tutorial_dir, SubjectName, 'nirs',sprintf('%s_task-tapping_run-01.snirf',SubjectName));
FluenceDir  = fullfile(tutorial_dir, 'derivatives','Fluences', SubjectName);

% Check if the folder contains the required files
if ~file_exist(RawFile)
    error(['The folder ' tutorial_dir ' does not contain the folder from the file nirstorm_tutorial_2024.zip.']);
end

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
% % Import hand-know region
import_label(sSubject.Surface(iCortex).FileName, scoutPath,0);
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

% Process: Duplicate tapping events
sFile = bst_process('CallProcess', 'process_evt_merge', sFile, [], ...
    'evtnames', 'tapping', ...
    'newname',  'tapping/start', ...
    'delete',   0);

% Process: Convert to simple event
sFile = bst_process('CallProcess', 'process_evt_simple', sFile, [], ...
    'eventname',  'tapping/start', ...
    'method', 1);

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

for iPipeline = 1:length(pipeline)
    sPipeline = pipeline(iPipeline);

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
        'SS_chan',                 'name', ...  % Based on Names
        'SS_chan_name',            'S1D17,S2D17', ...
        'separation_threshold_cm', 1.5);

    sPreproc_tmp = bst_process('CallProcess', 'process_import_data_time', sPreproc_tmp, [], ...
    'subjectname',   SubjectName, ...
    'condition',     sprintf('%s_task-tapping_run-01_pipeline-%s',SubjectName,sPipeline.name), ...
    'timewindow',    [], ...
    'split',         0, ...
    'ignoreshort',   0, ...
    'usectfcomp',    0, ...
    'usessp',        0, ...
    'freq',          [], ...
    'baseline',      [], ...
    'blsensortypes', 'NIRS');

    % Remove short-separation channels
    tree_set_channelflag(sPreproc_tmp.FileName, 'AddBad', 'S1D17WL685, S1D17WL830, S2D17WL685, S2D17WL830, S3D17WL685, S3D17WL830');

    sPreproc(iPipeline) = sPreproc_tmp;

end
    %% Part 4: Estimation of the HRF to tapping -> then localize

for iPipeline = 1:length(pipeline)
    sPipeline = pipeline(iPipeline);
    sData     = sPreproc(iPipeline);
    
    % 1. Estinate the response using epoch averaging
    sTrialsOd = bst_process('CallProcess', 'process_import_data_event', sData, [], ...
        'subjectname', SubjectName, ...
        'condition',   '', ...
        'eventname',   'tapping/start', ...
        'timewindow',  [], ...
        'epochtime',   sPipeline(1).epoch_duration, ...
        'createcond',  0, ...
        'ignoreshort', 0, ...
        'usectfcomp',  0, ...
        'usessp',      0, ...
        'freq',        [], ...
        'baseline',    []);

    trialStatus = true(1,20);
    trialStatus([1, 15]) = false;

    % Process: DC offset correction: [-10.000s,0.000s]
    sTrialsOd = bst_process('CallProcess', 'process_baseline_norm', sTrialsOd(trialStatus), [], ...
        'baseline',    [-10, 0], ...
        'sensortypes', 'NIRS', ...
        'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
        'overwrite',   0);
    
    % Process: Average+Stderr: By trial group (folder average)
    sAverageOd = bst_process('CallProcess', 'process_average', sTrialsOd, [], ...
        'avgtype',       5, ...  % By trial group (folder average)
        'avg_func',      7, ...  % Arithmetic average + Standard error
        'weighted',      0, ...
        'keepevents',    1);


    % 2. Localization of the response on the cortex 
    
    % Process: Compute fluence
    % bst_process('CallProcess', 'process_nst_cpt_fluences', sAverageOd, [], ...
    %     'subjectname',  SubjectName, ...
    %     'fluencesCond', struct(...
    %          'surface',                   'montage', ...
    %          'ChannelFile',               sAverageOd.ChannelFile    , ...
    %          'SubjectName',               SubjectName, ...
    %          'segmentation_label',        1, ...
    %          'wavelengths',               '685 ,830', ...
    %          'software',                  'mcxlab-cl', ...
    %          'mcxlab_gpuid',              1, ...
    %          'mcxlab_nphoton',            100, ...
    %          'outputdir',                 FluenceDir, ...
    %          'mcxlab_flag_thresh',        0, ...
    %          'mcxlab_overwrite_fluences', 0, ...
    %          'mcxlab_flag_autoOP',        1));

    % Process: Compute head model from fluence
    bst_process('CallProcess', 'process_nst_import_head_model', sAverageOd, [], ...
        'data_source',               FluenceDir, ...
        'use_closest_wl',            0, ...
        'method',                    'geodesic_dist', ...  %  Geodesic (recommended)
        'smoothing_fwhm',            10, ...
        'use_all_pairs',             0, ...
        'normalize_fluence',         1, ...
        'force_median_spread',       0, ...
        'sensitivity_threshold_pct', 0);


    % Process: Source reconstruction - wMNE
    sFilesMNE = bst_process('CallProcess', 'process_nst_wmne', sAverageOd, [], ...
        'thresh_dis2cortex',    5, ...
        'depth_weightingMNE',   0.3, ...
        'TimeSegment',          sPipeline(1).epoch_duration, ...
        'NoiseCov_recompute',   1, ...
        'TimeSegmentNoise',     [-10, 0], ...
        'store_sparse_results', 0);

    % Process: Compute sources: BEst
    mem_option = be_pipelineoptions([], 'cMEM');
    mem_option.optional = struct_copy_fields(mem_option.optional, ...
                         struct(...
                                 'TimeSegment',     sPipeline(1).epoch_duration, ...
                                 'BaselineType',    {{'within-data'}}, ...
                                 'Baseline',        [], ...
                                 'BaselineHistory', {{'within'}}, ...
                                 'BaselineSegment', [-10, 0], ...
                                 'groupAnalysis',   0, ...
                                 'display',         0));
    mem_option.model.depth_weigth_MEM = 0.3;
    mem_option.model.depth_weigth_MNE = 0.3;


    sFilesMEM = bst_process('CallProcess', 'process_nst_cmem', sAverageOd, [], ...
        'mem', struct('MEMpaneloptions', mem_option), ...
        'thresh_dis2cortex',       5, ...
        'NoiseCov_recompute',      1, ...
        'auto_neighborhood_order', 1, ...
        'store_sparse_results',    0);

end

%% Part 5: Locqliwe then estimate the HRF to tapping


for iPipeline = 1:length(pipeline)
    sPipeline = pipeline(iPipeline);
    sData     = sPreproc(iPipeline);

    if any(contains(sPipeline.localize_continous, 'mne'))
        % Process: Source reconstruction - wMNE
        sFilesMNE = bst_process('CallProcess', 'process_nst_wmne', sData, [], ...
            'thresh_dis2cortex',    5, ...
            'depth_weightingMNE',   0.3, ...
            'TimeSegment',          [], ...
            'NoiseCov_recompute',   1, ...
            'TimeSegmentNoise',     [760, 780], ...
            'store_sparse_results', 0);

        bst_process('CallProcess', 'process_windows_average_time', sFilesMNE(contains({sFilesMNE.Comment}, {'HbO','HbR','HbT'})), [], ...
            'Eventname',      'tapping', ...
            'timewindow',     sPipeline.epoch_duration, ...
            'remove_DC',      1, ...
            'baselinewindow', [-10, 0], ...
            'overwrite',      0, ...
            'source_abs',     0);
    end

    if any(contains(sPipeline.localize_continous, 'wMEM'))

        mem_option = be_pipelineoptions([], 'wMEM');
        mem_option.optional = struct_copy_fields(mem_option.optional, ...
                         struct(...
                                 'TimeSegment',     [0, 1123], ...
                                 'BaselineType',    {{'within-data'}}, ...
                                 'BaselineHistory', {{'within'}}, ...
                                 "baseline_shuffle", 0, ...
                                 "BaselineSegment", [760, 780] , ...
                                 'display',         1));
        mem_option.model.depth_weigth_MEM = 0.3;
        mem_option.model.depth_weigth_MNE = 0.3;
        mem_option.wavelet.selected_scales =  [3:9];

        profile on -historysize 1e9
        sFilesMEM = bst_process('CallProcess', 'process_nst_cmem', sData, [], ...
            'mem', struct('MEMpaneloptions', mem_option), ...
            'thresh_dis2cortex',       5, ...
            'NoiseCov_recompute',      1, ...
            'auto_neighborhood_order', 1, ...
            'store_sparse_results',    0);
        profile viewer
        
       bst_process('CallProcess', 'process_windows_average_time', sFilesMEM(contains({sFilesMEM.Comment}, {'HbO','HbR','HbT'})), [], ...
            'Eventname',      'tapping', ...
            'timewindow',     sPipeline.epoch_duration, ...
            'remove_DC',      1, ...
            'baselinewindow', [-10, 0], ...
            'overwrite',      0, ...
            'source_abs',     0);

      mem_option.wavelet.selected_scales =  [6:9];

      sFilesMEM = bst_process('CallProcess', 'process_nst_cmem', sData, [], ...
            'mem', struct('MEMpaneloptions', mem_option), ...
            'thresh_dis2cortex',       5, ...
            'NoiseCov_recompute',      1, ...
            'auto_neighborhood_order', 1, ...
            'store_sparse_results',    0);
       bst_process('CallProcess', 'process_windows_average_time', sFilesMEM(contains({sFilesMEM.Comment}, {'HbO','HbR','HbT'})), [], ...
            'Eventname',      'tapping', ...
            'timewindow',     sPipeline.epoch_duration, ...
            'remove_DC',      1, ...
            'baselinewindow', [-10, 0], ...
            'overwrite',      0, ...
            'source_abs',     0);
    end

end

% Save and display report
ReportFile = bst_report('Save', []);
if ~isempty(reports_dir) && ~isempty(ReportFile)
    bst_report('Export', ReportFile, reports_dir);
else
    bst_report('Open', ReportFile);
end

disp([10 'BST> tutorial_nirstorm: Done.' 10]);

end

