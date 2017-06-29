function translateClusters(sourceFolder, targetFolder, ChGroups)

addpath('./plotFunctions/');
datapath = getDataPath(sourceFolder);
cluster = struct;

for ChGroup = ChGroups
    disp(['ChGroup ' num2str(ChGroup)]);
    
    if (exist([sourceFolder 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAllBis.mat'], 'file') ==  2) && ...
            (exist([targetFolder 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAll.mat'], 'file') ==  2) && ...
            (exist([sourceFolder 'ChGroup_' num2str(ChGroup) '\clusterVecAll.mat'], 'file') ==  2)
        
        load([sourceFolder 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAllBis.mat']);
        SchainsMatTot = L2chainsMatTotAll;
        clear L2chainsMatTotAll;
        
        load([sourceFolder 'ChGroup_' num2str(ChGroup) '\clusterVecAll.mat']);
        Scluster = cluster;
        clear cluster;
        
        load([targetFolder 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAll.mat']);
        TchainsMatTot = L2chainsMatTotAll;
        clear L2chainsMatTotAll;
        
        load([targetFolder 'ChGroup_' num2str(ChGroup) '\linksMatrix.mat']);
        
        addpath([pwd '/clusteringFunctions']);
        
        % Get target chainsMatTot up to (in struct fields)
        % Calculate chain centroids
        if ~isfield(TchainsMatTot, 'centroid');
            TchainsMatTot = getChainCentroids(TchainsMatTot);
            disp('Centroids computed');
        end

        % Calculate ISIs if they are missing
        if ~isfield(TchainsMatTot, 'isi')
            for c = 1 : length(TchainsMatTot)-1
                TchainsMatTot(c).isi = getIsi(TchainsMatTot(c), datapath); 
            end
            disp('ISIs computed');
        end
        
        % Get num of spikes for each chain
        if ~isfield(TchainsMatTot, 'numSpikes')
            for c = 1 : length(TchainsMatTot)-1
                TchainsMatTot(c).numSpikes = getChainLength(linksMatrix, TchainsMatTot(c).num);
            end
        end
        
        [TchainsMatTot.cluster_mode_1] = deal([0,0,0]);
        [TchainsMatTot.cluster_mode_2] = deal([0,0,0]);
        
        % Append split clusters to target chainsMat
        splitChains = SchainsMatTot(cellfun(@(x) ~isempty(strfind(x, '_')), {SchainsMatTot.trueNumber}));
        for c = 1 : length(splitChains)
            splitChains(c).num = c + TchainsMatTot(end-1).num;
        end
        
        if ~isfield(splitChains, 'firstFile')
           for c = 1 : length(splitChains)
              splitChains(c).firstFile = TchainsMatTot(1).firstFile;
           end
        end
        
        if ~isempty(splitChains)
            TchainsMatTot = [TchainsMatTot(1:end-1); splitChains; TchainsMatTot(end)];
        end
        
        % Get list of chainNums to translate from source to target
        slist = zeros(length(SchainsMatTot)-1,2)*NaN;
        for x = 1 : length(SchainsMatTot)-1
            slist(x,1) = SchainsMatTot(x).num;
            slist(x,2) = TchainsMatTot(find(strcmp([TchainsMatTot.names], SchainsMatTot(x).names) & ...
                strcmp({TchainsMatTot.trueNumber}, SchainsMatTot(x).trueNumber), 1, 'first')).num;
        end
    
        % Translate clusters from source to target
        clusterVecAll = Scluster.clusterVecAll;
        for x = 1 : size(clusterVecAll,2)
            newNums = clusterVecAll{1,x};
            clusterVecAll{1,x} = slist(ismember(slist(:,1), newNums), 2)';
        end
        
        manualModifications = Scluster.manualModifications;
        mcount = 1;
        for x = 1 : length(manualModifications)
            manMod = manualModifications{x};
            if ~isempty(find(slist(:,1) == manMod(1),1)) && ~isempty(find(slist(:,1) == manMod(2),1))
                manMod(1) = slist(find(slist(:,1) == manMod(1),1),2);
                manMod(2) = slist(find(slist(:,1) == manMod(2),1),2);
                manualModifications{mcount} = manMod;
                mcount = mcount+1;
            end
        end
    
        manualClusters = Scluster.manualClusters;
        for x = 1 : size(manualClusters,2)
            newNums = manualClusters{1,x};
            manualClusters{1,x} = slist(ismember(slist(:,1), newNums), 2)';
        end
        
        clustersChecked = Scluster.clustersChecked;
        for x = 1 : size(clustersChecked,2)
            newNums = clustersChecked{1,x};
            clustersChecked{1,x} = slist(ismember(slist(:,1), newNums), 2)';
        end
    
        SpairsMatrix = Scluster.pairsMatrix;
        pairsMatrix = false(max(slist(:,2))+1);
        pairsMatrix(slist(:,2)+1, slist(:,2)+1) = SpairsMatrix(slist(:,1)+1, slist(:,1)+1);
        
        cluster = struct;
        cluster.clusterVecAll = clusterVecAll;
        cluster.linksMatrix = linksMatrix;        
        cluster.pairsMatrix = pairsMatrix;        
        cluster.manualModifications = manualModifications;
        cluster.manualClusters = manualClusters;
        cluster.clustersChecked = clustersChecked;
        
        % plot colours
        L2chainsMatTotAll = plotFunctionClusterAssignation(TchainsMatTot, clusterVecAll);
        save([targetFolder 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAllBis.mat'], 'L2chainsMatTotAll', '-v7.3');
        save([targetFolder 'ChGroup_' num2str(ChGroup) '\clusterVecAll.mat'], 'cluster', '-v7.3');
        
        if exist([sourceFolder 'ChGroup_' num2str(ChGroup) '\Split Chains'], 'dir') == 7
            if exist([targetFolder 'ChGroup_' num2str(ChGroup) '\Split Chains'], 'dir') ~= 7
                mkdir([targetFolder 'ChGroup_' num2str(ChGroup) '\Split Chains']);
            end
            % Copy split chain files
            % Get list of old splits
            sFiles = dir([sourceFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\*.clusters']);
            for sf = 1 : length(sFiles)
                chainNum = sFiles(sf).name(1:end-9);
                newChainNum = num2str(slist(find(slist(:,1) == str2double(chainNum),1),2));
                if ~isempty(newChainNum)
                    cFiles = dir([sourceFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\' chainNum '.*']);
                    for cf = 1 : length(cFiles)
                        extsn = strsplit(cFiles(cf).name, chainNum); 
                        extsn = extsn{2};
                        copyfile([sourceFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\' cFiles(cf).name], ...
                            [targetFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\' newChainNum extsn]);
                    end
                    cFiles = dir([sourceFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\' chainNum '_*']);
                    for cf = 1 : length(cFiles)
                        extsn = strsplit(cFiles(cf).name, chainNum); 
                        extsn = extsn{2};
                        copyfile([sourceFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\' cFiles(cf).name], ...
                            [targetFolder 'ChGroup_' num2str(ChGroup) '\Split Chains\' newChainNum extsn]);
                    end
                end
            end
        end
        
        clear L2chainsMatTotAll TchainsMatTot SchainsMatTot cluster Scluster pairsMatrix SpairsMatrix manualModifications linksMatrix;
    
    else
        disp('Source/target files do not exist. Skipping...');
    end
end
    
    
