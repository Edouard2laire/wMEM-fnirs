function varargout = process_nst_simul_nirs( varargin )
    eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Wavelet filtering';

    sProcess.FileTag     = 'WFilter';
    sProcess.Category    = 'Filter';
    
    sProcess.SubGroup    = {'Custom Processes','NIRS - wMEM'};
    sProcess.Index       = 3010;
    
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'raw', 'data'};
    sProcess.OutputTypes = {'raw', 'data'};
    
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;

    % Default values for some options
    sProcess.isSourceAbsolute = 0;

    sProcess.options.selected_scales.Comment = 'Selected scales: ';
    sProcess.options.selected_scales.Type    = 'text';
    sProcess.options.selected_scales.Value   = '';

    sProcess.options.vanishing_moment.Comment = 'Vanishing moments';
    sProcess.options.vanishing_moment.Type    = 'value';
    sProcess.options.vanishing_moment.Value   = {3, '', 0};

    sProcess.options.shrinkage.Comment = 'Apply shrinkage';
    sProcess.options.shrinkage.Type    = 'checkbox';
    sProcess.options.shrinkage.Value   =  0;

    sProcess.options.wavelet_order.Comment = 'Wavelet order';
    sProcess.options.wavelet_order.Type    = 'value';
    sProcess.options.wavelet_order.Value   = {10, '', 0};

    sProcess.options.decomposition_levels.Comment = 'Dcomposition level';
    sProcess.options.decomposition_levels.Type    = 'value';
    sProcess.options.decomposition_levels.Value   = {128, '', 0};
    
end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

%% ===== RUN =====
function sInputs = Run(sProcess, sInputs) %#ok<DEFNU>

     
    OPTIONS  = struct();
    OPTIONS.mandatory.pipeline  = 'wMEM';
    OPTIONS.mandatory.DataTime  = sInputs.TimeVector;
    OPTIONS.mandatory.DataTypes = sInputs.ChannelTypes;

    OPTIONS.wavelet.type        =  'rdw';

    OPTIONS.wavelet.nb_levels      = sProcess.options.decomposition_levels.Value{1};
    OPTIONS.wavelet.order          =  sProcess.options.wavelet_order.Value{1};
    OPTIONS.wavelet.vanish_moments = sProcess.options.vanishing_moment.Value{1};
    OPTIONS.wavelet.shrinkage      = sProcess.options.shrinkage.Value;
    
    OPTIONS.wavelet.selected_scales = str2double(strsplit(sProcess.options.selected_scales.Value, ','));
    OPTIONS.wavelet.single_box      = false;

    OPTIONS.optional.TimeSegment    = sInputs.TimeVector;
    OPTIONS.optional.BaselineTime   = sInputs.TimeVector;

    
    OPTIONS.optional.verbose    = true;
    OPTIONS.optional.display    = true;

    OPTIONS.solver.NoiseCov  = [];
     
    OPTIONS.automatic.sampling_rate = 1 / (sInputs.TimeVector(2) - sInputs.TimeVector(1));

    sChannel = in_bst_channel(sInputs.ChannelFile);
    for iMod = 1:length( OPTIONS.mandatory.DataTypes)
        iData = good_channel(sChannel.Channel, sInputs.ChannelFlag, OPTIONS.mandatory.DataTypes{iMod});
        OPTIONS.automatic.Modality(iMod) = struct('data', sInputs.A(iData, :), 'baseline', [], 'emptyroom', [], 'channels', 1:length(iData));
    end


    obj = struct('ImageGridAmp', []);
    [obj.hfig, obj.hfigtab] = be_create_figure(OPTIONS);

    [OPTIONS, obj] = be_wdata_preprocessing(obj, OPTIONS);
    [obj.hfig, obj.hfigtab] = be_display_time_scale_boxes(obj,OPTIONS);
    
    for iMod = 1:length( OPTIONS.mandatory.DataTypes)
        
        obj_tmp = obj; 

        obj_tmp.data = obj_tmp.data{1};                 
        obj_tmp.ImageGridAmp = obj_tmp.data(:,OPTIONS.automatic.selected_samples(1,:));       

        inv_proj = be_wavelet_inverse_projection(obj_tmp, OPTIONS);
        
        iData = good_channel(sChannel.Channel, sInputs.ChannelFlag, OPTIONS.mandatory.DataTypes{iMod});
        sInputs.A(iData, :) =  obj_tmp.ImageGridAmp * inv_proj;
    end
    
end






            