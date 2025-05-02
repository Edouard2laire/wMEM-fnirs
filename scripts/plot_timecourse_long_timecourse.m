
SubjectName   = {'sub-01'};


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




%% Figure 1 and 2. Figure of the entire signal. 
sFilesGRP       = {};

sFiles{1} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_MNE_sources__|_HbO_250412_1656.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_MNE_sources__|_HbR_250412_1656.mat'};
sFiles{2} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_cMEM__timewindow__5_to_1123.2s__smooth=0.6___HbO_250412_1649.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_cMEM__timewindow__5_to_1123.2s__smooth=0.6___HbR_250412_1649.mat'};

sFiles{3} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbO_250430_1523.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbR_250430_1523.mat'};

sFiles_label                   = {'a. MNE','b. cMEM', 'c. wMEM'}; 

OPTIONS.TimeSegment = [0 1120];
OPTIONS.title       = 'Reconstructed Timecourse in the hand knob';
fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_all.svg'));


OPTIONS.TimeSegment = [530 590];
OPTIONS.title       = 'Reconstructed Timecourse in the hand knob';
fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_zoomed.svg'));


%% Figure 2. Figure of the averaged timecourse

sFiles{1} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_MNE_sources__|_HbO_250412_1656_winavg_250430_1508.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_MNE_sources__|_HbR_250412_1656_winavg_250430_1508.mat', ...
    };

sFiles{2} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_cMEM__timewindow__5_to_1123.2s__smooth=0.6___HbO_250412_1649_winavg_250430_1508.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_cMEM__timewindow__5_to_1123.2s__smooth=0.6___HbR_250412_1649_winavg_250430_1508.mat', ...
    };
    
sFiles{3} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbO_250430_1523_winavg_250430_1532.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_wMEM___smooth=0.6_DWT_j1___2___3___4___5___6___7___8___9__10_____HbR_250430_1523_winavg_250430_1532.mat', ...
    };

OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = 'Averaged Timecourse in the hand knob';
OPTIONS.vline       = 13;

fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'reconstructed_signal_cortex_avg.svg'));


OPTIONS.vline       = 13;
plot_brain(SubjectName, sFiles,sFiles_label,  OPTIONS)



%% Figure for the signal; averaged then localized
sFiles = {};

sFiles{1} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_MNE_sources__|_HbO_250414_2224.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_MNE_sources__|_HbR_250414_2224.mat', ...
    };

sFiles{2} = {...    
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6___HbO_250414_2223.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD__motioncorr_band/results_NIRS_cMEM__timewindow__-10_to_30s__smooth=0.6___HbR_250414_2223.mat'};
sFiles_label                   = {'a. MNE','b. cMEM' }; 

OPTIONS.TimeSegment = [-10 30];
OPTIONS.title       = 'Averaged Timecourse in the hand knob';
OPTIONS.vline       = 13;

fig = figure('units','normalized','outerposition',[0 0 0.35 1]); hold on;
plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS);
saveas(fig,fullfile(OPTIONS.output_folder, 'avg_then_reconstrtion_signal_cortex.svg'));

OPTIONS.tag = 'avg';
plot_brain(SubjectName, sFiles, sFiles_label,  OPTIONS)



%% Function definition

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
        hold on;
        plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));
        plot(Time, HbR , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_blue(1,:));
        
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
            rectangle('Position', [ tapping.times(1,iTapping), -1 , ...
                diff(tapping.times(:,iTapping)), 2], ...
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
        ylim([-1.2 1.2]); yticks([-1 0 1])
        
        set(gca,    'Color',[1,1,1]);
        set(gcf,    'color','w');
        set(gca,    'fontsize', OPTIONS.fontsize,'FontWeight','Bold','FontAngle','italic','LineWidth',OPTIONS.LineWidth);
        
        
    end
    linkaxes(axes,'xy')
    
    sgt = sgtitle(sprintf ('Reconstructed Timecourse in the hand knob [%d, %ds]', OPTIONS.TimeSegment(1), OPTIONS.TimeSegment(2)));
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

        saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('map_%s_%s_HbO.svg',tag, sFiles_label{k})));
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