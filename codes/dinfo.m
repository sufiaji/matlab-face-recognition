function dinfo
%% function to display a figure contain ID information and reference image
%% of a person
% called when user click menu Face Recognition->ID Information->Display
% Information

% asking the uer about the ID of person which want to be displayed
prompt = {'Please type ID number or Name of the person : '};
title = 'Face Recognition';
numlines = 1;
defaultanswer = {'1'};
options.Resize = 'on';
answer = inputdlg(prompt,title,numlines,defaultanswer,options);
% load the data of person based on ID inputed
if ~isempty(answer)
    if(exist([answer{1} '.dat']))        
        load ([answer{1} '.dat'],'-mat');
        if exist('kl')
            try
				% sho the ID Information GUI, with the data of selected person parsed to the GUI
                gui_infoid('UserData',[{op} {a} {b} {c} {h} {kl}]);
            catch me
                d = errordlg(['Error: ' me.message]);
                uiwait(d);
            end
        else
            try
                gui_infoid('UserData',[{op} {a} {b} {c} {h} {[]}]);
            catch me
                d = errordlg(['Error: ' me.message]);
                uiwait(d);
            end
        end
    else
		% ID information of the person not found
        d = warndlg('There is no record about the person.','Face Recognition');
        uiwait(d);
    end
end