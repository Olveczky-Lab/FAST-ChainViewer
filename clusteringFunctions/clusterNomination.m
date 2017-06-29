function [clusterVecAll] = clusterNomination(clusterVecAll, type)
% Gives a name for the clusters. 

if type == 0
    clustersNames = {};
    
    for cluster = 1 : length(clusterVecAll)
        clustersNames{end + 1} = ['c' num2str(cluster)];
    end
    
    clusterVecAll = [clusterVecAll; clustersNames];
end

if type == 1;
    clustersNames = {};
    
    for cluster = 1 : length(clusterVecAll)
        clustersNames{end + 1} = ['m' datestr(now,'HH-MM-SS')];
    end
    
    clusterVecAll = [clusterVecAll; clustersNames];
end

if type == 2;
    clustersNames = {};
    
    for cluster = 1 : length(clusterVecAll)
        clustersNames{end + 1} = ['s' num2str(cluster)];
    end
    
    clusterVecAll = [clusterVecAll; clustersNames];
end


end
    
