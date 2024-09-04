%% Input definition
sFilesGRP       = {};

SubjectName   = {'sub-01'};

sFilesGRP{1}  = {...
    'sub-01/sub-01_task-tapping_run-01_dOD_band_scr_copy/results_NIRS_cMEM_|_timewindow:_-10_to_35s_|_smooth=0.6_|_HbO_240722_1928.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD_band_scr_copy/results_NIRS_cMEM_|_timewindow:_-10_to_35s_|_smooth=0.6_|_HbR_240722_1928.mat'};

sFilesGRP{2} = {...
    'sub-01/sub-01_task-tapping_run-01_dOD_band_scr_copy/results_NIRS_wMNE_sources_-_HbO_240722_2202.mat', ...
    'sub-01/sub-01_task-tapping_run-01_dOD_band_scr_copy/results_NIRS_wMNE_sources_-_HbR_240722_2202.mat'};


ROI_label     = {'hand'};
t_snapshot                  = [13];

%% Options
fig_label                   = {'cMEM','MNE', 'wMEM(all scale)', 'wMEM (selected scale)'}; 
%fig_label                   = {'OLD','NEW'}; 

fig_ROI_label               = {'Motor'};
toi                         = [-10 30];          
y_lim                       = [-50 100]; 
colors                      = {'g','r','b'};
options.same_scale          = 1;
options.do_normalize        = 0;
options.variance = 3; % 0 = no var, 1 = spatial variance, 2 = trials variance (std error)
options.show_sleep          = 0;
options.save_colbar         = 1;
options.fig_path            = '/Users/edelaire1/Documents/Etude/04_PHD/Article/NIRSTORM/NIRSTORM_neurophotonics/figure_v9/material/fig6';
options.save_fig            = 2 ; % 0: No save, 1 save Time course, 2 Save Time-course anad Figure, 3, save only figure
options.save_fig_method     = 'saveas'; % 'saveas', 'export_fig'
options.export_fig_dpi      = 90;

LineWidth = 2.5;
fontsize  = 20;

%% Code 

sSubject    = bst_get('Subject',SubjectName{1});
sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'scout_hand')).Scouts;

h = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
hold on;
norm_factor = 1;
idx_subplot = 1;
color_red = autumn(10);
color_red = color_red(1:3:10,:);

color_blue =  parula(10);
color_blue = color_blue(1:3:10,:);

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
            std_mem_hbo = [];
            std_mem_hbr = [];
        end

        stdshade_group(mem_hbo,0.25,color_red(k,:) ,time,[], std_mem_hbo);
        stdshade_group(mem_hbr,0.25,color_blue(k,:) ,time,[],std_mem_hbr);
        
        ylim(y_lim) 
        y_lim_rec = ylim(gca);
        if 0 && ~isempty(motion)               
            for i_motion = 1:size(motion.times,2)
                %rectangle('Position',[motion.times(1,i_motion), y_lim_rec(1) , motion.times(2,i_motion) - motion.times(1,i_motion),diff(y_lim_rec)],'FaceColor',[1 0 0 0.2],'LineStyle','none')
                plot(motion.times(:,i_motion)', -0.3*[1,1],'dr-','LineWidth',LineWidth);
            end
        end
        if ~isempty(Seizure)   
            for i_Seizure = 1:size(Seizure.times,2)
                plot(Seizure.times(:,i_Seizure)', -0.2*[1,1],'db-','LineWidth',LineWidth);
                %rectangle('Position',[Seizure.times(1,i_Seizure), y_lim_rec(1) , Seizure.times(2,i_Seizure) - Seizure.times(1,i_Seizure),diff(y_lim_rec)],'FaceColor',[0 1 0 0.2],'LineStyle','none')
            end
        end
        if options.show_sleep 
            if ~isempty(wake)   
                for i_wake = 1:size(wake.times,2)
                    plot(wake.times(:,i_wake)', -0.5*[1,1],'-','LineWidth',LineWidth,'Color',validatecolor(uint8([228,26,28])));
                    %rectangle('Position',[Seizure.times(1,i_Seizure), y_lim_rec(1) , Seizure.times(2,i_Seizure) - Seizure.times(1,i_Seizure),diff(y_lim_rec)],'FaceColor',[0 1 0 0.2],'LineStyle','none')
                end
            end
            if ~isempty(N1)   
                for i_wake = 1:size(N1.times,2)
                    plot(N1.times(:,i_wake)', -0.5*[1,1],'-','LineWidth',LineWidth,'Color',validatecolor(uint8([55,126,184])));
                    %rectangle('Position',[Seizure.times(1,i_Seizure), y_lim_rec(1) , Seizure.times(2,i_Seizure) - Seizure.times(1,i_Seizure),diff(y_lim_rec)],'FaceColor',[0 1 0 0.2],'LineStyle','none')
                end
            end
            if ~isempty(N2)   
                for i_wake = 1:size(N2.times,2)
                    plot(N2.times(:,i_wake)', -0.5*[1,1],'-','LineWidth',LineWidth,'Color',validatecolor(uint8([77,175,74])));
                    %rectangle('Position',[Seizure.times(1,i_Seizure), y_lim_rec(1) , Seizure.times(2,i_Seizure) - Seizure.times(1,i_Seizure),diff(y_lim_rec)],'FaceColor',[0 1 0 0.2],'LineStyle','none')
                end
            end
            if ~isempty(N3)   
                for i_wake = 1:size(N3.times,2)
                    plot(N3.times(:,i_wake)', -0.5*[1,1],'-','LineWidth',LineWidth,'Color',validatecolor(uint8([152,78,163])));
                    %rectangle('Position',[Seizure.times(1,i_Seizure), y_lim_rec(1) , Seizure.times(2,i_Seizure) - Seizure.times(1,i_Seizure),diff(y_lim_rec)],'FaceColor',[0 1 0 0.2],'LineStyle','none')
                end
            end
        end
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
        plot(time, zeros(1,length(time)), 'k--');
        
       for kl=1:length(t_snapshot)
            line([t_snapshot(kl) t_snapshot(kl)], ylim(gca))
       end   
       line([ 0 0 ], ylim(gca),'Color','black','LineStyle', '--' )
    end 
end


if options.save_fig == 1 || options.save_fig == 2 
    nst_save_figure(sprintf('%s/%s_%s.png',options.fig_path,SubjectName{:},'timecourse'), options, h)
end
for k = 1:length(sFilesGRP)
    sFiles= sFilesGRP{k};

    hHbO = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, ...
                                     sFiles{1}, 'NIRS', 'NewFigure');
                                 
    hHbR = view_surface_data(sSubject.Surface(sSubject.iCortex).FileName, ...
                                      sFiles{2}, 'NIRS', 'NewFigure');
                                 
    hFigSurfData{k} = {hHbO, hHbR};
end

if options.save_fig == 2 || options.save_fig == 3 

    
    input('Make figure ready HbO') 

    for k = 1:length(t_snapshot)

        panel_time('SetCurrentTime',  t_snapshot(k))

        for i_file = 1:length(sFilesGRP)
            tmp = hFigSurfData{i_file}; 
            out_figure_image(tmp{1}, sprintf('%s/3_%s_%s_%s_%ds_focus.png',options.fig_path,SubjectName{:},fig_label{i_file},'HbO',t_snapshot(k)))
        end
    end

    input('Make figure ready HbR') 

    for k = 1:length(t_snapshot)

        panel_time('SetCurrentTime',  t_snapshot(k))

        for i_file = 1:length(sFilesGRP)
            tmp = hFigSurfData{i_file}; 
            out_figure_image(tmp{2}, sprintf('%s/3_%s_%s_%s_%ds_focus.png',options.fig_path,SubjectName{:},fig_label{i_file},'HbR',t_snapshot(k)))
        end
    end
    

end
