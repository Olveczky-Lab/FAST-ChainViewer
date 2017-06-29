function plotCluster(chains, cluster, channels, size, color)

hold all
chains = chains(ismember([chains.num], cluster));

for a = 1 : length(chains)
    chains(a).color = repmat(color, length(chains(a).times), 1);
end
amps = vertcat(chains.amps);

for channel = channels
    if ~isempty(amps)
        scatter(vertcat(chains.times), double(amps(:,channel))*1.95e-7, size*6, vertcat(chains.color),'.'); 
    else
        warning('off', 'MATLAB:handle_graphics:exceptions:SceneNode');
        scatter(vertcat(chains.times), amps, size*6, vertcat(chains.color),'.'); 
    end    
end

xlabel('Time');