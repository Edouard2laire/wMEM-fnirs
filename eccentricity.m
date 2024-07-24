function [ecc,distance_dipoles] = eccentricity(Mesh,NZ,OD,OG,ctf2aims,...
                                                            vert,applyMean,dipoleLoc)
% [ecc,distance_dipoles] = eccentricity(Mesh,NZ,OD,OG,ctf2aims,vert,applyMean)
%__________________________________________________________________________
% Calculate the eccentricity of a group of vertices from the center of the
% brain. This center is defined as the middle of OG and OD and with the
% same height as NZ.
%--------------------------------------------------------------------------
% INPUTS
%--------------------------------------------------------------------------
% Mesh : (structure) Cortical mesh
% NZ, OD, OG : (n x 3 vectors) fiducial points
% ctf2aims : (n x 3 vectors) 
% vert : (vertor) vector of indices of the vertices which you want to know 
% the eccentricity
% applyMean : (boolean) if applyMean = 1, the results is the mean of all
% the vertices in vert (dflt:1)
%--------------------------------------------------------------------------
% OUTPUTS
%--------------------------------------------------------------------------
% ecc : (scalar) mean of eccentricity (euclidian distance between the 
% center and the vertice) of each vertice of vert
% distance_dipoles : (n x 1 vector) eccentricity for each of the vertice in
% the Mesh
%__________________________________________________________________________

NZ_Rec = NZ * ctf2aims(1:3,:) + ones(size(NZ,1),1) * ctf2aims(4,:);
NZ_Rec_Mean = mean(NZ_Rec,1);

OD_Rec = OD * ctf2aims(1:3,:)+ones(size(OD,1),1) * ctf2aims(4,:);
OD_Rec_Mean =mean(OD_Rec,1);

OG_Rec = OG * ctf2aims(1:3,:)+ones(size(OG,1),1) * ctf2aims(4,:);
OG_Rec_Mean =mean(OG_Rec,1);

center= mean([OD_Rec_Mean ; OG_Rec_Mean]);  % Midpoint of the line formed by joining OD & OG

center_high = [center(1) center(2) NZ_Rec_Mean(3) ];    % Same as NZ

center_high_fullmatrix = ones(length(Mesh.vertices),1) * center_high;

if nargin < 8

    distance_dipoles=sqrt(sum((Mesh.vertices-center_high_fullmatrix).*(Mesh.vertices-center_high_fullmatrix),2));                     % Euclidean distance of each dipoles from the center point

    if (nargin < 7) || applyMean
        ecc = mean(distance_dipoles(vert));
    else
        ecc = distance_dipoles(vert);
    end
else
    distance_dipoles=sqrt(sum((dipoleLoc-center_high).*(dipoleLoc-center_high),2));                     % Euclidean distance of each dipoles from the center point
    ecc = distance_dipoles;
    
end
end