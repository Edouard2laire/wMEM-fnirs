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

new_frequency = logspace( log10(0.002), log10(0.5), 500);

sleep_stage  = {'Wake'};
epi_activity = {'bursts', 'spikes_LR', 'spikes_RL', 'spikes_bilat', 'single_s'};


fprintf(' %d files detected \n', length(sFilesCortex));

%% Code
iFile = 1;

sData = in_bst_timefreq(sFilesCortex{iFile});
options = sData.Options;
%options.wavelet = rmfield(options.wavelet,'freqWindow');
options.colormap = 'jet';
options.clim = [0 0.25];
options.wavelet.display.fontscale = 44;

sDataHead = in_bst_data(sFilesData{1});

%%


sData = in_bst_timefreq(sFilesCortex{2});


sleep_events    = sDataHead.Events( cellfun(@(x) any(strcmp(x,sleep_stage)), {sDataHead.Events.label}));
epi_events      = sDataHead.Events( cellfun(@(x) any(strcmp(x,epi_activity)),{sDataHead.Events.label}));
motion_events   = sDataHead.Events( contains({sDataHead.Events.label}, 'motion'));

% Extend epi event to account for hemodynamic response 
for iEvent = 1:length(epi_events)
    epi_events(iEvent)  =  process_ft_wavelet('extendEvent', epi_events(iEvent), 30, 30  );
end
    
options.wavelet.freqs_analyzed = sData.Freqs;
options.title_tf = 'Power-Spectrum for Temporal Right - Channel Space (HbO)';


for kStage = 1:length(sleep_stage)
    out_averaged_segments = [] ;
    labels = {};
    
    for iChannel = 1:size(sData.TF,1)
        labels{iChannel} = sprintf('Channel %d', iChannel);
        
        sData.WDdata_avg = squeeze(sData.TF(iChannel,:,:))';
        
        splitting_events = [sleep_events,epi_events, motion_events]; 
        
        [sData.WDdata_avg, sData.time] = process_ft_wavelet('removeZero', sData.WDdata_avg,  sData.Time );
        file_segment = process_ft_wavelet('exctractSegment',sData.WDdata_avg,sData.time, splitting_events , sDataHead.Events, sData.Freqs );
        for iSegment = 1:length(file_segment)
            file_segment(iSegment).nAvg(1) = 1;
            file_segment(iSegment).nAvg(2:end) = 0;
        end
        segments = file_segment ;
    
    
    
    %% Average within each segment -  same ammount of averaging
    
    selected_segments   = segments(strcmp({segments.label}, sleep_stage{kStage}) & ...
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
    
    segments_stage = resampled_segments;
    
    
    sub_sample = repmat(resampled_segments(1), 1,n_boot) ;
    for iboot = 1:n_boot
        idx = randsample(length(segments_stage),5);
        sub_sample(iboot) = process_ft_wavelet('averageBetweenSegment', segments_stage(idx));
    end
    if isempty(out_averaged_segments)
        out_averaged_segments = process_ft_wavelet('averageBetweenSegment', sub_sample);
    else
        out_averaged_segments(end+1) = process_ft_wavelet('averageBetweenSegment', sub_sample);
    end
    
    end
    out_averaged_stage(kStage)  = process_ft_wavelet('averageBetweenSegment', out_averaged_segments);
end

fig = process_ft_wavelet('displayPowerSpectrum',cat(2,out_averaged_stage.WData)', ...
                                          cat(2,out_averaged_stage.WDataStd)', ...
                                          {'N2', 'N3'} , ...
                                          out_averaged_segments(1).freq , ...
                                          options);
legend off
fig.Position = [ -4.5944   -0.1411    2.8444    1.4844];
ylim([0 0.15]);

%saveas(fig,fullfile(folder_out, 'powerspectrum-channel-space-TR-N2_zoom.png'));
