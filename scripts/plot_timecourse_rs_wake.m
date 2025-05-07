%% 3. Plot power-spectrum
    
% Inputs -- TEMPORAL RIGHT
sFilesCortex = {...
    'sub-02/sub-02_task-rest_run-01_pipeline-preproc-TFR_Hb/timefreq_wavelet_250506_1824.mat', ...
    'sub-02/sub-02_task-rest_run-01_pipeline-preproc-TFR/timefreq_wavelet_250506_1809.mat', ...
    'sub-02/sub-02_task-rest_run-01_pipeline-preproc-TFR/timefreq_wavelet_250506_1906.mat'};

sFilesLabel = {'Channel',  'Cortex (wMEM)', 'Cortex (MNE)'};

power_spectrums = [];

for iFile = 1:length(sFilesCortex)
    averaged_segments = compute_power_spectrum(sFilesCortex(iFile));
    averaged_segments.label = sFilesLabel{iFile};

    power_spectrums = [ power_spectrums , averaged_segments];
end

options = struct();
options.colormap = 'jet';
options.clim = [0 0.25];
options.wavelet.display.fontscale = 44;
options.wavelet.display.TaegerK = 'yes';
options.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ] ./ 255;
options.title_tf = 'Power-Spectrum for Temporal Right (HbO))';
fig = process_ft_wavelet('displayPowerSpectrum',  cat(2,power_spectrums.WData)', ...
                                                  cat(2,power_spectrums.WDataStd)', ...
                                                  {power_spectrums.label} , ...
                                                  power_spectrums(1).freq , ...
                                                  options);


hLegend = findobj(fig, 'Type', 'Legend');
hLegend.Title.String = 'Method';
hLegend.Location = 'best';
