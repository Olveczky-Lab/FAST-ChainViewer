function [chainsMatTot, pairsMatrix] = removeOldSplits(chainsMatTot, pairsMatrix, chainNum)

[~, chainInd] = chainsSearch(chainsMatTot, chainNum);

trueNum = chainsMatTot(chainInd).trueNumber;
fname = chainsMatTot(chainInd).names{1};

oldSplitInds = false(size(chainsMatTot));

for a = 1 : length(chainsMatTot)-1
    orig_trueNum = strsplit(chainsMatTot(a).trueNumber, '_');
    if strcmp(chainsMatTot(a).names{1}, fname) && strcmp(orig_trueNum{1}, trueNum) && length(orig_trueNum) > 1
        oldSplitInds(a) = true;
    end
end

if any(oldSplitInds)
    disp('Removing Old Splits:');
    oldNums = [chainsMatTot(oldSplitInds).num];
    disp(oldNums);
    pairsMatrix(oldNums, oldNums) = false;
    chainsMatTot = chainsMatTot(~oldSplitInds);
end

