function Jfictif = AUC_create_JFictif_cluster(Jmeas, clusters, support, nbvertices, nTarget)
    %    Generation des sources fictives dans repartie dans le clustering !
    %    (pour le calcul d AUC_spurious)


    Isources_fictives_selected = [];
    IndiceCluster = randperm(length(clusters));
    i = 0;
    indice_decroissant = 1; % on ajoutre d abor le plus actif dans chaque cluster
    % puis le second plus actif ... et ainsi de suite
    
    while (length(Isources_fictives_selected) < nTarget)
        i = i+1;
        if (i > length(clusters))
            % on est deja passe une fois par chaque cluster
            % on prendra donc le 2nd point le plus actif
            i=1;
            indice_decroissant = indice_decroissant+1;
        end
        SelectCluster = IndiceCluster(i);
        
        [Jsorted, Indices_sorted ] = sort(Jmeas(clusters{SelectCluster}), 'descend');
        
        %Indice_source_in_cluster = randperm(length(clusters{SelectCluster}));
        %Candidat =  clusters{SelectCluster}(Indice_source_in_cluster(1));
        
        if (indice_decroissant  <= length(Indices_sorted))
            Candidat = clusters{SelectCluster}(Indices_sorted(indice_decroissant));
            
            if (~isempty(intersect(Candidat, support)) & ...
                    isempty(intersect(Candidat, Isources_fictives_selected))) 
                % Candidat bien dans le support fictif et pas deja pris
                Isources_fictives_selected = [Isources_fictives_selected Candidat];
            end
        end % on verifie que le point d indice indice_decroissant est toujours dans le clusters 
        
    end % end iwhile


    Jfictif = zeros(nbvertices,1);
    Jfictif(Isources_fictives_selected) = 1;
end