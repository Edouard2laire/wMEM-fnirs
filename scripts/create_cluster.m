


sChannels   = {'sub-02/sub-02_task-rest_run-01_pipeline-preproc_Hb/channel_nirsbrs.mat'};
SCI_file    = {'sub-02/sub-02_task-rest_run-01_pipeline-preproc_Hb/data_sci_250401_1239.mat'};

sChannels = in_bst_channel(sChannels{1}); 

regions = struct('name', '', 'detectors', {} , 'proximity', {}, 'idx', []);
regions(1).name = 'temportalright';
regions(1).sources = {'S1', 'S2','S3'};
regions(1).proximity  = {'D17', 'D19','D20'};

regions(2).name = 'temportalleft';
regions(2).sources = { 'S5', 'S6','S7'};
regions(2).proximity  = {'D17', 'D20'};

nChoose = 8;

Hem = 'HbO';

for iRegion = 1:length(regions)

    idx = contains( {sChannels.Channel.Name}, regions(iRegion).sources) & ...
         ~ contains( {sChannels.Channel.Name}, regions(iRegion).proximity)  & ...
         contains( {sChannels.Channel.Name}, Hem);

    regions(iRegion).idx =    find(idx);
end


sSCI = in_bst_data(SCI_file{1}); 
new_cluster = repmat(struct('Sensors',{}, 'Label', '', 'Color', [1 0.843 0], 'Function','Mean'), 1, length(regions));


for iRegion = 1:length(regions)

    
    channels_list = {sChannels.Channel(regions(iRegion).idx).Name};
    SCI           =  abs(sSCI.F(regions(iRegion).idx));

    [~,I] = sort(SCI, 'descend');


    I = I(1:  min( 25, length(I)));
    
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    ax = axes();

    set(f,'CurrentAxes',ax);


    stem(1:length(I), SCI(I) , 'filled');
    xticklabels(    channels_list(I))
    xticks(1:length(I))
    
    yline(0.98*SCI(I(min(length(I), nChoose))) , 'r--','LineWidth',2);
    xline(min(length(I), nChoose) + 0.5, 'r--','LineWidth',2);

    ylabel('SCI (%)')
    xlabel('Channels');

    set(ax,...
                'FontName','Times',...
                'FontAngle','Italic',...
                'FontSize',20);

    title(regions(iRegion).name)

    disp('Channels selection : ')
    disp(fprintf(' Name: %s_hem-%s_res-%d',regions(iRegion).name, Hem, min(length(I), nChoose)))
    disp(strjoin(channels_list(I(1:min(length(I), nChoose))), ' ,'));


    new_cluster(iRegion).Sensors = channels_list(I(1:min(length(I), nChoose)));
    new_cluster(iRegion).Label = sprintf('%s_hem-%s_res-%d', regions(iRegion).name, Hem, min(length(I), nChoose));
    new_cluster(iRegion).Color  = [1 0.843 0];
    new_cluster(iRegion).Function  = 'Mean';

end


