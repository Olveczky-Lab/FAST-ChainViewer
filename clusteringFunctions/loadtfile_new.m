function [t] = loadtfile_new (fname, cluster)

fid = fopen([fname '_' num2str(cluster, '%02u') '.t'] , 'r', 'b');

hdr = fread(fid, 400, '*char')';

fseek (fid, findstr(hdr, '%%ENDHEADER') + 11, 'bof');

t = fread(fid, inf, 'uint64=>uint64');

fclose (fid);