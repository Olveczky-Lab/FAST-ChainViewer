function plotSpikeFeature(chains, cutoff, channelx, channely, size, feature)

hold all
if ~isempty(chains)
    for a = 1 : length(chains)
        chains(a).color = repmat(chains(a).color, length(chains(a).times), 1);
    end
    
    if strcmp(feature, 'amps') == 1
        eval(['features = vertcat(chains.' feature ') ;']);
    else
        eval(['features = [chains.features];']);
        eval(['features = vertcat(features.' feature ') ;']);
    end
    scatter(double(features(:,channelx))*1.95e-7, double(features(:,channely))*1.95e-7, size*5, vertcat(chains.color),'.'); 
end

ylabel(['Ch' num2str(channely)]);
xlabel(['Ch' num2str(channelx)])