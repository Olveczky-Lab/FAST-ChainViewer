function setColorList(listRef, list, chainsMatTotSelected, select, clusterVecAll)

pre = '<HTML><FONT color="';
post = '</FONT></HTML>';

% Display the chains of a cluster.
if strcmp(select, 'all') == 1
    elementsValues = get(listRef, 'value');
    cluster = clusterVecAll{1, elementsValues};
    numElements = length(cluster);
    listboxStr = cell(numElements, 1);
    for i = 1 : numElements
        str = [pre rgb2hex(chainsMatTotSelected(i).color) '">' num2str(chainsMatTotSelected(i).num) post];
        listboxStr{i} = str;
    end
    
    set(list, 'string', listboxStr);
end

% Display the chains selected in the Map.
if strcmp(select, 'selectMap') == 1
    elements = get(listRef, 'string');
    elementsValues = get(listRef, 'value');
    numElements = length(elements);
    listboxStr = cell(length(chainsMatTotSelected), 1);
    for i = 1 : length(chainsMatTotSelected)
        str = [pre rgb2hex(chainsMatTotSelected(i).color) '">' num2str(chainsMatTotSelected(i).num) post];
        listboxStr{i} = str;
    end
    
    set(list, 'string', listboxStr);
end

% Display the clusters with their colors.
if strcmp(select, 'cluster') == 1
    elements = get(listRef, 'string');
    elementsValues = get(listRef, 'value');
    numElements = length(elements);
    listboxStr = cell(size(clusterVecAll, 2), 1); 
    for i = 1 : size(clusterVecAll, 2)
        str = [pre rgb2hex(clusterVecAll{3, i}) '">' clusterVecAll{2, i} post];
        listboxStr{i} = str;
    end
    
    set(list, 'string', listboxStr);
end
    



        
            
        