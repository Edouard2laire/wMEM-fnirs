
%% -------------------------------------------------------------------------
% Subject #2
SubjectName = {'Subject02'};
OPTIONS = get_options(SubjectName{1});

sFiles = cell(4, 1); % 1- BOLD, 2 - cMEM, 3 - MNE, 4 - wMEM

sFiles{1} = { 'Subject02/Subj2_Nph2014_HW1_Processed_BOLD/results_volume_projection_250708_1328_ssmooth_winavg_250715_1530.mat'};

sFiles{2} = {...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250721_1733.mat', ...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250721_1733.mat'};

sFiles{3} = {...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250718_1348_low_winavg_250718_1350.mat', ...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250718_1348_low_winavg_250718_1350.mat'};

sFiles{4} = {...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1__2__3__4__5__6__7__8_____HbO_250904_0121_low_winavg_250904_1035.mat', ...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1__2__3__4__5__6__7__8_____HbR_250904_0121_low_winavg_250904_1035.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 13, 13, 13];
OPTIONS.max_colormap        = [0.02, 100, 100, 100  ];
OPTIONS.tag                 = {'HbO', 'HbR'};

OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_L_rest';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)

OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_R_rest';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)

fig = figure('Units','pixels','Position', getFigureSize(10, 15));
set(fig, 'PaperPositionMode', 'auto');

OPTIONS.TimeSegment = [-10, 30];
OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_L_rest';
OPTIONS.vline = 13;

plot_timecourse(SubjectName, sFiles, name, OPTIONS)
saveas(fig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg', SubjectName{1}, OPTIONS.ROI, 'timecourse')));

close(fig)

fig = figure('Units','pixels','Position', getFigureSize(10, 15));
set(fig, 'PaperPositionMode', 'auto');

OPTIONS.TimeSegment = [-10, 30];
OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_R_rest';
OPTIONS.vline = 13;

plot_timecourse(SubjectName, sFiles, name, OPTIONS)
saveas(fig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg', SubjectName{1}, OPTIONS.ROI, 'timecourse')));

close(fig)


%% -------------------------------------------------------------------------
% Subject #3
SubjectName     = {'Subject03'};
OPTIONS         = get_options(SubjectName{1});

sFiles = cell(4, 1); % 1- BOLD, 2 - cMEM, 3 - MNE, 4 - wMEM

sFiles{1} = {...
    'Subject03/Subj3_Nph2014_HW1_Processed_BOLD/results_volume_projection_250708_1328_ssmooth_winavg_250715_1530.mat'};


sFiles{2} = {...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250721_1446.mat', ...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250721_1446.mat'};

sFiles{3} = {...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250718_1213_low_winavg_250718_1218.mat', ...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250718_1213_low_winavg_250718_1218.mat'};

sFiles{4} = {...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1__2__3__4__5__6__7_____HbO_250903_1406_low_winavg_250903_1610.mat', ...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1__2__3__4__5__6__7_____HbR_250903_1406_low_winavg_250903_1610.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 13, 13, 13];
OPTIONS.max_colormap        = [0.02, 100, 100, 100  ];
OPTIONS.tag                 = {'HbO', 'HbR'};

OPTIONS.atlas = 'User scouts_04';
OPTIONS.ROI = 'BOLD_L_rest';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)

OPTIONS.atlas = 'User scouts_04';
OPTIONS.ROI = 'BOLD_R_rest';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)


fig = figure('Units','pixels','Position', getFigureSize(10, 15));
set(fig, 'PaperPositionMode', 'auto');

OPTIONS.TimeSegment = [-10, 30];
OPTIONS.atlas = 'User scouts_04';
OPTIONS.ROI = 'BOLD_L_rest';
OPTIONS.vline = 13;

plot_timecourse(SubjectName, sFiles, name, OPTIONS)
saveas(fig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg', SubjectName{1}, OPTIONS.ROI, 'timecourse')));

close(fig)

fig = figure('Units','pixels','Position', getFigureSize(10, 15));
set(fig, 'PaperPositionMode', 'auto');

OPTIONS.TimeSegment = [-10, 30];
OPTIONS.atlas = 'User scouts_04';
OPTIONS.ROI = 'BOLD_R_rest';
OPTIONS.vline = 13;

plot_timecourse(SubjectName, sFiles, name, OPTIONS)
saveas(fig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg', SubjectName{1}, OPTIONS.ROI, 'timecourse')));

close(fig)


%% -------------------------------------------------------------------------
% Subject #5
SubjectName = {'Subject05'};
OPTIONS         = get_options(SubjectName{1});

sFiles = cell(4, 1); % 1- BOLD, 2 - cMEM, 3 - MNE, 4 - wMEM


sFiles{1} = {...
    'Subject05/Subj5_Nph2014_HW1_Processed_BOLD/results_volume_projection_250708_1329_ssmooth_winavg_250715_1531.mat'};

sFiles{2} = {...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250903_1128.mat', ...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250903_1128.mat'};

sFiles{3} = {...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250718_1338_low_winavg_250718_1340.mat', ...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250718_1338_low_winavg_250718_1340.mat'};

sFiles{4} = {...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1__2__3__4__5__6__7__8_____HbO_250903_0034_low_winavg_250903_1043.mat', ...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j1__2__3__4__5__6__7__8_____HbR_250903_0034_low_winavg_250903_1043.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 13, 13, 13];
OPTIONS.max_colormap        = [0.02, 50, 50, 50  ];
OPTIONS.tag                 = {'HbO', 'HbR'};

OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_L_rest';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)

OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_R_rest';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)


fig = figure('Units','pixels','Position', getFigureSize(10, 15));
set(fig, 'PaperPositionMode', 'auto');

OPTIONS.TimeSegment = [-10, 30];
OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_L_rest';
OPTIONS.vline = 13;

plot_timecourse(SubjectName, sFiles, name, OPTIONS)
saveas(fig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg', SubjectName{1}, OPTIONS.ROI, 'timecourse')));

close(fig)

fig = figure('Units','pixels','Position', getFigureSize(10, 15));
set(fig, 'PaperPositionMode', 'auto');

OPTIONS.TimeSegment = [-10, 30];
OPTIONS.atlas = 'User scouts_05';
OPTIONS.ROI = 'BOLD_R_rest';
OPTIONS.vline = 13;

plot_timecourse(SubjectName, sFiles, name, OPTIONS)
saveas(fig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s.svg', SubjectName{1}, OPTIONS.ROI, 'timecourse')));

close(fig)

%% Functions definitions
function OPTIONS = get_options(SubjectName)

    OPTIONS = struct();
    OPTIONS.color_red = [215,48,39 ; ...
                 252,141,89; ...
                 254,224,144] ./ 255;
    
    
    OPTIONS.color_blue  =  [69, 117, 180 ;...
                           145, 191, 219; ...
                           224, 243, 248] ./ 255;
    OPTIONS.LineWidth   = 2.5;
    OPTIONS.fontsize    = 20;
    OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','hearing_words_subjects');
    OPTIONS.output_folder = fullfile(OPTIONS.output_folder, SubjectName);
    
    if ~exist(OPTIONS.output_folder)
        mkdir(OPTIONS.output_folder)
    end


end

function DisplayUnits = getDisplayUnit(sFile)
    

    sData = in_bst_results(sFile, 1, 'DisplayUnits');
    DisplayUnits =  sData.DisplayUnits;
    
end

function plot_brain( SubjectName, sFiles, sFiles_label, OPTIONS)

    sSubject    = bst_get('Subject',SubjectName{1});

    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name}, OPTIONS.atlas )).Scouts;
    iRoi        = find(strcmpi({Scouts.Label}, strrep(OPTIONS.ROI, ' ','')));
    assert(~isempty(iRoi));

    for k = 1:length(sFiles)
        
        sFile  = sFiles{k};

        for iMap = 1:length(sFile)

            sMap = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, sFile{iMap}, 'NIRS', 'NewFigure');
            panel_surface('SetSurfaceSmooth', sMap, 1, 0.3, 0)

            if length(sFile) > 1
               tag =  OPTIONS.tag{iMap};
            else
                tag = 'BOLD';
            end

            panel_time('SetCurrentTime',  OPTIONS.snapshot_times(k));

            panel_scout('SetSelectedScouts', iRoi)
            panel_scout('SetScoutTextVisible', 0, 1);
            panel_scout('SetScoutTransparency', 1);


            bst_colormaps('SetColormapName',      'source', "jet");
            bst_colormaps('SetMaxCustom', 'source', [], -OPTIONS.max_colormap(k), OPTIONS.max_colormap(k))


            bst_figures('SetBackgroundColor', sMap, [1 1 1]) 

            figure_3d('SetStandardView',sMap, {OPTIONS.orientation});

            hColorbar = findobj(sMap, 'Tag', 'Colorbar');
            set(hColorbar, 'XColor', [0, 0, 0], ...
                           'YColor', [0, 0, 0], ...
                           'FontSize', 25, ...
                           'Position', [470 ,   90,    15,    90]);

        
            % Create a new figure to host the copied colorbar
            % hNewFig = figure;
            % ax = axes('Parent', hNewFig); % Not really needed but ensures we have an axes
            % set(ax, 'Visible', 'off');   % Hide the dummy axes
            % 
            % Copy the colorbar into the new figure
            % newColorbar = copyobj(hColorbar, hNewFig);
            % newColorbar.Position = [ 40 , 80, 15, 90 ];
            % hNewFig.Position = [ 100 , 0 , 140, 200];
            % 
            % saveas(hNewFig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s_%s_colorbar.svg',SubjectName{1}, sFiles_label{k}, tag,  OPTIONS.orientation)));
            % 
            % set (hColorbar, 'Visible', 'off');
            % set(hColorbar.Children, 'Visible', 'off')

            saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s_%s.tiff',SubjectName{1}, sFiles_label{k}, tag,  OPTIONS.orientation)), 'tiffn');
            close(sMap); %close(hNewFig);
        end
    end
end


function  plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS)
    

    sSubject    = bst_get('Subject',SubjectName{1});
    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name}, OPTIONS.atlas )).Scouts;
    ROI         = Scouts( strcmpi({Scouts.Label},  OPTIONS.ROI));
    assert(~isempty(ROI));


    hold on;

   for k = 1:length(sFiles)
        
        sFile  = sFiles{k};
        
        if strcmpi(sFiles_label{k}, 'bold')
            sData = in_bst_results(sFile{1}, 1);     Time = sData.Time;
            HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 

            norm_factor = max(HbO);
            HbO = HbO ./ norm_factor; 
            HbR = [];
        else
            sData = in_bst_results(sFile{1}, 1);     Time = sData.Time;
            HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 
            
            sData = in_bst_results(sFile{2}, 1);
            HbR = mean(sData.ImageGridAmp(ROI.Vertices,:));
            
            norm_factor = max(HbO);
            HbO = HbO ./ norm_factor; 
            HbR = HbR ./ norm_factor; 
        end

        
        

        if ~isempty(HbR)
            plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color', OPTIONS.color_red(1 + mod(2+ k, 3),:));
            plot(Time, HbR , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color', OPTIONS.color_blue(1 + mod(2+ k, 3),:));
        else
            plot(Time, -1 * HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color', [0, 0 ,0] );
        end

        xlim(OPTIONS.TimeSegment);
        ylim([-1.5 1.5]); yticks([-1 0 1])
               
   end

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
            'FaceColor', [0.3 00.1, 0.7, 0.2] , ...
            'EdgeColor', [ 0 0 0 0]);
        
    end


    if isfield(OPTIONS, 'vline') && ~isempty(OPTIONS.vline)
        xline(OPTIONS.vline, 'Color','black','LineStyle', '--' )
    end
    
    if k == length(sFiles)
        xlabel('Time(s)');
    end
    ylabel('Amplitude');
    

    set(gca,    'Color', [1,1,1]);
    set(gcf,    'color', 'w');
    set(gca,    'fontsize', OPTIONS.fontsize, 'FontWeight','Bold', 'LineWidth', OPTIONS.LineWidth);


end
