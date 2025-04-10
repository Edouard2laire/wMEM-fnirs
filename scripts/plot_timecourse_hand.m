%% Input definition
sFilesGRP       = {};

SubjectName   = {'sub-01'};

% sFilesGRP{1}  = {...
%     'sub-01/sub-01_task-tapping_run-01_pipeline-strict/results_NIRS_cMEM_|_timewindow:_-10_to_35s_|_smooth=0.6_|_HbO_240903_1402.mat', ...
%     'sub-01/sub-01_task-tapping_run-01_pipeline-strict/results_NIRS_cMEM_|_timewindow:_-10_to_35s_|_smooth=0.6_|_HbR_240903_1402.mat'};


% sFilesGRP{2} = {...
%     'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_cMEM_|_timewindow:_-10_to_35s_|_smooth=0.6_|_HbO_240903_1404.mat', ...
%     'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_cMEM_|_timewindow:_-10_to_35s_|_smooth=0.6_|_HbR_240903_1404.mat'};

sFilesGRP{1} = {...
    'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_wMNE_sources_-_HbO_240903_1406_WAvg.mat', ...
    'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_wMNE_sources_-_HbR_240903_1406_WAvg.mat'};

sFilesGRP{2} = {...
    'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_wMEM_|_smooth=0.6_DWT(j3__4__5__6__7__8__9)_|_HbO_240903_1415_WAvg.mat', ...
    'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_wMEM_|_smooth=0.6_DWT(j3__4__5__6__7__8__9)_|_HbR_240903_1416_WAvg.mat'};


sFilesGRP{3} = {...
    'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_wMEM_|_smooth=0.6_DWT(j6__7__8__9)_|_HbO_240903_1419_WAvg.mat', ...
    'sub-01/sub-01_task-tapping_run-01_pipeline-liberal/results_NIRS_wMEM_|_smooth=0.6_DWT(j6__7__8__9)_|_HbR_240903_1419_WAvg.mat'};



ROI_label     = {'hand'};
t_snapshot                  = [13];

%% Options
fig_label                   = {'cMEM (filter)', 'cMEM','MNE', 'wMEM(all scale)', 'wMEM (selected scale)'}; 
%fig_label                   = {'OLD','NEW'}; 

fig_ROI_label               = {'Motor'};
toi                         = [-10 30];          
y_lim                       = [-50 100]; 
colors                      = {'g','r','b'};
options.same_scale          = 1;
options.do_normalize        = 0;
options.variance            = 0; % 0 = no var, 1 = spatial variance, 2 = trials variance (std error)
options.save_colbar         = 1;
options.fig_path            = '/Users/edelaire1/Documents/Etude/04_PHD/Abstract/2024_fNIRS_UK/figure_tapping';
options.save_fig            = 1 ; % 0: No save, 1 save Time course, 2 Save Time-course anad Figure, 3, save only figure
options.save_fig_method     = 'saveas'; % 'saveas', 'export_fig'
options.export_fig_dpi      = 90;

LineWidth = 2.5;
fontsize  = 20;

%% Code 

sSubject    = bst_get('Subject',SubjectName{1});
sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'User scouts')).Scouts;

h = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
hold on;
norm_factor = 1;
idx_subplot = 1;



color_red = [215,48,39 ; ...
             252,141,89; ...
             254,224,144] ./ 255;


color_blue =  [69,117,180 ;...
               145,191,219; ...
                224,243,248] ./ 255;

for k = 1:length(sFilesGRP)
    
    sFiles  = sFilesGRP{k};
    if options.do_normalize 
        if (k == 1 || ~options.same_scale) 
            HbO = in_bst_data(sFiles{1});
            HbR = in_bst_data(sFiles{2});
    
            idx = panel_time('GetTimeIndices', HbO.Time, [-10 30]);
    
            norm_factor = max(max(abs(HbO.ImageGridAmp(:,idx) + HbR.ImageGridAmp(:,idx))));
            disp(sprintf('Norm factor %.2f, mult factor:%.2f', norm_factor, 1/norm_factor))
        end
         
        sFiles = bst_process('CallProcess', 'process_scale', sFiles, [], ...
                'factor',    1/norm_factor, ...
                'overwrite', 0);
        sFilesGRP{k} =  {sFiles.FileName};
        sFiles  = sFilesGRP{k};
    end

    HbO = in_bst_data(sFiles{1});
    HbR = in_bst_data(sFiles{2});  
    
    %data    =  in_bst_data(HbO.DataFile);

    %events  = data.Events;
    motion  = []; %events( strcmp( {events.label},'motion'));
    Seizure = []; %events( strcmp( {events.label},'Seizure'));
    wake    = []; %events( strcmp( {events.label},'wake'));
    N1      = []; %events( strcmp( {events.label},'N1'));
    N2      = []; %events( strcmp( {events.label},'N2'));
    N3      = []; %events( strcmp( {events.label},'N3'));

    tmp = {};
    all_ax = [];
    for i=1:length(ROI_label)
        ROIS = Scouts( strcmpi({Scouts.Label}, ROI_label{i}));

        mem_hbo = HbO.ImageGridAmp(ROIS.Vertices,:); 
        mem_hbr = HbR.ImageGridAmp(ROIS.Vertices,:);
                 
        time = HbO.Time;
        n_row = 1; % length(sFilesGRP);

        if options.variance == 1 
            std_mem_hbo = std(mem_hbo,[],1);
            %std_mem_hbr = std(mem_hbr,[],2);

        elseif options.variance == 2 

        else
            std_mem_hbo = zeros(1,length(time));
            std_mem_hbr = zeros(1,length(time));
        end

        shadedErrorBar(time, mean(mem_hbo),  std_mem_hbo,'lineProps' , {'LineWidth',LineWidth, 'Color',color_red(k,:)});
        shadedErrorBar(time, mean(mem_hbr),  std_mem_hbo,'lineProps' , {'LineWidth',LineWidth , 'Color',color_blue(k,:)});
        
            
        ylim(y_lim) 
        y_lim_rec = ylim(gca);

        %title(sprintf('%s - %s',fig_ROI_label{i}, fig_label{k}))
        
        xlim(toi);
        set(gca,'Color',[1,1,1]);
        set(gcf,'color','w');

        set(gca,'fontsize', fontsize,'FontWeight','Bold','FontAngle','italic','LineWidth',LineWidth);

        if k == length(sFilesGRP)
            xlabel('Time(s)');
        end

        if i == 1
            ylabel('Amplitude');
        end    
        plot(time, zeros(1,length(time)), 'k--','LineWidth',LineWidth);
        
       for kl=1:length(t_snapshot)
            line([t_snapshot(kl) t_snapshot(kl)], ylim(gca))
       end   
       line([ 0 0 ], ylim(gca),'Color','black','LineStyle', '--' )
    end 
end


if options.save_fig == 1 || options.save_fig == 2 
    nst_save_figure(sprintf('%s/%s_%s.png',options.fig_path,SubjectName{:},'timecourse'), options, h)
end

% 
% 
% for k = 1:length(sFilesGRP)
%     sFiles= sFilesGRP{k};
% 
%     hHbO = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, ...
%                                      sFiles{1}, 'NIRS', 'NewFigure');
% 
%     hHbR = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, ...
%                                       sFiles{2}, 'NIRS', 'NewFigure');
% 
%     hFigSurfData{k} = {hHbO, hHbR};
% end
% 
% if options.save_fig == 2 || options.save_fig == 3 
% 
% 
%     input('Make figure ready HbO') 
% 
%     for k = 1:length(t_snapshot)
% 
%         panel_time('SetCurrentTime',  t_snapshot(k))
% 
%         for i_file = 1:length(sFilesGRP)
%             tmp = hFigSurfData{i_file}; 
%             out_figure_image(tmp{1}, sprintf('%s/3_%s_%s_%s_%ds_focus.png',options.fig_path,SubjectName{:},fig_label{i_file},'HbO',t_snapshot(k)))
%         end
%     end
% 
%     input('Make figure ready HbR') 
% 
%     for k = 1:length(t_snapshot)
% 
%         panel_time('SetCurrentTime',  t_snapshot(k))
% 
%         for i_file = 1:length(sFilesGRP)
%             tmp = hFigSurfData{i_file}; 
%             out_figure_image(tmp{2}, sprintf('%s/3_%s_%s_%s_%ds_focus.png',options.fig_path,SubjectName{:},fig_label{i_file},'HbR',t_snapshot(k)))
%         end
%     end
% 
% 
% end
