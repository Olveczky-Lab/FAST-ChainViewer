function chains = getSpikesListofChains(fpath, ChGroup, chnNums, getwv)

if nargin < 4
    getwv = 1;
end
getwv = logical(getwv);

% chNums = vector of chains to get

samp = 64;
psamp = 32;

fullpath = [fpath '/ChGroup_' num2str(ChGroup)];

% Get channel validity for this tetrode
nCh = getNChans(fpath, ChGroup);

if getwv
    chains = struct('num', [], 'times', [], 'amps', [], 'wv', []);
else
    chains = struct('num', [], 'times', []);
end

for c = 1 : length(chnNums)
    chains(c).num = chnNums(c);

    % Spike times
    tfid = fopen([fullpath '/MergedChains/' num2str(chnNums(c)) '.stimes'], 'r', 'l');
    chains(c).times = fread(tfid, inf, 'uint64');
    fclose(tfid);

    if getwv
        % Spike indices
        nfid = fopen([fullpath '/MergedChains/' num2str(chnNums(c)) '.snums'], 'r', 'l');
        snums = fread(nfid, inf, 'uint64');
        fclose(nfid);

        % Read in spike amps
        sAmps = zeros(length(snums), 4);
        allwv = zeros(length(snums), 4, samp);
        smap = memmapfile([fullpath '/Spikes'], 'Format', 'int16');
        %     sfid = fopen([fullpath '\Spikes']);
        for n = 1 : length(snums)
        %         fseek (sfid, (snums(n) * (samp*nCh)) * 2, 'bof');
        %         wv = fread (sfid, samp*nCh, 'int16=>int16');
            wv = smap.Data(snums(n)*(samp*nCh)+1:(snums(n)+1)*(samp*nCh));
            wv = reshape(wv, nCh, length(wv)/nCh);
            wv = permute(reshape(wv, nCh, samp, numel(wv)/(samp*nCh)), [2 1 3]);
            sAmps(n,1:nCh) = wv(psamp,:);
            allwv(n, 1:nCh, :) = wv';
        end

        allwv = double(allwv)*1.95e-7;
        sAmps = double(sAmps)*1.95e-7;

        %     fclose(sfid);   
        clear smap;

        chains(c).amps = sAmps;
        chains(c).wv = allwv;
    end

end