function saved = saveSpikesforSplit(chains, datadir, savedir)

% Saves cluster spikes (wv + times) to file for splitting
saved = false;

for c = 1 : length(chains)
    savepath = [savedir 'Split Chains'];
    if exist(savepath, 'dir') ~= 7
        mkdir(savepath);
    end
    
    choice = 'Yes';
    if ~isempty(dir([savepath '\' num2str(chains(c).num) '_*.t']))
        choice = questdlg('Splits exist. Continue?', 'Splits Exist', 'Yes', 'No', 'No');
    end
    
    if strcmp(choice, 'Yes')
        % Get L1 spiketimes and wv
        thisChain = getSomeMergedChains([datadir chains(c).names{:}], chains(c).channel, mat2cell(chains(c).trueNumber, 1), 1, 1);
        t = thisChain.times;
        % Typecast times to uint16
        t = reshape(typecast(t, 'uint16'), 4, numel(t));

        % Convert wv to uint16 as well
        wv = permute(uint16(thisChain.wv+32768/2)+32768/2, [3 2 1]);

        if ~isempty(t) && ~isempty(wv)
            % Combine t-wv
            twv = [t; reshape(wv, 4*size(wv,1), numel(wv)/(4*size(wv,1)))];
            twv = reshape(twv, numel(twv),1);

            % Save twv to local file for clustering
            sfid = fopen([savepath '/' num2str(chains(c).num) '.s'], 'w', 'b');
            fwrite(sfid, twv, 'uint16');
            fclose(sfid);
            saved = true;
            disp(['Chain ' num2str(chains(c).num) ' MClust spike file saved.']);
        else
            disp(['Chain  ' num2str(chains(c).num) ' data missing.']);        
        end
    end
end



