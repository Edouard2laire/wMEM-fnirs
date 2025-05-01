function [AUC] = ComputeAUC(Vec1,Vec2)
% ***********************************************************************
% [AUC] = ComputeAUC(Vec1,Vec2)
%  compute area under the curve using the trapezoids method
% ***********************************************************************
% Inputs : 
%   Vec1 : list of abscissae
%   Vec2 : list of ordinates
%
% ***********************************************************************
% Outputs : 
%    AUC : area under the curve
% ***********************************************************************
% C. Grova - Montreal Neurological Institute - 09 02 2004 
% ***********************************************************************

    if (length(Vec1) ~= length(Vec2))
        disp('Both vectors should have the same length');
        exit;
    end
    
    [X, I]  = sort(Vec1);
    Y       =  Vec2(I); 
    
    AUC = trapz(X,Y);
end