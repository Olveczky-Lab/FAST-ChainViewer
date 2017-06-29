function [clusterSelectedName, chainsList] = findCluster(handles, chainsSelected)
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    chainsList = [];
    clusterSelected = [];
    clusterSelectedName = {};
    
    for a = 1 : size(clusterVecAll, 2)
        clusterTested = clusterVecAll{1, a};
        
        for b = 1 : length(clusterTested)
            if clusterTested(b) == chainsSelected
                clusterSelected = clusterVecAll{1, a};
                clusterSelectedName = clusterVecAll{2, a};
            end
        end
    end
    
    if isempty(clusterSelected) == 0
        for a =  1 : length(chainsMatTot)
            for b = 1 : length(clusterSelected)
                if chainsMatTot(a).num == clusterSelected(b)
                    chainsList = [chainsList; chainsMatTot(a)];
                end
            end
        end
        
        for a =  1 : length(chainsMatTot)
            if chainsMatTot(a).num == chainsSelected
                chains = chainsMatTot(a);
            end
        end
    end
end