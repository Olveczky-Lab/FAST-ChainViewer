function newNums = updateChainNum(oldNums, chainsMatOld, chainsMatNew)

[~,ind] = unique(oldNums, 'first');
oldNums = oldNums(sort(ind));

newNums = zeros(size(oldNums));
for c = 1 : length(oldNums)
    if oldNums(c) < 0
        chainInd = find(arrayfun(@(x) any(oldNums(c) == x), [chainsMatOld.num]));

        newInd = find(strcmp(chainsMatOld(chainInd).names{1}, [chainsMatNew.names]) & ...
            strcmp(chainsMatOld(chainInd).trueNumber, {chainsMatNew.trueNumber}),1,'first');

        if ~isempty(newInd)
            newNums(c) = chainsMatNew(newInd).num;
        else
            newNums(c) = NaN;
        end
    else
        newNums(c) = oldNums(c);
    end
end