function chainParents = findSplitChainParents(chains, chainsMatTot)

chainParents = zeros(size(chains)) * NaN;

% Identify split chains in list
chainInds = find(ismember([chainsMatTot.num], chains));
split_chains = find(cellfun(@(x) ~isempty(strfind(x, '_')), {chainsMatTot(chainInds).trueNumber}));

for c = 1 : length(split_chains)
    split_chainInd = chainInds(split_chains(c));
    parentFile = chainsMatTot(split_chainInd).names{1};
    parentTrueNum = strsplit(chainsMatTot(split_chainInd).trueNumber, '_');
    parentTrueNum = parentTrueNum{1};
    parentInd = find(strcmp(parentFile, [chainsMatTot.names]) & strcmp(parentTrueNum, {chainsMatTot.trueNumber}), 1, 'first');
    if ~isempty(parentInd)
        chainParents(split_chains(c)) = chainsMatTot(parentInd).num;
    end
end