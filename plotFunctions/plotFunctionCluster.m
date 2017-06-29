function plotFunctionCluster(cluster_mode, chainsMatTot, channel, clusterVecAll, dataTips, pointSize)
% Plot the chains in function of the cluster mode. 

v1 = num2str(cluster_mode(1));
v2 = num2str(cluster_mode(2));
v3 = num2str(cluster_mode(3));
cluster_mode = [v1 v2 v3];

switch cluster_mode
    case '000' % Normal mode.
        plotSpikeChains(chainsMatTot, 1, channel, pointSize);
    case '001' % Normal mode.
        plotSpikeChains(chainsMatTot, 1, channel, pointSize);        
    case '100' % Plot the cluster in a single color.
        for a = 1 : length(chainsMatTot)
            chainsMatTot(a).color = chainsMatTot(a).cluster_mode_1;
        end
        plotSpikeChains(chainsMatTot, 1, channel, pointSize)
    case '101' % Plot the checked clusters in a single color.
        clusCheckInd = find(cellfun(@(x) ~isempty(strfind(x, '*')), clusterVecAll(2,:)));
        for a = 1 : length(clusCheckInd)
            [~,~,clustChainsInd] = intersect(clusterVecAll{1, clusCheckInd(a)}, [chainsMatTot.num]);
            [chainsMatTot(clustChainsInd).color] = deal(chainsMatTot(clustChainsInd).cluster_mode_1);
        end
        plotSpikeChains(chainsMatTot, 1, channel, pointSize)        
    case '010' % Plot the clusters in a special color.
        for a = 1 : length(chainsMatTot)
            chainsMatTot(a).color = chainsMatTot(a).cluster_mode_2;
        end
        plotSpikeChains(chainsMatTot, 1, channel, pointSize)
    case '011' % Plot the checked clusters in a special color.
        [chainsMatTot(1 : (end - 1)).color] = deal([0, 0, 0]);
        clusCheckInd = find(cellfun(@(x) ~isempty(strfind(x, '*')), clusterVecAll(2,:)));
        for a = 1 : length(clusCheckInd)
            [~,~,clustChainsInd] = intersect(clusterVecAll{1, clusCheckInd(a)}, [chainsMatTot.num]);
            [chainsMatTot(clustChainsInd).color] = deal(chainsMatTot(clustChainsInd).cluster_mode_2);
        end
        plotSpikeChains(chainsMatTot, 1, channel, pointSize)  
end

% Customize data tips
if strcmp(dataTips, 'ON') == 1
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', {@dataTipText, chainsMatTot, clusterVecAll})
end


end


