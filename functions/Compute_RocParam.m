function [Roc_struct] = Compute_RocParam(J, Jtheo, Jfictif, thresholds, area)

% ***********************************************************************
% [Roc_struct] = Compute_RocParam(J, Jth, thresholds)
% Compute ROC parameters form the computed distribution J and the theoretical distribution Jth
% ***********************************************************************
% Inputs : 
%    J : vector (nbvertices) containing the probability of each source to be active (to be thresholded 
%    between 0 and 1
%    Jtheo : vector (nbvertices) containing 1 if the dipole is active 0 otherwise
%    thresholds : list of thresholds to apply to J
%
% ***********************************************************************
% Outputs :
%   the sutructure Roc_struct containing following fields
%    .specificity : tn / (tn + fp) nb de ce qui n a pas ete detecte, sur tout ce qui ne devrait pas etre detecte
%    .sensitivity : tp / (tp + fn) nb de ce qui a ete detecte, sur tout ce qui devrait etre detecte
%    .ppv  : positive predictive value : tp  / (tp + fp)
%    .npv  : negative predictive value : tn / (fn + tn)
%    .dice : Dice: 2*TP/(2*TP + FP + FN)
%    .tp : true positive rate
%    .fp : false positive rate
%    .tn : true negative rate
%    .fn : false negative rate
%
% ***********************************************************************
% C. Grova - Montreal Neurological Institute - 05 01 2004 
% ***********************************************************************

if nargin < 5
    area = [];
end

nbtest = length(thresholds);


Roc_struct.tp = zeros(nbtest,1);
Roc_struct.tn = zeros(nbtest,1);
Roc_struct.fp = zeros(nbtest,1);
Roc_struct.fn = zeros(nbtest,1);
Roc_struct.specificity = zeros(nbtest,1);
Roc_struct.sensitivity = zeros(nbtest,1);
Roc_struct.ppv = zeros(nbtest,1);
Roc_struct.npv = zeros(nbtest,1);
Roc_struct.dice = zeros(nbtest,1);

if ~isempty(area)
    Roc_struct.tp_area = zeros(nbtest,1);
    Roc_struct.tn_area = zeros(nbtest,1);
    Roc_struct.fp_area = zeros(nbtest,1);
    Roc_struct.fn_area = zeros(nbtest,1);
    Roc_struct.specificity_area = zeros(nbtest,1);
    Roc_struct.sensitivity_area = zeros(nbtest,1);
    Roc_struct.ppv_area = zeros(nbtest,1);
    Roc_struct.npv_area = zeros(nbtest,1);
    Roc_struct.dice_area = zeros(nbtest,1);
end

for i = 1:nbtest
    Jthresh = (J >= thresholds(i));

    Roc_struct.tp(i) = sum(Jthresh .* Jtheo); %/ sum(Jthresh)
    Roc_struct.tn(i) = sum(~(Jthresh) .* Jfictif); %/ sum(~Jthresh)
    Roc_struct.fp(i) = sum(Jthresh .* Jfictif); %/ sum(Jthresh)
    Roc_struct.fn(i) = sum(~(Jthresh) .* (Jtheo)); % / sum(~Jthresh) 
    
    
    Roc_struct.specificity(i) =   Roc_struct.tn(i) /  (Roc_struct.tn(i) + Roc_struct.fp(i));
    Roc_struct.sensitivity(i) =   Roc_struct.tp(i) /  (Roc_struct.tp(i) + Roc_struct.fn(i));
    Roc_struct.ppv(i)         =   Roc_struct.tp(i) /  (Roc_struct.tp(i) + Roc_struct.fp(i));
    Roc_struct.npv(i)         =   Roc_struct.tn(i) /  (Roc_struct.tn(i) + Roc_struct.fn(i));
    Roc_struct.dice(i)        = 2*Roc_struct.tp(i) /  (2*Roc_struct.tp(i) + Roc_struct.fp(i) + Roc_struct.fn(i));
    
    
    if ~isempty(area)
        Roc_struct.tp_area(i) = sum(area( find(Jthresh .* Jtheo))); 
        Roc_struct.tn_area(i) = sum(area( find(~(Jthresh) .* Jfictif)));
        Roc_struct.fp_area(i) = sum(area( find(Jthresh .* Jfictif))); 
        Roc_struct.fn_area(i) = sum(area( find(~(Jthresh) .* (Jtheo)))); 
    
    
        Roc_struct.specificity_area(i) =   Roc_struct.tn_area(i) /  (Roc_struct.tn_area(i) + Roc_struct.fp_area(i));
        Roc_struct.sensitivity_area(i) =   Roc_struct.tp_area(i) /  (Roc_struct.tp_area(i) + Roc_struct.fn_area(i));
        Roc_struct.ppv_area(i)         =   Roc_struct.tp_area(i) /  (Roc_struct.tp_area(i) + Roc_struct.fp_area(i));
        Roc_struct.npv_area(i)         =   Roc_struct.tn_area(i) /  (Roc_struct.tn_area(i) + Roc_struct.fn_area(i));
        Roc_struct.dice_area(i)        = 2*Roc_struct.tp_area(i) /  (2*Roc_struct.tp_area(i) + Roc_struct.fp_area(i) + Roc_struct.fn_area(i));
    end

end

