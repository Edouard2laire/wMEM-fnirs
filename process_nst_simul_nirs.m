function varargout = process_nst_simul_nirs( varargin )
    eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Simulate NIRS signal';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = {'NIRS', 'Simulation'};
    sProcess.Index       = 3003;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data', 'raw', 'results'};
    sProcess.OutputTypes = {'data', 'data', 'results'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;

    sProcess.options.SNR.Comment = 'SNR';
    sProcess.options.SNR.Type    = 'value';
    sProcess.options.SNR.Value   = {2,'db',0};

        % === SCOUTS
    sProcess.options.scouts.Comment = '';
    sProcess.options.scouts.Type    = 'scout';
    sProcess.options.scouts.Value   = {};

        % Definition of the options
    sProcess.options.thresh_dis2cortex.Comment = 'Reconstruction Field of view (distance to montage border)';
    sProcess.options.thresh_dis2cortex.Type    = 'value';
    sProcess.options.thresh_dis2cortex.Value   = {3, 'cm',2};

end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

    sStudy = bst_get('Study', sInputs.iStudy);
    OPTIONS = sProcess.options;

    % Load data
    sData = in_bst_data(sInputs(1).FileName);
    ChannelMat = in_bst_channel(sInputs(1).ChannelFile);
    if ~isfield(ChannelMat.Nirs, 'Wavelengths')
        bst_error(['simulatrion code works only for dOD data ' ... 
                   ' (eg do not use MBLL prior to this process)']);
        return;
    end

    % Load head model
    nirs_head_model = in_bst_headmodel(sStudy.HeadModel(sStudy.iHeadModel).FileName);
    sCortex = in_tess_bst(nirs_head_model.SurfaceFile);


    % generate activation aptch 

    ROI  =  sProcess.options.scouts.Value;
    iAtlas = find(strcmp( {sCortex.Atlas.Name},ROI{1}));
    iRois  = find(contains({sCortex.Atlas(iAtlas).Scouts.Label} , ROI{2} ));

    ROI_select = sCortex.Atlas(iAtlas).Scouts(iRois);
    
    activation = struct(); 
    activation.Label = ROI_select(1).Label;
    activation.Vertices = ROI_select(1).Vertices;
    activation.ampmode = 'unif';

    activation.options = struct(); 
    activation.options.type = 'oscilation';
    activation.options.freq = 0.1; %0.006;
    activation.options.SNR =   sProcess.options.SNR.Value{1};
    activation.options.peak_time = sData.Time(round(length(sData.Time)/2)) ; %peak at the middle of the time window
    activation.options.duration = 40; %seconds

   
    [data_simul,groundTruth,SNR_est]  = simulNirs(sCortex, nirs_head_model, activation, ChannelMat,sData, OPTIONS);

    iStudy = db_add_condition(sInputs.SubjectName, 'Simulation');
    sStudy = bst_get('Study', iStudy);
    
    % Save channel definition
    [tmp, iChannelStudy] = bst_get('ChannelForStudy', iStudy);
    db_set_channel(iChannelStudy, ChannelMat, 2, 0);

    sDataOut = db_template('data');
    sDataOut.F            = data_simul; 
    sDataOut.Comment      = sprintf('simul | SNR = %ddb',activation.options.SNR) ;
    sDataOut.ChannelFlag  = ones(size(data_simul, 1), 1);
    sDataOut.Time         = sData.Time;
    sDataOut.DataType     = 'recordings'; 
    sDataOut.nAvg         = 1;
    sDataOut.Events       = [];
    sDataOut = bst_history('add', sDataOut, 'process', sProcess.Comment);
    sDataOut.DisplayUnits = 'delta OD';

    % Generate a new file name in the same folder
    OutputFile_data = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), 'data_sim');
    sDataOut.FileName = file_short(OutputFile_data);
    bst_save(OutputFile_data, sDataOut, 'v7');
    % Register in database
    db_add_data(iStudy, OutputFile_data, sDataOut);
    OutputFiles{1} = OutputFile_data;

    sDataOut = db_template('data');
    sDataOut.F            = SNR_est; 
    sDataOut.Comment      = [sInputs(1).Comment ' | SNR'];
    sDataOut.ChannelFlag  = ones(size(data_simul, 1), 1);
    sDataOut.Time         = [0];
    sDataOut.DataType     = 'recordings'; 
    sDataOut.nAvg         = 1;
    sDataOut.Events       = [];
    sDataOut = bst_history('add', sDataOut, 'process', sProcess.Comment);
    sDataOut.DisplayUnits = 'db';

    % Generate a new file name in the same folder
    OutputFile = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), 'data_snr');
    sDataOut.FileName = file_short(OutputFile);
    bst_save(OutputFile, sDataOut, 'v7');
    % Register in database
    db_add_data(iStudy, OutputFile, sDataOut);
    OutputFiles{2} = OutputFile;



    OutputFile = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), ['results_ground_truth_simul']);

    % ===== CREATE FILE STRUCTURE =====
    ResultsMat = db_template('resultsmat');
    ResultsMat.Comment       = 'Ground Truth';
    ResultsMat.DataFile      =  file_short(OutputFile_data);
    ResultsMat.HeadModelFile = sStudy.HeadModel(sStudy.iHeadModel).FileName;
    ResultsMat.Function      = '';
    ResultsMat.Time          = sData.Time;
    ResultsMat.ImageGridAmp  = groundTruth;
    ResultsMat.ChannelFlag   = [];
    ResultsMat.GoodChannel   = [];
    ResultsMat.DisplayUnits  = 'delta OD';
    ResultsMat.SurfaceFile   = nirs_head_model.SurfaceFile;
    % Save new file structure
    bst_save(OutputFile, ResultsMat, 'v6');
    % Update database
    db_add_data(iStudy, OutputFile, ResultsMat);
    OutputFiles{3} = OutputFile;


end


function [data_simul,groundTruth,SNR_est]  = simulNirs(sCortex, head_model,activation, ChannelMat, noise , OPTIONS )


    iwl = 1;
    swl = ['WL' num2str(ChannelMat.Nirs.Wavelengths(1))];
    selected_chans = strcmpi({ChannelMat.Channel.Group}, swl) & (noise.ChannelFlag>0)';

    % Select valid node on the cortex
    thresh_dis2cortex       = OPTIONS.thresh_dis2cortex.Value{1} .* 0.01;
    valid_nodes             = nst_headmodel_get_FOV(ChannelMat, sCortex, thresh_dis2cortex,noise.ChannelFlag );

    % Noise data
    Channel         = ChannelMat.Channel(selected_chans);
    Time            = round(noise.Time,6);  
    noise_data      = noise.F(selected_chans,:);

    % Remove 0 from the gain matrix

    gain = nst_headmodel_get_gains(head_model, iwl, ChannelMat.Channel, find(selected_chans));

    gain = gain(:,valid_nodes);
    gain(gain == 0) = min( gain(gain>0));

    % Load valid node on the cortex 
    sigma = activation.options.duration / 2.354;
    Tc = (Time- activation.options.peak_time);
    y = cos(2*pi*activation.options.freq*Tc) .* ...
                exp( - Tc .^ 2 ./ ( 2* sigma^2));
    env = [ exp( - Tc .^ 2 ./ ( 2* sigma^2))  ;  -exp( - Tc .^ 2 ./ ( 2* sigma^2))];
    figure;
    subplot(121)
    
    plot(Tc, [y; env])
    title('Time course')
    subplot(122)
    periodogram(y,[],length(y),10)
    xline(activation.options.freq)
    xlim([ 0 0.1])

    nodes = zeros(1,size(sCortex.Vertices,1));
    nodes(activation.Vertices) = 1; 

    nodes = nodes(valid_nodes);
    activated_vertices = find(nodes);

    data_cortex = zeros(length(valid_nodes), length(Time));
    data_cortex(activated_vertices, :) = repmat(y, length(activated_vertices), 1); 
    
    data_head = gain * data_cortex;
    
    [~,I] = max(var(data_head,[],2)); % find the sensors to use to fix the SNR
    SNR = 10^(activation.options.SNR)/10;
    k = sqrt(SNR * var(noise_data(I,:),[],2) / var(data_head(I,:),[],2));

    data_simul = noise.F;
    data_simul(selected_chans, :) =  k*data_head + noise_data ;
    

    groundTruth = zeros(size( sCortex.Vertices,1), length(Time));
    groundTruth(valid_nodes , :) = k*data_cortex; 

    SNR_est = zeros(size(noise.F,1),1); 
    SNR_est(selected_chans, :) = 10*log10(sqrt(var(k*data_head,[],2) ./ var(noise_data,[],2)));

end