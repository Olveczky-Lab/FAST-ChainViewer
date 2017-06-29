function [chainsMatTotSelected] = chainsSelection(chainsMatTot, selectXMin, selectXMax, selectYMin, selectYMax, channel_4_1, channel_4_2, from, plot_mode)

chainsMatTotSelected = [];
v1 = num2str(plot_mode(1));
v2 = num2str(plot_mode(2));
v3 = num2str(plot_mode(3));
v4 = num2str(plot_mode(4));
v5 = num2str(plot_mode(5));
v6 = num2str(plot_mode(6));
v7 = num2str(plot_mode(7));
type = [v1 v2 v3 v4 v5 v6 v7];

for a = 1 : length(chainsMatTot)
    switch type
        case '1000000'
            indiceMinX = double(chainsMatTot(a).amps(:, channel_4_1)) * 1.95e-7 >= selectXMin;
            indiceMaxX = double(chainsMatTot(a).amps(:, channel_4_1)) * 1.95e-7 <= selectXMax;
            indiceMinY = double(chainsMatTot(a).amps(:, channel_4_2)) * 1.95e-7 >= selectYMin;
            indiceMaxY = double(chainsMatTot(a).amps(:, channel_4_2)) * 1.95e-7 <= selectYMax;
            selectInd = (indiceMinX & indiceMaxX & indiceMinY & indiceMaxY);
        case '0100000'
            indiceMinX = double(chainsMatTot(a).features.energy(:, channel_4_1)) * 1.95e-7 >= selectXMin;
            indiceMaxX = double(chainsMatTot(a).features.energy(:, channel_4_1)) * 1.95e-7 <= selectXMax;
            indiceMinY = double(chainsMatTot(a).features.energy(:, channel_4_2)) * 1.95e-7 >= selectYMin;
            indiceMaxY = double(chainsMatTot(a).features.energy(:, channel_4_2)) * 1.95e-7 <= selectYMax;
            selectInd = (indiceMinX & indiceMaxX & indiceMinY & indiceMaxY);
        case '0001000'
            indiceMinX = double(chainsMatTot(a).features.pc1(:, channel_4_1)) * 1.95e-7 >= selectXMin;
            indiceMaxX = double(chainsMatTot(a).features.pc1(:, channel_4_1)) * 1.95e-7 <= selectXMax;
            indiceMinY = double(chainsMatTot(a).features.pc1(:, channel_4_2)) * 1.95e-7 >= selectYMin;
            indiceMaxY = double(chainsMatTot(a).features.pc1(:, channel_4_2)) * 1.95e-7 <= selectYMax;
            selectInd = (indiceMinX & indiceMaxX & indiceMinY & indiceMaxY);
        case '0000100'
            indiceMinX = double(chainsMatTot(a).features.valley(:, channel_4_1)) * 1.95e-7 >= selectXMin;
            indiceMaxX = double(chainsMatTot(a).features.valley(:, channel_4_1)) * 1.95e-7 <= selectXMax;
            indiceMinY = double(chainsMatTot(a).features.valley(:, channel_4_2)) * 1.95e-7 >= selectYMin;
            indiceMaxY = double(chainsMatTot(a).features.valley(:, channel_4_2)) * 1.95e-7 <= selectYMax;
            selectInd = (indiceMinX & indiceMaxX & indiceMinY & indiceMaxY);
        case '0000010'
            indiceMinX = double(chainsMatTot(a).features.width(:, channel_4_1)) * 1.95e-7 >= selectXMin;
            indiceMaxX = double(chainsMatTot(a).features.width(:, channel_4_1)) * 1.95e-7 <= selectXMax;
            indiceMinY = double(chainsMatTot(a).features.width(:, channel_4_2)) * 1.95e-7 >= selectYMin;
            indiceMaxY = double(chainsMatTot(a).features.width(:, channel_4_2)) * 1.95e-7 <= selectYMax;
            selectInd = (indiceMinX & indiceMaxX & indiceMinY & indiceMaxY);
        case '0000001'
            indiceMinX = double(chainsMatTot(a).features.pc2(:, channel_4_1)) * 1.95e-7 >= selectXMin;
            indiceMaxX = double(chainsMatTot(a).features.pc2(:, channel_4_1)) * 1.95e-7 <= selectXMax;
            indiceMinY = double(chainsMatTot(a).features.pc2(:, channel_4_2)) * 1.95e-7 >= selectYMin;
            indiceMaxY = double(chainsMatTot(a).features.pc2(:, channel_4_2)) * 1.95e-7 <= selectYMax;
            selectInd = (indiceMinX & indiceMaxX & indiceMinY & indiceMaxY);
    end
    
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