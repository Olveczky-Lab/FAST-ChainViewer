function data_path = getDataPath(load_path)

server_path = '\\serverpath\Data\';

if ~isempty(strfind(load_path, 'Rat_1'))
    data_path = [server_path 'Rat_1\'];    
elseif ~isempty(strfind(load_path, 'Rat_2'))
    data_path = [server_path 'Rat_2\'];
end

