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
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;

    sProcess.options.method.Type       = 'radio_linelabel';
    sProcess.options.method.Comment    = {'Oscillations', 'Task','Simulation type'; 'oscilation', 'task',''};
    sProcess.options.method.Value      = 'oscilations';


    sProcess.options.sim_name.Comment = 'Simulation Name: ';
    sProcess.options.sim_name.Type    = 'text';
    sProcess.options.sim_name.Value   = '';


    sProcess.options.SNR.Comment = 'SNR';
    sProcess.options.SNR.Type    = 'value';
    sProcess.options.SNR.Value   = {0.5,'db',2};

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


    OutputFiles = {};
    sStudy = bst_get('Study', sInputs.iStudy);
    OPTIONS = sProcess.options;
        
    disp('')

    % Load data
    sData = in_bst_data(sInputs(1).FileName);
    ChannelMat = in_bst_channel(sInputs(1).ChannelFile);
    if ~isfield(ChannelMat.Nirs, 'Wavelengths')
        bst_error(['simulatrion code works only for dOD data ' ... 
                   ' (eg do not use MBLL prior to this process)']);
        return;
    end

    % Load head model
    HeadModelFile   = sStudy.HeadModel(sStudy.iHeadModel).FileName;
    nirs_head_model = in_bst_headmodel(HeadModelFile);
    sCortex = in_tess_bst(nirs_head_model.SurfaceFile);


    % generate activation patch 

    ROI  =  sProcess.options.scouts.Value;
    Atlas_name = ROI{1};
    iAtlas = find(strcmp( {sCortex.Atlas.Name}, Atlas_name));

    % Create output condition
    iStudy = db_add_condition(sInputs.SubjectName, sProcess.options.sim_name.Value);
    sStudy = bst_get('Study', iStudy);

    % Save channel definition
    [~, iChannelStudy] = bst_get('ChannelForStudy', iStudy);
    db_set_channel(iChannelStudy, ChannelMat, 2, 0);

    % Copy head model
    db_set_headmodel(HeadModelFile, iStudy);

    bst_progress('start', 'Simulating signal', 'Simulating signal', 1, length(ROI{2})) 
    for iROI = 1:length(ROI{2})


        ROI_name = ROI{2}{iROI};
        iRois  = find(contains({sCortex.Atlas(iAtlas).Scouts.Label} , ROI_name ));
    
        ROI_select = sCortex.Atlas(iAtlas).Scouts(iRois);
        
        activation = struct(); 

        activation.Label    = ROI_select(1).Label;
        activation.Vertices = ROI_select(1).Vertices;
        activation.ampmode  = 'unif';

        activation.options =  get_default_options(sData.Time, sProcess.options.method.Value);
        activation.options.SNR = sProcess.options.SNR.Value{1};

        [data_simul, groundTruth, groundTruthHead, SNR_est, ChannelFlag,  event]  = simulNirs(sCortex, nirs_head_model, activation, ChannelMat,sData, OPTIONS);
    

        sDataOut = db_template('data');
        sDataOut.F            = data_simul; 
        sDataOut.Comment      = sprintf('simul | %s | %s  SNR =  %.2fdb',Atlas_name, ROI_name, activation.options.SNR) ;
        sDataOut.ChannelFlag  = ChannelFlag;
        sDataOut.Time         = sData.Time;
        sDataOut.DataType     = 'recordings'; 
        sDataOut.nAvg         = 1;
        sDataOut.Events       = event;
        sDataOut = bst_history('add', sDataOut, 'process', sProcess.Comment);
        sDataOut.DisplayUnits = 'delta OD';
    
        % Generate a new file name in the same folder
        OutputFile_data = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), 'data_sim');
        sDataOut.FileName = file_short(OutputFile_data);
        bst_save(OutputFile_data, sDataOut, 'v7');
        % Register in database
        db_add_data(iStudy, OutputFile_data, sDataOut);
        OutputFiles{end+1} = OutputFile_data;

        ResultsMat = db_template('resultsmat');
        ResultsMat.Comment       = 'Ground Truth';
        ResultsMat.DataFile      = file_short(OutputFile_data);
        ResultsMat.Function      = '';
        ResultsMat.Time          = sData.Time;
        ResultsMat.ImageGridAmp  = groundTruth;
        ResultsMat.ChannelFlag   = [];
        ResultsMat.GoodChannel   = [];
        ResultsMat.DisplayUnits  = 'delta OD';
        ResultsMat.SurfaceFile   = nirs_head_model.SurfaceFile;
        ResultsMat.Options    = activation;
        % % Save new file structure
        OutputFile = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), 'results_ground_truth_simul');
        bst_save(OutputFile, ResultsMat, 'v6');
        % Update database
        db_add_data(iStudy, OutputFile, ResultsMat);
        %OutputFiles{end+1} = OutputFile;

        sDataOut = db_template('data');
        sDataOut.F            = groundTruthHead; 
        sDataOut.Comment      = sprintf('Truth | %s | %s  SNR =  %.2fdb',Atlas_name,ROI_name, activation.options.SNR) ;
        sDataOut.ChannelFlag  = ChannelFlag;
        sDataOut.Time         = sData.Time;
        sDataOut.DataType     = 'recordings'; 
        sDataOut.nAvg         = 1;
        sDataOut.Events       = event;
        sDataOut = bst_history('add', sDataOut, 'process', sProcess.Comment);
        sDataOut.DisplayUnits = 'delta OD';

        % Generate a new file name in the same folder
        OutputFile_data = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), 'data_sim');
        sDataOut.FileName = file_short(OutputFile_data);
        bst_save(OutputFile_data, sDataOut, 'v7');
        % Register in database
        db_add_data(iStudy, OutputFile_data, sDataOut);
        %OutputFiles{end+1} = OutputFile_data;

        ResultsMat = db_template('resultsmat');
        ResultsMat.Comment       = 'Ground Truth';
        ResultsMat.DataFile      = file_short(OutputFile_data);
        ResultsMat.Function      = '';
        ResultsMat.Time          = sData.Time;
        ResultsMat.ImageGridAmp  = groundTruth;
        ResultsMat.ChannelFlag   = [];
        ResultsMat.GoodChannel   = [];
        ResultsMat.DisplayUnits  = 'delta OD';
        ResultsMat.SurfaceFile   = nirs_head_model.SurfaceFile;
        ResultsMat.Options    = activation;
        % % Save new file structure
        OutputFile = bst_process('GetNewFilename', bst_fileparts(sStudy.FileName), 'results_ground_truth_simul_NIRS');
        bst_save(OutputFile, ResultsMat, 'v6');
        % Update database
        db_add_data(iStudy, OutputFile, ResultsMat);
        %OutputFiles{end+1} = OutputFile;

        sDataOut = db_template('data');
        sDataOut.F            = SNR_est; 
        sDataOut.Comment      = sprintf('SNR | %s | %s  SNR = %.2fdb',Atlas_name,ROI_name, activation.options.SNR) ;
        sDataOut.ChannelFlag  = ChannelFlag;
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
        %OutputFiles{end+1} = OutputFile;
        

        bst_progress('inc', 1);
    end

    % Update tree 
    panel_protocols('UpdateNode', 'Study', iStudy);

end


function [data_simul, groundTruth, groundTruthHead, SNR_est, ChannelFlag, event]  = simulNirs(sCortex, head_model, activation, ChannelMat, noise , OPTIONS )


    iwl = 2;
    swl = ['WL' num2str(ChannelMat.Nirs.Wavelengths(iwl))];
    selected_chans = strcmpi({ChannelMat.Channel.Group}, swl) & (noise.ChannelFlag>0)';

    % Select valid node on the cortex
    thresh_dis2cortex       = OPTIONS.thresh_dis2cortex.Value{1} .* 0.01;
    valid_nodes             = nst_headmodel_get_FOV(ChannelMat, sCortex, thresh_dis2cortex, noise.ChannelFlag);

    % Noise data
    Time            = round(noise.Time,6);  
    noise_data      = noise.F(selected_chans,:);

    % Remove 0 from the gain matrix

    gain = nst_headmodel_get_gains(head_model, iwl, ChannelMat.Channel, find(selected_chans));

    gain = gain(:,valid_nodes);
    gain(gain == 0) = min( gain(gain>0));

    switch(activation.options.type)

        case 'oscilation'
            [y, event] = simulate_oscilations(Time, activation.options);
        case 'task'
            [y, event] = simulate_task(Time, activation.options);

    end
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
    
    groundTruthHead = zeros(size(noise.F));
    groundTruthHead(selected_chans, :) =  k*data_head;
    

    groundTruth = zeros(size( sCortex.Vertices,1), length(Time));
    groundTruth(valid_nodes , :) = k*data_cortex; 

    SNR_est = zeros(size(noise.F,1),1); 
    SNR_est(selected_chans, :) = 10*log10(sqrt(var(k*data_head,[],2) ./ var(noise_data,[],2)));



    ChannelFlag = -1 * ones(size(noise.F,1),1); 
    ChannelFlag(selected_chans, :) = 1;


end


function options    = get_default_options(Time, type)
% Return the default options for the type of simulation
% type is either oscilations or task

    options = struct(); 
    options.type = type;

    switch(type)
        case 'oscilation'

            options.freq        = 0.1; %0.006;
            options.peak_time   = Time(round(length(Time)/2)) ; %peak at the middle of the time window
            options.duration    = 40; %seconds

        case 'task' 
            hrf_types   = process_nst_glm_fit('get_hrf_types');
            options.hrf = hrf_types.GAMMA;
            options.task_duration = 10; % seconds
            options.rest_duration = [30 , 40]; % seconds uniform from 30 to 60s

    end



end


function [y, event] = simulate_oscilations(Time, options)
    

    event = db_template('Event');
    event.label = 'oscilations';
    event.times = options.peak_time;
    event.color = [ .4    .4    1];
    event.epochs = 1;
    sigma   = options.duration / 2.354;
    Tc      = ( Time -  options.peak_time);


    y = cos(2 * pi * options.freq * Tc) .*  exp( - Tc .^ 2 ./ ( 2* sigma^2));

end

function [y, event_task] = simulate_task(Time, options)

    paradigm = zeros(1, length(Time));

    event_task = db_template('Event');
    event_task.label = 'Task';
    event_task.color = [ .4    .4    1];

    % Leave 1 minute of RS at the begening 
    [~, idx_start] =  min(abs(Time - 60)); 
    T = Time(idx_start);

    % Random generator for the rest duration
    pd = makedist('unif', options.rest_duration(1), options.rest_duration(2));

    while( T +  options.task_duration + options.rest_duration(1) <  (Time(end)  ))
        
        % 1. Add task
        idx_task =  panel_time('GetTimeIndices', Time, [T, T + options.task_duration]);
        paradigm(idx_task) = 1;
        event_task.times(:, end+1) = [T; T + options.task_duration];

        T = T + options.task_duration;

        % 2. Add Rest
        
        rest_duration = random(pd);
        T = T + rest_duration;

    end

    model = nst_glm_initialize_model(Time);
    model = nst_glm_add_regressors(model, "event", event_task, options.hrf, 30);

    y = transpose(model.X ./ max(model.X)); 
    
    event_task.epochs = ones(1, size(event_task.times,2));

end


            