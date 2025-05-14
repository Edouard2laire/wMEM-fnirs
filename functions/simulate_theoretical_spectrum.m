function [Time, y, Events, wData, averaged_segments, OPTIONS] = simulate_theoretical_spectrum (sFile)
% Produce the theoretical spectrum based on the e vent in sFIle.


    sData = in_bst_data(sFile{1});
    Time = sData.Time;
    iEvt = find(strcmp({sData.Events.label},'tapping'));
    Events = sData.Events(iEvt);
    Events.times = Events.times(:,2:end);
    model = nst_glm_initialize_model(sData.Time);

    hrf_types   = process_nst_glm_fit('get_hrf_types');
    model = nst_glm_add_regressors(model, "event", Events, hrf_types.CANONICAL, 30);
    
    y = model.X(:,1);
    y = y ./ max(y);
   

    % COmpute TF -representation 
    OPTIONS =  get_option(sData.Time);

    [wData, OPTIONS] = compute_time_frequency(sData.Time, y', OPTIONS);
    OPTIONS = process_ft_wavelet('select_frequency_band',0.002, 2, OPTIONS);

    averaged_segments = compute_spectrum(sData, wData, OPTIONS);

end


function OPTIONS =  get_option(time)


    OPTIONS.wavelet.vanish_moments =  1.5 ; % vanish momemts
    OPTIONS.wavelet.order          =  20 ;  % spectral decay
    OPTIONS.wavelet.nb_levels      =  1024;% number of voices
    OPTIONS.wavelet.verbose        = 1;   % verbose or not
    OPTIONS.mandatory.DataTime     = time; 
    OPTIONS.wavelet.display.fontscale = 16;
    OPTIONS.wavelet.display.TaegerK = 'yes';



end

function [wData, OPTIONS] = compute_time_frequency(time, y, OPTIONS)
    [F, iOrigTime] = process_ft_wavelet('pad_signal', time, y );
    
    % Step 1 - compute time-frequency representation
    [tmp, OPTIONS] = be_CWavelet(squeeze(F), OPTIONS);
    
    % Step 2- Normalize the TF maps ( Remove 1/f)
    [power, title_tf] = process_ft_wavelet('apply_measure', tmp(iOrigTime,:)', OPTIONS);
    OPTIONS.title_tf =  title_tf ;
    
    % Step 3- Normalize the TF maps ( standardize power)
    power_time              = sqrt(sum(power.^2));
    wData                   = power ./ median(power_time) ;
end


function averaged_segments = compute_spectrum(sData, wData, options)
    
    %% options
    new_frequency = logspace( log10(0.002), log10(2), 500);

    sleep_stage  = {'Wake'; 'N1';'N2';'N3';'REM'};
    epi_activity = {'tapping', 'spikes_LR', 'spikes_RL', 'spikes_bilat', 'single_s'};
    

      
    if isfield(options.wavelet, 'freqWindow')
        options.wavelet = rmfield(options.wavelet,'freqWindow');
    end

    options.colormap = 'jet';
    options.clim = [0 0.25];
    options.wavelet.display.fontscale = 44;
    options.color_map =  [  228,  26,  28  ; ...
                            55,  126, 184  ; ...
                            77,  175,  74  ; ...
                            152,  78, 163  ; ...
                            255, 127,   0  ] ./ 255;
    
    
    
    
    fprintf(' %d files detected \n', 1);
    
    %% Code
    segments = [];

    sleep_events    = sData.Events( cellfun(@(x) any(strcmp(x,sleep_stage)), {sData.Events.label}));
    epi_events      = sData.Events( cellfun(@(x) any(strcmp(x,epi_activity)),{sData.Events.label}));
    motion_events   = sData.Events( contains({sData.Events.label}, 'motion'));

    % Extend epi event to account for hemodynamic response 
    for iEvent = 1:length(epi_events)
        epi_events(iEvent)  =  process_ft_wavelet('extendEvent', epi_events(iEvent), 10,  20  );
    end
    

    sData.WDdata_avg = wData;
    sData.Freqs      = options.wavelet.freqs_analyzed;

    options.wavelet.freqs_analyzed = sData.Freqs;
    [sData.WDdata_avg, sData.time] = process_ft_wavelet('removeZero', sData.WDdata_avg,  sData.Time );

    splitting_events = [sleep_events, epi_events, motion_events]; 

    file_segment = process_ft_wavelet('exctractSegment',sData.WDdata_avg, sData.Time, splitting_events , sData.Events, sData.Freqs );
    for iSegment = 1:length(file_segment)
        file_segment(iSegment).nAvg(1) = 1;
        file_segment(iSegment).nAvg(2:end) = 0;
    end
    segments = [segments ; file_segment ];


    %% Average within each segment -  same ammount of averaging
    sleep_stage = {'Wake', 'tapping'};
    selected_segments   = segments(cellfun(@(x) any(strcmp(sleep_stage, x)), {segments.label}) & ...
                                    [segments.duration] >= 20, :);
    
    epoched_segments    = process_ft_wavelet('epochSegment', selected_segments,  20, 0);
    averaged_segments   = process_ft_wavelet('averageWithinSegment',epoched_segments);
    resampled_segments  = process_ft_wavelet('resampleFrequency',averaged_segments, new_frequency);
    
    
    disp(' - - - - - - - - - - - -')
    fprintf(' %d segments of %ds analyed  \n', length(resampled_segments), epoched_segments(1).time(end));
    for iStage = 1:length(sleep_stage)
        segments_stage = resampled_segments( strcmp({resampled_segments.label}, sleep_stage{iStage}), : );
        fprintf('%s : %d segment. \n',  ...
                    sleep_stage{iStage}, ...
                    length(segments_stage));
    end
    disp(' - - - - - - - - - - - -')
    
    n_boot = 100;
    averaged_segments = repmat(resampled_segments(1), 1,length(sleep_stage)) ;
    is_included       = true(1,length(sleep_stage));
    
    for iStage = 1:length(sleep_stage)
        segments_stage = resampled_segments( strcmp({resampled_segments.label}, sleep_stage{iStage}), : );
        
        if length(segments_stage) < 5
            is_included(iStage) = false;
            continue;
        end
    
        sub_sample = repmat(resampled_segments(1), 1,n_boot) ;
        for iboot = 1:n_boot
    
            idx = randsample(length(segments_stage), 5);
            sub_sample(iboot) = process_ft_wavelet('averageBetweenSegment', segments_stage(idx));
        end
    
    
        averaged_segments(iStage) = process_ft_wavelet('averageBetweenSegment', sub_sample);
    end
    
    averaged_segments = averaged_segments(is_included);

end