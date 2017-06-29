function [extractChains] = chainsExtractionAlgo(chains, threshold)
% This function allows to extract the chains with an high amplitude.
newChains = [];

for b = 1 : length(chains)
    if (any(sign(mean(double(chains(b).amps) * 1.95e-7, 1)) == 1)) & (any(mean(double(chains(b).amps) * 1.95e-7, 1) > 75e-6))
        chains(b).times = (((chains(b).times / 30000) / 60) / 60);
        newChains = [newChains, chains(b)];
    end
    if (any(sign(mean(double(chains(b).amps) * 1.95e-7, 1)) == -1)) & (any(mean(double(chains(b).amps) * 1.95e-7, 1) < threshold))
        chains(b).times = (((chains(b).times / 30000) / 60) / 60);
        newChains = [newChains, chains(b)];
    end
end
extractChains = newChains;
end

    
