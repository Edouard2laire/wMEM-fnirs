
SubjectName   = {'sub-02'};

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
OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','Simulation','task');




%% Part 1. Plot Recording on the scalp
channel_file = {'sub-02/simulation_wake_task_0.25dB_left_medium/channel_nirsbrs.mat'};
sFiles = { 'sub-02/simulation_wake_task_0.25dB_left_medium/data_sim_250420_1954.mat'};


OPTIONS.selected_channel = 'S6D14';
OPTIONS.TimeSegment      = [0 320];
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
close(hFig)


%% Figure 1 and 2. Figure of the entire signal. 
sFiles       = {};

sFiles{1} = {...
                'sub-02/simulation_wake_task_0.25dB_left_medium/results_NIRS_MNE_sources_|_WL830_nm_250420_2001.mat' };
sFiles{2} = {...
                'sub-02/simulation_wake_task_0.25dB_left_medium/results_NIRS_wMEM__smooth=0.6_DWT(j1__2__3__4__5__6__7__8__9)__WL830nm_250420_2005.mat'};


sFiles_label                   = {'a. MNE', 'c. wMEM'}; 

OPTIONS.TimeSegment =  [0 320];
OPTIONS.title       = '';
hFig = figure('Units','pixels','Position', getFigureSize(42.7, 22.5));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_all.svg'));
close(hFig)


OPTIONS.TimeSegment = [240 280];
OPTIONS.title       = '';
hFig = figure('Units','pixels','Position', getFigureSize(14.6, 22.500));
set(hFig, 'PaperPositionMode', 'auto');hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_zoomed.svg'));
close(hFig)


%% Plot Average 

sFiles = { 'sub-02/simulation_wake_task_0.25dB_left_medium/data_sim_250420_1954_low_03_winavg_250420_1959.mat'};
channel_file = {'sub-02/simulation_wake_task_0.25dB_left_medium/channel_nirsbrs.mat'};

OPTIONS.vline       = 10; OPTIONS.montage = 'WL830[tmp]';
OPTIONS.selected_channel = {};

hFig = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'topography_avg_HbO.svg'));


%% =================================== todo


sFiles = { 'sub-02/simulation_wake_task_0.25dB_left_medium/data_sim_250420_1954_low_03_winavg_250420_1959.mat'};
channel_file = {'sub-02/simulation_wake_task_0.25dB_left_medium/channel_nirsbrs.mat'};

OPTIONS.selected_channel = {};
OPTIONS.TimeSegment = [-10 30];


OPTIONS.title = 'Averaged signal'; OPTIONS.plot_montage = 0;
hFig = figure('Units','pixels','Position', getFigureSize(42.7, 22.5));
set(hFig, 'PaperPositionMode', 'auto'); hold on;
plot_timecouse_channels(channel_file{1}, sFiles{1}, OPTIONS)

ax = nexttile([2,1]); 
set(ax,    'fontsize', OPTIONS.fontsize,  'LineWidth',OPTIONS.LineWidth);
t = title(ax, 'b. Topography - WL 830', 'FontSize',   OPTIONS.fontsize + 10);

OPTIONS.vline       = 10; OPTIONS.montage = 'WL830[tmp]';
fig_topo = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
    copyobj(allchild(get(fig_topo, 'CurrentAxes')), ax);
        view(ax, [0    1   0]);
        camup(ax, [0 0 1]);
        camlight(findobj(ax, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');

        axis(ax, 'equal')
        axis(ax, 'off')

ax.TitleHorizontalAlignment = 'left';
close(fig_topo)


saveas(hFig,fullfile(OPTIONS.output_folder, 'signal_head_avg.svg'));
close(hFig)
%% Figure 2. Figure of the averaged timecourse

sFiles{1}   = {    'sub-02/simulation_wake_task_0.25dB_left_medium/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6__WL830nm_250420_1959.mat'};
sFiles{2}   = {    'sub-02/simulation_wake_task_0.25dB_left_medium/results_NIRS_MNE_sources_|_WL830_nm_250420_2001_low_winavg_250420_2000.mat'};
sFiles{3}   = {    'sub-02/simulation_wake_task_0.25dB_left_medium/results_NIRS_wMEM__smooth=0.6_DWT(j1__2__3__4__5__6__7__8__9)__WL830nm_250420_2005_low_winavg_250420_2004.mat'};

sFiles_label                   = {'a. cMEM', 'b. MNE',  'c. wMEM'}; 


OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 10;

hFig = figure('Units','pixels','Position', getFigureSize(14.6, 22.500));
set(hFig, 'PaperPositionMode', 'auto');hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(hFig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_avg.svg'));


OPTIONS.vline       = 10;
plot_brain(SubjectName, sFiles,sFiles_label,  OPTIONS)


%% Function definition


function hFig = plot_topography(SubjectName,channel_file,  sFiles, OPTIONS)
    [hFig, iDS, iFig] =                    view_topography(sFiles, 'NIRS', '3DOptodes');

    panel_montage('SetCurrentMontage',hFig, OPTIONS.montage)
    bst_figures('SetBackgroundColor',hFig, [1 1 1])
    figure_3d('SetStandardView',hFig, {'left'});


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
        figure_3d('SetStandardView',hFig, {'left'});

        
        figure(OPTIONS.fig);
        t = tiledlayout(1,2); 
    
        ax = nexttile(); 

        copyobj(allchild(get(hFig, 'CurrentAxes')), ax);
        view(ax, [-0.0108    0.9694    0.0072]);
        camup(ax, [0.0515   -0.0093    0.9906]);
        camlight(findobj(ax, '-depth', 1, 'Tag', 'FrontLight'), 'headlight');

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
        iChannels = channel_find(sChannels.Channel, {'WL830'});
        OPTIONS.selected_channel = 'all channels';
    end

    iChannels = intersect(iChannels,iChannels_good);

    data = sData.F(iChannels, :);
    norm_factor = max(max(data(1:2:end,:)));

    data = data ./ norm_factor; 

    hold on;
    plot(ax, sData.Time, data(1:2:end,:) , 'DisplayName',[ 'WL830'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));

    xlim(OPTIONS.TimeSegment);
    ylim([-1.5 1.5]); yticks([-1 0 1])

    if isempty(sData.Events)
        sData.Events = db_template('Event');
        sData.Events.label  = 'Task';
        sData.Events.times  = [0 ; 10];
    end

    events      = sData.Events;
    tapping     =  events( strcmp( {events.label}, 'Task'));
    
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
        %t2.Position = [314.315253982301,1.5512,0];
        ax.TitleHorizontalAlignment = 'left';
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
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'simulation_medium_left')).Scouts;
    iRoi        = find(strcmpi({Scouts.Label}, 'FOV_copy.1'));

    ROI         = Scouts( iRoi );
    
       
    
    tiledlayout(length(sFiles),1)
    axes = [];
    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        sData = in_bst_results(sFile{1});     Time = sData.Time;
        HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 
        

        
        norm_factor = max(HbO);
        HbO = HbO ./ norm_factor; 
        
        

        ax1 = nexttile(); 
        set(ax1,    'fontsize', OPTIONS.fontsize,  'LineWidth',OPTIONS.LineWidth);

        hold on;
        plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - WL 830'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
        
        xlim(OPTIONS.TimeSegment);
        ylim([-1.5 1.5]); yticks([-1 0 1])
               
        title(sFiles_label{k}, 'FontSize', OPTIONS.fontsize + 10);
        ax1.TitleHorizontalAlignment = 'left'; 
        axes(end+1) = ax1;
        
        sData_head  =  in_bst_data(sData.DataFile, 'Events');
        if isempty(sData_head.Events)
            sData_head.Events = db_template('Event');
            sData_head.Events.label  = 'Task';
            sData_head.Events.times  = [0 ; 10];
        end

        events      = sData_head.Events;
        tapping     =  events( strcmp( {events.label}, 'Task'));
        
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

    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'simulation_medium_left')).Scouts;
    iRoi        = find(strcmpi({Scouts.Label}, 'FOV_copy.1'));

    if isfield(OPTIONS, 'tag')
       tag =  OPTIONS.tag;
    else
        tag = '';
    end

    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        sMap = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, sFile{1}, 'NIRS', 'NewFigure');

        panel_time('SetCurrentTime',  OPTIONS.vline)
        panel_scout('SetSelectedScouts', iRoi)
        panel_scout('SetScoutTextVisible', 0, 1);
        panel_scout('SetScoutTransparency', 1);

        bst_colormaps('SetColormapName',    'nirs', "jet");
        bst_figures('SetBackgroundColor',   sMap, [1 1 1]) 
        figure_3d('SetStandardView',        sMap, {'left'});


        hColorbar = findobj(sMap, 'Tag', 'Colorbar');
        set(hColorbar, 'XColor', [0, 0, 0], ...
                       'YColor', [0, 0, 0] );

        saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_HbO.svg',sFiles_label{k}, tag )));
        close(sMap)
    end

    % Display ROI
    sMap = view_surface(sSubject.Surface(sSubject.iCortex).FileName);
    panel_scout('SetSelectedScouts', iRoi)
    panel_scout('SetScoutTextVisible', 0, 1);

    bst_figures('SetBackgroundColor',   sMap, [1 1 1]) 
    figure_3d('SetStandardView',        sMap, {'left'});

    saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_HbO.svg','Ground_truth', tag )));
    close(sMap)


end