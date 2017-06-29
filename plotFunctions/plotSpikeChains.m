function plotSpikeChains(chains, cutoff, channels, size)

hold all
if ~isempty(chains)
    for a = 1 : length(chains)
        chains(a).color = repmat(chains(a).color, length(chains(a).times), 1);
    end
    amps = vertcat(chains.amps);
    
    for channel = channels
        scatter(vertcat(chains.times), double(amps(:,channel))*1.95e-7, size*6, vertcat(chains.color),'.'); 
    end
end
xlabel('Time');