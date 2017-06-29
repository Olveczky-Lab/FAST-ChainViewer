function [L2chains] = getLevel2BackgroundSpikes(fpath, ChGroup, padwv)
% This function allows to load the level 2 spikes.

if nargin < 3
    padwv = 1;
end
padwv = logical(padwv);

samp = 64;
psamp = 32;

L2chains = struct('num', [], 'times', [], 'amps', [], 'wv', []);

% Get channel validity for this ChGroup
nCh = getNChans(fpath, ChGroup);

% Load in all Level 2 spike times
L2tfid = fopen([fpath '/ChGroup_' num2str(ChGroup) '/Level2/SpikeTimesRaw'], 'r', 'l');
if L2tfid ~= -1
    L2times = fread(L2tfid, inf, 'uint64=>uint64');
    fclose(L2tfid);

    % Load all Level 2 waveforms and spike amps
    L2wvfid = fopen([fpath '/ChGroup_' num2str(ChGroup) '/Level2/Spikes'], 'r', 'l');
    tempL2wv = fread(L2wvfid, inf, 'int16=>int16');
    fclose(L2wvfid);
    tempL2wv = reshape(tempL2wv, nCh, samp, length(tempL2wv)/(nCh*samp));
    tempL2wv = permute(tempL2wv, [3 1 2]);
    if padwv
        L2wv = int16(zeros(size(tempL2wv,1),4,samp));
        L2wv(:, 1:nCh,:) = tempL2wv;
    else
        L2wv = tempL2wv;
    end

    L2amps = squeeze(L2wv(:,:,psamp));

    % Only chain is all L2 spikes
    L2chains.num = -1;
    L2chains.times = L2times;
    L2chains.amps = L2amps;
    L2chains.wv = L2wv; 
end