% Script generated by Brainstorm (13-Mar-2024)

% Input files
sFiles = {...
    'Subject01/simulation_oscilations_20cm/data_sim_240404_1672.mat'};

% Start a new report
bst_report('Start', sFiles);

% Process: Compute sources: BEst
sFiles = bst_process('CallProcess', 'process_nst_export_hpc', sFiles, [], ...
    'mem',                     struct(...
         'MEMpaneloptions', struct(...
               'InverseMethod', 'MEM', ...
               'automatic',     struct(...
                     'MEMexpert',   1, ...
                     'version',     '2.7.3', ...
                     'last_update', ''), ...
               'clustering',    struct(...
                     'neighborhood_order',   4, ...
                     'MSP_window',           10, ...
                     'clusters_type',        'static', ...
                     'MSP_scores_threshold', 0), ...
               'optional',      struct(...
                     'TimeSegment',     [0, 299.9], ...
                     'groupAnalysis',   0, ...
                     'Baseline',        [], ...
                     'BaselineHistory', {{'within'}}, ...
                     'display',         1, ...
                     'BaselineSegment', [0, 299.9]), ...
               'mandatory',     struct(...
                     'pipeline', 'wMEM'), ...
               'model',         struct(...
                     'active_mean_method', 2, ...
                     'alpha_method',       1, ...
                     'alpha_threshold',    0, ...
                     'initial_lambda',     1, ...
                     'depth_weigth_MNE',   0.3, ...
                     'depth_weigth_MEM',   0.3), ...
               'solver',        struct(...
                     'spatial_smoothing',  0.6, ...
                     'active_var_mult',    0.05, ...
                     'inactive_var_mult',  0, ...
                     'NoiseCov_method',    6, ...
                     'Optim_method',       'fminunc', ...
                     'parallel_matlab',    1, ...
                     'NoiseCov_recompute', 1), ...
               'wavelet',       struct(...
                     'type',            'rdw', ...
                     'vanish_moments',  3, ...
                     'shrinkage',       0, ...
                     'selected_scales', [1, 2, 3, 4, 5, 6, 7, 8, 9]))), ...
    'thresh_dis2cortex',       5, ...
    'auto_neighborhood_order', 1);

% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);
% bst_report('Export', ReportFile, ExportDir);
% bst_report('Email', ReportFile, username, to, subject, isFullReport);

% Delete temporary files
% gui_brainstorm('EmptyTempFolder');

