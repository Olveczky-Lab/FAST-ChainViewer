function plotLinks(chainsMatTot, pairsMatrix, channel)
% Allow to plot the links between chains. 

links = {};
for a = 1 : length(chainsMatTot)
    chain = chainsMatTot(a);
    indice = length(chain.times) / 2;
    valueTime = ((max(chain.times) - min(chain.times)) / 2) + min(chain.times);
    amps = double(chain.amps(:, channel)) * 1.95e-7;
    valueAmps = ((max(amps) - min(amps)) / 2) + min(amps);
    strNum = [num2str(chain.num)];
    
    hold all
    scatter(chain.times, amps, 6*5, chain.color,'.');
    scatter(valueTime, valueAmps, 1000, [0, 0, 0])
    text(valueTime - (0.005 * valueTime), valueAmps + (0.01 * valueAmps), strNum)
    links{end + 1} = {valueTime, valueAmps};
end

for a = 1 : length(chainsMatTot)
    for b = 1 : length(chainsMatTot)
        if (a ~= b) && ((pairsMatrix(chainsMatTot(a).num + 1, chainsMatTot(b).num + 1) == 1) || (pairsMatrix(chainsMatTot(b).num + 1, chainsMatTot(a).num + 1) == 1))
            x = [links{a}{1}, links{b}{1}];
            y = [links{a}{2}, links{b}{2}];
            plot(x, y, '-', 'color', [0, 0, 0]);
        end
    end
end



