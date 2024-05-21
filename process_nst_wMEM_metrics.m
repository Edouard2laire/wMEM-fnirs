function varargout = process_nst_wMEM_metrics( varargin )
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
    sProcess.Comment     = 'Compute Metrics';
    sProcess.FileTag     = '';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'NIRS', 'Simulation'};
    sProcess.Index       = 20150;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'results'};
    sProcess.OutputTypes  = {'results'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.isSeparator = 0;
    
    % === MAX DIST
    sProcess.options.maxDist.Comment = ['Maximum distance for the ' ...
                                'computation of the metrics (0: disable)'];
    sProcess.options.maxDist.Type    = 'value';
    sProcess.options.maxDist.Value   = {40, 'mm', 0};
    
    
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
    %% ===== RUN =====function OutputFile = Run(sProcess, sInput)
    % Load input file
    sGroundTruth = in_bst_data(sInput(strcmp({sInput.Comment},'Ground Truth')).FileName);
    sCortex = load(file_fullpath(sGroundTruth.SurfaceFile));
    simulation_options = sGroundTruth.simulation_options; 
    
    % save information about the simulation 
    iMaps = find(~strcmp({sInput.Comment},'Ground Truth'));
    all_results = table('Size',[length(iMaps) 9],'VariableType',{'string','double','double','double','string','double','double','double','double'},'VariableNames',{'ROI', 'SNR','active_area','time','method','DLE','SD','AUC','correlation'});
    for iFile = 1:length(iMaps)
        results = table();
        sData = in_bst_data(sInput(iMaps(iFile)).FileName);
        results.ROI = string(simulation_options.Label);
        results.SNR  = simulation_options.options.SNR;
        results.active_area = length(simulation_options.Vertices);
    
        
        [M,timeZeroSample] =  max(max(abs(sGroundTruth.ImageGridAmp)));
        results.time = sGroundTruth.Time(timeZeroSample);
        vertex_active = find(sGroundTruth.ImageGridAmp(:,timeZeroSample));
        
        d = min(nst_pdist(sCortex.Vertices*1000,sCortex.Vertices(vertex_active,:)*1000),[],2);
        
        results.method  = string(sData.Comment);
        valide_nodes = find(~all(abs(sData.ImageGridAmp) == 0,2));
    
    
        % Compute spatial metrics (at the time of the peak)
        data = abs(sData.ImageGridAmp(valide_nodes,timeZeroSample));
        gt = zeros(size(sData.ImageGridAmp,1),1);
        gt(vertex_active) = 1;
        tActiveVertex = find(gt(valide_nodes)); 
        tInactiveVertex = setdiff(1:length(valide_nodes),tActiveVertex)';
    
        distances = d(valide_nodes); 
    
        % 1. DLE --  Distance from the max vertex to the ground truth
        [~,maxVert] = max(abs(data));
        results.DLE = distances(maxVert);
            
        % 2. Spatial Dispersion
        results.SD = sqrt(sum(distances.^2 .* data.^2) / sum(data.^2));
        
        % 3. AUC 
        
        data = data ./ max(data);
        thresholds = linspace(0, 1, 5000);

        % Following code use resampling for the AUC. to check with
        % christophe
        % VoisinsOA = adj2Voisins(sCortex.VertConn(valide_nodes,valide_nodes));
        % nClusters = 10;
        % isRandom = 1;
        % VERBOSE = 0;
        % Labels = tess_cluster(sCortex.VertConn(valide_nodes,valide_nodes), nClusters, isRandom, VERBOSE);
        % 
        % mycluster = cell(1,nClusters);
        % for i = 1:nClusters
        %     mycluster{i} = find(Labels == i);
        % end
        % 
        % Jtheo = zeros(size(data));
        % Jtheo(tActiveVertex) = 1;
        % 
        % nb_resampling = 100;
        % ordreVoisinage = 8;
        % [Res_summary,Res_close_summary,Res_far_summary  ] =  Compute_ALL_AUC_global(0, ...
        %                                                                         Jtheo, data, 1, ...
        %                                                                         VoisinsOA, ...
        %                                                                         mycluster, ...
        %                                                                         nb_resampling,...
        %                                                                         ordreVoisinage,...
        %                                                                         thresholds, ...
        %                                                                         []);


        sensitivity  = zeros(1,length(thresholds));
        specificity  = zeros(1,length(thresholds));
        TP  = zeros(1,length(thresholds));
        FP  = zeros(1,length(thresholds));
        TN  = zeros(1,length(thresholds));
        FN  = zeros(1,length(thresholds));
    
        for iThreshold = 1:length(thresholds)
            active_vertex = find(abs(data) >= thresholds(iThreshold)); 
            inactive_vertex = find(abs(data) < thresholds(iThreshold)); 
    
            TP(iThreshold) = length(intersect(tActiveVertex, active_vertex));
            FP(iThreshold) = length(setdiff(active_vertex,tActiveVertex));
            
            TN(iThreshold) = length(intersect(tInactiveVertex, inactive_vertex ));
            FN(iThreshold) = length(setdiff(inactive_vertex,tInactiveVertex));
    
            sensitivity(iThreshold)  = TP(iThreshold) / (TP(iThreshold) + FN(iThreshold));
            specificity(iThreshold)  = TN(iThreshold) / (TN(iThreshold) + FP(iThreshold));
        end
        
        [~,idx] = sort(1-specificity);
        results.AUC = trapz(1-specificity(idx),sensitivity(idx));
        %figure; subplot(121); plot(thresholds, [TP; FP; TN; FN]);  subplot(122); plot(1-specificity(idx),sensitivity(idx)); 
    
        %2. Compute the temporal metrics 
        all_corr = zeros(1, length(vertex_active));
        for iVertex = 1:length(vertex_active)
            Corr = corrcoef(sGroundTruth.ImageGridAmp(vertex_active(iVertex), :), sData.ImageGridAmp(vertex_active(iVertex), :) );
            all_corr(iVertex) = Corr(1,2);
        end
        results.correlation = median(all_corr);
        all_results(iFile,:) = results;
    end

    %3. Save the results 
    writetable(all_results,sProcess.options.textFile.Value{1},'WriteMode','Append')
end
