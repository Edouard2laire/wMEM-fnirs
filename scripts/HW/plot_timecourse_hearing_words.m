
SubjectName   = {'HW1'}; %% Subject02


OPTIONS = struct();
OPTIONS.color_red = [215,48,39 ; ...
             252,141,89; ...
             254,224,144] ./ 255;


OPTIONS.color_blue  =  [69, 117, 180 ;...
                       145, 191, 219; ...
                       224, 243, 248] ./ 255;
OPTIONS.LineWidth   = 2.5;
OPTIONS.fontsize    = 20;
OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','hearing_words');

if ~exist(OPTIONS.output_folder)
    mkdir(OPTIONS.output_folder)
end

%% Part 1. Plot Recording on the scalp

channel_file = {'HW1/HW1_task_preproc_Hb_02/channel_nirsbrs.mat'};
sFiles = { 'HW1/HW1_task_preproc_Hb_02/data_hb_250507_2304.mat'};

OPTIONS.selected_channel = 'S26D25';
OPTIONS.TimeSegment      = [0 220];
if isfield(OPTIONS, 'vline')
    OPTIONS = rmfield(OPTIONS, 'vline');
end

OPTIONS.title = ''; OPTIONS.plot_montage = 1;
fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
OPTIONS.fig = fig;
plot_timecouse_channels(channel_file{1}, sFiles{1}, OPTIONS)
saveas(fig,fullfile(OPTIONS.output_folder, 'signal_head_all.svg'));
close(fig)


%% Figure 1 and 2. Figure of the entire signal. 
sFiles       = {};


sFiles{1} = {...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbO_250430_1118_low.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbR_250430_1118_low.mat'};
sFiles{2} = {...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbO_250430_1326_low.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbR_250430_1326_low.mat'};

sFiles_label                   = {'a. MNE', 'c. wMEM'}; 

OPTIONS.TimeSegment = [0 205];
OPTIONS.title       = '';
fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_all.svg'));


OPTIONS.TimeSegment = [25 60];
OPTIONS.title       = '';
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_zoomed.svg'));


%%
OPTIONS.vline       = 13; OPTIONS.montage = 'HbO[tmp]';
OPTIONS.selected_channel = 'S26D25';

fig = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'topography_avg_HbO.svg'));
close(fig)

OPTIONS.vline       = 13; OPTIONS.montage = 'HbR[tmp]';
OPTIONS.selected_channel = 'S26D25';

fig = plot_topography(SubjectName,channel_file{1}, sFiles{1}, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'topography_avg_HbR.svg'));
close(fig)

%%
channel_file = {'HW1/HW1_task_preproc_Hb_02/channel_nirsbrs.mat'};
sFiles = { 'HW1/HW1_task_preproc_Hb_02/data_hb_250505_1217.mat'};
OPTIONS.selected_channel = 'S26D25';
OPTIONS.TimeSegment = [-10 30];
OPTIONS.title = 'Averaged signal'; OPTIONS.plot_montage = 0;
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecouse_channels(channel_file{1}, sFiles{1}, OPTIONS)
saveas(fig,fullfile(OPTIONS.output_folder, 'signal_head_avg.svg'));
close(fig)


%% Figure 2. Figure of the averaged timecourse
sFilesGRP       = {};
sFiles{1} = {...
    'HW1/HW1_task_preproc/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6___HbO_250430_1543.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6___HbR_250430_1543.mat'};

sFiles{2} = {...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbO_250430_1118_low_winavg_250430_1333.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbR_250430_1118_low_winavg_250430_1333.mat'};



sFiles{3} = {...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbO_250430_1326_low_winavg_250430_1333.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbR_250430_1326_low_winavg_250430_1333.mat'};

sFiles_label                   = {'a. cMEM', 'b. MNE','c. wMEM'}; 


OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 13;

fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_avg.svg'));


OPTIONS.vline       = 13;
plot_brain(SubjectName, sFiles,sFiles_label,  OPTIONS)


%% Function definition


function hFig = plot_topography(SubjectName,channel_file,  sFiles, OPTIONS)
    [hFig, iDS, iFig] = view_topography(sFiles , 'NIRS', '3DSensorCap');
    
    panel_montage('SetCurrentMontage',hFig, OPTIONS.montage)
    bst_figures('SetBackgroundColor',hFig, [1 1 1])
    figure_3d('SetStandardView',hFig, {'left'});
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

        t1 = title(ax, 'a. Montage');
        ax.TitleHorizontalAlignment = 'left';
        set(ax,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);
        close(hFig)
        
        ax = nexttile(); 
    
    else
        t = tiledlayout(3,1); 
        ax = nexttile([3 1]); 
    end

    sData = in_bst_data(sFile);
    iChannels_good = good_channel(sChannels.Channel, sData.ChannelFlag, 'nirs');
    iChannels = channel_find(sChannels.Channel, {OPTIONS.selected_channel});
    iChannels = intersect(iChannels,iChannels_good);

    data = sData.F(iChannels, :);
    norm_factor = max(data(1,:));

    data = data ./ norm_factor; 

    hold on;
    plot(ax, sData.Time, data(1,:) , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
    plot(ax, sData.Time, data(2,:) , 'DisplayName',[ 'HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));

    xlim(OPTIONS.TimeSegment);
    ylim([-1.5 1.5]); yticks([-1 0 1])

    if isempty(sData.Events)
        sData.Events = db_template('Event');
        sData.Events.label  = 'task';
        sData.Events.times  = [0 ; 16];
    end

    events      = sData.Events;
    tapping     =  events( strcmp( {events.label}, 'task'));
    
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
        t2 = title(ax, sprintf('b. Recording for %s',OPTIONS.selected_channel));

        % HACK
        t2.Position(2) = t2.Position(2) + 0.02;
    else
        t2 = title(ax, sprintf('a. Recording for %s',OPTIONS.selected_channel));
    end
    
    ax.TitleHorizontalAlignment = 'left';
    set(ax,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);


    if OPTIONS.plot_montage && ~isempty(OPTIONS.title)
        sgt = title(t, sprintf ('%s [%d, %ds]',OPTIONS.title , OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)));
        sgt.FontSize = 40; sgt.FontWeight = 'Bold';
    end

    set(gca,    'Color',[1,1,1]);
    set(gcf,    'color','w');
    set(gca,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold', 'LineWidth',OPTIONS.LineWidth);

end


function  plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS)
    

    sSubject    = bst_get('Subject',SubjectName{1});
    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts')).Scouts;
    ROI         = Scouts( strcmpi({Scouts.Label}, 'ROI'));
    
       
    
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
            sData_head.Events.label  = 'task';
            sData_head.Events.times  = [0 ; 16];
        end

        events      = sData_head.Events;
        tapping     =  events( strcmp( {events.label}, 'task'));
        
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
        set(gca,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold','FontAngle','italic','LineWidth',OPTIONS.LineWidth);
        
        
    end
    linkaxes(axes,'xy')
    
    if ~isempty(OPTIONS.title )
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
        figure_3d('SetStandardView',sMap, {'left'});

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
        figure_3d('SetStandardView',sMap, {'left'});


        hColorbar = findobj(sMap, 'Tag', 'Colorbar');
        set(hColorbar, 'XColor', [0, 0, 0, 1], ...
                       'YColor', [0, 0, 0, 1] );

        saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_HbR.svg',sFiles_label{k}, tag )));
        close(sMap)


    end
end