function [clusterVecFinal] = clusterConstruction(clusterVecTotAll)
% This function search the relations between the different clusters
% contained in the file "clusterVecTotAll", for one channel, and try to
% join them. 

%%%%%%%%%%%%%%
% INITIATION %
%%%%%%%%%%%%%%
clusterVecFinal = {};

%%%%%%%%%%%
% PROCESS %
%%%%%%%%%%%
for clust1 = 1 : (length(clusterVecTotAll));
    newCluster = clusterVecTotAll{clust1};
    
    clust2 = 1;
    while clust2 <= (length(clusterVecTotAll))
        
        clusterVecAll2 = clusterVecTotAll{clust2};
        
        if (length(newCluster) >= 2) && (length(clusterVecAll2) >= 2) && (clust1 ~= clust2)
            % The new cluster is built and and the common chains
            % are deleted.
            testCluster = [newCluster, clusterVecAll2];
            newClusterVerified = unique(testCluster);
            
            % If there were commun chains, the new cluster is
            % verified.
            if length(testCluster) > length(newClusterVerified)
                newCluster = newClusterVerified;
                clusterVecTotAll{clust2} = [];
                clust2 = 1;
            end
        end
        clust2 = clust2 + 1;
    end
    
    % The new cluster is added to the list.
    if length(newCluster) > 1
        clusterVecFinal{end + 1} = newCluster;
        clusterVecTotAll{clust1} = [];
    end
    clear newCluster newClusterVerified;
end

end
                        
            