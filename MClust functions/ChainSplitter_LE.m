% File: ChainSplitter_LE.m
% Function: Loading Engine to read spike data into MClust
% Author: Ashesh Dhawale 
% Date: 17/09/2015
% based on code by Malcolm Lidierth @ (http://www.ced.co.uk) for the loading engine LoadSE_SON.m

function varargout = ChainSplitter_LE(fn, varargin)

samp = 64;                       % samples per spike per channel
samprate = 3e4;					% sampling rate
offset = 0;                         % offset to start of data 
t = [];
wv = [];  

clear tstamplist; clear index;


if strcmp(fn, 'get') && strcmp(varargin{1}, 'ExpectedExtension')

    varargout{1} = '.s';
    
else
    
    fid = fopen(fn, 'r', 'b');

    if nargin == 3
        records_to_get = varargin{1};
        record_units = varargin{2};

        if record_units == 1            % timestamp list

            fseek(fid, offset * 2, 'bof');
            tstamplist = fread(fid, inf, '4*uint16=>uint16', samp*4 * 2);    % read in complete timestamp list
            tstamplist = typecast(tstamplist, 'uint64');
            tstamplist = double(tstamplist); 

            t = records_to_get;

            index = find(ismember(tstamplist,t));

            for x = 1:length(index)                         % read in only relevant entries
                fseek (fid, (4 + offset + ((index(x)-1)*((samp*4)+4))) * 2, 'bof');
                wv = [wv; fread(fid, 4*samp, 'uint16=>uint16')];
            end

            wv = reshape (wv, samp, 4, (length(wv)/(samp*4)));
            wv = permute(wv, [3 2 1]);
            wv = double(wv) - 32768;

        elseif record_units == 2            % record number list

            twv = [];
            for x = 1:length(records_to_get)                % read in only relevant entries
                fseek (fid, (offset + ((records_to_get(x)-1)*((samp*4)+4))* 2), 'bof');
                twv = [twv; fread(fid, 4 + samp*4, 'uint16=>uint16')];
            end

            twv = typecast(twv, 'uint64');
            t = twv (1 : (samp)+1 : length(twv))';
            twv (1 : (samp)+1 : length(twv)) = uint64(Inf)-1;
            twv = typecast(twv(twv ~= uint64(Inf)-1), 'uint16');
            wv = reshape (twv, samp, 4, (length(twv)/(samp*4)));
            wv = permute(wv, [3 2 1]);

            t = double(t); 
            wv = double(wv) - 32768;

        elseif record_units == 3            % range of timestamps

            fseek (fid, offset * 2, 'bof');
            tstamplist = fread(fid, inf, '4*uint16=>uint16', samp*4 * 2);    % read in complete timestamp list

            tstamplist = typecast(tstamplist, 'uint64');
            tstamplist = double(tstamplist); % keep at 100 kHz 

            index = find(tstamplist >= records_to_get(1) & tstamplist <= records_to_get(2));    
            t = tstamplist(index);

            fseek (fid, (offset + ((index(1)-1) * ((samp*4)+4))) * 2, 'bof');
            twv = fread (fid, length(index)*((samp*4)+4), 'uint16=>uint16');    % read in all data within range into twv

            twv = typecast(twv, 'uint64');
            t = twv (1 : (samp)+1 : length(twv))';
            twv (1 : (samp)+1 : length(twv)) = uint64(Inf)-1;
            twv = typecast(twv(twv ~= uint64(Inf)-1), 'uint16');
            wv = reshape (twv, samp, 4, (length(twv)/(samp*4)));
            wv = permute(wv, [3 2 1]);

            t=double(t);
            wv = double(wv) - 32768;

        elseif record_units == 4            % range of records

            fseek (fid, (offset + ((records_to_get(1)-1) * ((samp*4)+4))) * 2, 'bof');
            twv = fread(fid, (records_to_get(2) - records_to_get(1) + 1) * (4*(samp)+4), 'uint16=>uint16');   % read in entire record range in into single vector

            twv = typecast(twv, 'uint64');
            t = twv (1 : (samp)+1 : length(twv))';
            twv (1 : (samp)+1 : length(twv)) = uint64(Inf)-1;
            twv = typecast(twv(twv ~= uint64(Inf)-1), 'uint16');
            wv = reshape (twv, samp, 4, (length(twv)/(samp*4)));
            wv = permute(wv, [3 2 1]);
            wv = double(wv) - 32768;

            t = double(t);  

        elseif record_units == 5            % count of spikes

            fseek (fid, offset * 2, 'bof');
            tstamplist = fread(fid, inf, '4*uint16=>uint16', samp*4 * 2);    % read in complete timestamp list
            tstamplist = typecast(tstamplist, 'uint64');
            t = length(tstamplist);        

        end

    else                                % get all records

        record_units = -1;
        fseek (fid, offset, 'bof');
        twv = fread(fid, inf, 'uint16=>uint16');

        twv = typecast(twv, 'uint64');
        t = twv (1 : (samp)+1 : length(twv))';
        twv (1 : (samp)+1 : length(twv)) = uint64(Inf)-1;
        twv = typecast(twv(twv ~= uint64(Inf)-1), 'uint16');
        wv = reshape (twv, samp, 4, (length(twv)/(samp*4)));
        wv = permute(wv, [3 2 1]);
        wv = double(wv) - 32768;

        t = double(t);   

    end

    fclose(fid);

    if nargout == 1
        varargout{1} = double(t')/samprate;      % Convert to 1 s timescale
    else
        varargout{1} = double(t')/samprate;      % Convert to 1 s timescale
        varargout{2} = 10*wv (:,:,1:samp); % Gain factor to display waveforms clearly in MClust
    end
end