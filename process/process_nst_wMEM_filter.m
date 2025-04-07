function varargout = process_nst_wMEM_filter( varargin )
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


    sProcess.options.display.Comment = 'Activate display';
    sProcess.options.display.Type    = 'checkbox';
    sProcess.options.display.Value   =  1;

    
end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end

%% ===== RUN =====
function sInput = Run(sProcess, sInput) %#ok<DEFNU>

     
    [OPTIONS, obj] = getOptions(sProcess, sInput);

    [OPTIONS, obj] = be_wdata_preprocessing(obj, OPTIONS);
    
    if OPTIONS.optional.display
        be_display_time_scale_boxes(obj, OPTIONS);
    end

    sInput.A = waveletet_to_timecourse(sInput, obj, OPTIONS);

    sInput.Comment = [ sInput.Comment , ...
                        sprintf('| WFilter ( j %s)',strrep(num2str(unique(OPTIONS.automatic.selected_samples(2,:))),'  ',', '))];

end

        
function [OPTIONS, obj] = getOptions(sProcess, sInput)

    OPTIONS  = struct();
    OPTIONS.mandatory.pipeline  = 'wMEM';
    OPTIONS.mandatory.DataTime  = sInput.TimeVector;
    OPTIONS.mandatory.DataTypes = sInput.ChannelTypes;
    OPTIONS.mandatory.DataTypes = intersect(OPTIONS.mandatory.DataTypes,{'EEG', 'MEG', 'SEEG', 'NIRS'});
    
    OPTIONS.wavelet.type            = 'rdw';
    OPTIONS.wavelet.nb_levels       = sProcess.options.decomposition_levels.Value{1};
    OPTIONS.wavelet.order           = sProcess.options.wavelet_order.Value{1};
    OPTIONS.wavelet.vanish_moments  = sProcess.options.vanishing_moment.Value{1};
    OPTIONS.wavelet.shrinkage       = sProcess.options.shrinkage.Value;
    
    OPTIONS.wavelet.selected_scales = str2double(strsplit(sProcess.options.selected_scales.Value, ','));
    OPTIONS.wavelet.single_box      = false;
    
    OPTIONS.optional.TimeSegment    = sInput.TimeVector;
    OPTIONS.optional.BaselineTime   = sInput.TimeVector;
    OPTIONS.optional.verbose        = true;
    OPTIONS.optional.display        = sProcess.options.display.Value;
   
    OPTIONS.solver.NoiseCov         = [];
    
    OPTIONS.automatic.sampling_rate = 1 / (sInput.TimeVector(2) - sInput.TimeVector(1));
    OPTIONS.output.save_extra_information = 0;

    sChannel = in_bst_channel(sInput.ChannelFile);

    n0 = 0;
    for iMod = 1:length( OPTIONS.mandatory.DataTypes)
        iData = good_channel(sChannel.Channel, sInput.ChannelFlag, OPTIONS.mandatory.DataTypes{iMod});

        if isempty(iData)
            continue
        end

        OPTIONS.automatic.Modality(iMod) = struct('idx_data', iData, 'data', sInput.A(iData, :), 'baseline', [], 'emptyroom', [], 'channels', n0 + (1:length(iData)));
        n0 = n0 + length(iData);
    end

    obj = struct('ImageGridAmp', []);
    [obj.hfig, obj.hfigtab] = be_create_figure(OPTIONS);

end

function A = waveletet_to_timecourse(sInput, obj, OPTIONS)
    
    A = sInput.A;

    for iMod = 1:length( OPTIONS.mandatory.DataTypes)
        
        obj_tmp = obj; 
        
        obj_tmp.data = obj_tmp.data{iMod};                 
        obj_tmp.ImageGridAmp = obj_tmp.data(:,OPTIONS.automatic.selected_samples(1,:));       
        
        inv_proj = be_wavelet_inverse_projection(obj_tmp, OPTIONS);
        
        iData = OPTIONS.automatic.Modality(iMod).idx_data;
        A(iData, :) =  obj_tmp.ImageGridAmp * inv_proj;
    end

end