addpath(genpath('/Users/edelaire1/Documents/software/gramm-master'));

output_folder = fullfile('/Users/edelaire1/Documents/Etude/04_PHD/Abstract/2026_fNIRS_china/figures','Simulation','task');
if ~exist(output_folder)
    mkdir(output_folder)
end


%% Main Figure. Comparison MNE, cMEM, wMEM

data1 = read_metrics(fullfile('data','metrics','metrics_task','metrics_MNE_simul-task_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_task','metrics_MNE_simul-task_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_task','metrics_MNE_simul-task_0.25dB_medium.csv'));

data_MNE  = [ data1 ; data2; data3];
data_MNE.label = repmat({'MNE'}, height(data_MNE), 1);

data_MNE_select =  extract_data(data_MNE,  @(data) data.isLowPass && ~data.isAvgFirst);

data1 = read_metrics(fullfile('data','metrics','metrics_task','metrics_wMEM_simul-task_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_task','metrics_wMEM_simul-task_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_task','metrics_wMEM_simul-task_0.25dB_medium.csv'));

data_wMEM  = [data1 ;  data2; data3];
data_wMEM.label = repmat({'wMEM'}, height(data_wMEM), 1);

data_wMEM_select =  extract_data(data_wMEM,  @(data) data.nbo == 6 && strcmp(data.wavelet_scale_method,'fixed') && data.isLowPass);

% data1 = read_metrics(fullfile('data','metrics','metrics_task','metrics_cMEM_simul-task_-1.00dB_medium.csv'));
% data2 = read_metrics(fullfile('data','metrics','metrics_task','metrics_cMEM_simul-task_0.00dB_medium.csv'));
% data3 = read_metrics(fullfile('data','metrics','metrics_task','metrics_cMEM_simul-task_0.25dB_medium.csv'));
% 
% data_cMEM  = [data1; data2; data3];
% data_cMEM.label = repmat({'cMEM'}, height(data_cMEM), 1);
% data_cMEM_select =  extract_data(data_cMEM,  @(data) data.nbo == 4);


data_all_select = [data_MNE_select ; data_wMEM_select ];



 %%
fig = figure('Units','pixels','Position', getFigureSize(20.8, 6));
set(fig, 'PaperPositionMode', 'auto');

clear g
data_all_select.label = data_all_select.snr;
g(1,1) = plot_boxplot(data_all_select, {'DLE'},  'method'); g(1,1).set_title('a. DLE (mm)'); g(1,1).no_legend()
g(1,2) = plot_boxplot(data_all_select, {'SD'},   'method'); g(1,2).set_title('b. SD (mm)'); g(1,2).no_legend()
g(1,3) = plot_boxplot(data_all_select, {'correlation'},   'method'); g(1,3).set_title('c. Correlation (%)');

g(1,1).geom_hline("yintercept",5,"style", 'b--');
g(1,2).geom_hline("yintercept",10,"style", 'b--');
g(1,3).geom_hline("yintercept", 0.8,"style", 'b--');

g(1,:).set_title('Localization of simulated task activity');
g.set_text_options("base_size", 15, "label_scaling",1, "title_scaling",1.2, "big_title_scaling", 1.33 , "font", 'Times New Roman');
g.set_names('x','SNR','Column','','y','Value', 'Color', 'Method');
g.set_order_options('color',{  'MNE' 'wMEM'});

color_red = [
             252,141,89; ...
             215,48,39 ; ...
             254,224,144] ./ 255;
g.set_color_options('map',color_red(1:2, :), 'n_color',2,'n_lightness',1);


g.draw();
g(1,1).facet_axes_handles.YLim = [0, 15]; 
g(1,2).facet_axes_handles.YLim = [0, 20];  
g(1,3).facet_axes_handles.YLim = [0, 1];   


% Remove the background of the box
arrayfun(@(x)  arrayfun( @(y)set( y.box_handle, 'FaceAlpha', 0), x(1).results.stat_boxplot)  ,  g)
pause(1)
saveas(fig,fullfile(output_folder,'main_comparison_task_a.svg'));
close(fig);

%%
disp('Stat on SD')
disp('-------------')
compute_stats(data_all_select, 'SD');


%%
disp('Stat on SD (DLE = 0)')
disp('-------------')
compute_stats(data_all_select2, 'SD');

%%
disp('Stat on correlation (DLE = 0)')
disp('-------------')
compute_stats(data_all_select2, 'correlation');



%% Annex. Impact of the pipeline on MNE localization

data1 = read_metrics(fullfile('data','metrics','metrics_task','metrics_MNE_simul-task_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_task','metrics_MNE_simul-task_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_task','metrics_MNE_simul-task_0.25dB_medium.csv'));

data_MNE  = [ data1 ; data2; data3];

clear g

fig = figure('units','normalized','outerposition',[0 0 1 1]);
g = plot_boxplot( data_MNE , {'DLE','SD', 'correlation'}, 'snr');
g.set_title('Localization metrics')
g.set_title('Localization of simulated task activity using MNE');
g.set_layout_options( 'legend',true);
g.set_names('x','Method','Column','','y','Value', 'color','SNR');

g.draw();

g.facet_axes_handles(1,1).YLim = [0, 30];
g.facet_axes_handles(1,2).YLim = [0, 20]; 
g.facet_axes_handles(1,3).YLim = [0, 1]; 

% Remove the background of the box
arrayfun(@(x) set(x.box_handle, 'FaceAlpha', 0),  g(1).results.stat_boxplot)

pause(1)
saveas(fig,fullfile(output_folder,'annex_comparison_simulation_task_mne.svg'));

%% Annex. Impact of the pipeline on wMEM localization

data1 = read_metrics(fullfile('data','metrics','metrics_task','metrics_wMEM_simul-task_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_task','metrics_wMEM_simul-task_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_task','metrics_wMEM_simul-task_0.25dB_medium.csv'));
data_wMEM  = [data1 ;  data2; data3];

for i = 1:height(data_wMEM)
    data_wMEM(i,'label') = {sprintf('NBO = %d',data_wMEM(i,:).nbo)};
end

clear g

fig = figure('units','normalized','outerposition',[0 0 1 1]);
g = plot_boxplot( data_wMEM , {'DLE','SD', 'correlation'}, 'snr','isLowPass');
g.set_title('Localization metrics')
g.set_title('Localization of simulated task activity using wMEM')
g.set_layout_options( 'legend',true);
g.set_names('x','Method','Column','','y','Value', 'color','SNR', 'row','low-pass');
g.draw();


g.facet_axes_handles(1,1).YLim = [0, 30]; g.facet_axes_handles(2,1).YLim = [0, 30];
g.facet_axes_handles(1,2).YLim = [0, 20]; g.facet_axes_handles(2,2).YLim = [0, 20];
g.facet_axes_handles(1,3).YLim = [0, 1];  g.facet_axes_handles(2,3).YLim = [0, 1];

% Remove the background of the box
arrayfun(@(x) set(x.box_handle, 'FaceAlpha', 0),  g(1).results.stat_boxplot)

pause(1)
saveas(fig,fullfile(output_folder,'annex_comparison_simulation_task_wmem.svg'));


%% Annex. Impact of the pipeline on cMEM localization

data1 = read_metrics(fullfile('data','metrics','metrics_task','metrics_cMEM_simul-task_-1.00dB_medium.csv'));
data2 = read_metrics(fullfile('data','metrics','metrics_task','metrics_cMEM_simul-task_0.00dB_medium.csv'));
data3 = read_metrics(fullfile('data','metrics','metrics_task','metrics_cMEM_simul-task_0.25dB_medium.csv'));

data_cMEM  = [ data1; data2; data3];

for i = 1:height(data_cMEM)
    data_cMEM(i,'label') = {sprintf('NBO = %d',data_cMEM(i,:).nbo)};
end

clear g
fig = figure('units','normalized','outerposition',[0 0 1 1]);
g = plot_boxplot( data_cMEM , {'DLE','SD', 'correlation'}, 'snr');
g.set_title('Localization metrics')
g.set_title('Localization of simulated task activity')
g.set_layout_options( 'legend',true);
g.set_names('x','Method','Column','','y','Value', 'color','SNR');

g.draw();

g.facet_axes_handles(1,1).YLim = [0, 30];
g.facet_axes_handles(1,2).YLim = [0, 20];
g.facet_axes_handles(1,3).YLim = [0, 1];

% Remove the background of the box
arrayfun(@(x) set(x.box_handle, 'FaceAlpha', 0),  g(1).results.stat_boxplot)

pause(1)
saveas(fig, fullfile(output_folder,'annex_comparison_simulation_task_cmem.svg'));

%% Perform some stat and display: 

grpstats(data_all_select(:,{'label','snr', 'DLE','SD','correlation'}),{'label','snr'},'median')
grpstats(data_all_select(:,{'label','snr', 'DLE','SD','correlation'}),{'label'},'median')

data_all_select2 =  extract_data(data_all_select,  @(data) data.DLE == 0);
grpstats(data_all_select2(:,{'label','snr', 'DLE','SD','correlation'}),{'label'},'median')


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
    g.set_text_options("base_size", 15, "big_title_scaling",1.33 ,"font", 'Times New Roman');
    g.set_title(sprintf('Influence of operation order %s source localization', strjoin(unique(S.method),', ')));

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

function compute_stats(data, predictor)

    %assert(isfield(data, predictor), 'Unable to find predictor %s in data', predictor)

    % Treat ROI as replicates
    [p, tbl, stats] = anovan(data.(predictor), {data.method, data.snr}, ...
                                        'model', 'interaction', ...
                                        'varnames', {'Method','SNR'});

    %% --- Generate text for the ANOVA results ---
    anova_text = sprintf(['A two-way ANOVA revealed a main effect of Method (F(%d,%d) = %.2f, p = %.4f), ', ...
                          'a main effect of SNR (F(%d,%d) = %.2f, p = %.4f), ', ...
                          'and a Method × SNR interaction (F(%d,%d) = %.2f, p = %.4f) on %s.'], ...
                          tbl{2,3}, tbl{5,3}, tbl{2,6}, p(1), ...   % Method row
                          tbl{3,3}, tbl{5,3}, tbl{3,6}, p(2), ...   % SNR row
                          tbl{4,3}, tbl{5,3}, tbl{4,6}, p(3), predictor);      % Interaction row
    disp(anova_text)

    % Multiple comparisons for Method
    figure;
    results = multcompare(stats, 'Dimension', 1);   % 1 = Method
    
    % Multiple comparisons for SNR
    figure;
    results_snr = multcompare(stats, 'Dimension', 2);
    
    % If you want comparisons within each SNR (interaction)
    figure;
    [results_interaction, m, h, gnames] = multcompare(stats, 'Dimension', [1 2]);
    
    % Loop through results and only keep within-SNR comparisons
    interaction_text = ['Post-hoc comparisons within Method × SNR: ', newline ];
    for i = 1:size(results_interaction,1)
    
    
        tokens = regexp(gnames{results_interaction(i,1)}, 'Method=(.*),SNR=(.*)', 'tokens');
        method_g1 = tokens{1}{1};
        snr_g1 = str2double(tokens{1}{2});
    
        tokens = regexp(gnames{results_interaction(i,2)}, 'Method=(.*),SNR=(.*)', 'tokens');
        method_g2 = tokens{1}{1};
        snr_g2 = str2double(tokens{1}{2});
        
        if snr_g1 ~= snr_g2
            continue;
        end
    
        % only compare if both groups are from the same SNR
        label1 = gnames{results_interaction(i,1)};
        label2 = gnames{results_interaction(i,2)};
        diff   = results_interaction(i,4);
        pval   = results_interaction(i,6);
    
        if pval < 0.05
            interaction_text = [interaction_text ,  sprintf('%s vs %s: diff = %.2f, p = %.4f.\n', label1, label2, diff, pval)];
        end
    end
    
    disp(interaction_text);

end