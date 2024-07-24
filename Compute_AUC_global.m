function [Res_close,Res_far] = Compute_AUC_global(Mesh, Jtheo, Jmeas,  VoisinsOA, clusters, ordreVois, visu, thresholds, area)
% ***********************************************************************
% [ROC_Result, AUC_Result] = Compute_AUC_global(Jtheo, Jmeas,  VOISINS, ListMethods, clusters, ordreVois)
% Draw a ROC curve given a a Patch structure used ofr simulation ans a SourceLoc structure for 
% ***********************************************************************
% Inputs : 
% ***********************************************************************
% Outputs : 
% ***********************************************************************
% C. Grova - Montreal Neurological Institute - 21 03 2005 
% ***********************************************************************

% Generation of the theoretical file

if nargin < 8 || isempty(thresholds)
    thresholds = linspace(0,1, 100); % 0:0.05:1;
end
if nargin < 9 || isempty(area)
    area = [];  
end

nbvertices = length(Jtheo);

Itheo = find(Jtheo ~=0);
Itheo = unique(Itheo);
     

% --------------------------------------------------------------------
% Computation of AUC_close
% --------------------------------------------------------------------

% definition du Support proche a l aide d un voinnage a l ordre 10 du patch
SupportClose = [];
for i = 1:length(Itheo)
    SupportClose = unique([ SupportClose VoisinsOA{ordreVois,Itheo(i)}]);
end

% Tirage des sources fictives
% Isources_fictives = [];
Isources_fictives = intersect(Itheo, SupportClose);
Isources_fictives = setxor(SupportClose, Isources_fictives);

%disp(['Itheo: ' num2str(length(Itheo))])
%disp(['Isources_fictives: ' num2str(length(Isources_fictives))])


IndicesSourcesF = randperm(length(Isources_fictives));


if size(IndicesSourcesF,2)>size(Itheo,1)
    Isources_fictives_selected = zeros(1,length(Itheo));
    Isources_fictives_selected = Isources_fictives(IndicesSourcesF(1:length(Itheo)));
else
    Isources_fictives_selected = zeros(1,size(IndicesSourcesF,2));
    Isources_fictives_selected = Isources_fictives(IndicesSourcesF(1:size(IndicesSourcesF,2)));
end



%if(length(Itheo)> length(Isources_fictives))
%		
%	p = length(Isources_fictives) ;
% 	Isources_fictives_selected(1:p) = Isources_fictives(IndicesSourcesF(1:length(Isources_fictives)));
%	Reste = length(Itheo) - p
%
%	while (Reste > 0)
%				
%		IndicesSourcesF = randperm(length(Isources_fictives));
%		
%		if Reste > length(Isources_fictives)
% 			Isources_fictives_selected = [ Isources_fictives_selected Isources_fictives(IndicesSourcesF(1:length(Isources_fictives)))];
%		else	
%			length(Isources_fictives_selected(p+1:end))
% 	                Isources_fictives_selected(p+1:end) = Isources_fictives(IndicesSourcesF(1:Reste));	
%		end % end if 
%		
%		p = p + length(Isources_fictives)
%		Reste = length(Itheo) -p
%
%	end % end while
%
%else 
%
% 	Isources_fictives_selected = Isources_fictives(IndicesSourcesF(1:length(Itheo)));
%end  % end if

Jfictif = zeros(nbvertices,1);
Jfictif(Isources_fictives_selected) = 1;


Res_close = Compute_RocParam(Jmeas, Jtheo,Jfictif,  thresholds, area);
Res_close.thresholds = thresholds;

Res_close.AUC = ComputeAUC(1-Res_close.specificity,Res_close.sensitivity);
if ~isempty(area)
    Res_close.AUC_area = ComputeAUC(1-Res_close.specificity_area,Res_close.sensitivity_area);
end

% --------------------------------------------------------------------
% Computation of AUC_far
% --------------------------------------------------------------------

SupportFar = setdiff([1:length(Jmeas)], SupportClose);

Isources_fictives = intersect(Itheo, SupportFar);
Isources_fictives = setxor(SupportFar, Isources_fictives);

%IndicesSourcesF = randperm(length(Isources_fictives));
%Isources_fictives_selected = Isources_fictives(IndicesSourcesF(1:length(Itheo)));

%Jfictif = zeros(nbvertices,1);
%Jfictif(Isources_fictives_selected) = 1;

% Analyse par courbe ROC : 
          
% Generation des sources fictives dans repartie dans le clustering ! (pour le calcul d AUC_spurious)
if ~isempty(clusters)
    Jfictif = zeros(nbvertices,1);
    Isources_fictives_selected = [];
    IndiceCluster = randperm(length(clusters));
    i = 0;
    indice_decroissant = 1; % on ajoutre d abor le plus actif dans chaque cluster
    % puis le second plus actif ... et ainsi de suite
    
    while (length(Isources_fictives_selected) < length(Itheo))
        i = i+1;
        if (i>length(clusters))
            % on est deja passe une fois par chaque cluster
            % on prendra donc le 2nd point le plus actif
            i=1;
            indice_decroissant = indice_decroissant+1;
        end
        SelectCluster = IndiceCluster(i);
        
        [Jsorted, Indices_sorted ] = sort(-Jmeas(clusters{SelectCluster}));
        
        %Indice_source_in_cluster = randperm(length(clusters{SelectCluster}));
        %Candidat =  clusters{SelectCluster}(Indice_source_in_cluster(1));
        
        if (indice_decroissant  <= length(Indices_sorted))
            Candidat = clusters{SelectCluster}(Indices_sorted(indice_decroissant));
            
            if (~isempty(intersect(Candidat, Isources_fictives)) & ...
                    isempty(intersect(Candidat, Isources_fictives_selected))) 
                % Candidat bien dans le support fictif et pas deja pris
                Isources_fictives_selected = [Isources_fictives_selected Candidat];
            end
        end % on verifie que le point d indice indice_decroissant est toujours dans le clusters 
        
    end % end iwhile
end %end if clusters

Jfictif(Isources_fictives_selected) = 1;

Res_far = Compute_RocParam(Jmeas, Jtheo,Jfictif,  thresholds, area);
Res_far.thresholds = thresholds;
Res_far.AUC = ComputeAUC(1-Res_far.specificity,Res_far.sensitivity);
if ~isempty(area)
    Res_far.AUC_area = ComputeAUC(1-Res_far.specificity_area,Res_far.sensitivity_area);
end

clear Jsel Energy Jmeas Res

end
