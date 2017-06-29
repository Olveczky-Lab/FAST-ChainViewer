function [pairsMatrix] = thresholdApplication(linksMatrix, pairsMatrix, distThreshold, corrThreshold, isiThreshold)

threshRows = find((linksMatrix(:, 6) > corrThreshold) & (linksMatrix(:, 11) < distThreshold) & (linksMatrix(:, 10) > isiThreshold));

pairsMatrix(sub2ind(size(pairsMatrix), linksMatrix(threshRows,1)+1, linksMatrix(threshRows,2)+1)) = 1;

end