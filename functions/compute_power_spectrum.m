function averaged_segments = compute_power_spectrum(sFilesCortex)
    bst_plugin('Load', 'TFNIRS', 1);
    
    %% options
    
    %new_frequency = logspace( log10(0.002), log10(1.5), 500);
    new_frequency = logspace( log10(0.002), log10(2), 500);

    sleep_stage  = {'Wake'; 'N1';'N2';'N3';'REM'};
    epi_activity = {'tapping', 'spikes_LR', 'spikes_RL', 'spikes_bilat', 'single_s'};
    

    
    sData = in_bst_timefreq(sFilesCortex{1}, 0, 'Options');
    options = sData.Options;
    
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
    
    
    
    
    fprintf(' %d files detected \n', length(sFilesCortex));
    
    %% Code
    segments = [];
    for iFile = 1:length(sFilesCortex)
        sData = in_bst_timefreq(sFilesCortex{iFile});
        sDataHead = in_bst_data(sData.DataFile, {'DataFile', 'Events'});

        if isempty(sDataHead.Events) && isfield(sDataHead ,'DataFile')
            sDataHead = in_bst_data(sDataHead.DataFile, 'Events');
        end
        
        sleep_events    = sDataHead.Events( cellfun(@(x) any(strcmp(x,sleep_stage)), {sDataHead.Events.label}));
        epi_events      = sDataHead.Events( cellfun(@(x) any(strcmp(x,epi_activity)),{sDataHead.Events.label}));
        motion_events   = sDataHead.Events( contains({sDataHead.Events.label}, 'motion'));
    
        % Extend epi event to account for hemodynamic response 
        for iEvent = 1:length(epi_events)
            epi_events(iEvent)  =  process_ft_wavelet('extendEvent', epi_events(iEvent), 10,  20  );
        end
        
        if size(sData.TF,1) > 1
            sData.WDdata_avg = squeeze(mean(sData.TF))';
        else
            sData.WDdata_avg = squeeze(sData.TF)';
        end
        options.wavelet.freqs_analyzed = sData.Freqs;
        [sData.WDdata_avg, sData.time] = process_ft_wavelet('removeZero', sData.WDdata_avg,  sData.Time );
        %process_ft_wavelet('displayTF_Plane',sData.WDdata_avg, sData.time, struct_copy_fields(options,sData.Options));
    
        splitting_events = [sleep_events, epi_events, motion_events]; 
    
        file_segment = process_ft_wavelet('exctractSegment',sData.WDdata_avg,sData.time, splitting_events , sDataHead.Events, sData.Freqs );
        for iSegment = 1:length(file_segment)
            file_segment(iSegment).nAvg(1) = 1;
            file_segment(iSegment).nAvg(2:end) = 0;
        end
        segments = [segments ; file_segment ];
    end
    
    
    %% Average within each segment -  same ammount of averaging
    sleep_stage = {'Wake', 'tapping'};
    selected_segments   = segments(cellfun(@(x) any(strcmp(sleep_stage, x)), {segments.label}) & ...
                                    [segments.duration] >= 20, :);
    
    epoched_segments    = process_ft_wavelet('epochSegment', selected_segments,  20, 0);
    averaged_segments   = process_ft_wavelet('averageWithinSegment',epoched_segments);
    resampled_segments  = process_ft_wavelet('resampleFrequency',averaged_segments, new_frequency);
    
    
    disp(' - - - - - - - - - - - -')
    fprintf(' %d segments of %ds analyed  \n', length(resampled_segments), round(epoched_segments(1).time(end)));
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

