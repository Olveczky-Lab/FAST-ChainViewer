function [chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAll)
% Color modes determination for the clusters. 

[chainsMatTot(1:end).cluster_mode_1] = deal(chainsMatTot.color);
[chainsMatTot(1:end).cluster_mode_2] = deal([0,0,0]);

allChainNums = [chainsMatTot.num];
for b = 1 : size(clusterVecAll,2)
    clustChainNums = clusterVecAll{1,b}; % identify chains in cluster 
    [~,~,clustChainsInd] = intersect(clustChainNums, allChainNums); % Find array index for chains from their chain nums
    
    [chainsMatTot(clustChainsInd).cluster_mode_1] = deal([0,0,0]);
    [chainsMatTot(clustChainsInd).cluster_mode_2] = deal(clusterVecAll{3,b});    
end
end