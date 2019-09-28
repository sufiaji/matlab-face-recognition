% After facerecognition, this code captures the ID number of a person.
%Then reads the information stored in IDnumber.DAT
% % Return Value :
% % exception = 2 -> THERE IS NO RECORD ABOUT THE GROUP
% % exception = 1 -> Error on reading database

function [name surename phone access refimg exception] = ldinfo(pminf)
exception = 0;
name = '';
surename = '';
phone = '';
refimg = [];
jk = num2str(pminf);
if(exist([jk '.dat']))
    load ([jk '.dat'],'-mat');
    if exist('kl')
        try
            name = a; surename = b; phone = c;
            access = h; refimg = kl;
        catch
            exception = 1;
            return
        end
        
    else
        try
            name = a; surename = b; phone = c;
            access = h;
        catch
            exception = 1;
            return
        end
    end
else
    exception = 2;
    return
end


