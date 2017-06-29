function chains = getAllMergedChains(fpath, ChGroup, padwv, getwv)
% This function allows to load the complete data spikes.

if nargin < 3
    padwv = 1;
    getwv = 1;
elseif nargin < 4
    getwv = 1;
end

samp = 64;
psamp = 32;

padwv = logical(padwv);

if getwv == 1
    chains = struct('num', [], 'times', [], 'amps', [], 'wv', []);
else
    chains = struct('num', [], 'times', []);
end

fullpath = [fpath '/ChGroup_' num2str(ChGroup) '/MergedChains/'];
    
clist = dir(fullfile([fullpath '*.stimes']));

% Remove split chain names from list (look for '_')
keep = false(length(clist),1);
splitstring = '_';
for n = 1 : length(clist)
    if isempty(strfind(clist(n).name, splitstring))
        keep(n) = true;
    end
end
clist = clist(keep);
nchains = length(clist);

% Get channel validity for this ChGroup
[nCh, ChVec] = getNChans(fpath, ChGroup);

if ~isempty(clist) && nCh > 0
    chains(nchains).num = [];
    chains(nchains).times = [];
    chains(nchains).amps = [];
    chains(nchains).wv = [];
    
    % Read in spike times, amps, wv for every chain
    for x = 1 : length(clist)
        chains(x).num = str2num(clist(x).name(1:end-7));
        
        % Spike times
        tfid = fopen([fullpath clist(x).name], 'r', 'l');
        chains(x).times = fread(tfid, inf, 'uint64=>uint64');
        fclose(tfid);
        
        if getwv == 1
            % WV and amps
            wvfid = fopen([fullpath num2str(chains(x).num) '.wv'], 'r', 'l');
            tempwv = fread(wvfid, inf, 'int16=>int16');
            fclose(wvfid);

            tempwv = reshape(tempwv, nCh, samp, length(tempwv)/(nCh*samp));
            tempwv = permute(tempwv, [3 1 2]);

            if padwv
                wv = zeros(length(chains(x).times),4,samp,'int16');
                wv(:,ChVec,:) = tempwv;
            else
                wv = tempwv;
            end

            chains(x).wv = wv;
            amps = squeeze(wv(:,:,psamp));
            chains(x).amps = double(amps)*1.95e-7;
        end
    end
    
    [~,I] = sort([chains.num]);
    chains = chains(I);
end

