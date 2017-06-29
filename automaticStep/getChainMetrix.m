                                function metrix = getChainMetrix(chains, L2chains, ChGroup, datapath, fileName, firstFile)
%GETCHAINMETRIX Get chain features for generating linksMatrix

lengthCutOff = 100; % spikes
samprate = 3e4;

threshold_plus = 75e-6;
threshold_minus = -100e-6;

% Get channel validity for this ChGroup
[nCh, goodChan] = getNChans([datapath fileName], ChGroup);

fOffset = double(str2num(['uint64(' fileName ')']) - str2num(['uint64(' firstFile ')'])) / (1e7 * 3600);

% Calculate metrics for each feature, chain by chain
metrix = struct;
for a = 1 : length(chains)
    chains(a).times = double(chains(a).times)/(3600*samprate) + fOffset;
    
    metrix(a).fname = fileName;
    metrix(a).ntimes = numel(chains(a).times);
    
    % Does chain cross + or - amp threshold?
    [maxamp,maxchan] = max(mean(abs(L2chains(a).amps),1));
		
    condition_plus = all(sign(L2chains(a).amps(:,maxchan)) == 1) && mean(L2chains(a).amps(:,maxchan)) >= threshold_plus; 
    condition_minus = all(sign(L2chains(a).amps(:,maxchan)) == -1) && mean(L2chains(a).amps(:,maxchan)) <= threshold_minus; 
    condition_plusminus = xor(all(sign(L2chains(a).amps(:,maxchan)) == 1), any(sign(L2chains(a).amps(:,maxchan)) == 1));  
    condition_plusminus = condition_plusminus && maxamp >= min(abs([threshold_plus threshold_minus]));

    ampCriterion = any([condition_plus condition_minus condition_plusminus]);
    
    
    if length(chains(a).times) > lengthCutOff && ampCriterion
        
        % selectInd
        metrix(a).selectInd = min([round(0.1*length(chains(a).times)) 100]);
        metrix(a).startTime = chains(a).times(metrix(a).selectInd);
        metrix(a).endTime = chains(a).times(end-metrix(a).selectInd+1);

        % wv        
        [wv1, wv2] = getStartEndWV([datapath fileName], ChGroup, chains(a), metrix(a).selectInd, nCh, goodChan);
        
        wv1mean = squeeze(mean(double(wv1) * 1.95e-7));
        wv2mean = squeeze(mean(double(wv2) * 1.95e-7));
        wv1mean(~goodChan,:) = NaN;
        wv2mean(~goodChan,:) = NaN;
        metrix(a).wv1mean = wv1mean(:)';
        metrix(a).wv2mean = wv2mean(:)';

        metrix(a).wv1std = squeeze(std(double(wv1(:,goodChan,:)) * 1.95e-7));
        metrix(a).wv2std = squeeze(std(double(wv2(:,goodChan,:)) * 1.95e-7));
        metrix(a).wv1std = sum(metrix(a).wv1std(:))';
        metrix(a).wv2std = sum(metrix(a).wv2std(:))';

        % ISI
        times = (double(chains(a).times)  * 3600) * 1000;
        metrix(a).isi = sgolayfilt(histc(diff(times), logspace(0, 6, 100)), 3, 9);  
    else
        metrix(a).selectInd = NaN;
        metrix(a).startTime = NaN;
        metrix(a).endTime = NaN;
        metrix(a).wv1mean = [];
        metrix(a).wv2mean = [];
        metrix(a).wv1std = [];
        metrix(a).wv2std = [];
        metrix(a).isi = [];
    end
end


end

