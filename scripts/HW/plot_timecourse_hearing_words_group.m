SubjectName   = {'Group_analysis'};


%% Figure 1. 1. Figure of the averaged BOLD

sFiles      = {};
sFiles{1}   = {'Group_analysis/@intra/results_average_250729_1710.mat'};

OPTIONS     = get_options();
OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 16.5;
OPTIONS.norm_factor = 1/100;

OPTIONS.ROI = 'group_BOLD_left';
sFiles_label                   = {'a. BOLD | left'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_BOLD_left_cortex_avg.svg'));


OPTIONS.ROI = 'group_BOLD_right';
sFiles_label                   = {'b. BOLD | right'}; 

fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_BOLD_right_cortex_avg.svg'));


OPTIONS.orientation = 'left';
OPTIONS.ROI = 'group_BOLD_left';
plot_brain(SubjectName, sFiles, sFiles_label,  OPTIONS)


OPTIONS.orientation = 'right';
OPTIONS.ROI = 'group_BOLD_right';
plot_brain(SubjectName, sFiles, sFiles_label,  OPTIONS)

%% Figure 1.3 Figure of the averaged cMEM

sFiles{1} = {...
    'Group_analysis/@intra/results_average_250729_1723.mat', ...
    'Group_analysis/@intra/results_average_250729_1726.mat'};

OPTIONS     = get_options();
OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 16.5;

OPTIONS.ROI = 'group_cMEM_left';
sFiles_label                   = {'a. left'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
OPTIONS.norm_factor = plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cMEM_left_cortex_avg.svg'));


OPTIONS.ROI = 'group_cMEM_right';
sFiles_label                   = {'b. right'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cMEM_right_cortex_avg.svg'));


OPTIONS.orientation = 'left';
OPTIONS.ROI = 'group_cMEM_left';
OPTIONS.tag = {'HbO', 'HbR'};
plot_brain(SubjectName, sFiles, {'cMEM'},  OPTIONS)


OPTIONS.orientation = 'right';
OPTIONS.ROI = 'group_cMEM_right';
OPTIONS.tag = {'HbO', 'HbR'};
plot_brain(SubjectName, sFiles, {'cMEM'},  OPTIONS)


%% Figure 1.4 Figure of the averaged MNE

sFiles{1} = {...
    'Group_analysis/@intra/results_average_250731_1457.mat', ...
    'Group_analysis/@intra/results_average_250731_1458.mat'};

OPTIONS     = get_options();
OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 16.5;

OPTIONS.ROI = 'group_MNE_left';
sFiles_label                   = {'a. left'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
OPTIONS.norm_factor = plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_MNE_left_cortex_avg.svg'));


OPTIONS.ROI = 'group_MNE_right';
sFiles_label                   = {'b. right'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_MNE_right_cortex_avg.svg'));


OPTIONS.orientation = 'left';
OPTIONS.ROI = 'group_MNE_left';
OPTIONS.tag = {'HbO', 'HbR'};
plot_brain(SubjectName, sFiles, {'MNE'},  OPTIONS)


OPTIONS.orientation = 'right';
OPTIONS.ROI = 'group_MNE_right';
OPTIONS.tag = {'HbO', 'HbR'};
plot_brain(SubjectName, sFiles, {'MNE'},  OPTIONS)

%% Figure 1.5 Figure of the averaged wMEM

sFiles{1} = {...
    'Group_analysis/@intra/results_average_250729_1703.mat', ...
    'Group_analysis/@intra/results_average_250729_1704.mat'};


OPTIONS     = get_options();
OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = '';
OPTIONS.vline       = 16.5;

OPTIONS.ROI = 'group_wMEM_left';
sFiles_label                   = {'a. left'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
OPTIONS.norm_factor = plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_wMEM_left_cortex_avg.svg'));


OPTIONS.ROI = 'group_wMEM_right';
sFiles_label                   = {'b. right'}; 
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_wMEM_right_cortex_avg.svg'));


OPTIONS.orientation = 'left';
OPTIONS.ROI = 'group_wMEM_left';
OPTIONS.tag = {'HbO', 'HbR'};
plot_brain(SubjectName, sFiles, {'wMEM'},  OPTIONS)


OPTIONS.orientation = 'right';
OPTIONS.ROI = 'group_wMEM_right';
OPTIONS.tag = {'HbO', 'HbR'};
plot_brain(SubjectName, sFiles, {'wMEM'},  OPTIONS)



%% Functions definitions

function OPTIONS = get_options()

    OPTIONS = struct();
    OPTIONS.color_red = [215,48,39 ; ...
                 252,141,89; ...
                 254,224,144] ./ 255;
    
    
    OPTIONS.color_blue  =  [69, 117, 180 ;...
                           145, 191, 219; ...
                           224, 243, 248] ./ 255;
    OPTIONS.LineWidth   = 2.5;
    OPTIONS.fontsize    = 20;
    OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','hearing_words_group');
    
    if ~exist(OPTIONS.output_folder)
        mkdir(OPTIONS.output_folder)
    end


end

function DisplayUnits = getDisplayUnit(sFile)
    

    sData = in_bst_results(sFile, 1, 'DisplayUnits');
    DisplayUnits =  sData.DisplayUnits;
    
end


function  norm_factor = plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS)
    

    sSubject    = bst_get('Subject',SubjectName{1});
    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts')).Scouts;
    ROI         = Scouts( strcmpi({Scouts.Label}, OPTIONS.ROI));
    
    assert(~isempty(ROI))
    
    tiledlayout(length(sFiles),1)
    axes = [];
    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        sData = in_bst_results(sFile{1});     Time = sData.Time;
        HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 
        
        if isfield(OPTIONS, 'norm_factor') && ~isempty(OPTIONS.norm_factor)
            norm_factor = OPTIONS.norm_factor;
        else
            norm_factor = max(HbO); 
        end

        HbO = HbO ./ norm_factor; 

        if length(sFile) >= 2
            sData = in_bst_results(sFile{2});
            HbR = mean(sData.ImageGridAmp(ROI.Vertices,:));
            HbR = HbR ./ norm_factor; 
        else
            HbR = [];
        end
        
        

        ax1 = nexttile(); 
        hold on;
        plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
        if ~isempty(HbR)
            plot(Time, HbR , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));
        end

        xlim(OPTIONS.TimeSegment);
        ylim([-1.5 1.5]); yticks([-1 0 1])
               
        title(sFiles_label{k})
        ax1.TitleHorizontalAlignment = 'left'; 
        axes(end+1) = ax1;
        

        if isfield(sData, 'DataFile') && ~isempty(sData.DataFile)
            sData_head  =  in_bst_data(sData.DataFile, 'Events');
        else
            sData_head  =  struct('Events', []);
        end

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
        yline(0, 'Color','black','LineStyle', '--' );

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

    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts')).Scouts;
    iRoi        = find(strcmpi({Scouts.Label}, strrep(OPTIONS.ROI, ' ','')));

    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};

        for iMap = 1:length(sFile)

            sMap = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, sFile{iMap}, 'NIRS', 'NewFigure');
            panel_surface('SetSurfaceSmooth', sMap, 1, 0.3, 0)
            if isfield(OPTIONS, 'tag')
               tag =  OPTIONS.tag{iMap};
            else
                tag = getDisplayUnit(sFile{iMap});
            end

            panel_time('SetCurrentTime',  OPTIONS.vline);
            panel_scout('SetSelectedScouts', iRoi)
    
            panel_scout('SetScoutTextVisible', 0, 1);
            panel_scout('SetScoutTransparency', 1);
            bst_colormaps('SetColormapName',      'nirs', "jet");
            bst_figures('SetBackgroundColor', sMap, [1 1 1]) 
            figure_3d('SetStandardView',sMap, {OPTIONS.orientation});
    
            hColorbar = findobj(sMap, 'Tag', 'Colorbar');
            set(hColorbar, 'XColor', [0, 0, 0], ...
                           'YColor', [0, 0, 0] );
    
            saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg',sFiles_label{k}, tag,  OPTIONS.orientation)));
            close(sMap)
        end
    end
end
