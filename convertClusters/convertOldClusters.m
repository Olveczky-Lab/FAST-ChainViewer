function cluster = convertOldClusters(loaddir, ChGroup)

loadpath = [loaddir '/ChGroup_' num2str(ChGroup) '/'];

% Load modified chainsMatTot
chainsMatTotOld = load([loadpath 'L2chainsMatTotAllBis.mat']);
chainsMatTotOld = chainsMatTotOld.L2chainsMatTotAll;
clear L2chainsMatTotAll;

chainsMatTotNew = load([loadpath 'L2chainsMatTotAll.mat']);
chainsMatTotNew = chainsMatTotNew.L2chainsMatTotAll;
clear L2chainsMatTotAll;

% Load old cluster info
clusterOld = load([loadpath 'clusterVecAll.mat']);
clusterOld = clusterOld.cluster;
clear cluster;

%% Update clusters

cluster = struct; % New cluster struct

% First add split chains to chainsMatTotNew
splitInd = find(~cellfun(@isempty, strfind({chainsMatTotOld.trueNumber},'_')));
splitChains = chainsMatTotOld(splitInd);
newSplitNums = num2cell(chainsMatTotNew(end-1).num + (1:length(splitInd)));
[splitChains.num] = deal(newSplitNums{:});
splitChains = rmfield(splitChains, {'cluster_mode_1','cluster_mode_2'});

chainsMatTotNew = [chainsMatTotNew(1:end-1); splitChains; chainsMatTotNew(end)];

% Get translation list from old chain numbers to new chain numbers
newNumList = updateChainNumList(chainsMatTotOld(1:end-1), chainsMatTotNew(1:end-1));

% Update clusterVecAll
cluster.clusterVecAll = clusterOld.clusterVecAll;
for c = 1 : length(cluster.clusterVecAll)
    cluster.clusterVecAll{1,c} = newNumList(clusterOld.clusterVecAll{1,c} + 1); 
end

% Update clustersChecked
cluster.clustersChecked = clusterOld.clustersChecked;
for c = 1 : length(cluster.clustersChecked)
    cluster.clustersChecked{1,c} = newNumList(clusterOld.clustersChecked{1,c} + 1); 
end

% Update manualClusters
cluster.manualClusters = clusterOld.manualClusters;
for c = 1 : length(cluster.manualClusters)
    cluster.manualClusters{1,c} = newNumList(clusterOld.manualClusters{1,c} + 1); 
end

% Update manualModifications
cluster.manualModifications = clusterOld.manualModifications;
for c = 1 : length(cluster.manualModifications)
    Mod = clusterOld.manualModifications{c};
    Mod(Mod(1:2) >= 0) = newNumList(Mod(Mod(1:2)>= 0)+1);
    cluster.manualModifications{c} = Mod;
end

% Update linksMatrix
load([loadpath 'linksMatrix.mat']);
cluster.linksMatrix = linksMatrix;

% Update pairsMatrix
pairsMatrixOld = clusterOld.pairsMatrix;

pairsMatrixNew = false(max([chainsMatTotNew.num])+1);
orows = find(any(pairsMatrixOld,2)); % non zero rows
ocols = find(any(pairsMatrixOld,1)); % non zero columns
pairsMatrixNew(newNumList(orows)+1, newNumList(ocols)+1) = pairsMatrixOld(orows, ocols);

cluster.pairsMatrix = pairsMatrixNew;


