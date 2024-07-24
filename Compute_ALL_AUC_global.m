function [Res_summary,Res_close_summary,Res_far_summary  ] = Compute_ALL_AUC_global(Mesh, Jtheo, J, peak,  VoisinsOA, clusters, nb_resampling, ordreVoisinage, thresholds, area)
% ***********************************************************************
% [AUC,AUC_close,AUC_far] = Compute_ALL_AUC_global(Mesh, Jtheo, Jmeas, peak,  VoisinsOA, clusters, ordreVois, visu)
% ***********************************************************************
% Inputs : 
% ***********************************************************************
% Outputs : 
% ***********************************************************************
% C. Grova - Montreal Neurological Institute - 21 03 2005 
% ***********************************************************************


if nargin < 9
    thresholds = [];
end
if nargin < 10
    area = [];
end
mypeak = peak ;% peak ou on calcule les metriques AUC
%ordreVoisinage = 10; % definition du support Close pour le calcul d AUCclose qui tire les sources fictives dans un voisinage autour de la source simulee

Jmeas = abs(J(:,mypeak)) / max(abs(J(:,mypeak))); % normalisation entre 0 et 1 du vecteur resultat a tester

%nb_resampling = 30; % nombre de reechantillonnage

for i = 1:nb_resampling
    [Res_close(i),Res_far(i)]   = Compute_AUC_global(Mesh, Jtheo, Jmeas,  VoisinsOA, clusters, ordreVoisinage, 0,thresholds, area);
end

Res_close_summary = struct();
Res_far_summary = struct();
Res_summary = struct();

fields = fieldnames(Res_close);
for i = 1:length(fields)
    data_close =  cell2mat({Res_close.(fields{i})});
    if size(data_close,2) == nb_resampling
        Res_close_summary.(sprintf('%s_mean', fields{i}))   = mean(data_close,2);
        Res_close_summary.(sprintf('%s_std', fields{i}))    = std(data_close,[],2);
    else
        Res_close_summary.(sprintf('%s', fields{i})) = Res_close(1).(fields{i});
    end
    
    data_far =  cell2mat({Res_far.(fields{i})});
    if size(data_close,2) == nb_resampling
        Res_far_summary.(sprintf('%s_mean', fields{i}))   = mean(data_far,2);
        Res_far_summary.(sprintf('%s_std', fields{i}))    = std(data_far,[],2);
    else
        Res_far_summary.(sprintf('%s', fields{i})) = Res_close(1).(fields{i});
    end
    if size(data_close,2) == nb_resampling
        Res_summary.(sprintf('%s_mean', fields{i}))   = (mean(data_close,2) + mean(data_far,2)) / 2;
        Res_summary.(sprintf('%s_std', fields{i}))    = ( std(data_close,[],2) + std(data_far,[],2)) / 2;

    else
        Res_summary.(sprintf('%s', fields{i})) = Res_close(1).(fields{i});
    end
end





end
