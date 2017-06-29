function [linksMatrix, singleCluster] = generateLinksMatrix(metrix, L2chainsMatTotAll)
%GENERATELINKSMATRIX construct linksMatrix from individual file metrix

linksMatrix = [];
singleCluster = {};

withinFileCutOff = 5;
acrossFileCutoff = 25;

% Look for before and after links for each chain
tic;
for a = 1 : length(metrix)                              
    if a/5000 == fix(a/5000); toc; disp([num2str(100*a/length(metrix)) ' % done']); tic; end
    
    % Before chains
    beforeChains1 = strcmp(metrix(a).fname, [metrix.fname]) & abs(metrix(a).startTime - [metrix.endTime]) < withinFileCutOff;
    beforeChains2 = ~strcmp(metrix(a).fname, [metrix.fname]) & (metrix(a).startTime-[metrix.endTime]) < acrossFileCutoff & metrix(a).startTime > [metrix.endTime];
    beforeChains3 = metrix(a).endTime > [metrix.endTime];
    beforeChains = find((beforeChains1 | beforeChains2) & beforeChains3);
    
    if ~isempty(beforeChains)
        % wv comparison
        wvDist = sqrt(nansum((vertcat(metrix(beforeChains).wv2mean) - repmat(metrix(a).wv1mean,length(beforeChains),1)).^2, 2));
        wvStd2 = repmat(metrix(a).wv1std,length(beforeChains),1);
        wvStd1 = vertcat(metrix(beforeChains).wv2std);
                
        wvCorr = corr(metrix(a).wv1mean', vertcat(metrix(beforeChains).wv2mean)', 'rows', 'pairwise')';
        isiCorr = corr(metrix(a).isi, [metrix(beforeChains).isi], 'rows', 'pairwise')';
        lengthRow = vertcat(metrix(beforeChains).ntimes);
        
        timeDifference = metrix(a).startTime - vertcat(metrix(beforeChains).endTime);
        chainCol = repmat(L2chainsMatTotAll(a).num, length(beforeChains), 1);
        chainRow = vertcat(L2chainsMatTotAll(beforeChains).num);
        lengthCol = repmat(metrix(a).ntimes, length(beforeChains),1);
        
        linksProperties = [chainRow, chainCol, wvDist, wvStd1, wvStd2, wvCorr, timeDifference, lengthRow, lengthCol, isiCorr];
        linksMatrix = [linksMatrix; linksProperties];
    end
    
    % After chains
    afterChains1 = strcmp(metrix(a).fname, [metrix.fname]) & abs([metrix.startTime] - metrix(a).endTime) < withinFileCutOff;
    afterChains2 = ~strcmp(metrix(a).fname, [metrix.fname]) & ([metrix.startTime]-metrix(a).endTime) < acrossFileCutoff & [metrix.startTime] > metrix(a).endTime;
    afterChains3 = metrix(a).endTime < [metrix.endTime];
    afterChains = find((afterChains1 | afterChains2) & afterChains3);
    
    if ~isempty(afterChains)
        wvDist = sqrt(nansum((vertcat(metrix(afterChains).wv1mean) - repmat(metrix(a).wv2mean,length(afterChains),1)).^2, 2));
        wvStd1 = repmat(metrix(a).wv2std,length(afterChains),1);
        wvStd2 = vertcat(metrix(afterChains).wv1std);
        
        wvCorr = corr(metrix(a).wv2mean', vertcat(metrix(afterChains).wv1mean)', 'rows', 'pairwise')';
        isiCorr = corr(metrix(a).isi, [metrix(afterChains).isi], 'rows', 'pairwise')';
        lengthCol = vertcat(metrix(afterChains).ntimes);
                
        timeDifference = vertcat(metrix(afterChains).startTime) - metrix(a).endTime;
        chainRow = repmat(L2chainsMatTotAll(a).num, length(afterChains), 1);
        chainCol = vertcat(L2chainsMatTotAll(afterChains).num);
        lengthRow = repmat(metrix(a).ntimes, length(afterChains),1);
        
        linksProperties = [chainRow, chainCol, wvDist, wvStd1, wvStd2, wvCorr, timeDifference, lengthRow, lengthCol, isiCorr];
        linksMatrix = [linksMatrix; linksProperties];
    end
    
    if isempty([beforeChains afterChains]) && ~isnan(metrix(a).selectInd)
        singleCluster{end+1} = metrix(a);
    end
end
toc;

end

