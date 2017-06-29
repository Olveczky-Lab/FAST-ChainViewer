function [wv1, wv2] = getStartEndWV(datapath, ChGroup, chain, selectInd, nCh, ChVec)

samp = 64;

fpath = [datapath '\ChGroup_' num2str(ChGroup) '\MergedChains\' num2str(chain(1).num) '.wv'];

fid = fopen(fpath, 'r', 'l');

% WV1
tempwv = fread(fid, selectInd*nCh*samp, 'int16=>int16');
tempwv = reshape(tempwv, nCh, samp, length(tempwv)/(nCh*samp));
tempwv = permute(tempwv, [3 1 2]);

wv1 = zeros(selectInd,4,samp,'int16');
wv1(:,ChVec,:) = tempwv;

% WV2
fseek(fid, -(selectInd*nCh*samp*2), 'eof');
tempwv = fread(fid, inf, 'int16=>int16');
tempwv = reshape(tempwv, nCh, samp, length(tempwv)/(nCh*samp));
tempwv = permute(tempwv, [3 1 2]);

wv2 = zeros(selectInd,4,samp,'int16');
wv2(:,ChVec,:) = tempwv;

fclose(fid);