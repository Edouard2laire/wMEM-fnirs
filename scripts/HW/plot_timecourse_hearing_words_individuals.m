
%% Subject #1
OPTIONS = get_options();


SubjectName = {'Subject01'};

sFiles = cell(4, 1); % 1- BOLD, 2 - cMEM, 3 - MNE, 4 - wMEM
limites = cell(4, 1);

sFiles{1} = {...
    'Subject01/Subj1_Nph2014_HW1_Processed_BOLD/results_volume_projection_250708_1218_ssmooth_winavg_250715_1529.mat'};

sFiles{2} = {...
    'Subject01/Subj1_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250825_1252.mat', ...
    'Subject01/Subj1_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250825_1252.mat'};

sFiles{3} = {...
    'Subject01/Subj1_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250718_1153_low_winavg_250818_1125.mat', ...
    'Subject01/Subj1_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250718_1153_low_winavg_250818_1125.mat'};


sFiles{4} = {...
    'Subject01/Subj1_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j2__3__4__5__6__7_____HbO_250723_0258_low_winavg_250723_1200.mat', ...
    'Subject01/Subj1_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j2__3__4__5__6__7_____HbR_250723_0258_low_winavg_250723_1200.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 13.4, 14.4, 16.6  ];
OPTIONS.max_colormap        = [0.02, 50, 90, 35  ];
OPTIONS.tag                 = {'HbO', 'HbR'};


OPTIONS.ROI = 'BOLD_L_30';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)


OPTIONS.ROI = 'BOLD_R_30';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)



%% Subject #2

SubjectName = {'Subject02'};

sFiles = cell(4, 1); % 1- BOLD, 2 - cMEM, 3 - MNE, 4 - wMEM

sFiles{1} = {...
    'Subject02/Subj2_Nph2014_HW1_Processed_BOLD/results_volume_projection_250708_1328_ssmooth_winavg_250715_1530.mat'};

sFiles{2} = {...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250721_1733.mat', ...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250721_1733.mat'};

sFiles{3} = {...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250718_1348_low_winavg_250718_1350.mat', ...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250718_1348_low_winavg_250718_1350.mat'};

sFiles{4} = {...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j2__3__4__5__6__7_____HbO_250724_0224_low_winavg_250724_1055.mat', ...
    'Subject02/Subj2_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j2__3__4__5__6__7_____HbR_250724_0224_low_winavg_250724_1055.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 18.20, 16.30, 17  ];
OPTIONS.max_colormap        = [0.02, 50, 90, 35  ];
OPTIONS.tag                 = {'HbO', 'HbR'};


OPTIONS.ROI = 'BOLD_L_30';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)


OPTIONS.ROI = 'BOLD_R_30';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)


%% Subject #3
SubjectName = {'Subject03'};

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
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j3__4__5__6__7_____HbO_250723_1357_low_winavg_250723_1415.mat', ...
    'Subject03/Subj3_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j3__4__5__6__7_____HbR_250723_1357_low_winavg_250723_1415.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 14.20, 14.20, 14.70  ];
OPTIONS.max_colormap        = [0.02, 50, 90, 35  ];
OPTIONS.tag                 = {'HbO', 'HbR'};


OPTIONS.ROI = 'BOLD_L_30';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)


OPTIONS.ROI = 'BOLD_R_30';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)

%% Subject #5
SubjectName = {'Subject05'};

sFiles = cell(4, 1); % 1- BOLD, 2 - cMEM, 3 - MNE, 4 - wMEM


sFiles{1} = {...
    'Subject05/Subj5_Nph2014_HW1_Processed_BOLD/results_volume_projection_250708_1329_ssmooth_winavg_250715_1531.mat'};


sFiles{2} = {...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbO_250718_1648.mat', ...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_cMEM___timewindow__-10_to_30s___smooth=0.6____HbR_250718_1648.mat'};
sFiles{3} = {...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbO_250718_1338_low_winavg_250718_1340.mat', ...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_MNE_sources____HbR_250718_1338_low_winavg_250718_1340.mat'};
sFiles{4} = {...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j2__3__4__5__6__7_____HbO_250722_2100_low_winavg_250723_1220.mat', ...
    'Subject05/Subj5_Nph2014_HW1_dOD__motioncorr_band_scr/results_NIRS_wMEM___smooth=0.6_DWT_j2__3__4__5__6__7_____HbR_250722_2100_low_winavg_250723_1221.mat'};

name    = {'BOLD', 'cMEM', 'MNE', 'wMEM'};
OPTIONS.snapshot_times      = [13, 15.20, 16.90, 16.50 ];
OPTIONS.max_colormap        = [0.02, 20, 50, 15  ];
OPTIONS.tag                 = {'HbO', 'HbR'};


OPTIONS.ROI = 'BOLD_L_30';
OPTIONS.orientation = 'left';
plot_brain( SubjectName, sFiles, name, OPTIONS)


OPTIONS.ROI = 'BOLD_R_30';
OPTIONS.orientation = 'right';
plot_brain( SubjectName, sFiles, name, OPTIONS)

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
    OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','hearing_words_subjects');
    
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
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts_04')).Scouts;
    iRoi        = find(strcmpi({Scouts.Label}, strrep(OPTIONS.ROI, ' ','')));

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
            hNewFig = figure;
            ax = axes('Parent', hNewFig); % Not really needed but ensures we have an axes
            set(ax, 'Visible', 'off');   % Hide the dummy axes
            
            % Copy the colorbar into the new figure
            newColorbar = copyobj(hColorbar, hNewFig);
            newColorbar.Position = [ 40 , 80, 15, 90 ];
            hNewFig.Position = [ 100 , 0 , 140, 200];

            saveas(hNewFig, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s_%s_colorbar.svg',SubjectName{1}, sFiles_label{k}, tag,  OPTIONS.orientation)));
            
            set (hColorbar, 'Visible', 'off');
            set(hColorbar.Children, 'Visible', 'off')
            saveas(sMap, fullfile(OPTIONS.output_folder, sprintf('%s_%s_%s_%s.svg',SubjectName{1}, sFiles_label{k}, tag,  OPTIONS.orientation)));

            close(sMap); close(hNewFig);
        end
    end
end
