function [groupList] = clustersSelection(chainsMatTot, groupList, lengthParameter)
% This function allows to select only the cluster with more spikes than the
% length parameter.

% Selection by the length.
keep = false(1,length(groupList));

allNums = [chainsMatTot.num];
allNumSpikes = [chainsMatTot.numSpikes];
for c = 1 : length(groupList)
    chainInds = ismember(allNums, groupList{c});
    if sum(allNumSpikes(chainInds)) >= lengthParameter
        keep(c) = true;
    end
end

groupList = groupList(keep);
