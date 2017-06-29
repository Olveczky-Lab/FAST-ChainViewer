function L1spchains = getChainSplits(chains, datadir, savedir)

L1spchains = struct('num', [], 'times', [], 'amps', [], 'wv', [], 'splits', []);

% Get splits for each chain
for c = 1 : length(chains)
    % Find out how many split chains there are
    savepath = [savedir 'Split Chains'];
    nsplits = length(dir([savepath '\' num2str(chains(c).num) '_*.t']));
    
    if nsplits > 0
        % Get L1 spiketimes and wv
        thisChain = getSomeMergedChains([datadir chains(c).names{:}], chains(c).channel, mat2cell(chains(c).trueNumber, 1), 1, 0);
        times = thisChain.times;        
        
        splits = uint8(zeros(size(times)));
        
        % Read in MClust split times files
        for spl = 1 : nsplits
            split_times = loadtfile_new([savepath '\' num2str(chains(c).num)], spl);
            [~, ind] = intersect(times, split_times);
            splits(ind) = spl;
        end        
        
        L1spchains(c).num = chains(c).num;
        L1spchains(c).channel = chains(c).channel;
        L1spchains(c).trueNumber = thisChain.num;
        L1spchains(c).times = thisChain.times;
        L1spchains(c).amps = thisChain.amps;
        L1spchains(c).wv = thisChain.wv;
        L1spchains(c).splits = splits;
    else
        disp(['MClust t-files not found for chain ' num2str(chains(c).num)]);
        L1spchains(c) = [];
    end    
end