function [linksMatrix, singleCluster] = chainsClusteringLink(chainsMatTot, linksMatrix, singleCluster)
% This function allows to create a submatrix which contains the relations
% between all of the chains two by two. Each element of the matrix is a
% cell with the different statistics of the relations between the two
% chains, which are the two coordinates of the matrix. 

% Test of the compatibility.
for a = 1 : length(chainsMatTot)
    singleChain = 0;
    
    for b = 1 : length(chainsMatTot)
        % If 0, there is no compatibility. If 1, there is a compatibility.
        checkStep = 0;
        % If 0, no ISI statistic.
        checkIsi = 0;
            
        % If the two tested chains are not the same, the time compatibility
        % is then tested.
        if a ~= b
            % "select1" & "select2" are two indices dependents on the size
            % of the chains tested. These indices allow to defind the
            % portion of chains which will be tested.
            select1 = round(0.1*length(chainsMatTot(a).times));
            select2 = round(0.1*length(chainsMatTot(b).times));
            if select1 > 100
                select1 = 100;
            end
            if select2 > 100
                select2 = 100;
            end
            
            % The time compatibility between the two chains is tested.
            timeDifference1 = double(chainsMatTot(a).times(select1)) - double(chainsMatTot(b).times(end - select2));
            timeDifferencePur1 = timeDifference1;
            %             timeDifferencePur1 = double(chainsMatTot(a).times(1)) - double(chainsMatTot(b).times(end));
            timeDifference2 = double(chainsMatTot(b).times(select2)) - double(chainsMatTot(a).times(end - select1));
            timeDifferencePur2 = timeDifference2;
            %             timeDifferencePur2 = double(chainsMatTot(b).times(1)) - double(chainsMatTot(a).times(end));
            
            % Identification if a channel is down.
            downChannel = 0;
            
            if (sum(chainsMatTot(a).amps(:, 1)) == 0) || (sum(chainsMatTot(b).amps(:, 1)) == 0)
                downChannel = 1;
            end
            if (sum(chainsMatTot(a).amps(:, 2)) == 0) || (sum(chainsMatTot(b).amps(:, 2)) == 0)
                downChannel = 2;
            end
            if (sum(chainsMatTot(a).amps(:, 3)) == 0) || (sum(chainsMatTot(b).amps(:, 3)) == 0)
                downChannel = 3;
            end
            if (sum(chainsMatTot(a).amps(:, 4)) == 0) || (sum(chainsMatTot(b).amps(:, 4)) == 0)
                downChannel = 4;
            end
            
            % If the time difference is smaller than 15 hours, the
            % statistics are calculated. TimeDifference1 :
            if (((timeDifference1 < 5) && (timeDifference1 > -5) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 1)) || ((timeDifference1 < 25) && (timeDifference1 > 0) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 0))) && (chainsMatTot(b).times(end - select2) < chainsMatTot(a).times(end - select1))
                %if ((((timeDifference1 < 5) || (timeDifferencePur1 < 5)) && (timeDifference1 > 0)) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 1)) || ((((timeDifference1 < 25) || (timeDifferencePur1 < 25)) && (timeDifference1 > 0)) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 0)) && (chainsMatTot(b).times(end - select2) < chainsMatTot(a).times(select1))
                % Extraction of the waveforms. Only the centers of the
                % waveforms are used.
                if downChannel ~= 0
                    indiceChannel = [1, 2, 3, 4];
                    wv1 = double(chainsMatTot(a).wv(1 : select1, indiceChannel ~= downChannel, :))*1.95e-7;
                    wv2 = double(chainsMatTot(b).wv((end - select2 + 1) : end, indiceChannel ~= downChannel, :))*1.95e-7;
                else
                    wv1 = double(chainsMatTot(a).wv(1 : select1, :, :))*1.95e-7;
                    wv2 = double(chainsMatTot(b).wv((end - select2 + 1) : end, :, :))*1.95e-7;
                end
                
                % The waveforms are grouped the one after the others.
                wvSqueezeMean1 = squeeze(mean(wv1));
                wvSqueezeMeanTransp1 = wvSqueezeMean1';
                wvSqueezeMean2 = squeeze(mean(wv2));
                wvSqueezeMeanTransp2 = wvSqueezeMean2';
                
                % Distance statistic.
                wvDist = (wvSqueezeMeanTransp1(:) - wvSqueezeMeanTransp2(:)).^2;
                wvDistSum = sqrt(sum(wvDist));
                
                % Standart deviation statistic.
                wvSqueezeStd1 = squeeze(std(wv1));
                wvSqueezeStdTransp1 = wvSqueezeStd1';
                wvStdSum1 = sum(wvSqueezeStdTransp1(:));
                wvSqueezeStd2 = squeeze(std(wv2));
                wvSqueezeStdTransp2 = wvSqueezeStd2';
                wvStdSum2 = sum(wvSqueezeStdTransp2(:));
                
                % Waveforms correlation statistic.
                criteria_corr = corr(wvSqueezeMeanTransp1(:), wvSqueezeMeanTransp2(:));
                
                % ISI statistics (only if the chains are longer than 1000
                % spikes.
                if (length(chainsMatTot(a).times)) > 100 && (length(chainsMatTot(b).times)) > 100
                    cell1 = chainsMatTot(a);
                    cell2 = chainsMatTot(b);
                    cell1.times = (cell1.times  * 60) * 60;
                    cell2.times = (cell2.times * 60) * 60;
                    spikeActivity1 = sgolayfilt(histc(diff(double(cell1.times)), logspace(-3, 3, 100)), 3, 9);
                    spikeActivity2 = sgolayfilt(histc(diff(double(cell2.times)), logspace(-3, 3, 100)), 3, 9);
                    criteria_corr_activity = corr(spikeActivity1, spikeActivity2);
                    checkIsi = 1;
                end
                
                % Allows to continue.
                checkStep = 1;
                timeDifference = timeDifference1;
                timeCue = 1;
            end
            
            % If the time difference is smaller than 15 hours, the
            % statistics are calculated. TimeDifference2 :
            if (((timeDifference2 < 5) && (timeDifference2 > -5) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 1)) || ((timeDifference2 < 25) && (timeDifference2 > 0) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 0))) && (chainsMatTot(a).times(end - select1) < chainsMatTot(b).times(end - select2))
                %if ((((timeDifference2 < 5) || (timeDifferencePur2 < 5)) && (timeDifference2 > 0)) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 1)) || ((((timeDifference2 < 25) || (timeDifferencePur2 < 25)) && (timeDifference2 > 0)) && (strcmp(chainsMatTot(a).names{1}, chainsMatTot(b).names{1}) == 0)) && (chainsMatTot(a).times(end - select1) < chainsMatTot(b).times(select2))
                % Extraction of the waveforms. Only the centers of the
                % waveforms are used.
                if downChannel ~= 0
                    indiceChannel = [1, 2, 3, 4];
                    wv1 = double(chainsMatTot(b).wv(1 : select2, indiceChannel ~= downChannel, :))*1.95e-7;
                    wv2 = double(chainsMatTot(a).wv((end - select1  + 1): end, indiceChannel ~= downChannel, :))*1.95e-7;
                else
                    wv1 = double(chainsMatTot(b).wv(1 : select2, :, :))*1.95e-7;
                    wv2 = double(chainsMatTot(a).wv((end - select1 + 1) : end, :, :))*1.95e-7;
                end
                
                % The waveforms are grouped the one after the others.
                wvSqueezeMean1 = squeeze(mean(wv1));
                wvSqueezeMeanTransp1 = wvSqueezeMean1';
                wvSqueezeMean2 = squeeze(mean(wv2));
                wvSqueezeMeanTransp2 = wvSqueezeMean2';
                
                % Distance statistic.
                wvDist = (wvSqueezeMeanTransp1(:) - wvSqueezeMeanTransp2(:)).^2;
                wvDistSum = sqrt(sum(wvDist));
                
                % Standart deviation statistic.
                wvSqueezeStd1 = squeeze(std(wv1));
                wvSqueezeStdTransp1 = wvSqueezeStd1';
                wvStdSum1 = sum(wvSqueezeStdTransp1(:));
                wvSqueezeStd2 = squeeze(std(wv2));
                wvSqueezeStdTransp2 = wvSqueezeStd2';
                wvStdSum2 = sum(wvSqueezeStdTransp2(:));
                
                % Waveforms correlation statistic.
                criteria_corr = corr(wvSqueezeMeanTransp1(:), wvSqueezeMeanTransp2(:));
                
                % ISI statistics (only if the chains are longer than 1000
                % spikes.
                if (length(chainsMatTot(a).times)) > 100 && (length(chainsMatTot(b).times)) > 100
                    cell1 = chainsMatTot(a);
                    cell2 = chainsMatTot(b);
                    cell1.times = ((cell1.times  * 60) * 60);
                    cell2.times = ((cell2.times * 60) * 60);
                    spikeActivity1 = sgolayfilt(histc(diff(double(cell1.times)), logspace(-3, 3, 100)), 3, 9);
                    spikeActivity2 = sgolayfilt(histc(diff(double(cell2.times)), logspace(-3, 3, 100)), 3, 9);
                    criteria_corr_activity = corr(spikeActivity1, spikeActivity2);
                    checkIsi = 1;
                end
                
                % Allows to continue.
                checkStep = 1;
                timeDifference = timeDifference2;
                timeCue = 2;
            end
            
            % Assignation of the statistics to the matrix. If the chain a
            % is before the chain b, the row is assigned to chain a and the
            % column to chain b, and contrary.
            if (checkStep == 1) && (length(chainsMatTot(b).times) > 100) && (length(chainsMatTot(a).times) > 100)
                
                if timeCue == 1
                    chainRow = chainsMatTot(b).num;
                    chainColumn = chainsMatTot(a).num;
                    lengthRow = length(chainsMatTot(b).wv);
                    lengthColumn = length(chainsMatTot(a).wv);
                end
                if timeCue == 2
                    chainRow = chainsMatTot(a).num;
                    chainColumn = chainsMatTot(b).num;
                    lengthRow = length(chainsMatTot(a).wv);
                    lengthColumn = length(chainsMatTot(b).wv);
                end
                
                linksProperties = [chainRow, chainColumn, wvDistSum, wvStdSum1, wvStdSum2, criteria_corr, timeDifference, lengthRow, lengthColumn];
                
                if checkIsi == 1
                    linksProperties = [linksProperties, criteria_corr_activity];
                else
                    linksProperties = [linksProperties, 0];
                end
                
                linksMatrix(size(linksMatrix, 1) + 1, :) = linksProperties;
                clear linksProperties;
                
                singleChain = 1;
            end
        end
    end
    
    % If a chain has no partners and is long, it can be a single chain.
    % This kind of chain is stocked in a cell array.
    if (singleChain == 0) && (length(chainsMatTot(a)) > 1000)
        singleCluster{end  + 1} = chainsMatTot(a);
    end
end




            
                
            
            
            
            
