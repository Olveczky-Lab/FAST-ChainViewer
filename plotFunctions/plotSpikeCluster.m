function plotSpikeChains(chains, cutoff, channel)

if channel == 1
    for x = 1 : length(chains)        
        if length(chains(x).times) > cutoff
            plot(chains(x).times, double(chains(x).amps(:,1)) * 1.95e-7, '.', 'color', [0, 0, 0], 'markersize', 6, 'DisplayName', num2str(x-1));
            ylabel('Ch1'); zlabel('Ch2'); xlabel('Time');
            hold all
        end
    end
end 

if channel == 2
    for x = 1 : length(chains)        
        if length(chains(x).times) > cutoff
            plot(chains(x).times, double(chains(x).amps(:,2)) * 1.95e-7, '.', 'color', [0, 0, 0], 'markersize', 6, 'DisplayName', num2str(x-1));
            ylabel('Ch1'); zlabel('Ch2'); xlabel('Time');
            hold all
        end
    end
end

if channel == 3
    for x = 1 : length(chains)        
        if length(chains(x).times) > cutoff
            plot(chains(x).times, double(chains(x).amps(:,3)) * 1.95e-7, '.', 'color', [0, 0, 0], 'markersize', 6, 'DisplayName', num2str(x-1));
            ylabel('Ch1'); zlabel('Ch2'); xlabel('Time');
            hold all
        end
    end
end

if channel == 4
    for x = 1 : length(chains)        
        if length(chains(x).times) > cutoff
            plot(chains(x).times, double(chains(x).amps(:,4)) * 1.95e-7, '.', 'color', [0, 0, 0], 'markersize', 6, 'DisplayName', num2str(x-1));
            ylabel('Ch1'); zlabel('Ch2'); xlabel('Time');
            hold all
        end
    end
end