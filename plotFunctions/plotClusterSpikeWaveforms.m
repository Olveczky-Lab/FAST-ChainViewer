function plotClusterSpikeWaveforms(chains, cluster, color)
% This function allows to plot the spikes waveforms of one cluster. 
hold on;
axis auto;
chains = chains(ismember([chains.num], cluster));

for a = 1 : length(chains)
    wv = double(chains(a).wv(:, :, :)) * 1.95e-7;
    wvSqueezeMean = squeeze(mean(wv));
    wvSqueezeMeanTransp = wvSqueezeMean';
    for ch = 1 : 4
        line((ch-1)*64 + (0:63), squeeze(wvSqueezeMeanTransp(:,ch)), 'color', color, 'LineWidth', 0.1)
    end
    %         plot(wvSqueezeMeanTransp(:), 'color', listChains(a).color)
end
xlim([0, 255])
ylabel('V');
end
    
    
    
    
