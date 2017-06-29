function [clusterName, clusterInd] = getClusterName(chainNum, clusterVecAll)

clusterName = cell(length(chainNum),1);
clusterInd = zeros(length(chainNum),1);

for c = 1 : length(chainNum)
    tempInd = find(cellfun(@(x) any(x==chainNum(c)), clusterVecAll(1,:)));
    if ~isempty(tempInd)
        % Preferentially indicate whether the chain belongs to a starred or
        % manual cluster
        markedInd = find(cellfun(@(x) ~isempty(strfind(x, '*')), clusterVecAll(2,tempInd)), 1, 'first');
        manInd = find(cellfun(@(x) ~isempty(strfind(x, 'm')), clusterVecAll(2,tempInd)), 1, 'first');
        
        if ~isempty(markedInd)
            clusterInd(c) = tempInd(markedInd);
        elseif ~isempty(manInd)
            clusterInd(c) = tempInd(manInd);
        else
            clusterInd(c) = tempInd(1);
        end
        clusterName{c} = clusterVecAll{2,clusterInd};
    else
        clusterInd(c) = NaN;
        clusterName{c} = 'None';
    end
end