function [linksMatrix, singleCluster] = chainsClusteringLinkFast(chainsMatTot, linksMatrix, singleCluster)
% This function allows to create a submatrix which contains the relations
% between all of the chains two by two. Each element of the matrix is a
% cell with the different statistics of the relations between the two
% chains, which are the two coordinates of the matrix. 

% params
withinFileCutOff = 5;
acrossFileCutoff = 25;
lengthCutOff = 100; % spikes

% Calculate metrics for each feature, chain by chain
metrix = struct;
for a = 1 : length(chainsMatTot)
    if length(chainsMatTot(a).times) > lengthCutOff
        % selectInd
        metrix(a).selectInd = min([round(0.1*length(chainsMatTot(a).times)) 100]);
        metrix(a).startTime = chainsMatTot(a).times(metrix(a).selectInd);
        metrix(a).endTime = chainsMatTot(a).times(end-metrix(a).selectInd+1);

        % wv
        goodChan = squeeze((sum(sum(abs(chainsMatTot(a).wv),3),1))) > 0;
        
        wv1mean = squeeze(mean(double(chainsMatTot(a).wv(1:metrix(a).selectInd, :, :)) * 1.95e-7));
        wv2mean = squeeze(mean(double(chainsMatTot(a).wv((end-metrix(a).selectInd+1):end, :, :)) * 1.95e-7));
        wv1mean(~goodChan,:) = NaN;
        wv2mean(~goodChan,:) = NaN;
        metrix(a).wv1mean = wv1mean(:)';
        metrix(a).wv2mean = wv2mean(:)';

        metrix(a).wv1std = squeeze(std(double(chainsMatTot(a).wv(1:metrix(a).selectInd, goodChan, :)) * 1.95e-7));
        metrix(a).wv2std = squeeze(std(double(chainsMatTot(a).wv((end-metrix(a).selectInd+1):end, goodChan, :)) * 1.95e-7));
        metrix(a).wv1std = sum(metrix(a).wv1std(:))';
        metrix(a).wv2std = sum(metrix(a).wv2std(:))';

        % ISI
        times = ((double(chainsMatTot(a).times)  * 60) * 60) * 1000;
        metrix(a).isi = sgolayfilt(histc(diff(times), logspace(0, 6, 100)), 3, 9);  
    else
        metrix(a).selectInd = NaN;
        metrix(a).startTime = NaN;
        metrix(a).endTime = NaN;
    end
end

% Look for before and after links for each chain
for a = 1 : length(chainsMatTot)
    % Before chains
    beforeChains1 = strcmp(chainsMatTot(a).names{1}, [chainsMatTot.names]) & abs(metrix(a).startTime - [metrix.endTime]) < withinFileCutOff;
    beforeChains2 = ~strcmp(chainsMatTot(a).names{1}, [chainsMatTot.names]) & (metrix(a).startTime-[metrix.endTime]) < acrossFileCutoff & metrix(a).startTime > [metrix.endTime];
    beforeChains3 = metrix(a).endTime > [metrix.endTime];
    beforeChains = find((beforeChains1 | beforeChains2) & beforeChains3);
    
    if ~isempty(beforeChains)
        % wv comparison
        wvDist = sqrt(nansum((vertcat(metrix(beforeChains).wv2mean) - repmat(metrix(a).wv1mean,length(beforeChains),1)).^2, 2));
        wvStd2 = repmat(metrix(a).wv1std,length(beforeChains),1);
        wvStd1 = vertcat(metrix(beforeChains).wv2std);
        wvCorr = zeros(length(beforeChains),1);
        isiCorr = zeros(length(beforeChains),1);
        lengthRow = zeros(length(beforeChains),1);
        for b = 1 : length(beforeChains)
            wvCorr(b) = corr(metrix(a).wv1mean', metrix(beforeChains(b)).wv2mean', 'rows', 'pairwise');
            isiCorr(b) = corr(metrix(a).isi, metrix(beforeChains(b)).isi, 'rows', 'pairwise');
            lengthRow(b) = numel(chainsMatTot(beforeChains(b)).times);
        end
        
        timeDifference = metrix(a).startTime - vertcat(metrix(beforeChains).endTime);
        chainCol = repmat(chainsMatTot(a).num, length(beforeChains), 1);
        chainRow = vertcat(chainsMatTot(beforeChains).num);
        lengthCol = repmat(numel(chainsMatTot(a).times), length(beforeChains),1);
        
        linksProperties = [chainRow, chainCol, wvDist, wvStd1, wvStd2, wvCorr, timeDifference, lengthRow, lengthCol, isiCorr];
        linksMatrix = [linksMatrix; linksProperties];
    end
    
    % After chains
    afterChains1 = strcmp(chainsMatTot(a).names{1}, [chainsMatTot.names]) & abs([metrix.startTime] - metrix(a).endTime) < withinFileCutOff;
    afterChains2 = ~strcmp(chainsMatTot(a).names{1}, [chainsMatTot.names]) & ([metrix.startTime]-metrix(a).endTime) < acrossFileCutoff & [metrix.startTime] > metrix(a).endTime;
    afterChains3 = metrix(a).endTime < [metrix.endTime];
    afterChains = find((afterChains1 | afterChains2) & afterChains3);
    
    if ~isempty(afterChains)
        wvDist = sqrt(nansum((vertcat(metrix(afterChains).wv1mean) - repmat(metrix(a).wv2mean,length(afterChains),1)).^2, 2));
        wvStd1 = repmat(metrix(a).wv2std,length(afterChains),1);
        wvStd2 = vertcat(metrix(afterChains).wv1std);
        wvCorr = zeros(length(afterChains),1);
        isiCorr = zeros(length(afterChains),1);
        lengthCol = zeros(length(afterChains),1);
        for b = 1 : length(afterChains)
           wvCorr(b) = corr(metrix(a).wv2mean', metrix(afterChains(b)).wv1mean', 'rows', 'pairwise');
           isiCorr(b) = corr(metrix(a).isi, metrix(afterChains(b)).isi, 'rows', 'pairwise');
           lengthCol(b) = numel(chainsMatTot(afterChains(b)).times);
        end
        
        timeDifference = vertcat(metrix(afterChains).startTime) - metrix(a).endTime;
        chainRow = repmat(chainsMatTot(a).num, length(afterChains), 1);
        chainCol = vertcat(chainsMatTot(afterChains).num);
        lengthRow = repmat(numel(chainsMatTot(a).times), length(afterChains),1);
        
        linksProperties = [chainRow, chainCol, wvDist, wvStd1, wvStd2, wvCorr, timeDifference, lengthRow, lengthCol, isiCorr];
        linksMatrix = [linksMatrix; linksProperties];
    end
    
    if isempty([beforeChains afterChains]) && ~isnan(metrix(a).selectInd)
        singleCluster{end+1} = chainsMatTot(a);
    end
end

% Remove repeated rows

% [~, ind] = unique(linksMatrix(:,1:2), 'rows');
% linksMatrix = linksMatrix(ind,:);


            
                
            
            
            
            
