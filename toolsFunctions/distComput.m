function distComput(handles, chainsSelected)
    chainsMatTot = handles.chainsMatTot;
    
    chain1 = chainsSearch(chainsMatTot, chainsSelected(1));
    chain2 = chainsSearch(chainsMatTot, chainsSelected(2));
    
    disp('Loading complete chains...')
    pathway = [handles.pathBasic chain1.names{1}];
    chainSelectedTest1 = getSomeMergedChains(pathway, chain1.channel, mat2cell(chain1.trueNumber, 1), 1, 1)
    pathway = [handles.pathBasic chain2.names{1}];
    chainSelectedTest2 = getSomeMergedChains(pathway, chain2.channel, mat2cell(chain2.trueNumber, 1), 1, 1)
    
    select1 = round(0.1*length(chainSelectedTest1.amps));
    select2 = round(0.1*length(chainSelectedTest2.amps));
    
    if select1 > 100
        select1 = 100;
    end
    if select2 > 100
        select2 = 100;
    end
    
    wv1 = double(chainSelectedTest1.wv(1 : select1, :, :))*1.95e-7;
    wv2 = double(chainSelectedTest2.wv((end - select2 +1) : end, :, :))*1.95e-7;
    wvSqueezeMean1 = squeeze(mean(wv1));
    wvSqueezeMeanTransp1 = wvSqueezeMean1';
    wvSqueezeMean2 = squeeze(mean(wv2));
    wvSqueezeMeanTransp2 = wvSqueezeMean2';
    
    wvDist = (wvSqueezeMeanTransp1(:) - wvSqueezeMeanTransp2(:)).^2;
    wvDistSum = sqrt(sum(wvDist));
    wvSqueezeStd1 = squeeze(std(wv1));
    wvSqueezeStdTransp1 = wvSqueezeStd1';
    wvStdSum1 = sum(wvSqueezeStdTransp1(:));
    wvSqueezeStd2 = squeeze(std(wv2));
    wvSqueezeStdTransp2 = wvSqueezeStd2';
    wvStdSum2 = sum(wvSqueezeStdTransp2(:));
    
    criteria_dist = wvDistSum / ((wvStdSum2 + wvStdSum1) / 2);
    
    set(handles.textTools, 'string', num2str(criteria_dist));
end