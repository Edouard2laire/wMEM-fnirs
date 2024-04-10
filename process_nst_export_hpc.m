function varargout = process_nst_export_hpc( varargin )
% process_nst_export_hpc:  Compute source-localization using Bootstrap
% and MEM

% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
%
% Copyright (c)2000-2018 University of Southern California & McGill University
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
% Authors: Edouard Delaire, 2022

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Export data to HPC';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'NIRS', 'Simulation'};
    sProcess.Index       = 3004;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;


end
%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

    OutputFiles = {};

    token = char(floor(26*rand(1, 10)) + 65); 
    script_path = '/Users/edelaire1/Documents/Project/wMEM-fnirs';

    folder_out = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs', token );
    mkdir(fullfile(folder_out,'in'));

    
    %% Load head model
    sStudy = bst_get('Study', sInputs.iStudy);
    if isempty(sStudy.iHeadModel)
        bst_error('No head model found. Consider running "NIRS -> Compute head model"');
        return;
    end
    
    nirs_head_model = in_bst_headmodel(sStudy.HeadModel(sStudy.iHeadModel).FileName);
    nirs_head_model.FileName = sStudy.HeadModel(sStudy.iHeadModel).FileName;
    
    cortex = in_tess_bst(nirs_head_model.SurfaceFile);
    
    fID = fopen(fullfile(script_path, sprintf('launch_script_%s.sh', token)), 'w+');

    for iInput = 1:length(sInputs)
        if strcmp(sInputs(iInput).FileType, 'data')     % Imported data structure
            sDataIn = in_bst_data(sInputs(iInput).FileName);
        elseif strcmp(sInputs(iInput).FileType, 'raw')  % Continuous data file
            sDataIn = in_bst(sInputs(iInput).FileName, [], 1, 1, 'no');
        end
    
        ChannelMat = in_bst_channel(sInputs(iInput).ChannelFile);
        if ~isfield(ChannelMat.Nirs, 'Wavelengths')
            bst_error(['cMEM source reconstruction works only for dOD data ' ... 
                       ' (eg do not use MBLL prior to this process)']);
            return;
        end

        OPTIONS                 = struct();
        OPTIONS.sStudy          = sStudy;
        OPTIONS.Comment         = 'MEM';
        OPTIONS.DataFile        = sInputs(iInput).FileName;
        OPTIONS.ResultFile      = [];
        OPTIONS.HeadModelFile   = nirs_head_model.FileName;
        OPTIONS.FunctionName    = 'mem';
        OPTIONS.DataTypes = {'NIRS'};
        OPTIONS.NoiseCov = [];
    
        sOutput = struct(  'OPTIONS', OPTIONS, ...
                           'ChannelMat',ChannelMat, ...
                           'nirs_head_model', nirs_head_model, ...
                           'cortex', cortex, ...
                           'sDataIn', sDataIn) ; 
    
        %% Run MEM
        [~,sOutput_name] = fileparts(sInputs(iInput).FileName);
        save(fullfile(folder_out, 'in', sprintf('%s.mat', sOutput_name)), "sOutput");

        fprintf(fID, 'qsub -j y -o logs/%s.txt -pe smp 16 -S /bin/bash -m abe -M edouard.delaire@concordia.ca -cwd -q matlab.q -N MEM_%s ./start_hpc.sh %s %s \n', ...
                       sprintf('%d_%s',iInput,token), sprintf('%d_%s',iInput,token), fullfile(token, 'in', sprintf('%s.mat', sOutput_name)),  'wMEM_options.json');
    end
    fclose(fID);

     fID = fopen(fullfile(folder_out, 'README.txt'), 'w+');
     fprintf(fID, 'Simulation created on %s \n', char(datetime('today')));
     fprintf(fID, 'To tranfert the data to concordia, execute\n');
     fprintf(fID, 'rsync --progress --update --recursive ~/Documents/Project/wMEM-fnirs/%s edelaire@perf-imglab07:/NAS/home/edelaire/Documents/Project/wMEM-fnirs/  \n', token);
     fprintf(fID, 'rsync --progress --update --recursive ~/Documents/Project/wMEM-fnirs/%s edelaire@perf-imglab07:/NAS/home/edelaire/Documents/Project/wMEM-fnirs/  \n', sprintf('launch_script_%s.sh', token));

    fprintf(fID, 'To launch the script, execute\n');
    fprintf(fID, 'cd ~/Documents/Project/wMEM-fnirs\n');
    fprintf(fID, '%s\n', fullfile(script_path, sprintf('launch_script_%s.sh', token)));

    fprintf(fID, 'To collect the data from concordia, execute\n');
    fprintf(fID, 'rsync --progress --update --recursive edelaire@perf-imglab07:/NAS/home/edelaire/Documents/Project/wMEM-fnirs/%s  ~/Documents/Project/wMEM-fnirs \n', token);
    fprintf(fID, 'rsync --progress --update --recursive edelaire@perf-imglab07:/NAS/home/edelaire/Documents/Project/wMEM-fnirs/logs  ~/Documents/Project/wMEM-fnirs \n');

    fclose(fID);

end


