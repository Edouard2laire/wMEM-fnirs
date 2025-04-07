function varargout = process_nst_wMEM_metrics_other( varargin )
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>

    % Description the process
    sProcess.Comment     = 'Compute other';
    sProcess.FileTag     = '';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'NIRS', 'Simulation'};
    sProcess.Index       = 20150;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'results'};
    sProcess.OutputTypes = {'results'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.isSeparator = 0;
    
    
    % Definition of the options
    % === TARGET
    % File selection options
    SelectOptions = {...
        '', ...                            % Filename
        '', ...                            % FileFormat
        'save', ...                        % Dialog type: {open,save}
        'Save text file...', ... % Window title
        'ExportData', ...                  % LastUsedDir: {ImportData,ImportChannel,ImportAnat,ExportChannel,ExportData,ExportAnat,ExportProtocol,ExportImage,ExportScript}
        'single', ...                      % Selection mode: {single,multiple}
        'files', ...                        % Selection mode: {files,dirs,files_and_dirs}
        {{'.txt'}, 'text file', 'txt'}, ... % Available file formats
        []};                          % DefaultFormats: {ChannelIn,DataIn,DipolesIn,EventsIn,MriIn,NoiseCovIn,ResultsIn,SspIn,SurfaceIn,TimefreqIn}
    % Option: MRI file
    sProcess.options.textFile.Comment = 'Output folder:';
    sProcess.options.textFile.Type    = 'filename';
    sProcess.options.textFile.Value   = SelectOptions;
       
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

function OutputFile = Run(sProcess, sInput)
    OutputFile = '';
    
    global GlobalData;

    %% ===== RUN =====function OutputFile = Run(sProcess, sInput)
    % Load ground truth
    sGroundTruth = in_bst_data(sInput(strcmp({sInput.Comment},'Theo')).FileName);
    sCortex = load(file_fullpath(sGroundTruth.SurfaceFile));

    % Extract map at 358.3 ms
    t0 = 358.3*1e-3;
    [~,idx] = min(abs(sGroundTruth.Time - t0));
    sTruth = sGroundTruth.ImageGridAmp(:,idx);
    idx_truth = sTruth > 0;

    
    
    % GlobalData = rmfield(GlobalData , 'ROC_Struct') to clear 
    if isfield(GlobalData, 'ROC_Struct') && ~isempty(GlobalData.ROC_Struct)
        ROC_Struct = GlobalData.ROC_Struct;
    else
        ROC_Struct = prepare_ROC(sCortex);
        GlobalData.ROC_Struct = ROC_Struct;
    end

    Jtheo = zeros(size(sTruth));
    Jtheo(idx_truth) = 1;

    % Distance to the ground truth
    distances = min(nst_pdist(sCortex.Vertices*1000,sCortex.Vertices(idx_truth,:)*1000),[],2);
    
    iMaps = find(~strcmp({sInput.Comment},'Theo'));
    R = [];

    for iFile = 1:length(iMaps)
        sData = in_bst_data(sInput(iMaps(iFile)).FileName);
        data = abs(sData.ImageGridAmp(:,idx))*1e10;

        name = strsplit(sData.Comment, '|');
        name = string(name{1});

        % 1. DLE --  Distance from the max vertex to the ground truth
        [~,maxVert] = max(abs(data));
        DLE = distances(maxVert);


        % 2. Spatial Dispersion
        SD = sqrt(sum(distances.^2 .* data.^2) / sum(data.^2));


        % 3. Area 
        area = length(find( data > 0.3 * max(data)));

        % 4. AUC
        [Res_summary,Res_close_summary,Res_far_summary  ] =  Compute_ALL_AUC_global(0, ...
                                                                                 Jtheo, data, 1, ...
                                                                                 ROC_Struct.VoisinsOA, ...
                                                                                 ROC_Struct.mycluster, ...
                                                                                 ROC_Struct.nb_resampling,...
                                                                                 ROC_Struct.ordreVoisinage,...
                                                                                 ROC_Struct.thresholds, ...
                                                                                 []);
        auc_mean    = Res_summary.AUC_mean;
        auc_close   = Res_close_summary.AUC_mean;
        auc_far     = Res_far_summary.AUC_mean;

        if isfield(sData, 'MEMoptions') && isfield(sData.MEMoptions.automatic, 'perf')
            time_MNE = sData.MEMoptions.automatic.perf.MNE;
            time_MEM = sData.MEMoptions.automatic.perf.MEM;
            time_MainLoop = sData.MEMoptions.automatic.perf.MainLoop;
        end

        T = table(name, DLE, SD,area, auc_mean,auc_close,auc_far, time_MNE,time_MEM, time_MainLoop);
        R = [R; T];
    end

    %3. Save the results 
    writetable(R,sProcess.options.textFile.Value{1},'WriteMode','Append')
end



function [output] = prepare_ROC(sCortex)
    
    output = struct();
    output.VoisinsOA   = adj2Voisins(sCortex.VertConn);
    output.nClusters   = 30;
    output.isRandom    = 1;
    output.VERBOSE     = 0;
    output.Labels      = tess_cluster(sCortex.VertConn, output.nClusters, output.isRandom, output.VERBOSE);
    
    mycluster = cell(1,output.nClusters);
    for i = 1:output.nClusters
        mycluster{i} = find(output.Labels == i);
    end
    output.mycluster = mycluster;


    
    output.nb_resampling    = 39;
    output.ordreVoisinage   = 5;
    output.thresholds = linspace(0, 1, 100);
end