function [data_path, url_path, blob_path] = getDataPath(load_path)

titanic_url = 'http://140.247.178.149:5900/';
valemax_url = 'http://140.247.178.129:5900/';
sultana_url = 'http://140.247.178.35:5900/';
minotaur_url = 'http://140.247.178.191:5900/';

titanic_samba = '\\140.247.178.8\asheshdhawale\Data\';
valemax_samba = '\\140.247.178.42\asheshdhawale\Data\';
sultana_samba = '\\140.247.178.57\asheshdhawale\Data\';
minotaur_samba = '\\140.247.178.65\asheshdhawale\Data\';

blob_common = '/root/data/asheshdhawale/Data/';

if ~isempty(strfind(load_path, 'Dhanashri'))
    data_path = [valemax_samba 'Dhanashri\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Dhanashri/'];
    
elseif ~isempty(strfind(load_path, 'Hamir'))
    data_path = [sultana_samba 'Hamir\'];
    url_path = sultana_url;
    blob_path = [blob_common 'Hamir/'];
    
elseif ~isempty(strfind(load_path, 'Hindol'))
    data_path = [titanic_samba 'Hindol\'];
    url_path = titanic_url;
    blob_path = [blob_common 'Hindol/'];
    
elseif ~isempty(strfind(load_path, 'Kamod'))
    data_path = [sultana_samba 'Kamod\'];
    url_path = sultana_url;
    blob_path = [blob_common 'Kamod/'];
    
elseif ~isempty(strfind(load_path, 'Jaunpuri'))
    data_path = [valemax_samba 'Jaunpuri\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Jaunpuri/'];
    
elseif ~isempty(strfind(load_path, 'Gara'))
    data_path = [valemax_samba 'Gara\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Gara/'];
    
elseif ~isempty(strfind(load_path, 'Gandhar'))
    data_path = [valemax_samba 'Gandhar\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Gandhar/'];
    
elseif ~isempty(strfind(load_path, 'GaudMalhar'))
    data_path = [valemax_samba 'GaudMalhar\'];
    url_path = valemax_url;
    blob_path = [blob_common 'GaudMalhar/'];
    
elseif ~isempty(strfind(load_path, 'Gunakari'))
    data_path = [valemax_samba 'Gunakari\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Gunakari/'];
    
elseif ~isempty(strfind(load_path, 'Gorakh'))
    data_path = [valemax_samba 'Gorakh\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Gorakh/'];
    
elseif ~isempty(strfind(load_path, 'Desh'))
    data_path = [valemax_samba 'Desh\'];
    url_path = valemax_url;
    blob_path = [blob_common 'Desh/'];
    
elseif ~isempty(strfind(load_path, 'Champakali'))
    data_path = [titanic_samba 'Champakali\'];
    url_path = titanic_url;
    blob_path = [blob_common 'Champakali/'];
    
elseif ~isempty(strfind(load_path, 'SW60'))
    data_path = ['\\140.247.178.209\steffenwolff\SW60\'];
    url_path = sultana_url;
    blob_path = ['/root/data/steffenwolff/SW60/'];
    
elseif ~isempty(strfind(load_path, 'SW59'))
    data_path = ['\\140.247.178.98\steffenwolff\SW59\'];
    url_path = valemax_url;
    blob_path = ['/root/data/steffenwolff/SW59/'];
    
elseif ~isempty(strfind(load_path, 'SW77'))
    data_path = ['\\140.247.178.8\steffenwolff\SW77\'];
    url_path = titanic_url;
    blob_path = ['/root/data/steffenwolff/SW77/'];
    
elseif ~isempty(strfind(load_path, 'arches'))
    data_path = '\\140.247.178.8\rpoddar\arches\';
    url_path = titanic_url;
    blob_path = '/root/data/rpoddar/arches/';

elseif ~isempty(strfind(load_path, 'badlands'))
    data_path = '\\140.247.178.8\rpoddar\badlands\';
    url_path = titanic_url;
    blob_path = '/root/data/rpoddar/badlands/';
    
elseif ~isempty(strfind(load_path, 'tiny_drift_24h_SE'))
    data_path = [valemax_samba 'SimulatedData\tiny_drift_24h_SE\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/tiny_drift_24h_SE/'];
    
elseif ~isempty(strfind(load_path, 'med_drift_24h_SE'))
    data_path = [valemax_samba 'SimulatedData\med_drift_24h_SE\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/med_drift_24h_SE/'];
    
elseif ~isempty(strfind(load_path, 'small_drift_24h_SE'))
    data_path = [valemax_samba 'SimulatedData\small_drift_24h_SE\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/small_drift_24h_SE/'];
    
elseif ~isempty(strfind(load_path, 'large_drift_24h_SE'))
    data_path = [valemax_samba 'SimulatedData\large_drift_24h_SE\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/large_drift_24h_SE/'];

elseif ~isempty(strfind(load_path, 'huge_drift_24h_SE'))
    data_path = [valemax_samba 'SimulatedData\huge_drift_24h_SE\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/huge_drift_24h_SE/'];
    
elseif ~isempty(strfind(load_path, 'tiny_drift_24h'))
    data_path = [valemax_samba 'SimulatedData\tiny_drift_24h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/tiny_drift_24h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift_24h'))
    data_path = [valemax_samba 'SimulatedData\med_drift_24h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/med_drift_24h/'];
    
elseif ~isempty(strfind(load_path, 'small_drift_24h'))
    data_path = [valemax_samba 'SimulatedData\small_drift_24h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/small_drift_24h/'];
    
elseif ~isempty(strfind(load_path, 'large_drift_24h'))
    data_path = [valemax_samba 'SimulatedData\large_drift_24h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/large_drift_24h/'];

elseif ~isempty(strfind(load_path, 'huge_drift_24h'))
    data_path = [valemax_samba 'SimulatedData\huge_drift_24h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/huge_drift_24h/'];
    
elseif ~isempty(strfind(load_path, 'Harris_d14521.001'))
    data_path = [sultana_samba 'SimulatedData\Harris_d14521.001\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris_d14521.001/'];
    
elseif ~isempty(strfind(load_path, 'Harris_d14521_001'))
    data_path = [sultana_samba 'SimulatedData\Harris_d14521_001\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris_d14521_001/'];
    
elseif ~isempty(strfind(load_path, 'Harris_d561106'))
    data_path = [sultana_samba 'SimulatedData\Harris_d561106\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris_d561106/'];

elseif ~isempty(strfind(load_path, 'Harris_d533101'))
    data_path = [sultana_samba 'SimulatedData\Harris_d533101\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris_d533101/'];

elseif ~isempty(strfind(load_path, 'Harris_d561103'))
    data_path = [sultana_samba 'SimulatedData\Harris_d561103\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris_d561103/'];

elseif ~isempty(strfind(load_path, 'Harris_d561104'))
    data_path = [sultana_samba 'SimulatedData\Harris_d561104\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris_d561104/'];

elseif ~isempty(strfind(load_path, 'Harris'))
    data_path = [sultana_samba 'SimulatedData\Harris\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/Harris/'];
    
elseif ~isempty(strfind(load_path, 'd14521_001'))
    data_path = [valemax_samba 'SimulatedData\d14521_001\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/d14521_001/'];
    
elseif ~isempty(strfind(load_path, 'd561106'))
    data_path = [valemax_samba 'SimulatedData\d561106\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/d561106/'];

elseif ~isempty(strfind(load_path, 'd533101'))
    data_path = [valemax_samba 'SimulatedData\d533101\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/d533101/'];

elseif ~isempty(strfind(load_path, 'd561103'))
    data_path = [valemax_samba 'SimulatedData\d561103\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/d561103/'];

elseif ~isempty(strfind(load_path, 'd561104'))
    data_path = [valemax_samba 'SimulatedData\d561104\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/d561104/'];
    
elseif ~isempty(strfind(load_path, 'med_drift_240h'))
    data_path = [sultana_samba 'SimulatedData\med_drift_240h\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/med_drift_240h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift2_240h'))
    data_path = [sultana_samba 'SimulatedData\med_drift2_240h\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/med_drift2_240h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift3_240h'))
    data_path = [valemax_samba 'SimulatedData\med_drift3_240h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/med_drift3_240h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift4_240h'))
    data_path = [valemax_samba 'SimulatedData\med_drift4_240h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/med_drift4_240h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift5_240h'))
    data_path = [valemax_samba 'SimulatedData\med_drift5_240h\'];
    url_path = valemax_url;
    blob_path = [blob_common 'SimulatedData/med_drift5_240h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift_hybrid_256h'))
    data_path = [sultana_samba 'SimulatedData\med_drift_hybrid_256h\'];
    url_path = sultana_url;
    blob_path = [blob_common 'SimulatedData/med_drift_hybrid_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift6_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift6_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift6_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift7_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift7_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift7_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift8_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift8_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift8_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift9_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift9_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift9_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift10_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift10_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift10_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift11_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift11_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift11_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift12_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift12_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift12_256h/'];

elseif ~isempty(strfind(load_path, 'med_drift14_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift14_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift14_256h/'];

elseif ~isempty(strfind(load_path, 'med_drift15_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift15_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift15_256h/'];

elseif ~isempty(strfind(load_path, 'med_drift16_256h_2'))
    data_path = [minotaur_samba 'SimulatedData\med_drift16_256h_2\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift16_256h_2/'];
    
elseif ~isempty(strfind(load_path, 'med_drift16_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift16_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift16_256h/'];
    
elseif ~isempty(strfind(load_path, 'med_drift17_256h_SE'))
    data_path = [minotaur_samba 'SimulatedData\med_drift17_256h_SE\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift17_256h_SE/'];
    
elseif ~isempty(strfind(load_path, 'med_drift17_256h'))
    data_path = [minotaur_samba 'SimulatedData\med_drift17_256h\'];
    url_path = minotaur_url;
    blob_path = [blob_common 'SimulatedData/med_drift17_256h/'];
end

