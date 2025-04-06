
sFiles = bst_process('CallProcess', 'process_select_search', [], [], ...
    'search', '(([name CONTAINS "Avg: Task"] AND [parent EQUALS "simulation_wake_task_1db_small"]))');



bst_report('Start', sFiles);

MetricFile = { ...
                '/Users/edelaire1/Documents/Project/wMEM-fnirs/data/metrics/metrics_task/metrics_cMEM_simul-task_1db_small.csv';
                '/Users/edelaire1/Documents/Project/wMEM-fnirs/data/metrics/metrics_task/metrics_wMEM_simul-task_1db_small.csv';
                '/Users/edelaire1/Documents/Project/wMEM-fnirs/data/metrics/metrics_task/metrics_MNE_simul-task_1db_small.csv';
              };



for iFile = 1:length(sFiles)

    % Get results files 
    [sStudy, iStudy, iResults] = bst_get('ResultsForDataFile', sFiles(iFile).FileName);
    ResultFiles = sStudy.Result(iResults);
    

    % Process: Compute statistics on cMEM
    sMaps = ResultFiles( contains({ResultFiles.Comment}, {'Ground Truth', 'cMEM'}));
    bst_process('CallProcess', 'process_nst_wMEM_metrics', {sMaps.FileName}, [], ...
                                               'textFile', {MetricFile{1}, 'csv'});

    % Process: Compute statistics on wMEM
    sMaps = ResultFiles( contains({ResultFiles.Comment}, {'Ground Truth', 'wMEM'}));
    bst_process('CallProcess', 'process_nst_wMEM_metrics', {sMaps.FileName}, [], ...
                                               'textFile', {MetricFile{2}, 'csv'});

        % Process: Compute statistics on MNE
    sMaps = ResultFiles( contains({ResultFiles.Comment}, {'Ground Truth', 'MNE'}));
    bst_process('CallProcess', 'process_nst_wMEM_metrics', {sMaps.FileName}, [], ...
                                               'textFile', {MetricFile{3}, 'csv'});
end


% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);