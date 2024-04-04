% Return the area of the ROIs used for simulation. [mean, min, max]
% This could be more clean but whatever.  The results is in cm^2

[FaceArea, VertArea] = tess_area(sCortex.Vertices, sCortex.Faces);

sRois = sCortex.Atlas(14).Scouts;

vert_number  = zeros(1, 28);
vert_area    = zeros(1, 28);

for iRoi = 1:28
    vert_number(iRoi) = length(sRois(iRoi).Vertices);
    vert_area(iRoi) = sum(VertArea(sRois(iRoi).Vertices))*10000;
end


disp('Roi statistics')
fprintf('Size of the 28 ROis : mean: %d, min: %d, max: %d cm2 \n', round([ mean(vert_area), min(vert_area), max(vert_area)]))
fprintf('Size of the 28 ROis : mean: %d, min: %d, max: %d vertex \n', round([ mean(vert_number), min(vert_number), max(vert_number)]))