function [nChans, ChVec] = getNChans(fpath, ChGroup)

AllChNum = reshape(0:63, 4, 16); % Change if your tetrode channel mapping is not consecutive
AllChNum = num2cell(AllChNum, 1);

ChVec = false(1,4);
% Get channel validity for this tetrode
snipSettings = xml2struct([fpath '\SnippeterSettings.xml']);
if isfield(snipSettings.TitanSpikeSnippeterSettings.EIBElectrodePlacement, 'ElectrodeSet')
    try
        allTets = [snipSettings.TitanSpikeSnippeterSettings.EIBElectrodePlacement.ElectrodeSet{:}];
    catch
        allTets = [snipSettings.TitanSpikeSnippeterSettings.EIBElectrodePlacement.ElectrodeSet];
    end
    allTetNums = [allTets.Attributes];
    allTetNums = cellfun(@str2double, {allTetNums.Name});
    allNChans = cellfun(@numel, {allTets.Channel});

    nChans = allNChans(allTetNums == ChGroup);
    if isempty(nChans)
        nChans = 0;
    else  
        try
            ChNums = [allTets(allTetNums == ChGroup).Channel{:}];
            ChVec = ismember(AllChNum{ChGroup+1}, cellfun(@str2double, {ChNums.Text}));
        catch
            ChNums = [allTets(allTetNums == ChGroup).Channel];
            ChVec(1) = true;
        end
        
    end
else
    nChans = 0;
end

