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
    sProcess.Comment     = 'Compute sources: BEst';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'NIRS', 'Simulation'};
    sProcess.Index       = 3004;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;



    % Definition of the options for source reconstruction

    sProcess.options.mem.Comment = {'panel_brainentropy', 'Source estimation options: '};
    sProcess.options.mem.Type    = 'editpref';
    sProcess.options.mem.Value   = be_main();

    sProcess.options.thresh_dis2cortex.Comment = 'Reconstruction Field of view (distance to montage border)';
    sProcess.options.thresh_dis2cortex.Type    = 'value';
    sProcess.options.thresh_dis2cortex.Value   = {3, 'cm',2};
    
    sProcess.options.auto_neighborhood_order.Comment = 'Set neighborhood order automatically (default)';
    sProcess.options.auto_neighborhood_order.Type    = 'checkbox';
    sProcess.options.auto_neighborhood_order.Value   = 1;
end
%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

    OutputFiles = {};
    folder_out = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs', string(datetime('today')) ,'in');
    if ~exist(folder_out)
        mkdir(folder_out)
    end
    
    %% Load head model
    sStudy = bst_get('Study', sInputs.iStudy);
    if isempty(sStudy.iHeadModel)
        bst_error('No head model found. Consider running "NIRS -> Compute head model"');
        return;
    end
    
    nirs_head_model = in_bst_headmodel(sStudy.HeadModel(sStudy.iHeadModel).FileName);
    nirs_head_model.FileName = sStudy.HeadModel(sStudy.iHeadModel).FileName;

    if strcmp(sInputs.FileType, 'data')     % Imported data structure
        sDataIn = in_bst_data(sInputs(1).FileName);
    elseif strcmp(sInputs.FileType, 'raw')  % Continuous data file
        sDataIn = in_bst(sInputs(1).FileName, [], 1, 1, 'no');
    end
    
    ChannelMat = in_bst_channel(sInputs(1).ChannelFile);
    if ~isfield(ChannelMat.Nirs, 'Wavelengths')
        bst_error(['cMEM source reconstruction works only for dOD data ' ... 
                   ' (eg do not use MBLL prior to this process)']);
        return;
    end
    sProcess.options.NoiseCov_recompute.Value   = 1;
    OPTIONS         = process_nst_cmem('getOptions',sProcess,nirs_head_model, sInputs(1).FileName);


    %% Run MEM
    sOutput = export(OPTIONS,ChannelMat, sDataIn );
    [~,sOutput_name] = fileparts(sInputs(1).FileName);
    save(fullfile(folder_out, sprintf('%s.mat', sOutput_name)), "sOutput");


end


function sOutput = export(OPTIONS,ChannelMat, sDataIn )


    nirs_head_model = in_bst_headmodel(OPTIONS.HeadModelFile);
    cortex = in_tess_bst(nirs_head_model.SurfaceFile);

    thresh_dis2cortex       = OPTIONS.thresh_dis2cortex;
    valid_nodes             = nst_headmodel_get_FOV(ChannelMat, cortex, thresh_dis2cortex,sDataIn.ChannelFlag );


    %% estimate the neighborhood order for cMEM  (goal: # of clusters ~= # of good channels) 
    if OPTIONS.flag_auto_nbo
        swl = ['WL' num2str(ChannelMat.Nirs.Wavelengths(1))];
        n_channel = sum(strcmpi({ChannelMat.Channel.Group}, swl) & (sDataIn.ChannelFlag>0)');
    
        nbo = process_nst_cmem('estimate_nbo',cortex, valid_nodes, n_channel, 1 );
        OPTIONS.MEMpaneloptions.clustering.neighborhood_order = nbo;
    end

    
    sOutput = struct( 'OPTIONS', OPTIONS, ...
                       'ChannelMat',ChannelMat, ...
                       'nirs_head_model', nirs_head_model, ...
                       'cortex', cortex, ...
                       'sDataIn', sDataIn) ; 

end
