function plotSpikeWaveforms(listChains, thickness)
% This function allows to plot the spikes waveforms of one cluster. 

if nargin < 2
    thickness = 0.5;
end

hold on;
axis auto;
for a = 1 : length(listChains)
    wv = double(listChains(a).wv(:, :, :)) * 1.95e-7;
    wvSqueezeMean = squeeze(mean(wv));
    wvSqueezeMeanTransp = wvSqueezeMean';
    for ch = 1 : 4
        line((ch-1)*64 + (0:63), squeeze(wvSqueezeMeanTransp(:,ch)), 'color', listChains(a).color, 'LineWidth', thickness)
    end
    %         plot(wvSqueezeMeanTransp(:), 'color', listChains(a).color)
end
xlim([0, 255])
end
    
    
    
    
