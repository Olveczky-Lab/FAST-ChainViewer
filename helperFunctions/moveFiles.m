pathData = ['H:\Clustering\Dhanashri\ResultsTmp\ChGroup_1\'];
pathDest = ['U:\Data\Dhanashri\'];
load([pathData 'L2chainsMatTotAllBis.mat']);

indices = [];
for a = 1 : length(L2chainsMatTotAll)
    test = find(L2chainsMatTotAll(a).trueNumber == '_');
    if isempty(test) == 0
        indices = [indices, a];
    end
end

infoVec = [];
for a = 1 : length(indices)
    infoVec = [infoVec; L2chainsMatTotAll(indices(a)).trueNumber, L2chainsMatTotAll(indices(a)).names];
    areFilesThere = dir([pathData L2chainsMatTotAll(indices(a)).trueNumber '.*']);
    if ~isempty(areFilesThere)
        movefile([pathData L2chainsMatTotAll(indices(a)).trueNumber '.*'], [pathDest L2chainsMatTotAll(indices(a)).names{1} '/ChGroup_' num2str(L2chainsMatTotAll(indices(a)).channel) '/MergedChains/'])
    end
end