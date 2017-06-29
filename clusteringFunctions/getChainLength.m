function numSpikes = getChainLength(linksMatrix, chainNums)

numSpikes = zeros(size(chainNums));

for c = 1 : length(chainNums)
    [indiceRow, indiceColumn] = find(linksMatrix(:, 1:2) == chainNums(c));

    if ~isempty(indiceRow) && ~isempty(indiceColumn)
        numSpikes(c) = linksMatrix(indiceRow(1), indiceColumn(1)+7);
    else
        numSpikes(c) = NaN;
    end
end