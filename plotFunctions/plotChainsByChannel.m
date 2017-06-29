function plotChainsByChannel(chains, channelx, channely, size)
% Allow to plot a chain in function of two tetrodes. 
hold all
if ~isempty(chains)
    for a = 1 : length(chains)
        chains(a).color = repmat(chains(a).color, length(chains(a).times), 1);
    end
    
    amps = vertcat(chains.amps);
    scatter(double(amps(:, channelx))*1.95e-7, double(amps(:, channely))*1.95e-7, size*5, vertcat(chains.color), '.'); 
end

ylabel(['Ch' num2str(channely)]); xlabel(['Ch' num2str(channelx)]);