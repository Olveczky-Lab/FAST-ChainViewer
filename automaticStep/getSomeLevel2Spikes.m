function [L2chains] = getSomeLevel2Spikes(fpath, ChGroup, chainNums, padwv)

if nargin < 4
    padwv = 1;
end
padwv = logical(padwv);

samp = 64;
psamp = 32;

L2chains = struct('num', [], 'times', [], 'amps', [], 'wv', []);

% Get channel validity for this ChGroup
[nCh, ChVec] = getNChans(fpath, ChGroup);

% Load in all Level 2 spike times for this file and ChGroup
L2tfid = fopen([fpath '/ChGroup_' num2str(ChGroup) '/Level2/SpikeTimesRaw'], 'r', 'l');
L2times = fread(L2tfid, inf, 'uint64=>uint64');
fclose(L2tfid);

% Load all Level 2 waveforms and spike amps for this file and ChGroup
L2wvfid = fopen([fpath '/ChGroup_' num2str(ChGroup) '/Level2/Spikes'], 'r', 'l');
tempL2wv = fread(L2wvfid, inf, 'int16=>int16');
fclose(L2wvfid);
tempL2wv = reshape(tempL2wv, nCh, samp, length(tempL2wv)/(nCh*samp));
tempL2wv = permute(tempL2wv, [3 1 2]);
if padwv
    L2wv = int16(zeros(size(tempL2wv,1),4,samp));
    L2wv(:,ChVec,:) = tempL2wv;
else
    L2wv = tempL2wv;
end

L2amps = squeeze(L2wv(:,:,psamp));

% Assign L2 spikes to chains
for chn = 1 : length(chainNums)
    % Read in L2 indices for this chain  
    L2fid = fopen([fpath '/ChGroup_' num2str(ChGroup) '/MergedChains/' chainNums{chn} '.l2snums'], 'r', 'l');
    L2nums = fread(L2fid, inf, 'uint64=>uint64');
    fclose(L2fid);
    
    L2chains(chn).num = chainNums{chn};
    L2chains(chn).times = L2times(L2nums+1);
    L2chains(chn).amps = L2amps(L2nums+1,:);
    L2chains(chn).wv = L2wv(L2nums+1,:,:);    
end