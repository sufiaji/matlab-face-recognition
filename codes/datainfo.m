% Displays how many faces stored in the facedatabase
function numid = datainfo
% load database file and calculate how many IDs are stored
numid = 0;
if(exist('fdata.dat')==2)
    load('fdata.dat','-mat');    
    numid = fnumber;
else
    numid = 0;
end

