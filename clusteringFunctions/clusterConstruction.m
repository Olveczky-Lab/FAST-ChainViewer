function [clusterVecFinal] = clusterConstruction(groupList)
% This function search the relations between the different clusters
% contained in the array groupList, for one channel, and try to
% join them. 

cluster_labels = 1:size(groupList,1);

for c = 1:size(groupList,1);
    clust_mem = (cluster_labels == c);
    while ~isempty(clust_mem) && any(clust_mem(:))
        inClust = groupList(cluster_labels==c,:);
        outClustInd = find(cluster_labels~=c);
        outClust = groupList(outClustInd,:);
        clust_mem = ismember(outClust, inClust);
        cluster_labels(outClustInd(any(clust_mem,2))) = c;
    end
end

u_cluster_labels = unique(cluster_labels);
clusterVecFinal = cell(1,length(u_cluster_labels));

for clustnum = 1 : length(u_cluster_labels)
    chains = unique(groupList(cluster_labels == u_cluster_labels(clustnum)));
    clusterVecFinal{clustnum} = chains(:)';
end

            