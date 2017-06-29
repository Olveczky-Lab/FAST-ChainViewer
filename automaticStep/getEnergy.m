function energy = getEnergy(wv)

wv = double(wv);
energy = uint16(squeeze(sqrt(sum(wv.^2,3)/size(wv,3))));