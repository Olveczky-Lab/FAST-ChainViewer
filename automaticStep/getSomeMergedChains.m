 function chains = getSomeMergedChains(fpath, ChGroup, chainNums, getwv, padwv)

if nargin < 4
    getwv = 1;
    padwv = 1;
elseif nargin < 5
    padwv = 1;
end

getwv = logical(getwv);
padwv = logical(padwv);

samp = 64;
psamp = 32;

if getwv
    chains = struct('num', [], 'times', [], 'amps', [], 'wv', []);
else
    chains = struct('num', [], 'times', []);
end

fullpath = [fpath '\ChGroup_' num2str(ChGroup) '\MergedChains\'];
    
nchains = length(chainNums);

% Get channel validity for this ChGroup
[nCh, ChVec] = getNChans(fpath, ChGroup);

if ~isempty(chainNums)
    chains(nchains).num = '';
    chains(nchains).times = [];
    chains(nchains).amps = [];
    chains(nchains).wv = [];
    
    % Read in spike times, amps, wv for every chain
    for c = 1 : nchains
        chains(c).num = chainNums{c};
        
         % Spike times
        tfid = fopen([fullpath chainNums{c} '.stimes'], 'r', 'l');
        chains(c).times = fread(tfid, inf, 'uint64=>uint64');
        fclose(tfid);
        
        if getwv
            % WV and amps
            wvfid = fopen([fullpath chains(c).num '.wv'], 'r', 'l');
            tempwv = fread(wvfid, inf, 'int16=>int16');
            fclose(wvfid);

            tempwv = reshape(tempwv, nCh, samp, length(tempwv)/(nCh*samp));
            tempwv = permute(tempwv, [3 1 2]);
            
            if padwv
                wv = zeros(length(chains(c).times),4,samp,'int16');
                wv(:,ChVec,:) = tempwv;
            else
                wv = tempwv;
            end
            
            chains(c).wv = wv;
            amps = squeeze(wv(:,:,psamp));
            chains(c).amps = double(amps)*1.95e-7;
        end
    
    end
    
    [~,I] = sort(chainNums);
    chains = chains(I);
end

