%% This make plot for the simulations maps
SubjectName   = {'sub-02'};


OPTIONS = struct();
OPTIONS.color_red = [215,48,39 ; ...
             252,141,89; ...
             254,224,144] ./ 255;


OPTIONS.color_blue =  [69,117,180 ;...
                      145,191,219; ...
                      224,243,248] ./ 255;
OPTIONS.LineWidth = 2.5;
OPTIONS.fontsize  = 20;
OPTIONS.output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','Simulation','oscilation');

simulation_type       = 'osc';
SNR                   = 0.25;

sFiles = bst_process('CallProcess', 'process_select_search', [], [], ...
    'search', [ '(( [name CONTAINS "simul |"] ', ....
                'AND', ....
                sprintf('[parent EQUALS "simulation_wake_%s_%0.2fdB_left_medium"]', simulation_type, SNR), ...
                '))' ] ...
                );
sTruth = bst_process('CallProcess', 'process_select_search', [], [], ...
    'search', [ '(( [name CONTAINS "Truth | "] ', ....
                'AND', ....
                sprintf('[parent EQUALS "simulation_wake_%s_%0.2fdB_left_medium"]', simulation_type, SNR), ...
                '))' ] ...
                );
ROI_ID = 1; 
OPTIONS.ROI_ID = sprintf('FOV_copy.%d ',ROI_ID);

sFiles = sFiles( contains({sFiles.Comment}, sprintf('FOV_copy.%d ',ROI_ID)));
sTruth = sTruth( contains({sTruth.Comment}, sprintf('FOV_copy.%d ',ROI_ID)));

[sStudy, iStudy, iResults] = bst_get('ResultsForDataFile',sFiles.FileName);
ResultFiles = sStudy.Result(iResults);
ResultFiles =  ResultFiles( [ ...
                    find(contains({ResultFiles.Comment},{'Ground Truth'})) , ...
                    find(contains({ResultFiles.Comment},{'MNE'})), ...
                    find(contains({ResultFiles.Comment},{'adaptive'}))]);

%%

OPTIONS.TimeSegment = [0, 320];

fig = figure('units','normalized','outerposition',[0 0 1 1]); hold on;
plot_timecourse(SubjectName, ResultFiles, {ResultFiles.Comment}, OPTIONS)




%% Functions


function  plot_timecourse(SubjectName, sFiles, sFiles_label, OPTIONS)
    

    sSubject    = bst_get('Subject',SubjectName{1});
    sCortex     = in_tess_bst(sSubject.Surface(sSubject.iCortex).FileName);
    Scouts      = sCortex.Atlas(strcmp({sCortex.Atlas.Name},'simulation_medium_left')).Scouts;
    ROI         = Scouts( strcmpi({Scouts.Label}, strrep(OPTIONS.ROI_ID,' ','')));
    
       
    
    tiledlayout(length(sFiles),1)
    axes = [];
    for k = 1:length(sFiles)
        
        sFile  = sFiles(k);
        
        sData = in_bst_results(sFile.FileName);     Time = sData.Time;
        HbO = mean(sData.ImageGridAmp(ROI.Vertices,:)); 
 
        
        norm_factor = max(abs(HbO));
        HbO = HbO ./ norm_factor; 

        
        

        ax1 = nexttile(); 
        hold on;
        plot(Time, HbO , 'DisplayName',[ sFiles_label{k} ' - HbO'], 'LineWidth', OPTIONS.LineWidth, 'Color',OPTIONS.color_red(1,:));

        
        title(sFiles_label{k})
        ax1.TitleHorizontalAlignment = 'left'; 
        axes(end+1) = ax1;
        
        sData_head  =  in_bst_data(sData.DataFile, 'Events');
        if isempty(sData_head.Events)
            sData_head.Events = db_template('Event');
            sData_head.Events.label  = 'tapping';
            sData_head.Events.times  = [0 ; 10];
        end

        events      = sData_head.Events(1);
        if size(events.times,1) == 1
            events.times = [ events.times- 25 ; events.times+25];
        end
        
        for iTapping = 1:size(events.times,2)
            rectangle('Position', [ events.times(1,iTapping), -1 , ...
                                    diff(events.times(:,iTapping)), 2], ...
                      'FaceColor', [205./255, 208./255, 248./255, 0.3] , ...
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