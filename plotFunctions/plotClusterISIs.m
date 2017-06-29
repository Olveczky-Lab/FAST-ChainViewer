function plotClusterISIs(chains, cluster, color)
% This function allows to plot the ISIs of one cluster. 
hold on;
chains = chains(ismember([chains.num], cluster));

if ~isempty(chains)
    allisi = zeros(length(chains), numel(chains(1).isi));
    for x = 1 : length(chains)
        allisi(x,:) = chains(x).isi(:)';
    end
    allisi(isnan(allisi)) = 0;
else
    allisi = [];
end

semilogx([2e-3, 2e-3], [0, max(allisi(:))*1.2], '--', 'color', [0  0  0]);

for a = 1 : length(chains)
    semilogx(logspace(-3, 3, 100), chains(a).isi, 'color', color);
end
xlim([1e-3 1e3])
ylim([0, inf]);
xlabel('ISI (s)');
set(gca, 'XScale', 'log');
end
    
    
    
    
