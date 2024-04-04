

SNR = 0.25;
output_path = "/Users/edelaire1/Documents/Project/wMEM-fnirs/data/metrics/metrics_osc";

sFiles = bst_process('CallProcess', 'process_select_search', [], [], ...
    'search', [ '(( [name CONTAINS "simul |"] ', ....
                'AND', ....
                sprintf('[parent EQUALS "simulation_wake_osc_%0.2fdB_left_medium"]',SNR), ...
                '))' ] ...
                );



bst_report('Start', sFiles);

MetricFile = { ...
                sprintf('metrics_wMEM_simul-oscilations_%0.2fdB_medium.csv', SNR) ;...
                sprintf('metrics_MNE_simul-oscilations_%0.2fdB_medium.csv', SNR ) ; ...
              };


for iFile = 1:length(sFiles)

    % Get results files 
    [sStudy, iStudy, iResults] = bst_get('ResultsForDataFile', sFiles(iFile).FileName);
    ResultFiles = sStudy.Result(iResults);


    % Process: Compute statistics on wMEM
    sMaps = ResultFiles( contains({ResultFiles.Comment}, {'Ground Truth', 'wMEM'}));
    bst_process('CallProcess', 'process_nst_wMEM_metrics', {sMaps.FileName}, [], ...
                                                'time_of_interest',  170, ...
                                                'range_of_interest', [120, 220], ...
                                               'textFile', {fullfile(output_path, MetricFile{1}), 'csv'});

        % Process: Compute statistics on MNE
    sMaps = ResultFiles( contains({ResultFiles.Comment}, {'Ground Truth', 'MNE'}));
    bst_process('CallProcess', 'process_nst_wMEM_metrics', {sMaps.FileName}, [], ...
                                                'time_of_interest',  170, ...
                                                'range_of_interest', [120, 220], ...
                                               'textFile', {fullfile(output_path, MetricFile{2}), 'csv'});
end


% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);
