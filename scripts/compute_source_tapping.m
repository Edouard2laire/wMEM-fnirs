sFiles = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/data_block001.mat'};


timewindow_full      = [5, 1123];
baselinewindow_full  = [250, 270];

% Start a new report
bst_report('Start', sFiles);

if isempty(gcp('nocreate'))
    parpool(8);
end

sInput = sFiles{1};


% % Process: Source reconstruction - wMNE
% bst_process('CallProcess', 'process_nst_wmne', sInput, [], ...
%                                             'thresh_dis2cortex',  5, ...
%                                             'depth_weightingMNE', 0.3, ...
%                                             'TimeSegment',        timewindow_full, ...
%                                             'NoiseCov_recompute', 1, ...
%                                             'TimeSegmentNoise',   baselinewindow_full);

% selected_scales = [1:8]; alpha_init = 7; neighborhood_order = 4; normalization = 'fixed';
% compute_wMEM(sInput, timewindow_full, baselinewindow_full, neighborhood_order, selected_scales, alpha_init, normalization);

selected_scales = [1:10]; alpha_init = 7; neighborhood_order = 6; normalization = 'adaptive';
compute_wMEM(sInput, timewindow_full, baselinewindow_full, neighborhood_order, selected_scales, alpha_init, normalization);

selected_scales = [1:9]; alpha_init = 7; neighborhood_order = 6; normalization = 'adaptive';
compute_wMEM(sInput, timewindow_full, baselinewindow_full, neighborhood_order, selected_scales, alpha_init, normalization);

selected_scales = [3:9]; alpha_init = 7; neighborhood_order = 6; normalization = 'adaptive';
compute_wMEM(sInput, timewindow_full, baselinewindow_full, neighborhood_order, selected_scales, alpha_init, normalization);

% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);


function sFilesMEM = compute_wMEM(sImput, timewindow_full, baselinewindow_full, neighborhood_order, selected_scales, alpha_init, normalization)

    mem_option = be_pipelineoptions([], 'wMEM','NIRS');
    mem_option.optional = struct_copy_fields(mem_option.optional, ...
                                        struct(...
                                        'TimeSegment',    timewindow_full, ...
                                        'BaselineType',    {{'within-data'}}, ...
                                        'BaselineHistory', {{'within'}}, ...
                                        "baseline_shuffle", 0, ...
                                        "BaselineSegment", baselinewindow_full , ...
                                        'display',         0));
    
    mem_option.clustering =  struct_copy_fields(mem_option.clustering, ...
                                         struct('neighborhood_order', neighborhood_order));
    
    mem_option.wavelet.selected_scales  = selected_scales;
    mem_option.model.alpha_method       = alpha_init;
    mem_option.optional.normalization   = normalization;
    mem_option.solver.parallel_matlab   = 1;
    
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