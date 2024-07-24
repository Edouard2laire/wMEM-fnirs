function VoisinsOA = adj2Voisins(adj)
% Convert the adjacency matrix 'adj' to 'VoisinsOA' neighbor cell vector
len = length(adj);

VoisinsOA = cell(12,len);

h = waitbar(0,'Please wait...');
for iScale = 1:12
    adj_i = logical(adj^iScale);
    adj_i(logical(eye(size(adj_i)))) = 0;
    for iSource = 1:len
       VoisinsOA{iScale,iSource} = find(adj_i(iSource,:));
    end
    waitbar(iScale / 12)
end
close(h) 

end