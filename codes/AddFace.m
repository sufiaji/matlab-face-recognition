%Stores the selected image to the database
%Stores the information about the face
function AddFace(face)
if length(face) > 1   
    % resize the input image to 250x250
    face = imresize(face,[250 250]);
    % if database exist, load database and assign new face image to database
    if(exist('fdata.dat')==2)
        load('fdata.dat','-mat');
        fnumber = fnumber+1;
        max_class = max_class+1;
        class_number = max_class;
        data{fnumber,1} = face(:);      
        data{fnumber,2} = class_number;
        save('fdata.dat','data','fnumber','max_class','-append');
        h1 = msgbox(strcat('Face succesfully added to database with ID number --> ',num2str(class_number)),'Face Recognition');
        uiwait(h1);
        % ask user to fill the information related to the new person that
        % have been added
        prompt = {'Name:','Surename:','Phone Number'};
        title = 'Please fill detail information';
        numlines = 1;
        defaultanswer = {'','',''};
        options.Resize = 'on';
        answer = inputdlg(prompt,title,numlines,defaultanswer,options);
        a = ''; b = ''; c = ''; d = ''; h = 'Y';
        if ~isempty(answer)
            a = answer{1};
            b = answer{2}; 
            c = answer{3};
            h = 'Y';
            op = (strcat(num2str(class_number)));
        else
            return;
        end 
        % ask user to give the reference image for new person that have
        % been added to database
        h1 = msgbox('Please add a refference image ','Face Recognition');
        uiwait(h1);
        [ans,pathname]=uigetfile({'*.jpg';'*.jpeg'},'Select an IMAGE');
        if isequal(ans,0)
            h1 = msgbox('Action Cancelled !');
            uiwait(h1);
            y = num2str(class_number);
            save([y '.dat'],'a','b','c','h','op');
            save([a '.dat'],'a','b','c','h','op');
            h1 = msgbox('Information is saved','Face Recognition');
            uiwait(h1);
            return
        end 
        % save ID information and the reference image to database
        try            
            kl = imread([pathname ans]); 
            sh = figure; sa = axes('Parent',sh);
            imshow(kl,'Parent',sa);
            y = num2str(class_number);
            save([y '.dat'],'a','b','c','h','kl','op');
            save([a '.dat'],'a','b','c','h','kl','op');
            pause(1);
            close(sh);
            h1 = msgbox('Information is saved','Face Recognition');
            uiwait(h1);
        catch me
            y=num2str(class_number);
            save([y '.dat'],'a','b','c','h')
            save([a '.dat'],'a','b','c','h')
            h1 = errordlg({['Error: ' me.message];'Other variables are saved'},'Face Recognition');
            uiwait(h1);
            return
        end
    % if database file is not created yet
    else
        % initialize data to be saved
        fnumber = 1;
        class_number = 1;
        data{fnumber,1} = face(:);
        max_class = 1;
        data{fnumber,2} = class_number;
        % create database file and save the data
        save('fdata.dat','data','fnumber','max_class');
        h1 = msgbox(['Database was empty and has just been created. Face succesfully added to database with ID number-->' num2str(class_number)],'Face Recognition');
        uiwait(h1);
        % ask user to fill ID information for this new person
        prompt = {'Name:','Surename:','Phone Number'};
        title = 'Please fill detail information';
        numlines = 1;
        defaultanswer = {'','',''};
        options.Resize = 'on';
        answer = inputdlg(prompt,title,numlines,defaultanswer,options);
        a = ''; b = ''; c = ''; d = ''; h = 'Y';
        if ~isempty(answer)
            a = answer{1};
            b = answer{2}; 
            c = answer{3};
            h = 'Y';
            op=(strcat(num2str(class_number)));
        end 
        % ask user to add reference image for this new person
        h1 = msgbox('Please add a reference image','Face Recognition');
        uiwait(h1);
        [ans,pathname] = uigetfile({'*.jpg';'*.jpeg'},'Select an IMAGE');
        if isequal(ans,0)
            h1 = msgbox('Action Cancelled !','Face Recognition');
            uiwait(h1);
            y = num2str(class_number);
            save([y '.dat'],'a','b','c','h','op')
            save([a '.dat'],'a','b','c','h','op')
            h1 = msgbox('Information is saved!','Face Recognition');
            uiwait(h1);
            return
        end 
        % save ID information and the reference image to database
        try
            kl=imread([pathname ans]);
            sh = figure; sa = axes('Parent',sh);
            imshow(kl,'Parent',sa)
            y = num2str(class_number);
            save([y '.dat'],'a','b','c','h','kl','op');
            save([a '.dat'],'a','b','c','h','kl','op');
            pause(1);
            close(sh);
            h1 = msgbox('Information is saved!','Face Recognition');
            uiwait(h1);
        catch me
            y = num2str(class_number); 
            save([y '.dat'],'a','b','c','h','op');
            save([a '.dat'],'a','b','c','h','op'); 
            h1 = errordlg({['Error: ' me.message];'Other variables are saved'},'Face Recognition');
            uiwait(h1);
            return
        end
    end
end