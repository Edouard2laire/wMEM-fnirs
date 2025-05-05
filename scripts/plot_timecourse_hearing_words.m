
SubjectName   = {'HW1'};


OPTIONS = struct();
OPTIONS.color_red = [215,48,39 ; ...
             252,141,89; ...
             254,224,144] ./ 255;


OPTIONS.color_blue =  [69,117,180 ;...
                      145,191,219; ...
                      224,243,248] ./ 255;
OPTIONS.LineWidth = 2.5;
OPTIONS.fontsize  = 20;
OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','hearing_words');

if ~exist(OPTIONS.output_folder)
    mkdir(OPTIONS.output_folder )
end

%% Figure 1 and 2. Figure of the entire signal. 
sFiles       = {};


sFiles{1} = {...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbO_250430_1118.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbR_250430_1118.mat'};

sFiles{2} = {...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbO_250430_1326.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbR_250430_1326.mat'};

sFiles_label                   = {'a. MNE', 'c. wMEM'}; 

OPTIONS.TimeSegment = [0 220];
OPTIONS.title       = 'Reconstructed Timecourse';
fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_all.svg'));


OPTIONS.TimeSegment = [110 140];
OPTIONS.title       = 'Reconstructed Timecourse';
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_zoomed.svg'));


%% Figure 2. Figure of the averaged timecourse
sFilesGRP       = {};

sFiles{1} = {...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbO_250430_1118_low_winavg_250430_1333.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_MNE_sources____HbR_250430_1118_low_winavg_250430_1333.mat'};


sFiles{2} = {...
    'HW1/HW1_task_preproc/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6___HbO_250430_1543.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6___HbR_250430_1543.mat'};

sFiles{3} = {...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbO_250430_1326_low_winavg_250430_1333.mat', ...
    'HW1/HW1_task_preproc/results_NIRS_wMEM__smooth=0.6_DWT(j3__4__5__6__7__8__9)___HbR_250430_1326_low_winavg_250430_1333.mat'};

sFiles_label                   = {'a. MNE','b. cMEM', 'c. wMEM'}; 


OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = 'Averaged Timecourse';
OPTIONS.vline       = 13;

fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_avg.svg'));


OPTIONS.vline       = 13;
plot_brain(SubjectName, sFiles,sFiles_label,  OPTIONS)


%% Function definition

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
        
        xlim(OPTIONS.TimeSegment);
        ylim([-1.5 1.5]); yticks([-1 0 1])
        
        set(gca,    'Color',[1,1,1]);
        set(gcf,    'color','w');
        set(gca,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold','FontAngle','italic','LineWidth',OPTIONS.LineWidth);
        
        
    end
    linkaxes(axes,'xy')
    
    sgt = sgtitle(sprintf ('%s [%d, %ds]',OPTIONS.title , OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)));
    sgt.FontSize = 25; sgt.FontWeight = 'Bold';


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