function [Res_close,Res_far] = Compute_AUC_global(Jtheo, Jmeas,  VoisinsOA, clusters, ordreVois, thresholds, area)
% ***********************************************************************
% [ROC_Result, AUC_Result] = Compute_AUC_global(Jtheo, Jmeas,  VOISINS, ListMethods, clusters, ordreVois)
% Draw a ROC curve given a a Patch structure used ofr simulation ans a SourceLoc structure for 
% ***********************************************************************
% Inputs : 
%   - Jtheo: Ground truth. Binnary map
%   - Jmeas: Measured map. Scaled between 0 and 1.
%   - VoisinsOA
%   - clusters
%   - ordreVois
%   - thresholds. Threshold used for the computqtion of the ROC curve. By
%   default: linspace(0, 1, 100)
%   - area: 
% ***********************************************************************
% Outputs : 
%   - Res_close, Res_far. structure containing the results for the close
%   and far sources. 
% ***********************************************************************
% C. Grova - Montreal Neurological Institute - 21 03 2005 
% ***********************************************************************

if nargin < 8 || isempty(thresholds)
    thresholds = linspace(0, 1, 100);  
end
if nargin < 9 || isempty(area)
    area = [];  
end

nbvertices = length(Jtheo);

Itheo       = find(Jtheo ~=0);
Itheo       = unique(Itheo);

% Target number for the number of vertex in JFictif
nTarget = length(Itheo);

% --------------------------------------------------------------------
% Computation of AUC_close
% --------------------------------------------------------------------

% definition du Support proche a l aide d un voinnage a l ordre 10 du patch
SupportClose = [];
for i = 1:length(Itheo)
    SupportClose = unique([ SupportClose VoisinsOA{ordreVois,Itheo(i)}]);
end

% Tirage des sources fictives
Isources_fictives   = intersect(Itheo, SupportClose);
Isources_fictives   = setxor(SupportClose, Isources_fictives);

if 0 && ~isempty(clusters)
    Jfictif = AUC_create_JFictif_cluster(Jmeas, clusters, Isources_fictives, nbvertices, nTarget);
else
    Jfictif = AUC_create_JFictif_random(Isources_fictives, nbvertices, nTarget);
end

Res_close       = Compute_RocParam(Jmeas, Jtheo, Jfictif,  thresholds, area);
Res_close.AUC   = ComputeAUC(1-Res_close.specificity,Res_close.sensitivity);
if ~isempty(area)
    Res_close.AUC_area = ComputeAUC(1-Res_close.specificity_area,Res_close.sensitivity_area);
end

% --------------------------------------------------------------------
% Computation of AUC_far
% --------------------------------------------------------------------

SupportFar = setdiff(1:length(Jmeas), SupportClose);

Isources_fictives = intersect(Itheo, SupportFar);
Isources_fictives = setxor(SupportFar, Isources_fictives);

% Analyse par courbe ROC : 
if ~isempty(clusters)
    Jfictif = AUC_create_JFictif_cluster(Jmeas, clusters, Isources_fictives, nbvertices, nTarget);
else
    Jfictif = AUC_create_JFictif_random(Isources_fictives, nbvertices, nTarget);
end

Res_far     = Compute_RocParam(Jmeas, Jtheo, Jfictif,  thresholds, area);
Res_far.AUC = ComputeAUC(1-Res_far.specificity,Res_far.sensitivity);
if ~isempty(area)
    Res_far.AUC_area = ComputeAUC(1-Res_far.specificity_area,Res_far.sensitivity_area);
end

end
