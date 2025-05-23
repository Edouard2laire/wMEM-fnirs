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
    sProcess.SubGroup    = {'Custom Processes','NIRS - wMEM'};
    sProcess.Index       = 20150;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'results'};
    sProcess.OutputTypes  = {'results'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.isSeparator = 0;
    

    sProcess.options.time_of_interest.Comment = 'Time of interest: ';
    sProcess.options.time_of_interest.Type    = 'value';
    sProcess.options.time_of_interest.Value   = {0.34, 's',5};

    sProcess.options.range_of_interest.Comment = 'Time window for correlation: ';
    sProcess.options.range_of_interest.Type    = 'timewindow';
    sProcess.options.range_of_interest.Value   =  []; 


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
        {{'.csv'}, 'text file', 'csv'}, ... % Available file formats
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

    % Load subject
    sSubject = bst_get('Subject', sInput.SubjectName);
    % identify inputs
    iMaps = find(~contains({sInput.Comment},{'Ground Truth', 'Theo'}));
    iTruth = find(contains({sInput.Comment},{'Ground Truth', 'Theo'}));
    
    assert(length(iTruth) == 1, 'Please provide only one ground truth');

    % Identify FOV from map 1
    sData           = in_bst_results(sInput(iMaps(1)).FileName);
    idx_FOV         = find(~all(abs(sData.ImageGridAmp) == 0,2));


    % Load ground truth
    sGroundTruth = in_bst_data(sInput(iTruth).FileName);

    % Load surface
    sCortex     = in_tess_bst(sGroundTruth.SurfaceFile);

    % Prepare new surface - only FOV
    iRemoveVert = setdiff(1:size(sCortex.Vertices,1), idx_FOV);
    if ~isempty(iRemoveVert)
        [sCortex.Vertices, sCortex.Faces, sCortex.Atlas] = tess_remove_vert(sCortex.Vertices, sCortex.Faces, iRemoveVert, sCortex.Atlas);
        sCortex.VertConn = sCortex.VertConn(idx_FOV,idx_FOV);
    end

    % Get left and right cortex
    [rH, lH]    = tess_hemisplit(sCortex);
    

    % Find the time of interest : peak of the simulated response
    if ~isempty(sProcess.options.time_of_interest.Value{1})
        [~, timeZeroSample] = min(abs( sGroundTruth.Time - sProcess.options.time_of_interest.Value{1}));
    else
        [~, timeZeroSample] =  max(max(abs(sGroundTruth.ImageGridAmp)));
    end
    sTruth              =  sGroundTruth.ImageGridAmp(idx_FOV,:);


    % prepare new ground truth map based on the FOV

    if isfield(sGroundTruth, 'Options')
        simulation_options = sGroundTruth.Options; 
        Jtheo = zeros(size(sGroundTruth.ImageGridAmp,1),1);
        Jtheo(simulation_options.Vertices) = 1;
    else
        simulation_options = struct();
        Jtheo = sGroundTruth.ImageGridAmp(:,timeZeroSample);
        Jtheo =  Jtheo ~= 0; 
    end

    Jtheo       = Jtheo(idx_FOV);
    idx_truth   = find(Jtheo); 
    

    % Measure depth
    sScalp = in_tess_bst(sSubject.Surface(sSubject.iScalp).FileName);
    depth = 1000 * min(nst_pdist(sCortex.Vertices(idx_truth,:),sScalp.Vertices),[],2);

    % === Depth of the cavity
    
    sMri        = in_mri_bst(sSubject.Anatomy(sSubject.iAnatomy).FileName);

    NZ = sMri.SCS.NAS;
    OD = sMri.SCS.RPA;
    OG = sMri.SCS.LPA;

    %Mesh
    Mesh.vertices = sCortex.Vertices;
    Mesh.faces = sCortex.Faces;
    mriCoord = cs_convert(sMri, 'scs', 'mri', Mesh.vertices)' * 1000;
    Mesh.vertices = mriCoord';
    Mesh.faces = sCortex.Faces;

    Mesh.vertices(:,1)=size(sMri.Cube,1)*sMri.Voxsize(1)-Mesh.vertices(:,1) ;%*1;%sMri.Voxsize(1);
    Mesh.vertices(:,2)=size(sMri.Cube,2)*sMri.Voxsize(2)-Mesh.vertices(:,2) ;%*1;%sMri.Voxsize(2);
    Mesh.vertices(:,3)=size(sMri.Cube,3)*sMri.Voxsize(3)-Mesh.vertices(:,3) ;%*1;%sMri.Voxsize(3);

    %eccentricity
    [~, all_eccentricity] = eccentricity(Mesh,NZ,OD,OG,eye(4,3), idx_truth, 1);
    



    % Estimate lateralization of the scout 
    isLeftScout     = ~isempty(intersect(lH, idx_truth));
    isRightScout    = ~isempty(intersect(rH, idx_truth));

    assert(xor(isLeftScout,isRightScout),'The scout cannot be bilateral');

    % Estimate distance from all the vertex to the ROI, in milimeter
    distances = 1000 * min(nst_pdist(sCortex.Vertices,sCortex.Vertices(idx_truth,:)),[],2);

    % GlobalData = rmfield(GlobalData , 'ROC_Struct') to clear 
    if isfield(GlobalData, 'ROC_Struct') && ~isempty(GlobalData.ROC_Struct)
        ROC_Struct = GlobalData.ROC_Struct;
    else
        ROC_Struct = prepare_ROC(sCortex);
        save_brainstorm_clusters(sGroundTruth.SurfaceFile,idx_FOV, ROC_Struct, Jtheo);
        GlobalData.ROC_Struct = ROC_Struct;
    end
    
    % save information about the simulation 
    % all_results = table('Size',[length(iMaps) 10],'VariableType',{'string','double','double','double','string','double','double','double','double','double'},'VariableNames',{'ROI', 'SNR','active_area','time','method','rsa','DLE','SD','AUC','correlation'});
    
    for iFile = 1:length(iMaps)

        results = table();

        sData           = in_bst_results(sInput(iMaps(iFile)).FileName);
        sMap            = sData.ImageGridAmp(idx_FOV,:);
        sMap_max        = sData.ImageGridAmp(idx_FOV,timeZeroSample);

        if isfield(simulation_options, 'Label')
           results.ROI     = string(simulation_options.Label);
        else           
            results.ROI     = num2str(iFile);
        end

        if isfield(simulation_options, 'options') && isfield(simulation_options.options, 'SNR')
            results.snr     = simulation_options.options.SNR;
        else
            results.snr     = NaN;
        end
        
        % Information about the ground truth
        results.depth   = mean(depth);

        summary_func_eccentricity = {@mean, @median, @min, @max};
        for iFun = 1:length(summary_func_eccentricity)
            label = sprintf('eccentricity_%s', func2str(summary_func_eccentricity{iFun}));
            value = summary_func_eccentricity{iFun}(all_eccentricity(idx_truth));
            results.(label) = value;
        end

        results.NVertex = length(idx_truth);
        results.time    = sData.Time(timeZeroSample);
        
        if isfield(sData, 'Options') && isfield(sData.Options, 'FunctionName') && ~isempty(sData.Options.FunctionName)
            results.method = string(sData.Options.FunctionName);
        elseif isfield(sData,'Function') && ~isempty(sData.Function)
            results.method = string(sData.Function);
        else
            if contains (sData.Comment,'MNE')
                results.method  = "MNE";
            elseif contains (sData.Comment,'cMEM')
                results.method  = "cMEM";
            else
                results.method  = "wMEM";
            end
        end
        
        % Compute spatial metrics (at the time of the peak)

        % Estimate the ratio of spurius activity :  energy on
        % controlateral side / total energy

        sMap_max_left   = sMap_max(lH);
        sMap_max_right  = sMap_max(rH);
        
        total_energy = sum(sMap_max_right.^2) + sum(sMap_max_left.^2);
        if isLeftScout 
            results.RSA = 100 * sum(sMap_max_right.^2) / total_energy;
        else
            results.RSA = 100 * sum(sMap_max_left.^2) / total_energy;
        end
        

        % 1. DLE --  Distance from the max vertex to the ground truth
        [~,maxVert] = max(abs(sMap_max));
        results.DLE = distances(maxVert);
            
        % 2. Spatial Dispersion
        results.SD = sqrt(sum(distances.^2 .* sMap_max.^2) / sum(sMap_max.^2));
        
        % 3. AUC 


        [Res_summary, Res_close_summary, Res_far_summary  ] =  Compute_ALL_AUC_global(0, ...
                                                                                 Jtheo, sMap_max, 1, ...
                                                                                 ROC_Struct.VoisinsOA, ...
                                                                                 ROC_Struct.mycluster, ...
                                                                                 ROC_Struct.nb_resampling,...
                                                                                 ROC_Struct.ordreVoisinage,...
                                                                                 ROC_Struct.thresholds, ...
                                                                                 []);
        [~,idx_30per] = min(abs(Res_summary.thresholds - 0.3));

        results.auc_mean        = Res_summary.AUC_mean;
        results.auc_mean_sd     = Res_summary.AUC_std;

        results.auc_close       = Res_close_summary.AUC_mean;
        results.auc_close_sd    = Res_close_summary.AUC_std;

        results.auc_far         = Res_far_summary.AUC_mean;
        results.auc_far_sd      = Res_far_summary.AUC_std;

        results.ppv_30          = Res_summary.ppv_mean(idx_30per);
        results.npv_30          = Res_summary.npv_mean(idx_30per);
        results.dice_30         = Res_summary.dice_mean(idx_30per);
        results.sensitivity_30  = Res_summary.sensitivity_mean(idx_30per);
        results.specificity_30  = Res_summary.specificity_mean(idx_30per);

        %2. Compute the temporal metrics 
        all_corr    = zeros(1, length(idx_truth));
        all_scales  = zeros(1, length(idx_truth));
        
        TimeRange = sProcess.options.range_of_interest.Value{1};
        iTime = panel_time('GetTimeIndices', sData.Time, TimeRange);

        for iVertex = 1:length(idx_truth)

            Corr = corrcoef(sTruth(idx_truth(iVertex), iTime), sMap(idx_truth(iVertex), iTime) );
            all_corr(iVertex) = Corr(1,2);

            mdl = fitlm( sMap(idx_truth(iVertex), iTime), sTruth(idx_truth(iVertex), iTime));
            all_scales(iVertex) = mdl.Coefficients.Estimate(2);
        end


        results.correlation = median(all_corr);
        results.scales      = median(all_scales);
        results.comment     = string(sData.Comment);

        all_results(iFile,:) = results;

    end
    %3. Save the results 
    writetable(all_results,sProcess.options.textFile.Value{1},'WriteMode','Append')
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

    output.nb_resampling    = 1000;
    output.ordreVoisinage   = 5;
    output.thresholds = linspace(0, 1, 100);
end

function save_brainstorm_clusters(surfaceFile,idx_FOV, ROC_Struct, Jtheo)

    sCortex = in_tess_bst(surfaceFile);
    
    iAtlas = find(strcmp({sCortex.Atlas.Name}, 'ROC_ROI'));
    if isempty(iAtlas)
        sCortex.Atlas(end+1) = struct('Name',  'ROC_ROI' , 'Scouts', repmat(db_template('scout'),1,length(ROC_Struct.mycluster)) );
        iAtlas = find(strcmp({sCortex.Atlas.Name}, 'ROC_ROI'));

    else
        sCortex.Atlas(iAtlas) = struct('Name',  'ROC_ROI' , 'Scouts', repmat(db_template('scout'),1,length(ROC_Struct.mycluster)) );
    end


    for iCluster = 1:length(ROC_Struct.mycluster)
        clusters = db_template('scout');
        clusters.Vertices = idx_FOV(ROC_Struct.mycluster{iCluster});
        clusters.Seed = idx_FOV(ROC_Struct.mycluster{iCluster}(1));
        clusters.Label    = sprintf('Cluster %d', iCluster);
        clusters.Color    = rand(1,3);

        
        sCortex.Atlas(iAtlas).Scouts(iCluster)  = clusters;
    end


    Itheo = find(Jtheo ~=0);
    Itheo = unique(Itheo);
     
    SupportClose = [];
    for i = 1:length(Itheo)
        SupportClose = unique([ SupportClose ROC_Struct.VoisinsOA{ROC_Struct.ordreVoisinage,Itheo(i)}]);
    end
    SupportFar = setdiff([1:length(Jtheo)], SupportClose);

    iAtlas = find(strcmp({sCortex.Atlas.Name}, 'support_close'));
    if isempty(iAtlas)
        sCortex.Atlas(end+1) = struct('Name',  'support_close' , 'Scouts', repmat(db_template('scout'),1, 2) );
        iAtlas = find(strcmp({sCortex.Atlas.Name}, 'support_close'));

    else
        sCortex.Atlas(iAtlas) = struct('Name',  'support_close' , 'Scouts', repmat(db_template('scout'),1, 2) );
    end
    
    clusters = db_template('scout');
    clusters.Vertices = idx_FOV(SupportClose);
    clusters.Seed     = idx_FOV(SupportClose(1));
    clusters.Label    =  'Support close';
    clusters.Color    = rand(1,3);
    sCortex.Atlas(iAtlas).Scouts(1)  = clusters;

    clusters = db_template('scout');
    clusters.Vertices = idx_FOV(SupportFar);
    clusters.Seed     = idx_FOV(SupportFar(1));
    clusters.Label    =  'Support Far';
    clusters.Color    = rand(1,3);
    sCortex.Atlas(iAtlas).Scouts(2)  = clusters;

    bst_save( file_fullpath(surfaceFile), sCortex);
end
