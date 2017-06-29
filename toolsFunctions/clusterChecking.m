function [clusterChecked] = clusterChecking(clusterVecAll)
clusterChecked = [];
for cluster = 1 : size(clusterVecAll, 2)
    if strcmp(clusterVecAll{2, cluster}(1), '*') == 1
        clusterChecked = [clusterChecked, clusterVecAll(:, cluster)];
    end
end
end