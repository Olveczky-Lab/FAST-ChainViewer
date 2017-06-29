function [wv1, wv2] = plotOneSpikeWaveform(chainsMatTot, chain1num, compareToChain, spikeInd, thickness)
% Plot a single waveform of a chain to compare to another chain

if nargin < 5
    thickness = 0.5;
end

hold on;
axis auto;

wv2 = [];

chains(1) = chainsMatTot([chainsMatTot.num] == chain1num);
if ~isempty(compareToChain)
    chains(2) = chainsMatTot([chainsMatTot.num] == compareToChain);
    
    % Find comparison chain spike closest in time 
    [~, compareInd] = min(abs(double(chains(2).times) - double(chains(1).times(spikeInd))));
    wv2 = squeeze(double(chains(2).wv(compareInd, :, :)) * 1.95e-7)';
    for ch = 1 : 4
        line((ch-1)*64 + (0:63), squeeze(wv2(:,ch)), 'color', chains(2).color, 'LineWidth', thickness)
    end
end

wv1 = squeeze(double(chains(1).wv(spikeInd, :, :)) * 1.95e-7)';
for ch = 1 : 4
    line((ch-1)*64 + (0:63), squeeze(wv1(:,ch)), 'color', chains(1).color, 'LineWidth', thickness)
end
    %         plot(wvSqueezeMeanTransp(:), 'color', listChains(a).color)
    
    
xlim([0, 255])
end
    
    
    
    
