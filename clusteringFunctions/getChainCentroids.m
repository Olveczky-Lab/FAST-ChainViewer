function chainsMatTot = getChainCentroids(chainsMatTot)

for c = 1 : length(chainsMatTot)
    midInd = ceil(length(chainsMatTot(c).times) / 2);
    chainsMatTot(c).centroid = [chainsMatTot(c).times(midInd), double(chainsMatTot(c).amps(midInd,:))];
end