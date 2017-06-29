function [chainsMatTotSelected] = chainsSelection(chainsMatTot, selectTimeMin, selectTimeMax, selectAmpsMin, selectAmpsMax, channel, from)

chainsMatTotSelected = [];

for a = 1 : length(chainsMatTot)
    indiceMin = chainsMatTot(a).times >= selectTimeMin;
    indiceMax = chainsMatTot(a).times <= selectTimeMax;
    indiceMinAmps = double(chainsMatTot(a).amps(:, channel)) * 1.95e-7 >= selectAmpsMin;
    indiceMaxAmps = double(chainsMatTot(a).amps(:, channel)) * 1.95e-7 <= selectAmpsMax;
    selectInd = (indiceMin(:) & indiceMax(:) & indiceMinAmps(:) & indiceMaxAmps(:));
        
    if any(selectInd)
        chainsCell = chainsMatTot(a);
        chainsCell.times = chainsMatTot(a).times(selectInd);
        chainsCell.amps = chainsMatTot(a).amps(selectInd, :);
        if strcmp('fromClust', from) == 1
            chainsCell.wv = chainsMatTot(a).wv(selectInd, :, :);
        else
            if a == length(chainsMatTot)
                chainsCell.wv = [];
            end
        end
        chainsCell.features.energy = chainsMatTot(a).features.energy(selectInd, :);
        chainsCell.features.pc1 = chainsMatTot(a).features.pc1(selectInd, :);
        chainsCell.features.pc2 = chainsMatTot(a).features.pc2(selectInd, :);
        chainsCell.features.valley = chainsMatTot(a).features.valley(selectInd, :);
        chainsCell.features.width = chainsMatTot(a).features.width(selectInd, :);
        chainsMatTotSelected = [chainsMatTotSelected; chainsCell];
    end
end

end