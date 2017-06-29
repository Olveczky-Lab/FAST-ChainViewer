function plotChainCentroids(chains, channels, size)

hold all
if ~isempty(chains)
    centroids = vertcat(chains.centroid);
    
    for channel = channels
        scatter(centroids(:,1), double(centroids(:,1+channel))*1.95e-7, size*6, vertcat(chains.color),'s'); 
    end
end
xlabel('Time');