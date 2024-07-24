%% Settings 
addpath('/Users/edelaire1/Documents/software/brainstorm3'); 
if ~brainstorm('status')
    brainstorm
end

%close all;

path = '/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure-TFR';
folder_out = fullfile(path,'figures');

if ~exist(folder_out)
    mkdir(folder_out);
end

bst_plugin('Load', 'TFNIRS', 1);

%% options

new_frequency = logspace( log10(0.002), log10(1.5), 500);



options = load('/Users/edelaire1/Documents/Project/CIHR/CIHR_march_2024/TF/PA03/options.mat').options;
options.wavelet = rmfield(options.wavelet,'freqWindow');
options.colormap = 'jet';
options.clim = [0 0.25];
options.wavelet.display.fontscale = 44;
options.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ] ./ 255;


sleep_stage  = {'wake';'N1';'N2';'N3';'REM'};
epi_activity = {'bursts', 'spikes_LR', 'spikes_RL', 'spikes_bilat', 'single_s'};

%% Inputs -- TEMPORAL RIGHT
sFilesCortex = { 'Subject01/sub-03_ses-02_task-sleep_mod-nirs_run-02_sync_time_dOD__motioncorr_band_scr/timefreq_wavelet_240415_1603.mat'};
sFilesData =  { 'Subject01/sub-03_ses-02_task-sleep_mod-nirs_run-02_sync_time_dOD__motioncorr_band_scr/data_block001.mat'};



fprintf(' %d files detected \n', length(sFilesCortex));

%% Code
segments = [];
for iFile = 1:length(sFilesCortex)
    sData = in_bst_timefreq(sFilesCortex{iFile});
    sDataHead = in_bst_data(sFilesData{1});

    sleep_events    = sDataHead.Events( cellfun(@(x) any(strcmp(x,sleep_stage)), {sDataHead.Events.label}));
    epi_events      = sDataHead.Events( cellfun(@(x) any(strcmp(x,epi_activity)),{sDataHead.Events.label}));
    motion_events   = sDataHead.Events( contains({sDataHead.Events.label}, 'motion'));

    % Extend epi event to account for hemodynamic response 
    for iEvent = 1:length(epi_events)
        epi_events(iEvent)  =  process_ft_wavelet('extendEvent', epi_events(iEvent), 30, 30  );
    end
    
    if size(sData.TF,1) > 1
        sData.WDdata_avg = squeeze(mean(sData.TF))';
    else
        sData.WDdata_avg = squeeze(sData.TF)';
    end
    options.wavelet.freqs_analyzed = sData.Freqs;
    [sData.WDdata_avg, sData.time] = process_ft_wavelet('removeZero', sData.WDdata_avg,  sData.Time );
    process_ft_wavelet('displayTF_Plane',sData.WDdata_avg, sData.time, struct_copy_fields(options,sData.Options));

    splitting_events = [sleep_events,epi_events, motion_events]; 

    file_segment = process_ft_wavelet('exctractSegment',sData.WDdata_avg,sData.time, splitting_events , sDataHead.Events, sData.Freqs );
    for iSegment = 1:length(file_segment)
        file_segment(iSegment).nAvg(1) = 1;
        file_segment(iSegment).nAvg(2:end) = 0;
    end
    segments = [segments ; file_segment ];
end


%% Average within each segment -  same ammount of averaging

selected_segments   = segments(cellfun(@(x) any(strcmp(sleep_stage, x)), {segments.label}) & ...
                                [segments.duration] > 90, :);

epoched_segments    = process_ft_wavelet('epochSegment',selected_segments, 60, 30);

averaged_segments  = process_ft_wavelet('averageWithinSegment',epoched_segments);
resampled_segments = process_ft_wavelet('resampleFrequency',averaged_segments, new_frequency);


disp(' - - - - - - - - - - - -')
fprintf(' %d segments of 60s analyed  \n', length(resampled_segments));
for iStage = 1:length(sleep_stage)
    segments_stage = resampled_segments( strcmp({resampled_segments.label}, sleep_stage{iStage}), : );
    fprintf('%s : %d segment. \n',  ...
                sleep_stage{iStage}, ...
                length(segments_stage));
end
disp(' - - - - - - - - - - - -')

n_boot = 100;
averaged_segments = repmat(resampled_segments(1), 1,length(sleep_stage)) ;

for iStage = 1:length(sleep_stage)
    segments_stage = resampled_segments( strcmp({resampled_segments.label}, sleep_stage{iStage}), : );
    if length(segments_stage) < 5
        continue;
    end

    sub_sample = repmat(resampled_segments(1), 1,n_boot) ;
    for iboot = 1:n_boot
        idx = randsample(length(segments_stage),5);
        sub_sample(iboot) = process_ft_wavelet('averageBetweenSegment', segments_stage(idx));
    end
    averaged_segments(iStage) = process_ft_wavelet('averageBetweenSegment', sub_sample);
end
averaged_segments = averaged_segments(3:4);

options.title_tf = 'Power-Spectrum for Temporal Right - Cortical Surface (HbR)';
fig = process_ft_wavelet('displayPowerSpectrum',cat(2,averaged_segments.WData)', ...
                                          cat(2,averaged_segments.WDataStd)', ...
                                          {averaged_segments.label} , ...
                                          averaged_segments(1).freq , ...
                                          options);

ylim([0 0.3]);
% saveas(fig,fullfile(folder_out, 'powerspectrum-source-TR-N2N3-HbR.png'));


