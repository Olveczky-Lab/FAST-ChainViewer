function [handles] = replaceChainWithSplits(handles, chains, L1chainSplits, L2chainSplits)

samprate = 30000;
chainsMatTot = handles.chainsMatTot;
pairsMatrix = handles.pairsMatrix;
datadir = handles.pathBasic;
manualMod = handles.manualModifications;

clusterVecAll = handles.clusterVecAll;
clustersChecked = handles.clustersChecked;

for c = 1 : length(chains)
    chainpath = [datadir chains(c).names{:} '/ChGroup_' num2str(chains(c).channel) '/MergedChains/' chains(c).trueNumber];
    
    if ~isempty(L1chainSplits(c).splits) && max(L1chainSplits(c).splits) > 0 && max(L2chainSplits(c).splits) == max(L1chainSplits(c).splits)
        % Read in snums and L2 snums for this chain
        L2snumsfid = fopen([chainpath '.l2snums'], 'r', 'l');
        L2snums = fread(L2snumsfid, inf, 'uint64=>uint64');
        fclose(L2snumsfid);

        snumsfid = fopen([chainpath '.snums'], 'r', 'l');
        snums = fread(snumsfid, inf, 'uint64=>uint64');
        fclose(snumsfid);

        % Write new files for each split in data directory
        L1splits = L1chainSplits(c).splits;
        L2splits = L2chainSplits(c).splits;
        nsplits = double(max(L1splits));
        
        L2background = chainsMatTot(end);
        chainsMatTot = chainsMatTot(1:end-1);
        newNums = [];
        for n = 1 : nsplits
            splitpath = [chainpath '_' num2str(n)];
            % times file
            spL1times = L1chainSplits(c).times(L1splits == n);
            tfid = fopen([splitpath '.stimes'], 'w', 'l');
            fwrite(tfid, spL1times, 'uint64');
            fclose(tfid);
            
            % snums file
            snumfid = fopen([splitpath '.snums'], 'w', 'l');
            fwrite(snumfid, snums(L1splits == n), 'uint64');
            fclose(snumfid);
            
            % wv file
            splitwv = int16(L1chainSplits(c).wv(L1splits == n,:,:));
            splitwv = permute(splitwv, [2 3 1]);
            
            wvfid = fopen([splitpath '.wv'], 'w', 'l');
            fwrite(wvfid, splitwv(:), 'int16');
            fclose(wvfid);
            
            % L2snums files
            L2snumfid = fopen([splitpath '.l2snums'], 'w', 'l');
            fwrite(L2snumfid, L2snums(L2splits == n), 'uint64');
            fclose(L2snumfid);
            
            % Add splits to end of L2chainsMatTot
            chainsMatTot(end+1) = chains(c);
            chainsMatTot(end).num = chainsMatTot(end-1).num + 1;
            newNums = [newNums chainsMatTot(end).num];
            chainsMatTot(end).times = chains(c).times(L2splits == n);
            chainsMatTot(end).amps = chains(c).amps(L2splits == n,:);
            chainsMatTot(end).timeBegin = chains(c).timeBegin + double(spL1times(1) - L1chainSplits(c).times(1))/(3600*samprate);
            chainsMatTot(end).wv = chains(c).wv(L2splits == n,:,:);
            chainsMatTot(end).features.energy = chains(c).features.energy(L2splits == n,:);
            chainsMatTot(end).features.valley = chains(c).features.valley(L2splits == n,:);
            chainsMatTot(end).features.width = chains(c).features.width(L2splits == n,:);
            chainsMatTot(end).features.pc1 = chains(c).features.pc1(L2splits == n,:);
            chainsMatTot(end).features.pc2 = chains(c).features.pc2(L2splits == n,:);
            
            chainsMatTot(end).trueNumber = [chains(c).trueNumber '_' num2str(n)];
            chainsMatTot(end).color = colorSelection;
            if numel(chainsMatTot(end).times) > 100
                spL1times = double(spL1times) / 30000;
                chainsMatTot(end).isi = sgolayfilt(histc(diff(spL1times), logspace(-3, 3, 100)), 3, 9) / length(spL1times);        
            else
                chainsMatTot(end).isi = zeros(100,1) * NaN;
            end
            midInd = ceil(length(chainsMatTot(end).times) / 2);
            chainsMatTot(end).centroid = [chainsMatTot(end).times(midInd), double(chainsMatTot(end).amps(midInd,:))];
            chainsMatTot(end).numSpikes = length(spL1times);
        end
        chainsMatTot(end+1) = L2background;
        
        % Add rows and columns to pairsMatrix
        oldpairsMatrix = pairsMatrix;
        pairsMatrix = false(chainsMatTot(end-1).num + 1);
        pairsMatrix(1:size(oldpairsMatrix,1), 1:size(oldpairsMatrix,2)) = oldpairsMatrix;
        
        % delete links to old chain
        manualMod{end+1} = [chains(c).num, -1, 2];
        manualMod{end+1} = [-1, chains(c).num, 2];
        
        % Replace old chain num with new chain nums in clusterVecAll
        for clust = 1 : size(clusterVecAll,2)
            clustNums = clusterVecAll{1, clust};
            cInd = clustNums == chains(c).num;
            if any(cInd)
                clustNums = clustNums(~cInd);
                clustNums = [clustNums newNums];
                clusterVecAll{1, clust} = clustNums;
            end
        end
        
        % Replace old chain num with new chain nums in clustersChecked
        for clust = 1 : size(clustersChecked,2)
            clustNums = clustersChecked{1, clust};
            cInd = clustNums == chains(c).num;
            if any(cInd)
                clustNums = clustNums(~cInd);
                clustNums = [clustNums newNums];
                clustersChecked{1, clust} = clustNums;
            end
        end
        
        disp(['Chain ' num2str(chains(c).num) ' replaced.']);    
    else
        disp(['Chain ' num2str(chains(c).num) ' cannot be replaced; split files missing.']);
    end
end

handles.pairsMatrix = pairsMatrix;
handles.chainsMatTot = chainsMatTot;
handles.manualModifications = manualMod;
handles.clusterVecAll = clusterVecAll;
handles.clustersChecked = clustersChecked;