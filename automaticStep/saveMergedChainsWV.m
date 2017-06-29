function saveMergedChainsWV(fpath)

samp = 64;
chunk = 10e6; % 1 GB memory ~ 2e6 spikes for 4 Ch

for tet = 1 : 16
    
    disp(tet);

    fullpath = [fpath '\ChGroup_' num2str(tet-1)];

    clist = dir(fullfile([fullpath '\MergedChains\*.snums']));
    nchains = length(clist);

    % Get channel validity for this tetrode
    nCh = getNChans(fpath, tet-1);

    if ~isempty(clist) && nCh > 0
        chainNums = cell(nchains,1);

        % Read in spike nums for every chain
        for c = 1 : nchains
            nfid = fopen([fullpath '\MergedChains\' clist(c).name], 'r', 'l');
            chainNums{c} = fread(nfid, inf, 'uint64');
            fclose(nfid);
        end

        % Get size of Spikes file
        spfile = dir([fullpath '\Spikes']);
        nchunks = ceil(spfile(1).bytes / (chunk*samp*nCh*2));
        sfid = fopen([fullpath '\Spikes'], 'r', 'l');
        
        for x = 1 : nchunks
            % Read in chunk of spike file
            fseek(sfid, (x-1)*chunk*samp*nCh*2 ,'bof');
            if x == nchunks
                allspikes = fread(sfid, inf, 'int16=>int16');
                allsnums = (x-1)*chunk : ((x-1)*chunk + length(allspikes)/(samp*nCh))-1;
            else
                allspikes = fread(sfid, chunk*samp*nCh, 'int16=>int16');
                allsnums = (x-1)*chunk : x*chunk-1;
            end
            
            allspikes = reshape(allspikes, nCh*samp, length(allspikes)/(nCh*samp));
            
            % Write wv files for individual chains
            for c = 1 : nchains
                % Get wv for this chain in this chunk
                [~, Ic] = ismember(chainNums{c}, allsnums);
                Ic = Ic(Ic>0);
                chainwv = allspikes(:,Ic);
                
                if ~isempty(chainwv)
                    if x == 1
                        wvfid = fopen([fullpath '\MergedChains\' clist(c).name(1:end-6) '.wv'], 'w', 'l');
                    else
                        wvfid = fopen([fullpath '\MergedChains\' clist(c).name(1:end-6) '.wv'], 'a', 'l');     
                    end                
                    fwrite(wvfid, chainwv(:), 'int16');
                    fclose(wvfid);
                end
            end
        end
        fclose(sfid);
    end
end
