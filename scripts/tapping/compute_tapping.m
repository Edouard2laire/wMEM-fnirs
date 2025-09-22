%Similar to  tapping_fnirs but without the data importation. 

% Start a new report
bst_report('Start');

    sFile = { 'Sub04_ZapAnd_PAS10/@rawSub04_PAS10_Pre_Tapping/data_0raw_Sub04_PAS10_Pre_Tapping.mat'};
    
    options = struct();
    options.SubjectName = 'Sub04_ZapAnd_PAS10';
    options.timewindow                  = [10 1140];
    options.reconstructionTimewindow    = [30 1130];
    options.reconstructionBaseline      = [912, 932];
    options.condition_name = 'Sub04_cond-PAS10_task-tapping_run-pre_preproc';
    options.TrialStatus = listTrials(20, [1]);

    compute(sFile, options);



%% Save and display report
ReportFile = bst_report('Save', []);
bst_report('Open', ReportFile);

%     bst_report('Export', ReportFile, reports_dir);



%% ------------------------------------------------------------------------

function compute(sFile, options)
    % 0. Fix events name
    renameEvents(sFile, options);

    % 1. Perform preprocessing and importation to database
    sPreproc = preprocess(sFile, options);

    % 2. Compute the reconstruction (Avg -> cMEM, or MNE|wMEM -> Avg)
    localized_response = computeReconstruction(sPreproc, options);


    % 3. Compute the TF analysis (channel or along the cortical surface)
    compute_TF_sources(localized_response, options);
    compute_TF_channel(sPreproc, options);
end

function renameEvents(sFile, options)
% Required option: 
%       | reconstructionTimewindow

    assert(isfield(options, 'reconstructionTimewindow') && ~isempty(options.timewindow), 'Missing options field: reconstructionTimewindow')


    % deal with stupid event naming
    sData = in_bst_data(sFile{1});
    
    if any(strcmpi({sData.F.events.label}, 'Wake'))
        return;
    end

    bst_process('CallProcess', 'process_evt_extended', sFile, [], ...
        'eventname',  'PreTapping, PostTapping', ...
        'timewindow', [0, 10]);

    bst_process('CallProcess', 'process_evt_rename', sFile, [], ...
        'src',   'PreTapping, PostTapping', ...
        'dest',  'tapping');

    % Process: Duplicate tapping events
    bst_process('CallProcess', 'process_evt_merge', sFile, [], ...
        'evtnames', 'tapping', ...
        'newname',  'tapping/start', ...
        'delete',   0);
    
    % Process: Convert to simple event
    bst_process('CallProcess', 'process_evt_simple', sFile, [], ...
        'eventname',  'tapping/start', ...
        'method', 1);

    sData.F.events(end+1) = sData.F.events(end);
    sData.F.events(end).label = 'Wake';
    sData.F.events(end).times = options.reconstructionTimewindow';
    sData.F.events(end).epochs = [1];
    sData.F.events(end).color = [0.9, 0.5, 0.7];

    bst_save(file_fullpath(sFile{1}), sData)

end

function sPreproc = preprocess(sRaw, options)
% Required option: 
%       | timewindow
%       | condition_name
%       | SubjectName


    assert(isfield(options, 'timewindow') && ~isempty(options.timewindow), 'Missing options field: timewindow')
    assert(isfield(options, 'condition_name') && ~isempty(options.timewindow), 'Missing options field: condition_name')
    assert(isfield(options, 'SubjectName') && ~isempty(options.timewindow), 'Missing options field: SubjectName')


    %% Part 3. Preprocessing
    
    % Process: Detect bad channels
    sRaw = bst_process('CallProcess', 'process_nst_detect_bad', sRaw, [], ...
        'option_sci',                   0, ...
        'sci_threshold',                80, ...
        'power_threshold',              10, ...
        'option_coefficient_variation', 1, ...
        'coefficient_variation',        5, ...
        'option_remove_saturating',     0, ...
        'option_max_sat_prop',          10, ...
        'option_min_sat_prop',          10, ...
        'option_separation_filtering',  0, ...
        'option_separation',            [0, 5], ...
        'auxilary_signal',              3, ...  % Remove all
        'option_keep_unpaired',         0);
    
    % Process: Conversion to dOD
    
    sRawdOD = bst_process('CallProcess', 'process_nst_dOD', sRaw, [], ...
        'option_baseline_method', 1, ...  % mean
        'timewindow',             []);
    
    
    % Process: Motion Corrected (TDDR)
    sPreproc_tmp = bst_process('CallProcess', 'process_nst_motion_correction', sRawdOD, [], ...
                                                'method',            'tddr', ...  %  Temporal Derivative Distribution Repair
                                                'option_event_name', 'motion', ...
                                                'option_smoothing',  0.99);
    
    sPreproc_tmp = bst_process('CallProcess', 'process_bandpass', sPreproc_tmp, [], ...
                                                'sensortypes', 'NIRS', ...
                                                'highpass',    0.002, ...
                                                'lowpass',     2, ...
                                                'tranband',    0.002, ...
                                                'attenuation', 'relax', ...     % 40dB (relaxed)
                                                'ver',         '2019', ...      % 2019
                                                'mirror',      0, ...
                                                'overwrite',   0);
    
    sPreproc_tmp = bst_process('CallProcess', 'process_nst_remove_ssc', sPreproc_tmp, [], ...
                                                'SS_chan',                 'distance', ...  % Based on Distances
                                                'SS_chan_name',            '', ...
                                                'separation_threshold_cm', 1.4);
    
    sPreproc = bst_process('CallProcess', 'process_import_data_time', sPreproc_tmp, [], ...
                                                'subjectname',   options.SubjectName, ...
                                                'condition',     options.condition_name, ...
                                                'timewindow',    options.timewindow, ...
                                                'split',         0, ...
                                                'ignoreshort',   0, ...
                                                'usectfcomp',    0, ...
                                                'usessp',        0, ...
                                                'freq',          [], ...
                                                'baseline',      [], ...
                                                'blsensortypes', 'NIRS');
    
    % Remove short-separation channels
    tree_set_channelflag(sPreproc.FileName, 'AddBad', 'D17');

    computeHeadModel(sPreproc, options)


end


function computeHeadModel(sFile, options)
% Required option: 
%       | SubjectName


    assert(isfield(options, 'SubjectName') && ~isempty(options.timewindow), 'Missing options field: SubjectName')

    fluencesDir = '/Volumes/CrucialX8/data/tapping_zc/fluences';
    
    assert(exist(fullfile(fluencesDir, options.SubjectName), 'dir'), 'Fluences were not computed');

    %     % Process: Compute head model from fluence
    bst_process('CallProcess', 'process_nst_import_head_model', sFile, [], ...
        'data_source',               fullfile(fluencesDir, options.SubjectName), ...
        'use_closest_wl',            0, ...
        'method',                    'geodesic_dist', ...  %  Geodesic (recommended)
        'smoothing_fwhm',            10, ...
        'use_all_pairs',             0, ...
        'normalize_fluence',         1, ...
        'force_median_spread',       0, ...
        'sensitivity_threshold_pct', 0);
end


function localized_response = computeReconstruction(sPreproc, options)
% Required option: 
%       | reconstructionTimewindow
%       | reconstructionBaseline


    assert(isfield(options, 'reconstructionTimewindow') && ~isempty(options.reconstructionTimewindow), 'Missing options field: reconstructionTimewindow')
    assert(isfield(options, 'reconstructionBaseline') && ~isempty(options.reconstructionBaseline), 'Missing options field: reconstructionBaseline')

    %% Part 4: Estimation of the HRF to tapping -> then localize

    sAvg = low_pass_and_average(sPreproc, options);
    
    %     % Process: Compute sources: BEst
    mem_option = be_pipelineoptions([],  'cMEM', 'NIRS');
    mem_option.optional = struct_copy_fields(mem_option.optional, ...
                         struct(...
                                 'TimeSegment',     [-10, 30], ...
                                 'BaselineType',    {{'within-data'}}, ...
                                 'Baseline',        [], ...
                                 'BaselineHistory', {{'within'}}, ...
                                 'BaselineSegment', [-10, 0], ...
                                 'groupAnalysis',   0, ...
                                 'display',         0));
    mem_option.model.depth_weigth_MEM = 0.3;
    mem_option.model.depth_weigth_MNE = 0.3;
    
    
    bst_process('CallProcess', 'process_nst_cmem', sAvg, [], ...
                                'mem', struct('MEMpaneloptions', mem_option), ...
                                'thresh_dis2cortex',       5, ...
                                'NoiseCov_recompute',      1, ...
                                'auto_neighborhood_order', 1, ...
                                'store_sparse_results',    0);


    %% Part 5: Localize then estimate of the HRF to tapping
    
    % open parpool
    %if isempty(gcp('nocreate'))
    %    parpool(8);
    %end
    
    
    localized_response   = [];
    
    % Process: Source reconstruction - wMNE
    sFileMne = bst_process('CallProcess', 'process_nst_wmne', sPreproc, [], ...
                                                'thresh_dis2cortex',  5, ...
                                                'depth_weightingMNE', 0.3, ...
                                                'TimeSegment',        options.reconstructionTimewindow, ...
                                                'NoiseCov_recompute', 1, ...
                                                'TimeSegmentNoise',   options.reconstructionBaseline);
    localized_response = [localized_response, sFileMne(contains({sFileMne.Comment}, {'HbO','HbR','HbT'}))];
    
    
    % Process: Source reconstruction - wMEM [all scale] 
    selected_scales = [1:10]; alpha_init = 7; neighborhood_order = 6; normalization = 'adaptive';
    sFilewMEM = compute_wMEM(sPreproc, options.reconstructionTimewindow, options.reconstructionBaseline, neighborhood_order, selected_scales, alpha_init, normalization);
    localized_response = [localized_response, sFilewMEM(contains({sFilewMEM.Comment}, {'HbO','HbR','HbT'}))];
     
    % Process: Source reconstruction - wMEM [selected scale]
    % selected_scales = [3:9]; alpha_init = 7; neighborhood_order = 6; normalization = 'adaptive';
    % sFilewMEM = compute_wMEM(sPreproc, options.reconstructionTimewindow, options.reconstructionBaseline, neighborhood_order, selected_scales, alpha_init, normalization);
    % localized_response = [localized_response, sFilewMEM(contains({sFilewMEM.Comment}, {'HbO','HbR','HbT'}))];
    
    
    % Estimate averaged response from the localization
    low_pass_and_average(localized_response, options);
    
    % close parpool
    if isempty(gcp('nocreate'))
        delete(gcp);
    end

end


function out = listTrials(nTrials, RejectedTrials)

    listTrials = repmat({'1' },  1, nTrials);
    for iTrial = 1:length(RejectedTrials)
        listTrials{RejectedTrials(iTrial)} =  '-1';
    end
    out = strjoin(listTrials, ', ');

end


function sAvg = low_pass_and_average(sFile, options)
% Required option: 
%       | TrialStatus

    assert(isfield(options, 'TrialStatus') && ~isempty(options.TrialStatus), 'Missing options field: TrialStatus')


    sFile = bst_process('CallProcess', 'process_bandpass', sFile, [], ...
            'sensortypes', 'NIRS', ...
            'highpass',    0, ...
            'lowpass',     0.1, ...
            'tranband',    0.005, ...
            'attenuation', 'relax', ...     % 40dB (relaxed)
            'ver',         '2019', ...      % 2019
            'mirror',      0, ...
            'overwrite',   0);

    sAvg = bst_process('CallProcess', 'process_windows_average_time', sFile, [], ...
                    'Eventname',      'tapping', ...
                    'timewindow',     [-10, 30], ...
                    'remove_DC',      1, ...
                    'baselinewindow', [-10, 0], ...
                    'filter_trials',  1, ...
                    'trials_info',    options.TrialStatus);

end

function sFilesMEM = compute_wMEM(sImput, timewindow_full, baselinewindow_full, neighborhood_order, selected_scales, alpha_init, normalization)

    mem_option = be_pipelineoptions([], 'wMEM','NIRS');
    mem_option.optional = struct_copy_fields(mem_option.optional, ...
                                        struct(...
                                        'TimeSegment',    timewindow_full, ...
                                        'BaselineType',    {{'within-data'}}, ...
                                        'BaselineHistory', {{'within'}}, ...
                                        "baseline_shuffle", 0, ...
                                        "BaselineSegment", baselinewindow_full , ...
                                        'display',         1));
    
    mem_option.clustering =  struct_copy_fields(mem_option.clustering, ...
                                         struct('neighborhood_order', neighborhood_order));
    
    mem_option.wavelet.selected_scales  = selected_scales;
    mem_option.model.alpha_method       = alpha_init;
    mem_option.optional.normalization   = normalization;
    mem_option.solver.parallel_matlab   = ~isempty(gcp('nocreate'));
    
    sFilesMEM = bst_process('CallProcess', 'process_nst_cmem', sImput, [], ...
        'mem', struct('MEMpaneloptions', mem_option), ...
        'thresh_dis2cortex',       5, ...
        'NoiseCov_recompute',      1, ...
        'auto_neighborhood_order', 0, ...
        'store_sparse_results',    0);
    
    sFilesMEM =  bst_process('CallProcess', 'process_add_tag', sFilesMEM, [], ...
        'tag',            sprintf('| nbo = %d | alpha = %d | norm = %s',  neighborhood_order, alpha_init, normalization), ...
        'output',         'name'); 
end


function compute_TF_channel(sPreproc, options)
% Required option: 
%       | reconstructionTimewindow


    assert(isfield(options, 'reconstructionTimewindow') && ~isempty(options.reconstructionTimewindow), 'Missing options field: reconstructionTimewindow')

    if ~bst_plugin('Load', 'tfnirs')
        error('Unable to load TF-nirs');
    end

    % 6.2 - Estimate time-frequency at the channel level
    sPreprocHb = bst_process('CallProcess', 'process_nst_mbll_dOD', sPreproc, [], ...
                                                'option_age',         25, ...
                                                'option_pvf',         50, ...
                                                'option_do_plp_corr', 1, ...
                                                'option_dpf_method',  1);  % SCHOLKMANN2013
    
    sChannels = in_bst_channel(sPreprocHb.ChannelFile);

    new_cluster = repmat(struct('Sensors',{}, 'Label', '', 'Color', [1 0.843 0], 'Function','Mean'), 1, 2);

    [iChannels, Comment] = channel_find(sChannels.Channel, {'HbO'});
    new_cluster(1).Sensors = {sChannels.Channel(iChannels).Name};
    new_cluster(1).Label = 'motor_HbO';
    new_cluster(1).Color  = [1 0 0];
    new_cluster(1).Function  = 'Mean';
    
    [iChannels, Comment] = channel_find(sChannels.Channel, {'HbR'});
    new_cluster(2).Sensors = {sChannels.Channel(iChannels).Name};
    new_cluster(2).Label = 'motor_HbR';
    new_cluster(2).Color  = [0, 0, 1];
    new_cluster(2).Function  = 'Mean';
    
    sChannels.Clusters = new_cluster;
    bst_save(file_fullpath(sPreprocHb.ChannelFile), sChannels);
    
    
    % Process: Time-frequency: Morse Wavelet
    bst_process('CallProcess', 'process_ft_wavelet', sPreprocHb, [], ...
                                                'timewindow',     options.reconstructionTimewindow, ...
                                                'sensortypes',    'NIRS', ...
                                                'clusters',       {'motor_HbO', 'motor_HbR'}, ...
                                                'vanish_moments', 1.5, ...
                                                'order',          20, ...
                                                'nb_levels',      1024, ...
                                                'normalization',  1);


end

function  compute_TF_sources(localized_response, options)



    if ~bst_plugin('Load', 'tfnirs')
        error('Unable to load TF-nirs');
    end
    
    % 6.1 - Estimate time-frequency on the cortex 
    localized_response = localized_response(contains({localized_response.Comment}, {'HbO','HbR'}));
    for iFile = 1:length(localized_response)
    
        % Process: Time-frequency: Morse Wavelet(source)
        bst_process('CallProcess', 'process_ft_wavelet_surface', localized_response(iFile), [], ...
                                                'timewindow',     options.reconstructionTimewindow, ...
                                                'sensortypes',    'NIRS', ...
                                                'scouts',         {'User scouts', {'Hand'}}, ...
                                                'vanish_moments', 1.5, ...
                                                'order',          20, ...
                                                'nb_levels',      1024, ...
                                                'normalization',  1);
    
    end


end

