function [bytes, chainNames] = getAllMergedChainsSize(fpath, ChGroup, padwv)
% Get size of merged chains time + wv + amps 

if nargin < 3
    padwv = 1;
end

samp = 64;

fullpath = [fpath '/ChGroup_' num2str(ChGroup) '/MergedChains/'];

% Get number of spikes
chains = dir([fullpath '*.stimes']);
chainNames = cellfun(@(x) x(1:end-7), {chains.name}, 'unif', 0);

if ~isempty(chains)
    nspikes = sum([chains.bytes])/8;

    bytes = nspikes*8;

    if padwv == 1
        nCh = 4;
    else
        % Get channel validity for this ChGroup
        nCh = getNChans(fpath, ChGroup); 
    end

    bytes = bytes + nspikes*nCh*samp*2 + nspikes*nCh*8; % Add wv and amp sizes

else
    bytes = 0;
end

end

