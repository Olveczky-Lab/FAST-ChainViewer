function [energyList] = energyDetermination(chainsMatTot, channel)
% Compute the energy of the waveforms for the spikes in chainsMatTot.

energyList = {};
for chain = 1 : length(chainsMatTot)
    chainSelected = chainsMatTot(chain);
    energy = squeeze(sqrt(sum(chainSelected.wv(:, channel, :).^2, 3))) / sqrt(size(chainSelected.wv, 3));
    energyList{end + 1} = {energy, chainSelected.times, chainSelected.color};
end
