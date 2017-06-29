function L2chainSplits = getL2Splits(chains, L1chainSplits, datadir)

for c = 1 : length(chains)
    % Load real L2 chain times
    thisL2Chain = getSomeLevel2Spikes([datadir chains(c).names{:}], chains(c).channel, mat2cell(chains(c).trueNumber, 1), 1);
    
    [~, L2inL1ind] = intersect(L1chainSplits(c).times, thisL2Chain.times);
    
    if length(L2inL1ind) == length(thisL2Chain.times)
        chains(c).splits = L1chainSplits(c).splits(L2inL1ind);
    else
        disp(['Incomplete L2 match for chain ' num2str(chains(c).num)]); 
        chains(c).splits = [];
    end
end

L2chainSplits = chains;