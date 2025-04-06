addpath(genpath('/Users/edelaire1/Documents/software/gramm'));

%%  Analyze MNE results


data_MNE        = readtable("data/metrics/metrics_task/metrics_MNE_simul-task_1db_small.csv");
data_MNE        = add_column(data_MNE, 'nbo', @extract_nbo);
data_MNE        = add_column(data_MNE, 'wavelet_scale', @extract_scale_numbers);
data_MNE        = add_column(data_MNE, 'roi_idx', @extract_roi_name);
data_MNE        = add_column(data_MNE, 'isLowPass', @(data) (contains(data.comment, 'low') || ~contains(data.comment, 'Avg')));
data_MNE        = add_column(data_MNE, 'isAvgFirst', @(data) ~contains(data.comment, 'Avg'));
data_MNE        = add_column(data_MNE, 'label', @generate_label);


%% Display sparial variables
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_MNE, {'RSA','SD','DLE'});
g.draw();

% Display temporal variables

figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_MNE, {'correlation','scales'});
g.draw();

% Display AUC and ROC information
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_MNE, {'auc_close','sensitivity_30','specificity_30','ppv_30','npv_30'});
g.draw();


% Generate 2D plot

figure('Position',[100 100 550 550]);
g = plot_2D_scatterplot(data_MNE.sensitivity_30, data_MNE.specificity_30, 'Sensitivity', 'Specificity',  categorical(data_MNE.label), data_MNE.roi_idx, data_MNE.sensitivity_30 >= 0);
g = g.draw();

figure('Position',[100 100 550 550]);
g = plot_2D_scatterplot(data_MNE.DLE, data_MNE.SD, 'DLE (mm)', 'SD (mm)',  categorical(data_MNE.label), data_MNE.roi_idx, data_MNE.DLE >= 0);
g = g.draw();



%%  Analyze cMEM results

data_MEM  = readtable("data/metrics/metrics_task/metrics_cMEM_simul-task_1db_small.csv");

data_MEM        = add_column(data_MEM, 'nbo', @extract_nbo);
data_MEM        = add_column(data_MEM, 'wavelet_scale', @extract_scale_numbers);
data_MEM        = add_column(data_MEM, 'roi_idx', @extract_roi_name);
data_MEM        = add_column(data_MEM, 'isLowPass', @(data) (contains(data.comment, 'low') || ~contains(data.comment, 'Avg')));
data_MEM        = add_column(data_MEM, 'isAvgFirst', @(data) ~contains(data.comment, 'Avg'));
data_MEM        = add_column(data_MEM, 'label', @generate_label);

%%
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_MEM, {'RSA','SD','DLE'});
g.draw();


% Display temporal variables
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_MEM, {'correlation','scales'});
g.draw();

% Display AUC and ROC information
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_MEM, {'auc_close','sensitivity_30','specificity_30','ppv_30','npv_30'});
g.draw();


% Generate 2D plot

figure('Position',[100 100 550 550]);
g = plot_2D_scatterplot(data_MEM.sensitivity_30, data_MEM.specificity_30, 'Sensitivity', 'Specificity',  categorical(data_MEM.label), data_MEM.roi_idx, data_MEM.sensitivity_30 >= 0);
g = g.draw();

figure('Position',[100 100 550 550]);
g = plot_2D_scatterplot(data_MEM.DLE, data_MEM.SD, 'DLE (mm)', 'SD (mm)',  categorical(data_MEM.label), data_MEM.roi_idx, data_MEM.DLE >= 0);
g = g.draw();


%%  Analyze wMEM results


data_wMEM        = readtable("data/metrics/metrics_task/metrics_wMEM_simul-task_1db_small.csv");
data_wMEM        = add_column(data_wMEM, 'nbo', @extract_nbo);
data_wMEM        = add_column(data_wMEM, 'wavelet_scale', @extract_scale_numbers);
data_wMEM        = add_column(data_wMEM, 'roi_idx', @extract_roi_name);
data_wMEM        = add_column(data_wMEM, 'isLowPass', @(data) (contains(data.comment, 'low') || ~contains(data.comment, 'Avg')));
data_wMEM        = add_column(data_wMEM, 'isAvgFirst', @(data) ~contains(data.comment, 'Avg'));
data_wMEM        = add_column(data_wMEM, 'label', @generate_label);
%%


figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_wMEM, {'RSA','SD','DLE'}, 'nbo');
g.draw();

% Display temporal variables

figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_wMEM, {'correlation','scales'},'nbo');
g.draw();

% Display AUC and ROC information
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot(data_wMEM, {'sensitivity_30','specificity_30'}, 'nbo');
g.draw();




%% Combined analysis 

data_MNE_select = extract_data(data_MNE,  @(data) ~data.isAvgFirst && data.isLowPass);
data_MNE_select.label = repmat({'MNE'}, height(data_MNE_select), 1);

data_cMEM_select = extract_data(data_MEM,  @(data) data.nbo == 4);
data_cMEM_select.label = repmat({'cMEM'}, height(data_cMEM_select), 1);

data_wMEM_select = extract_data(data_wMEM,  @(data) strcmp(data.wavelet_scale{1},'6  7  8') && data.nbo == 4 &&  data.isLowPass);
data_wMEM_select.label = repmat({'wMEM'}, height(data_wMEM_select), 1);


%%
figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot([data_MNE_select ; data_cMEM_select; data_wMEM_select], {'RSA','SD','DLE'});
g.draw();

figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot([data_MNE_select ; data_cMEM_select; data_wMEM_select], {'ppv_30','npv_30'});
g.draw();


figure('units','normalized','outerposition',[0 0 1 1])
g = plot_boxplot([data_MNE_select ; data_cMEM_select; data_wMEM_select], {'correlation','scales'},'nbo');
g.draw();



%%
data_roi = extract_data([data_MNE_select ; data_cMEM_select; data_wMEM_select],  @(data) strcmp(data.ROI, 'FOV_copy.48')); 
display_results(data_roi)



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

        case 'MNE'
            if data.isAvgFirst
                label_list{end+1} = 'Lowpass';
                label_list{end+1} = 'Avg';
            end
            
            label_list{end+1} = 'MNE';
            
            if ~data.isAvgFirst && data.isLowPass
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

function g = plot_2D_scatterplot(x_val, y_val,x_label, y_label,  color, label, subset)

    g(1,1)= gramm('x', x_val ,'color', color, 'subset',subset);

    g(1,1).set_layout_options(  'position',[0 0.8 0.8 0.2],... %Set the position in the figure (as in standard 'Position' axe property)
                                'legend',false,... % No need to display legend for side histograms
                                'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
                                'margin_width',[0.1 0.02],...
                                'redraw',false); %We deactivate automatic redrawing/resizing so that the axes stay aligned according to the margin options
    g(1,1).set_names('y','PDF');
    g(1,1).stat_density("kernel","normal"); 
    g(1,1).geom_vline('xintercept', 10,'style','--');
    g(1,1).axe_property('XLim',[ 0, max(x_val(subset))], 'XTickLabel','');  
    
    
    g(2,1)=gramm('x', x_val,'y',y_val ,'label', label,'color', color,'subset',subset);
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
    g(3,1)=gramm('x',y_val,'color',color,'subset',subset);
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

function g = plot_boxplot(data_MNE, metrics, color)
    
    S = stack(data_MNE, metrics, 'NewDataVariableName','Metric');


    if nargin < 3
        color = S.method;
    else
        color = S.(color);
    end


    
    g = gramm("x",categorical(S.label),'y', S.Metric, 'color', color, 'label', S.ROI);
    g.facet_grid([], S.Metric_Indicator,"scale","independent");
    g.geom_jitter();
    g.stat_boxplot();
    g.set_names('x','operation order','Column','','y','Value');
    g.no_legend();
    g.set_text_options("base_size", 30, "font", 'Times New Roman');
    g.set_title(sprintf('Influence of operation order %s source localization', strjoin(unique(S.method),', ')));

end