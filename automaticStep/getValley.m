function valley = getValley(wv, psamp)

amps = squeeze(wv(:,:,psamp));

valley = int16(squeeze(min(wv .* repmat(sign(amps),1,1,size(wv,3)),[],3)) .* sign(amps));