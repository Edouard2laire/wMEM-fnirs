
SubjectName   = {'sub-01'};

%figure_setting();


OPTIONS = struct();
OPTIONS.color_red = [215,48,39 ; ...
             252,141,89; ...
             254,224,144] ./ 255;


OPTIONS.color_blue =  [69,117,180 ;...
                      145,191,219; ...
                      224,243,248] ./ 255;
OPTIONS.LineWidth = 2.5;
OPTIONS.fontsize  = 20;
OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','tapping');




%% Part 1. Plot Recording on the scalp
channel_file = {'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/channel_nirsbrs.mat'};
sFiles = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/data_hb_250506_1459.mat'};

OPTIONS.selected_channel = 'S1D14';
OPTIONS.TimeSegment      = [0 1120];
if isfield(OPTIONS, 'vline')
    OPTIONS = rmfield(OPTIONS, 'vline');
end

OPTIONS.title = ''; OPTIONS.plot_montage = 1;
hFig = figure('Units','pixels','Position', getFigureSize(42.7, 22.5));
set(hFig, 'PaperPositionMode', 'auto');
hold on;
OPTIONS.fig = hFig;
plot_timecouse_channels(channel_file{1}, sFiles{1}, OPTIONS)
saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_head_all.svg'));
%close(hFig)


%% Figure 1 and 2. Figure of the entire signal. 
sFiles       = {};

sFiles{1} = {...
                'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250506_1411.mat', ...
                'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250506_1411.mat', ...
            };

sFiles{2} = {...
                'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbO_250506_1418.mat', ...
                'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbR_250506_1418.mat'};

sFiles_label                   = {'a. MNE', 'c. wMEM'}; 

OPTIONS.TimeSegment = [10 1120];
OPTIONS.title       = '';
hFig = figure('Units','pixels','Position', getFigureSize(42.7, 22.5));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_all.svg'));
close(hFig)


OPTIONS.TimeSegment = [620 660];
OPTIONS.title       = '';
hFig = figure('Units','pixels','Position', getFigureSize(14.6, 22.500));
set(hFig, 'PaperPositionMode', 'auto');hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_zoomed.svg'));
close(hFig)


%% Plot Average 

sFiles = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/data_hb_250506_1460.mat'};
channel_file = {'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/channel_nirsbrs.mat'};

OPTIONS.vline       = 13; OPTIONS.montage = 'HbO[tmp]';
OPTIONS.selected_channel = {};

hFig = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'topography_avg_HbO.svg'));

OPTIONS.vline       = 13; OPTIONS.montage = 'HbR[tmp]';
OPTIONS.selected_channel = {};

fig_topo_HbR = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
saveas(fig_topo_HbR,fullfile(OPTIONS.output_folder, 'topography_avg_HbR.svg'));
%% 


sFiles = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/data_hb_250506_1460.mat'};
channel_file = {'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/channel_nirsbrs.mat'};

OPTIONS.selected_channel = {};
OPTIONS.TimeSegment = [-10 30];


OPTIONS.title = 'Averaged signal'; OPTIONS.plot_montage = 0;
hFig = figure('Units','pixels','Position', getFigureSize(42.7, 22.5));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
plot_timecouse_channels(channel_file{1}, sFiles{1}, OPTIONS)

ax = nexttile(); 
set(ax,    'fontsize', OPTIONS.fontsize,  'LineWidth',OPTIONS.LineWidth);

sFiles = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/data_hb_250506_1460.mat'};
OPTIONS.vline       = 13; OPTIONS.montage = 'HbO[tmp]';

fig_topo = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
    copyobj(allchild(get(fig_topo, 'CurrentAxes')), ax);
    % view(ax, 0.8855,  10.3315);
    % campos(ax, [ 0.0455   -2.0350    0.4073]);
    % camtarget(ax, [0.0140    0.0018    0.0360]);
    % camup(ax, [0, 0, 1]);
    % 
    % % Center the montage in the screen
    % xlim(ax, [ -0.0854    0.1133])
    % ylim(ax, [-0.0809    0.0963])
    % zlim(ax, [ -0.0218    0.1711])

    axis(ax, 'equal')
    axis(ax, 'off')
t = title(ax, 'b. Topography - HbO', 'FontSize',   OPTIONS.fontsize + 10);
%t.Position = [0    0.1481    0.1500];
close(fig_topo)

ax = nexttile(); 
set(ax,    'fontsize', OPTIONS.fontsize,  'LineWidth', OPTIONS.LineWidth);

sFiles = { 'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr_Hb/data_hb_250506_1460.mat'};
OPTIONS.vline       = 13; OPTIONS.montage = 'HbR[tmp]';

fig_topo = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
    ax.Box
    copyobj(allchild(get(fig_topo, 'CurrentAxes')), ax);
    % view(ax, 0.8855,  10.3315);
    % campos(ax, [ 0.0455   -2.0350    0.4073]);
    % camtarget(ax, [0.0140    0.0018    0.0360]);
    % camup(ax, [0, 0, 1]);
    % 
    % % Center the montage in the screen
    % xlim(ax, [ -0.0854    0.1133])
    % ylim(ax, [-0.0809    0.0963])
    % zlim(ax, [ -0.0218    0.1711])

    axis(ax, 'equal')
    axis(ax, 'off')

t2 = title(ax,'c. Topography - HbR', 'FontSize', OPTIONS.fontsize + 10);
%t2.Position(1) = 0; 

close(fig_topo)

saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_head_avg.svg'));
close(hFig)
%% Figure 2. Figure of the averaged timecourse
sFilesGRP       = {};


sFiles{1} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250506_1456.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250506_1456.mat'};

sFiles{2} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250506_1411_low_winavg_250507_1548.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250506_1411_low_winavg_250507_1548.mat'};

sFiles{3} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbO_250506_1418_low_winavg_250507_1548.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbR_250506_1418_low_winavg_250507_1548.mat'};


sFiles_label                   = {'a. cMEM', 'b. MNE',  'c. wMEM'}; 


OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 13;

hFig = figure('Units','pixels','Position', getFigureSize(14.6, 22.500));
set(hFig, 'PaperPositionMode', 'auto');hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_avg.svg'));


OPTIONS.vline       = 13;
plot_brain(SubjectName, sFiles,sFiles_label,  OPTIONS)


%% Function definition


function hFig = plot_topography(SubjectName,channel_file,  sFiles, OPTIONS)
    [hFig, iDS, iFig] =                    view_topography(sFiles, 'NIRS', '3DOptodes');

    panel_montage('SetCurrentMontage',hFig, OPTIONS.montage)
    bst_figures('SetBackgroundColor',hFig, [1 1 1])

    view( 6.2090,  37.7139);
    campos([ 0.2125   -1.0487    0.8715]);
    camtarget([0.0098   -0.0005    0.0562]);
    camup([0.1878    0.6254    0.7573]);
    hDestAxes = findobj(hFig, '-depth', 1, 'Tag', 'Axes3D');
    set(hDestAxes, 'CameraViewAngle', 6.6203);
    camlight(findobj(hDestAxes, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');

    panel_time('SetCurrentTime',  OPTIONS.vline)

    sSubject    = bst_get('Subject',SubjectName{1});
    panel_surface('AddSurface', hFig, sSubject.Surface(sSubject.iCortex).FileName);
    
    if ~isempty(OPTIONS.selected_channel)
        sChannels = in_bst_channel(channel_file);
        iChannels = channel_find(sChannels.Channel, {OPTIONS.selected_channel});
        
        scs = sChannels.Channel(iChannels(1)).Loc;
        mid = mean(scs, 2);
    
        hold on;
        plot3(gca, mid(1),  mid(2),mid(3), 'o', 'Color','black','MarkerSize',15,'MarkerFaceColor','black')
    end
end

function plot_timecouse_channels(channel_file, sFile, OPTIONS)
    
    sChannels = in_bst_channel(channel_file);

    if OPTIONS.plot_montage
        [hFig, iDS, iFig] = view_channels_3d(channel_file,  'NIRS-BRS', 'scalp', 0, 0);
        bst_figures('SetBackgroundColor',hFig, [1 1 1])

        view( 6.2090,  37.7139);
        campos([ 0.2125   -1.0487    0.8715]);
        camtarget([0.0098   -0.0005    0.0562]);
        camup([0.1878    0.6254    0.7573]);
        hDestAxes = findobj(hFig, '-depth', 1, 'Tag', 'Axes3D');
        set(hDestAxes, 'CameraViewAngle', 6.6203);
        camlight(findobj(hDestAxes, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');
        
        figure(OPTIONS.fig);
        t = tiledlayout(1,2); 
    
        ax = nexttile(); 
        copyobj(allchild(get(hFig, 'CurrentAxes')), ax);
        view( 6.2090,  37.7139);
        campos([ 0.2125   -1.0487    0.8715]);
        camtarget([0.0098   -0.0005    0.0562]);
        camup([0.1878    0.6254    0.7573]);
        hDestAxes = findobj(hFig, '-depth', 1, 'Tag', 'Axes3D');
        set(hDestAxes, 'CameraViewAngle', 6.6203);
        camlight(findobj(hDestAxes, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');

        % Center the montage in the screen
        xlim([-0.1209    0.1291])
        ylim([-0.1003    0.0997])
        zlim([-0.0387    0.1613])

        axis off
        ax.TitleHorizontalAlignment = 'left';
        set(ax,    'fontsize', OPTIONS.fontsize,  'LineWidth', OPTIONS.LineWidth);

        t1 = title(ax, 'a. Montage', 'FontSize', OPTIONS.fontsize + 10);
        close(hFig)
        
        ax = nexttile(); 
    
    else
        t = tiledlayout(2, 2);
        ax = nexttile([2 1]); 
    end
    set(ax,    'fontsize', OPTIONS.fontsize,  'LineWidth',OPTIONS.LineWidth);

    sData = in_bst_data(sFile);
    iChannels_good = good_channel(sChannels.Channel, sData.ChannelFlag, 'nirs');
    if ~isempty(OPTIONS.selected_channel)
        iChannels = channel_find(sChannels.Channel, {OPTIONS.selected_channel});
    else
        iChannels = channel_find(sChannels.Channel, {'HbO','HbR'});
        OPTIONS.selected_channel = 'all channels';
    end

    iChannels = intersect(iChannels,iChannels_good);

    data = sData.F(iChannels, :);
    norm_factor = max(max(data(1:2:end,:)));

    data = data ./ norm_factor; 

    hold on;
    plot(ax, sData.Time, data(1:2:end,:) , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
    plot(ax, sData.Time, data(2:2:end,:) , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));

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
        t2 = title(sprintf('b. Recording for %s',OPTIONS.selected_channel), 'FontSize', OPTIONS.fontsize + 10);

        % HACK
        t2.Position = [314.315253982301,1.5512,0];
        %ax.TitleHorizontalAlignment = 'left';
    else
        t2 = title(ax, sprintf('a. Recording for %s',OPTIONS.selected_channel), 'FontSize', OPTIONS.fontsize + 10);
        ax.TitleHorizontalAlignment = 'left';
    end
    


    if OPTIONS.plot_montage && ~isempty(OPTIONS.title)
        sgt = title(t, sprintf ('%s [%d, %ds]',OPTIONS.title , OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)), 'FontSize', OPTIONS.fontsize + 10);
        sgt.FontSize = 40; sgt.FontWeight = 'Bold';
    end

    set(gca,    'Color',[1,1,1]);
    set(gcf,    'color','w');


end


function  plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS)
    

    sSubject    = bst_get('Subject',SubjectName{1});
    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts')).Scouts;
    ROI         = Scouts( strcmpi({Scouts.Label}, 'hand'));
    
       
    
    tiledlayout(length(sFiles),1)
    axes = [];
    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        sData = in_bst_results(sFile{1});     Time = sData.Time;
        HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 
        
        sData = in_bst_results(sFile{2});
        HbR = mean(sData.ImageGridAmp(ROI.Vertices,:));
        
        norm_factor = max(HbO);
        HbO = HbO ./ norm_factor; 
        HbR = HbR ./ norm_factor; 
        
        

        ax1 = nexttile(); 
        set(ax1,    'fontsize', OPTIONS.fontsize,  'LineWidth',OPTIONS.LineWidth);

        hold on;
        plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
        plot(Time, HbR , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));
        
        xlim(OPTIONS.TimeSegment);
        ylim([-1.5 1.5]); yticks([-1 0 1])
               
        title(sFiles_label{k}, 'FontSize', OPTIONS.fontsize + 10);
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
        
        
    end
    linkaxes(axes,'xy')
    
    if ~isempty(OPTIONS.title )
        sgt = sgtitle(sprintf ('%s [%d, %ds]',OPTIONS.title , OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)), 'FontSize', OPTIONS.fontsize + 10);
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
        view( 6.2090,  37.7139);
        campos([ 0.2125   -1.0487    0.8715]);
        camtarget([0.0098   -0.0005    0.0562]);
        camup([0.1878    0.6254    0.7573]);
        hDestAxes = findobj(sMap, '-depth', 1, 'Tag', 'Axes3D');
        set(hDestAxes, 'CameraViewAngle', 6.6203);
        camlight(findobj(hDestAxes, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');

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
        view( 6.2090,  37.7139);
        campos([ 0.2125   -1.0487    0.8715]);
        camtarget([0.0098   -0.0005    0.0562]);
        camup([0.1878    0.6254    0.7573]);
        hDestAxes = findobj(sMap, '-depth', 1, 'Tag', 'Axes3D');
        set(hDestAxes, 'CameraViewAngle', 6.6203);
        camlight(findobj(hDestAxes, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');


        hColorbar = findobj(sMap, 'Tag', 'Colorbar');
        set(hColorbar, 'XColor', [0, 0, 0, 1], ...
                       'YColor', [0, 0, 0, 1] );

        saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_HbR.svg',sFiles_label{k}, tag )));
        close(sMap)


    end
end