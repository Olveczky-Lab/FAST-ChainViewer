function spwidth = getSpikeWidth(wv, psamp)

amps = squeeze(wv(:,:,psamp));

halfamps = bsxfun(@ge, wv.* repmat(sign(amps),1,1,size(wv,3)), sign(amps).*amps/2);

[~, maxrise] = max(halfamps(:,:,1:psamp), [], 3);
[~, maxfall] = max(halfamps(:,:,end:-1:psamp),[],3);
maxfall = size(wv,3) - maxfall + 1;

spwidth = uint8(squeeze(maxfall - maxrise)+1);