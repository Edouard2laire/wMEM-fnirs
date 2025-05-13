bst_plugin('Load','wmem-fnirs');


SubjectName   = {'sub-01'};


OPTIONS = struct();
OPTIONS.color_red = [215,48,39 ; ...
             252,141,89; ...
             254,224,144] ./ 255;


OPTIONS.color_blue  =  [69, 117, 180 ;...
                       145, 191, 219; ...
                       224, 243, 248] ./ 255;
OPTIONS.LineWidth   = 2.5;
OPTIONS.fontsize    = 20;
OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','TFR');
OPTIONS.TimeSegment      = [5 1120];

if ~exist(OPTIONS.output_folder)
    mkdir(OPTIONS.output_folder)
end


sFiles{1}       = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/data_hb_250506_1459.mat'};
sFilesTF{1}     = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/timefreq_wavelet_250509_1310.mat'};


sFiles{2} = {...
                'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250509_1324.mat', ...
                'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250509_1324.mat'};
sFilesTF{2}  = {'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/timefreq_wavelet_250509_1334.mat'};


sFiles{3} = {...
                        'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbO_250508_1951.mat', ...
                        'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbR_250508_1951.mat'};

sFilesTF{3}   = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/timefreq_wavelet_250509_1349.mat'};

sFilesLabel     = { 'Channel',  'Cortex (MNE)', 'Cortex (wMEM)'};
%% Get theoretical spectrum

[Time, y, Events,  wData, power_spectrums, tf_options] = simulate_theoretical_spectrum (sFiles{1});

OPTIONS = struct_copy_fields(OPTIONS, tf_options);
OPTIONS = process_ft_wavelet('select_frequency_band',0.002, 2, OPTIONS);
OPTIONS.TimeSegment      = [5 1120];

if isfield(OPTIONS, 'vline')
    OPTIONS = rmfield(OPTIONS, 'vline');
end
OPTIONS.title = ''; OPTIONS.plot_montage = 0;


hFig = figure('Units','pixels','Position', getFigureSize(45, 20));
set(hFig, 'PaperPositionMode', 'auto');
t = tiledlayout(2,2); 

% 1. Plot Channel and timecourse
ax = nexttile([2, 1]); 
title(ax, 'a. Montage');
ax.TitleHorizontalAlignment = 'left';
set(ax,    'fontsize', OPTIONS.fontsize, 'LineWidth',OPTIONS.LineWidth);
axis(ax,'off')

ax = nexttile(); 
hold on;
plot(ax, Time, y , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
    
xlim(OPTIONS.TimeSegment);
ylim([-1.5 1.5]); yticks([-1 0 1]), xticks(100:100:1100)
xlabel('Time(s)');
ylabel('Amplitude');
xlim([50, 1100]);

for iTapping = 1:size(Events.times,2)
    rectangle('Position', [ Events.times(1,iTapping), min(ylim(gca)) , ...
        diff(Events.times(:,iTapping)), max(ylim(gca)) - min(ylim(gca))], ...
        'FaceColor', [0.3 00.1, 0.7, 0.3] , ...
        'EdgeColor', [ 0 0 0 0]);
    
end
t2 = title(ax, 'b. Theoretical Recording');
ax.TitleHorizontalAlignment = 'left';
set(ax,    'fontsize', OPTIONS.fontsize, 'LineWidth',OPTIONS.LineWidth);
set(gca,    'Color',[1,1,1]);
set(gcf,    'color','w');

% 2. Plot Time-Frequency
ax = nexttile(); 


OPTIONS.colormap = 'jet';
process_ft_wavelet('displayTF_Plane', wData,  Time, OPTIONS,  hFig, ax);
title(ax,'c. Tine-frequency representation', 'FontSize', options_spectrum.wavelet.display.fontscale + 5)
ax.TitleHorizontalAlignment = 'left';
colorbar(ax,'eastoutside');

xlim([50, 1100]);
clim(ax, [0, 0.2])

saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_all_theo.svg'));
%close(hFig)


options_spectrum = struct();
options_spectrum.colormap = 'jet';
options_spectrum.clim = [0 0.25];
options_spectrum.wavelet.display.fontscale = 20;
options_spectrum.wavelet.display.TaegerK = 'yes';
options_spectrum.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ] ./ 255;

options_spectrum.title_tf = 'd. Power-Spectrum for Motor Left (theoretical)';
hFig = figure('Units','pixels','Position', getFigureSize(30, 20));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
options_spectrum.hFig = hFig;

hFig = process_ft_wavelet('displayPowerSpectrum',  cat(2,power_spectrums.WData)', ...
                                                  cat(2,power_spectrums.WDataStd)', ...
                                                   {'Rest','Task'} , ...
                                                  power_spectrums(1).freq , ...
                                                  options_spectrum);
ylim([0, 0.15]);

ax = gca;
ax.TitleHorizontalAlignment = 'left';

hLegend = findobj(hFig, 'Type', 'Legend');
hLegend.Title.String = '';
hLegend.Location = 'best';

saveas(hFig,fullfile(OPTIONS.output_folder, 'power_spectrum_theo.svg'));
close(hFig)

%% Part 1. Plot Recording on the scalp

channel_file    = {'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/channel_nirsbrs.mat'};

sChannels = in_bst_channel(channel_file{1});
OPTIONS.selected_channel = sChannels.Clusters(1).Sensors;
OPTIONS.TimeSegment      = [5 1120];
if isfield(OPTIONS, 'vline')
    OPTIONS = rmfield(OPTIONS, 'vline');
end

OPTIONS.title = ''; OPTIONS.plot_montage = 1;


hFig = figure('Units','pixels','Position', getFigureSize(45, 20));
set(hFig, 'PaperPositionMode', 'auto');

% 1. Plot Channel and timecourse
OPTIONS.fig = hFig;
plot_timecouse_channels(channel_file{1}, sFiles{1}{1}, OPTIONS)
xlim([50, 1100]);

% 2. Plot Time-Frequency
ax = nexttile(); 

sData = in_bst_timefreq(sFilesTF{1}{1});
OPTIONS = struct_copy_fields(OPTIONS,sData.Options);
OPTIONS = process_ft_wavelet('select_frequency_band',0.002, 2, OPTIONS);

OPTIONS.colormap = 'jet';
process_ft_wavelet('displayTF_Plane', squeeze(mean(sData.TF))',  sData.Time, OPTIONS, hFig, ax);
title(ax,'c. Tine-frequency representation', 'FontSize', options_spectrum.wavelet.display.fontscale + 5)
ax.TitleHorizontalAlignment = 'left';
colorbar(ax,'eastoutside');

xlim(ax,[50, 1000]);
clim(ax, [0, 0.2])

saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_all_head.svg'));
close(hFig)



%%

power_spectrums = compute_power_spectrum(sFilesTF{1});
options_spectrum = struct();
options_spectrum.colormap = 'jet';
options_spectrum.clim = [0 0.25];
options_spectrum.wavelet.display.fontscale = 20;
options_spectrum.wavelet.display.TaegerK = 'yes';
options_spectrum.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ] ./ 255;

options_spectrum.title_tf = 'd. Power-Spectrum for Motor Left (channels)';
hFig = figure('Units','pixels','Position', getFigureSize(30, 20));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
options_spectrum.hFig = hFig;

hFig = process_ft_wavelet('displayPowerSpectrum',  cat(2,power_spectrums.WData)', ...
                                                  cat(2,power_spectrums.WDataStd)', ...
                                                   {'Rest','Task'} , ...
                                                  power_spectrums(1).freq , ...
                                                  options_spectrum);
ylim([0, 0.15]);

ax = gca;
ax.TitleHorizontalAlignment = 'left';

hLegend = findobj(hFig, 'Type', 'Legend');
hLegend.Title.String = '';
hLegend.Location = 'best';

saveas(hFig,fullfile(OPTIONS.output_folder, 'power_spectrum_head.svg'));
close(hFig)
%% Timecourse for MNE


hFig = figure('Units','pixels','Position', getFigureSize(45, 20));
set(hFig, 'PaperPositionMode', 'auto');

% 1. Plot Channel and timecourse
OPTIONS.fig = hFig;
plot_timecourse_cortex(SubjectName, {sFiles{2}}, {'b. Reconstructed Time course (MNE)'}, OPTIONS)
xlim([50, 1100]);

% 2. Plot Time-Frequency
ax = nexttile(); 

sData = in_bst_timefreq(sFilesTF{2}{1});
OPTIONS = struct_copy_fields(OPTIONS,sData.Options);
OPTIONS = process_ft_wavelet('select_frequency_band', 0.002, 2, OPTIONS);

OPTIONS.colormap = 'jet';
process_ft_wavelet('displayTF_Plane', squeeze(sData.TF)',  sData.Time, OPTIONS, hFig, ax);

xlim(ax,[50, 1100]);
clim(ax, [0, 0.2]);
colorbar(ax,'eastoutside');

title(ax,'c. Tine-frequency representation', 'FontSize', options_spectrum.wavelet.display.fontscale + 5)
ax.TitleHorizontalAlignment = 'left';
saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_all_MNE.svg'));
close(hFig)

%%
power_spectrums = compute_power_spectrum(sFilesTF{2});
options_spectrum = struct();
options_spectrum.colormap = 'jet';
options_spectrum.clim = [0 0.25];
options_spectrum.wavelet.display.fontscale = 20;
options_spectrum.wavelet.display.TaegerK = 'yes';
options_spectrum.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ] ./ 255;

options_spectrum.title_tf = 'd. Power-Spectrum for Motor Left (MNE)';
hFig = figure('Units','pixels','Position', getFigureSize(30, 20));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
options_spectrum.hFig = hFig;

fig = process_ft_wavelet('displayPowerSpectrum',  cat(2,power_spectrums.WData)', ...
                                                  cat(2,power_spectrums.WDataStd)', ...
                                                  {'Rest','Task'} , ...
                                                  power_spectrums(1).freq , ...
                                                  options_spectrum);

ylim([0, 0.15]);
ax = gca;
ax.TitleHorizontalAlignment = 'left';


hLegend = findobj(fig, 'Type', 'Legend');
hLegend.Title.String = '';
hLegend.Location = 'best';

saveas(fig,fullfile(OPTIONS.output_folder, 'power_spectrum_MNE.svg'));
close(fig)

%% Timecourse for wMEM


hFig = figure('Units','pixels','Position', getFigureSize(45, 20));
set(hFig, 'PaperPositionMode', 'auto');

% 1. Plot Channel and timecourse
OPTIONS.fig = hFig;
plot_timecourse_cortex(SubjectName, {sFiles{3}}, {'b. Reconstructed Time course (wMEM)'}, OPTIONS)
xlim([50, 1100]);

% 2. Plot Time-Frequency
ax = nexttile(); 

sData = in_bst_timefreq(sFilesTF{3}{1});
OPTIONS = struct_copy_fields(OPTIONS,sData.Options);
OPTIONS = process_ft_wavelet('select_frequency_band',0.002, 2, OPTIONS);

OPTIONS.colormap = 'jet';
process_ft_wavelet('displayTF_Plane', squeeze(sData.TF)',  sData.Time, OPTIONS, hFig, ax);

xlim(ax,[50, 1100]);
clim(ax, [0, 0.2])
colorbar(ax,'eastoutside');

title(ax,'c. Tine-frequency representation', 'FontSize', options_spectrum.wavelet.display.fontscale + 5)
ax.TitleHorizontalAlignment = 'left';
saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_all_wMEM.svg'));
close(hFig)

%%
power_spectrums = compute_power_spectrum(sFilesTF{3});
options_spectrum = struct();
options_spectrum.colormap = 'jet';
options_spectrum.clim = [0 0.25];
options_spectrum.wavelet.display.fontscale = 20;
options_spectrum.wavelet.display.TaegerK = 'yes';
options_spectrum.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ] ./ 255;

options_spectrum.title_tf = 'd. Power-Spectrum for Motor Left (wMEM)';
hFig = figure('Units','pixels','Position', getFigureSize(30, 20));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
options_spectrum.hFig = hFig;
fig = process_ft_wavelet('displayPowerSpectrum',  cat(2,power_spectrums.WData)', ...
                                                  cat(2,power_spectrums.WDataStd)', ...
                                                  {'Rest','Task'} , ...
                                                  power_spectrums(1).freq , ...
                                                  options_spectrum);

ylim([0, 0.15]);

ax = gca;
ax.TitleHorizontalAlignment = 'left';

hLegend = findobj(fig, 'Type', 'Legend');
hLegend.Title.String = 'Method';
hLegend.Location = 'best';

saveas(fig,fullfile(OPTIONS.output_folder, 'power_spectrum_wMEM.svg'));
close(fig)

%% 3. Plot power-spectrum for HbO - not used


power_spectrums = [];

for iFile = 1:length(sFilesTF)
    averaged_segments = compute_power_spectrum(sFilesTF{iFile});
    
    % Extract means and standard deviations
    mu_a  = averaged_segments(1).WData;
    mu_b  = averaged_segments(2).WData;
    std_a = averaged_segments(1).WDataStd;
    std_b = averaged_segments(2).WDataStd;


    diff = averaged_segments(1);
    diff.WData =  log10( mu_b ./  mu_a);
    diff.WDataStd = sqrt( (std_a ./ mu_a).^2 + (std_b ./ mu_b).^2 ) / log(10);

    diff.label = sFilesLabel{iFile};
    power_spectrums = [ power_spectrums , diff];
end

options_spectrum = struct();
options_spectrum.colormap = 'jet';
options_spectrum.clim = [0 0.25];
options_spectrum.wavelet.display.fontscale = 20;
options_spectrum.wavelet.display.TaegerK = 'yes';
options_spectrum.color_map =  [  228,  26,  28  ; ...
                        55,  126, 184  ; ...
                        77,  175,  74  ; ...
                        152,  78, 163  ; ...
                        255, 127,   0  ; 
                        255, 127,   160 ] ./ 255;

options_spectrum.title_tf = 'Comparison with Wake';

fig = process_ft_wavelet('displayPowerSpectrum',  cat(2,power_spectrums.WData)', ...
                                                  cat(2,power_spectrums.WDataStd)', ...
                                                  {power_spectrums.label} , ...
                                                  power_spectrums(1).freq , ...
                                                  options_spectrum);

yline(0, '--');

hLegend = findobj(fig, 'Type', 'Legend');
hLegend.Title.String = 'Method';
hLegend.Location = 'best';

saveas(fig,fullfile(OPTIONS.output_folder, 'power_spectrum_diff.svg'));
%close(fig)


%% Functions
function selected_channels = get_selected_channels(channel_file)
    
    sChannel = in_bst_channel(channel_file{1},'Clusters');

    clusters  = sChannel.Clusters(contains({sChannel.Clusters.Label}','temportalright'));
    selected_channels = {};


    for iCluster = 1:length(clusters)
        selected_channels = union(selected_channels,clusters(iCluster).Sensors);
    end
end


%% Function definition
function hFig = plot_topography(SubjectName, channel_file,  sFiles, OPTIONS)
    [hFig, iDS, iFig] = view_topography(sFiles , 'NIRS', '3DSensorCap');
    
    panel_montage('SetCurrentMontage',hFig, OPTIONS.montage)
    bst_figures('SetBackgroundColor',hFig, [1 1 1])
    figure_3d('SetStandardView',hFig, {'right'});
    panel_time('SetCurrentTime',  OPTIONS.vline)

    sSubject    = bst_get('Subject',SubjectName{1});
    panel_surface('AddSurface', hFig, sSubject.Surface(sSubject.iCortex).FileName);

    sChannels = in_bst_channel(channel_file);
    iChannels = channel_find(sChannels.Channel, {OPTIONS.selected_channel});

    scs = sChannels.Channel(iChannels(1)).Loc;
    mid = mean(scs, 2);

    hold on;
    plot3(gca, mid(1),  mid(2),mid(3), 'o', 'Color','black','MarkerSize',15,'MarkerFaceColor','black')
end

function plot_timecouse_channels(channel_file, sFile, OPTIONS)
    
    sChannels = in_bst_channel(channel_file);
    sData = in_bst_data(sFile);

    iChannels_good = good_channel(sChannels.Channel, sData.ChannelFlag, 'nirs');
    iChannels = channel_find(sChannels.Channel, {OPTIONS.selected_channel{:}});
    iChannels = intersect(iChannels,iChannels_good);

    if OPTIONS.plot_montage
        [hFig, iDS, iFig] = view_channels_3d(channel_file,  'NIRS-BRS', 'scalp', 0, 0);
        bst_figures('SetBackgroundColor',hFig, [1 1 1])
        figure_3d('SetStandardView',hFig, {'right'});
        
        Channel = sChannels.Channel(iChannels);
        [S,D,WL] = panel_montage('ParseNirsChannelNames', {Channel.Name});

        % ===== DISPLAY CONNECTIONS =====
        % Find all pairs of connections
        [uniquePairs, iChanPairs] = unique([S',D'], 'rows');
        % Sort the pairs
        [iChanPairs,I] = sort(iChanPairs);
        uniquePairs = uniquePairs(I,:);
        % Pair locations: sources
        locPairSrc = cellfun(@(c)c(:,1)', {Channel(iChanPairs).Loc}, 'UniformOutput', 0);
        locPairSrc = cat(1, locPairSrc{:});
        % Pair locations: detectors
        locPairDet = cellfun(@(c)c(:,2)', {Channel(iChanPairs).Loc}, 'UniformOutput', 0);
        locPairDet = cat(1, locPairDet{:});
        
        % Make the position of the links more superficial, so they can be outside of the head and selected with the mouse
        if length(unique(locPairDet(:,3))) > 1 || length(unique(locPairSrc(:,3))) > 1
            normSrc = sqrt(sum(locPairSrc .^ 2, 2));
            normDet = sqrt(sum(locPairDet .^ 2, 2));
            locPairSrc = bst_bsxfun(@times, locPairSrc, (normSrc + 0.0035) ./ normSrc);
            locPairDet = bst_bsxfun(@times, locPairDet, (normDet + 0.0035) ./ normDet);
        end
        figure(OPTIONS.fig);
        t = tiledlayout(2,2); 
    
        ax = nexttile([2, 1]); 
        copyobj(allchild(get(hFig, 'CurrentAxes')), ax);
        view(ax, 6.2090,  37.7139);
        campos(ax, [ 0.2125   -1.0487    0.8715]);
        camtarget(ax, [0.0098   -0.0005    0.0562]);
        camup(ax, [0.1878    0.6254    0.7573]);
        hDestAxes = findobj(hFig, '-depth', 1, 'Tag', 'Axes3D');
        set(hDestAxes, 'CameraViewAngle', 6.6203);
        camlight(findobj(hDestAxes, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');

        % Display connections as lines
        hPairs = line(...
            [locPairSrc(:,1)'; locPairDet(:,1)'], ...
            [locPairSrc(:,2)'; locPairDet(:,2)'], ...
            [locPairSrc(:,3)'; locPairDet(:,3)'], ...
            'Color',      [.3 .3 1], ...
            'LineWidth',  3, ...
            'Marker',     'none', ...
            'Parent',     gca, ...
            'Tag',        'NirsCapLine');


        axis off

        t1 = title(ax, 'a. Montage');
        ax.TitleHorizontalAlignment = 'left';
        set(ax,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);
        close(hFig)
        
        ax = nexttile(); 
    
    else
        t = tiledlayout(3,1); 
        ax = nexttile([3 1]); 
    end


    
    iChannelsHbO      = channel_find(sChannels.Channel(iChannels),'HbO');
    iChannelsHbR      = channel_find(sChannels.Channel(iChannels),'HbR');

    data = sData.F(iChannels, :);
    norm_factor = max(data(1,:));

    data = data ./ norm_factor; 

    hold on;
    plot(ax, sData.Time, mean(data(iChannelsHbO,:)) , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
    plot(ax, sData.Time, mean(data(iChannelsHbR,:)) , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));
    
    xlim(OPTIONS.TimeSegment);
    ylim([-1.5 1.5]); yticks([-1 0 1])

    if isempty(sData.Events)
        sData.Events = db_template('Event');
        sData.Events.label  = 'tapping';
        sData.Events.times  = [0 ; 10];
    end

    events      = sData.Events;
    tapping     =  events( strcmp( {events.label}, 'tapping'));
    
    for iTapping = 1:size(tapping.times,2)
        rectangle('Position', [ tapping.times(1,iTapping), min(ylim(gca)) , ...
            diff(tapping.times(:,iTapping)), max(ylim(gca)) - min(ylim(gca))], ...
            'FaceColor', [0.3 00.1, 0.7, 0.3] , ...
            'EdgeColor', [ 0 0 0 0]);
        
    end




    if isfield(OPTIONS, 'vline') && ~isempty(OPTIONS.vline)
        xline(OPTIONS.vline,'Color','black','LineStyle', '--' )
    end

    xlabel('Time(s)');
    ylabel('Amplitude');
    
    if OPTIONS.plot_montage
        t2 = title(ax, 'b. Recording for selected channels');

        % HACK
        t2.Position(2) = t2.Position(2) + 0.02;
    else
        t2 = title(ax, 'a. Recording for selected channels');
    end
    
    ax.TitleHorizontalAlignment = 'right';
    set(ax,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);


    if OPTIONS.plot_montage && ~isempty(OPTIONS.title)
        sgt = title(t, sprintf ('%s [%d, %ds]',OPTIONS.title , OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)));
        sgt.FontSize = 40; sgt.FontWeight = 'Bold';
    end

    set(gca,    'Color',[1,1,1]);
    set(gcf,    'color','w');
    set(gca,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);

end


function  plot_timecourse_cortex(SubjectName, sFiles, sFiles_label, OPTIONS)
    

    sSubject    = bst_get('Subject',SubjectName{1});
    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts')).Scouts;
    ROI         = Scouts( strcmpi({Scouts.Label}, 'hand'));
    
       
    
    tiledlayout(2,2);
    
    hFig = view_surface(sSubject.Surface(sSubject.iCortex).FileName);
    panel_scout('SetSelectedScouts', 1)
    panel_scout('SetScoutTextVisible', 0, 1);

    figure(OPTIONS.fig);
    ax = nexttile([2, 1]); 
    copyobj(allchild(get(hFig, 'CurrentAxes')), ax);

    
    view(ax, 6.2090,  37.7139);
    campos(ax, [ 0.2125   -1.0487    0.8715]);
    camtarget(ax, [0.0098   -0.0005    0.0562]);
    camup(ax, [0.1878    0.6254    0.7573]);
    hDestAxes = findobj(hFig, '-depth', 1, 'Tag', 'Axes3D');
    set(hDestAxes, 'CameraViewAngle', 6.6203);
        

    title(ax, 'a. Cortex', 'FontSize', OPTIONS.fontsize + 5);
    ax.TitleHorizontalAlignment = 'left';
    axis(ax, 'off');

    axes = [];
    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        sData = in_bst_results(sFile{1});     Time = sData.Time;
        HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 
        
        sData = in_bst_results(sFile{2});
        HbR = mean(sData.ImageGridAmp(ROI.Vertices,:));
        
        norm_factor = max(abs(HbO));
        HbO = HbO ./ norm_factor; 
        HbR = HbR ./ norm_factor; 
        
        

        ax1 = nexttile(); 
        hold on;
        plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
        plot(Time, HbR , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));
        
        xlim(OPTIONS.TimeSegment);
        ylim([-1.5 1.5]); yticks([-1 0 1])
               
        title(sFiles_label{k})
        ax1.TitleHorizontalAlignment = 'left'; 
        axes(end+1) = ax1;

        
        sData_head  =  in_bst_data(sData.DataFile, 'Events');
        if isempty(sData_head.Events)
            sData_head.Events = db_template('Event');
            sData_head.Events.label  = 'tapping';
            sData_head.Events.times  = [0 ; 10];
        end

        events      = sData_head.Events;
        tapping     =  events( strcmp( {events.label}, 'tapping'));
        
        for iTapping = 1:size(tapping.times,2)
            rectangle('Position', [ tapping.times(1,iTapping), min(ylim(gca)) , ...
                diff(tapping.times(:,iTapping)), max(ylim(gca)) - min(ylim(gca))], ...
                'FaceColor', [0.3 00.1, 0.7, 0.3] , ...
                'EdgeColor', [ 0 0 0 0]);
            
        end


        if isfield(OPTIONS, 'vline') && ~isempty(OPTIONS.vline)
            xline(OPTIONS.vline,'Color','black','LineStyle', '--' )
        end

        if k == length(sFiles)
            xlabel('Time(s)');
        end
        ylabel('Amplitude');
        

        set(gca,    'Color',[1,1,1]);
        set(gcf,    'color','w');
        set(gca,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);
        
        
    end
    linkaxes(axes,'xy')
    
    if isfield(OPTIONS,'title') && ~isempty(OPTIONS.title )
        sgt = sgtitle(sprintf ('%s [%d, %ds]',OPTIONS.title , OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)));
        sgt.FontSize = 25; sgt.FontWeight = 'Bold';
    end

end


function plot_brain( SubjectName, sFiles, sFiles_label, OPTIONS)

    sSubject    = bst_get('Subject',SubjectName{1});
    if isfield(OPTIONS, 'tag')
       tag =  OPTIONS.tag;
    else
        tag = '';
    end

    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        sMap = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, sFile{1}, 'NIRS', 'NewFigure');

        panel_time('SetCurrentTime',  OPTIONS.vline)
        panel_scout('SetScoutTextVisible', 0, 1);
        panel_scout('SetScoutTransparency', 1);
        bst_colormaps('SetColormapName',      'nirs', "jet");
        bst_figures('SetBackgroundColor', sMap, [1 1 1]) 
        figure_3d('SetStandardView',sMap, {'right'});

        hColorbar = findobj(sMap, 'Tag', 'Colorbar');
        set(hColorbar, 'XColor', [0, 0, 0], ...
                       'YColor', [0, 0, 0] );

        saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_HbO.svg',sFiles_label{k}, tag )));
        close(sMap)

        sMap = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, sFile{2}, 'NIRS', 'NewFigure');

        panel_time('SetCurrentTime',  OPTIONS.vline)
        panel_scout('SetScoutTextVisible', 0, 1);
        panel_scout('SetScoutTransparency', 1);
        bst_colormaps('SetColormapName',      'nirs', "jet");
        bst_figures('SetBackgroundColor', sMap, [1 1 1]) 
        figure_3d('SetStandardView',sMap, {'right'});


        hColorbar = findobj(sMap, 'Tag', 'Colorbar');
        set(hColorbar, 'XColor', [0, 0, 0, 1], ...
                       'YColor', [0, 0, 0, 1] );

        saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_HbR.svg',sFiles_label{k}, tag )));
        close(sMap)


    end
end

