function output_txt = dataTipText(~,event_obj,chainsMatTot, clusterVecAll)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
dataIndex = get(event_obj, 'DataIndex');

numPoints = numel(event_obj.Target.XData);
numTimes = cumsum(cellfun(@numel, {chainsMatTot.times}));
numTimesToCompare = [0 numTimes(1:end-1)];

if numTimes(end) == numPoints
    chainInd = find(numTimesToCompare < dataIndex, 1, 'last');
    chainNum = num2str(chainsMatTot(chainInd).num);
    FileName = cell2mat(chainsMatTot(chainInd).names);
    TrueNum = chainsMatTot(chainInd).trueNumber;
    if ~isempty(clusterVecAll)
        [ClusterName, ~] = getClusterName(chainsMatTot(chainInd).num, clusterVecAll);
        Cluster = ClusterName{1};
    else
        Cluster = 'None';    
    end
    
else
    chainNum = num2str(length(chainsMatTot)+1);
    FileName = 'Background';
    TrueNum = '-1'; 
    Cluster = 'None';
end
    

output_txt = {['Time: ',num2str(pos(1),4)],...
    ['Amp: ',num2str(pos(2),4)], ...
    ['chainNum: ', chainNum],...
    ['FileName: ', FileName],...
    ['TrueNum: ', TrueNum],...
    ['Cluster: ', Cluster]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end
