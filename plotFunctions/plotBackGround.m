function plotBackGround(chains, skips, channels, size)

bgchains = chains(end);

hold all
if ~isempty(bgchains)
    bgchains.color = repmat(bgchains.color, length(bgchains.times(1:skips:end)), 1);
    amps = bgchains.amps;

    for channel = channels
        scatter(bgchains.times(1:skips:end), double(amps(1:skips:end,channel))*1.95e-7, size*6, bgchains.color,'.'); 
    end
end
xlabel('Time');