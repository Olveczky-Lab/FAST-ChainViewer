function [extractChains, extractInd] = chainsExtractionAlgo(chains)
% This function allows to extract the chains with an high amplitude.
    threshold_plus = 75e-6;
	threshold_minus = -100e-6;
    newChains = [];
    extractInd = [];
    
    for b = 1 : length(chains)       
		[maxamp,maxchan] = max(mean(abs(chains(b).amps),1));
		
        condition_plus = all(sign(chains(b).amps(:,maxchan)) == 1) && mean(chains(b).amps(:,maxchan)) >= threshold_plus; 
		condition_minus = all(sign(chains(b).amps(:,maxchan)) == -1) && mean(chains(b).amps(:,maxchan)) <= threshold_minus; 
		condition_plusminus = xor(all(sign(chains(b).amps(:,maxchan)) == 1), any(sign(chains(b).amps(:,maxchan)) == 1));  
		condition_plusminus = condition_plusminus && maxamp >= min(abs([threshold_plus threshold_minus]));
		
		if any([condition_plus condition_minus condition_plusminus])
			chains(b).times = (((chains(b).times / 30000) / 60) / 60);
			newChains = [newChains, chains(b)];
            extractInd = [extractInd, b];
        end
    end
    extractChains = newChains;
end

    
