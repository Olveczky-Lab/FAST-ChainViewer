function plotCompareChain(chainsMatTot, chainNum, channels, size)

chain = chainsMatTot(ismember([chainsMatTot.num], chainNum));

hold all

for channel = channels
    if ~isempty(chain)
        amps = double(chain.amps(:, channel)) * 1.95e-7;
        color = repmat(chain.color, numel(chain.times), 1);
        times = chain.times;
    else
        amps = [];
        color = [];
        times = [];
    end
    scatter(times, amps, size*6, color,'o'); 
end
xlabel('Time');