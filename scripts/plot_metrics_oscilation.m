addpath(genpath('/Users/edelaire1/Documents/software/gramm-master'));

output_folder = fullfile('/Users/edelaire1/Documents/Project/wMEM-fnirs/Figure','Simulation','oscilation');
if ~exist(output_folder)
    mkdir(output_folder)
end


%%  Analyze MNE results


data1 = read_metrics(fullfile('data','metrics','metrics_osc','metrics_MNE_simul-oscilations_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_osc','metrics_MNE_simul-oscilations_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_osc','metrics_MNE_simul-oscilations_0.25dB_medium.csv'));

data_MNE  = [data1 ; data2; data3];
data_MNE.label = repmat({'MNE'}, height(data_MNE), 1);

data1 = read_metrics(fullfile('data','metrics','metrics_osc','metrics_wMEM_simul-oscilations_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_osc','metrics_wMEM_simul-oscilations_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_osc','metrics_wMEM_simul-oscilations_0.25dB_medium.csv'));

data_wMEM = [data1 ; data2; data3];
data_wMEM_select =  extract_data(data_wMEM,  @(data) strcmp(data.wavelet_scale_method,'adaptive'));
data_wMEM_select.label = repmat({'wMEM'}, height(data_wMEM_select), 1);

data_all = [data_MNE ; data_wMEM_select];

%%
fig = figure('units','normalized','outerposition',[0 0 1 1]);
clear g

g(1,1) = plot_boxplot(data_all, {'DLE'},  'snr'); g(1,1).set_title('DLE (mm)');
g(1,2) = plot_boxplot(data_all, {'SD'},  'snr'); g(1,2).set_title('SD (mm)');
g(1,3) = plot_boxplot(data_all, {'correlation'},  'snr'); g(1,3).set_title('Correlation (%)');


data_all_select =  extract_data(data_all,  @(data) data.DLE == 0);

g(2,1) = plot_boxplot(data_all_select, {'DLE'},  'snr');            g(2,1).set_title('DLE (mm)');
g(2,2) = plot_boxplot(data_all_select, { 'SD'},  'snr');            g(2,2).set_title('SD (mm)');
g(2,3) = plot_boxplot(data_all_select, { 'correlation'},  'snr');   g(2,3).set_title('Correlation (%)');

g(1,1).geom_hline("yintercept",   5,  "style", 'b--', 'extent', 5);
g(2,1).geom_hline("yintercept",   5,  "style", 'b--', 'extent', 5);
g(1,2).geom_hline("yintercept",  10,  "style", 'b--', 'extent', 5);
g(2,2).geom_hline("yintercept",  10,  "style", 'b--', 'extent', 5);
g(1,3).geom_hline("yintercept", 0.8,  "style", 'b--', 'extent', 5);
g(2,3).geom_hline("yintercept", 0.8,  "style", 'b--', 'extent', 5);

g.set_title('Localization of simulated oscilations')

g.draw();

g(1,1).facet_axes_handles.YLim = [0, 40]; 
g(2,1).facet_axes_handles.YLim = [0, 40];  

g(1,2).facet_axes_handles.YLim = [0, 40];  
g(2,2).facet_axes_handles.YLim = [0, 40];  

g(1,3).facet_axes_handles.YLim = [0, 1];   
g(2,3).facet_axes_handles.YLim = [0, 1];   

% Remove the background of the box
arrayfun(@(x)  arrayfun( @(y)set( y.box_handle, 'FaceAlpha', 0), x(1).results.stat_boxplot)  ,  g)


pause(1)
saveas(fig,fullfile(output_folder,'main_comparison_oscilation.svg'));




%% Display AUC and ROC information

figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_all, {'auc_mean','sensitivity_30','specificity_30','ppv_30','npv_30'}, 'snr');
g.axe_property('YLim',[0, 1]);
g.draw();

arrayfun(@(x)  arrayfun( @(y)set( y.box_handle, 'FaceAlpha', 0), x(1).results.stat_boxplot)  ,  g)


%% Generate 2D plot



figure('Position',[100 100 550 550]);
g = plot_2D_scatterplot(data_all.DLE, data_all.SD, 'DLE (mm)', 'SD (mm)',  categorical(data_all.label), data_all.roi_idx, data_all.DLE >= 0,data_all.snr);
g = g.draw();

addlistener( g(2).facet_axes_handles, 'XLim', 'PostSet', @(src,evt) set(g(1).facet_axes_handles, 'XLim', get(g(2).facet_axes_handles, 'XLim')));
addlistener( g(2).facet_axes_handles, 'YLim', 'PostSet', @(src,evt) set(g(3).facet_axes_handles, 'XLim', get(g(2).facet_axes_handles, 'YLim')));



%% Function definitions


function display_results(data)
    
    for iData = 1:height(data)


        fprintf('\t--------\n');

        data_tmp = data(iData, :);
        fprintf('Roi:\t %s\n', data_tmp.ROI{1});
        fprintf('Roi:\t %s\n', data_tmp.comment{1});


        fprintf('\t--------\n');
        fprintf('DLE:\t %.2f\n', data_tmp.DLE);
        fprintf('SD:\t %.2f\n', data_tmp.SD);
        fprintf('RSA:\t %.2f\n', data_tmp.RSA);
        fprintf('AUC close:\t %.2f\n', data_tmp.auc_close);
        fprintf('AUC far:\t %.2f\n', data_tmp.auc_far);

        fprintf('\t--------\n');

    end

end





function data = add_column(data, name, extract_fn)
    
    data.(name) = repmat(extract_fn(data(1,:)), height(data), 1);

    for iData = 1:height(data)
        data{iData, name} = extract_fn(data(iData,:));
    end

end

function label = generate_label(data)
    
    label_list = {};
    
    switch(data.method{1})

        case { 'cMNE', 'MNE' } 
            if ismember('isAvgFirst', data.Properties.VariableNames) && data.isAvgFirst
                label_list{end+1} = 'Lowpass';
                label_list{end+1} = 'Avg';
            end
            
            label_list{end+1} = 'MNE';
            
            if (ismember('isAvgFirst', data.Properties.VariableNames) && ~data.isAvgFirst) &&  (ismember('isLowPass', data.Properties.VariableNames) &&  data.isLowPass)
                label_list{end+1} = 'Lowpass';
            end

            if ~data.isAvgFirst
                label_list{end+1} = 'Avg';
            end

        case 'cMEM'
            label_list{end+1} = 'cMEM';
            label_list{end+1} = sprintf('nbo = %d', data.nbo);

        case 'wMEM'
            label_list{end+1} = 'wMEM';

            if strcmp(data.wavelet_scale{1},'3  4  5  6  7  8')
                label_list{end+1} = '0.02 - 1.25Hz';
            elseif strcmp(data.wavelet_scale{1},'6  7  8')
                label_list{end+1} = '0.02 - 0.15Hz';
            else
                label_list{end+1} = sprintf('scale = %s ', strrep(data.wavelet_scale{1},'  ', ',')) ;
            end
            label_list{end+1} = sprintf('nbo = %d', data.nbo);

            % if ~data.isAvgFirst && data.isLowPass
            %     label_list{end+1} = 'Lowpass';
            % end
    end
    
    label = string(strjoin(label_list, ' | '));

end

function data = extract_data(data,  extract_fn)
    
    idx = false(1,height(data));

    for iData = 1:height(data)

        if extract_fn(data(iData,:))
            idx(iData) = true;
        end
    end

    data = data(idx, :);

end

function name = extract_roi_name(data)
    
    input_str = data.ROI;

    % Define regex pattern to extract 'nbo = <number>'
    pattern = '\s*(\d+)';
    
    % Apply regular expression
    tokens = regexp(input_str, pattern, 'tokens');

    % Check if a match is found
    if ~isempty(tokens)
        name = str2double(tokens{1}{1});
    else
        name = 0;
    end
end

function nbo = extract_nbo(data)

    input_str = data.comment;

    % Define regex pattern to extract 'nbo = <number>'
    pattern = 'nbo\s*=\s*(\d+)';
    
    % Apply regular expression
    tokens = regexp(input_str, pattern, 'tokens');
    
    % Check if a match is found
    if ~isempty(tokens{1})
        nbo = str2double(tokens{1}{1});
    else
        nbo = 0;
    end
end


function scale = extract_scale_numbers(data)

    input_str = data.comment;

    % Define regex pattern to extract numbers in parentheses after 'j'
    pattern = 'j([\d\s]+)\)';
    
    % Apply regular expression
    tokens = regexp(input_str, pattern, 'tokens');
    
    % Check if a match is found
    if ~isempty(tokens{1})
        % Convert extracted string of numbers into an array
        scale = (tokens{1}{1}); %#ok<ST2NM>
    else
        scale = {'1'};
    end



end

function scale_method = extract_normalization(data)

    if contains(data.comment, 'norm')
        if contains(data.comment, 'fixed')
            scale_method = {'fixed'};
        else
            scale_method = {'adaptive'};
        end
    else
        scale_method = {'NA'};
    end
           
end


function g = plot_boxplot(data_MNE, metrics, color, x_split)
    
    S = stack(data_MNE, metrics, 'NewDataVariableName','Metric');


    if nargin < 3 || isempty(color)
        color = S.method;
    else
        color = S.(color);
    end

    if nargin < 4
        x_grod = [];
    else
        x_grod = S.(x_split);
    end

    
    g = gramm("x",categorical(S.label),'y', S.Metric, 'color', categorical(color), 'label', S.ROI);
    g.facet_grid(categorical(x_grod), categorical(S.Metric_Indicator),"scale","independent");
    g.geom_jitter('dodge',0.7,'alpha', 0.7);
    g.stat_boxplot();
    g.set_names('x','Method','Column','','y','Value');
    g.no_legend();
    g.set_text_options("base_size", 15, "font", 'Times New Roman');
    g.set_title(sprintf('Influence of operation order %s source localization', strjoin(unique(S.method),', ')));

end

function g = plot_2D_scatterplot(x_val, y_val,x_label, y_label,  color, label, subset, group)

    g(1,1)= gramm('x', x_val ,'color', color, 'subset',subset, 'group',group, 'marker',group);

    g(1,1).set_layout_options(  'position',[0 0.8 0.8 0.2],... %Set the position in the figure (as in standard 'Position' axe property)
                                'legend',false,... % No need to display legend for side histograms
                                'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
                                'margin_width',[0.1 0.02],...
                                'redraw',false); %We deactivate automatic redrawing/resizing so that the axes stay aligned according to the margin options
    g(1,1).set_names('y','PDF');
    g(1,1).stat_density("kernel","normal"); 
    g(1,1).geom_vline('xintercept', 10,'style','--');
    g(1,1).axe_property('XLim',[ 0, max(x_val(subset))], 'XTickLabel','');  
    
    
    g(2,1)=gramm('x', x_val,'y',y_val ,'label', label,'color', color,'subset',subset,'group',group, 'marker',group);
    g(2,1).set_names('x', x_label, 'y', y_label);
    g(2,1).geom_point();  
    g(2,1).stat_ellipse("geom","line","type","95percentile");
    %g(2,1).geom_label();
    g(2,1).geom_hline('yintercept', 20,'style','--');
    g(2,1).geom_vline('xintercept', 10,'style','--');
    
    g(2,1).set_layout_options( ...
        'legend',true,...
        'Position',[0 0 0.8 0.8],...
        'margin_height',[0.1 0.02],...
        'margin_width',[0.1 0.02],...
        'redraw',true);
    g(2,1).axe_property('XLim',[ 0, max(x_val(subset))], 'Ylim',[ 0, max(y_val(subset))], 'Ygrid','on'); 
    
    
    
    %Create y data histogram on the right
    g(3,1)=gramm('x',y_val,'color',color,'subset',subset,'group',group, 'marker',group);
    g(3,1).set_layout_options(      'Position',[0.8 0 0.2 0.8],...
        'legend',false,...
        'margin_height',[0.1 0.02],...
        'margin_width', [0.02 0.05],...
        'redraw',false);
    
    g(3,1).set_names('x','');
    g(3,1).stat_density(); 
    g(3,1).geom_vline('xintercept', 20,'style','--');
    g(3,1).coord_flip();
    g(3,1).axe_property('XLim',[ 0, max(y_val(subset))], 'XTickLabel','');
    
    %Set global axe properties
    g.set_point_options('base_size',8);
    g.axe_property('TickDir','out','XGrid','on','GridColor',[0.5 0.5 0.5]);
    g.set_title('metrics');
    g.set_color_options('map','d3_10');

end

function data = read_metrics(file)

    data        = readtable(file);
    data        = add_column(data, 'nbo', @extract_nbo);
    data        = add_column(data, 'wavelet_scale', @extract_scale_numbers);
    data        = add_column(data, 'wavelet_scale_method', @extract_normalization);
    data        = add_column(data, 'roi_idx', @extract_roi_name);
    data        = add_column(data, 'isLowPass', @(data) (contains(data.comment, 'low') || ~contains(data.comment, 'Avg')));
    data        = add_column(data, 'isAvgFirst', @(data) ~contains(data.comment, 'Avg'));
    data        = add_column(data, 'label', @generate_label);

end