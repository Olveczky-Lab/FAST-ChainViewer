function newNumList = updateChainNumList(chainsMatOld, chainsMatNew)
% Make a conversion list from old chain nums to new chain nums
 % such that newChainNum = newNumList(oldChainNum+1)


newNumList = zeros(max([chainsMatOld.num])+1,1)*NaN;

oldNumList = [chainsMatOld.num];

fnOld = cellfun(@(x,y) strcat(x, y), [chainsMatOld.names], {chainsMatOld.trueNumber}, 'UniformOutput', false);
fnNew = cellfun(@(x,y) strcat(x, y), [chainsMatNew.names], {chainsMatNew.trueNumber}, 'UniformOutput', false);

[~, indOld, indNew] = intersect(fnOld, fnNew);

newNumList(oldNumList(indOld)+1) = [chainsMatNew(indNew).num];
