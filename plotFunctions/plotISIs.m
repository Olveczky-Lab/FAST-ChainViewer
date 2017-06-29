function plotISIs(chains, thickness)
% This function allows to plot the ISIs of one or more chains
if nargin < 2
    thickness = 0.5;
end

axis auto;
hold on;

allisi = zeros(length(chains), numel(chains(1).isi));
for c = 1 : length(chains)
    allisi(c,:) = chains(c).isi(:)';
end
allisi(isnan(allisi)) = 0;

% allisi = vertcat(chains.isi);
semilogx([2e-3, 2e-3], [0, max(allisi(:))*1.2], '--', 'color', [0  0  0]);

for a = 1 : length(chains)
    semilogx(logspace(-3, 3, 100), chains(a).isi, 'color', chains(a).color, 'LineWidth', thickness);
end
xlim([1e-3 1e3])
ylim([0 inf]);
xlabel('ISI (s)');
set(gca, 'XScale', 'log');
end
    
    
    
    
