function Jfictif = AUC_create_JFictif_random(support, nbvertices, nTarget)
    IndicesSourcesF     = randperm(length(support));
    
    
    if size(IndicesSourcesF,2) > nTarget
        Isources_fictives_selected = support(IndicesSourcesF(1:nTarget));
    else
        Isources_fictives_selected = support(IndicesSourcesF(1:size(IndicesSourcesF,2)));
    end
    
    
    Jfictif = zeros(nbvertices,1);
    Jfictif(Isources_fictives_selected) = 1;
end