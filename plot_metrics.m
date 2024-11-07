data1  = readtable("data/metrics/metrics_simul_0.25db.txt");
data2  = readtable("data/metrics/metrics_simul_1db.txt");

data = [data1; data2];
%data = data(data.SNR == 0.25, : );

for k = 1:size(data,1)
    if contains(data{k,'method'},'wMEM')
        data{k,'method'} = {'wMEM'};
    else
        data{k,'method'} = {'MNE'};
    end
end

data.rsa = data.rsa /100 ;

S = stack(data,{'rsa','SD','correlation'}, 'NewDataVariableName','Metric');

addpath(genpath('/Users/edelaire1/Documents/software/gramm'));

g = gramm("x",S.method,'y',S.Metric, 'color',S.method);
g.facet_grid(S.SNR, S.Metric_Indicator,"scale","independent");
g.geom_jitter();
g.stat_boxplot()
g.set_names('x','Method','Column','','y','Value','Row','SNR: ');
g.no_legend();
g.set_text_options("base_size",30,"font",'Times New Roman');
figure('units','normalized','outerposition',[0 0 1 1])
g.draw();
%g.export('file_name','metrics2.png','file_type','png' )

