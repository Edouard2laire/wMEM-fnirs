data  = readtable("data/metrics/metrics_simul_20cm.txt");
%data = data(data.SNR == 0.25, : );

for k = 1:size(data,1)
    if contains(data{k,'method'},'wMEM')
        data{k,'method'} = {'wMEM'};
    else
        data{k,'method'} = {'MNE'};
    end
end


S = stack(data,{'DLE','AUC','SD','correlation'}, 'NewDataVariableName','Metric');

addpath(genpath('/Users/edelaire1/Documents/software/gramm'));

g = gramm("x",S.method,'y',S.Metric,'color',S.method,'subset',S.SNR == 0.25);
g.facet_wrap(S.Metric_Indicator,'ncols',2, "scale","independent");
g.geom_jitter();
g.stat_boxplot()
g.set_names('x','Method','Column','','y','Value');
g.no_legend();
g.set_text_options("base_size",30,"font",'Times New Roman');
figure('units','normalized','outerposition',[0 0 1 1])
g.draw();
%g.export('file_name','metrics.png','file_type','png' )

