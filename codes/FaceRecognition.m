function varargout = FaceRecognition(varargin)
% FACERECOGNITION M-file for FaceRecognition.fig
%      FACERECOGNITION, by itself, creates a new FACERECOGNITION or raises the existing
%      singleton*.
%
%      H = FACERECOGNITION returns the handle to a new FACERECOGNITION or the handle to
%      the existing singleton*.
%
%      FACERECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACERECOGNITION.M with the given input arguments.
%
%      FACERECOGNITION('Property','Value',...) creates a new FACERECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FaceRecognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FaceRecognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FaceRecognition

% Last Modified by GUIDE v2.5 26-Oct-2010 22:05:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FaceRecognition_OpeningFcn, ...
                   'gui_OutputFcn',  @FaceRecognition_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FaceRecognition is made visible.
function FaceRecognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FaceRecognition (see VARARGIN)

% Choose default command line output for FaceRecognition
clc;
%% clear all variables
handles.imgresized = [];
handles.filedir = '';
handles.output = hObject;
handles.width = 24;
handles.height = 32;
handles.IMGDB = cell(3,[]);
handles.net = 0;
handles.G = 0;
handles.figureSingleImage = [];
handles.img_array = cell(1);
handles.img_single = [];
handles.series = 1;
handles.photo = [];
handles.acenter = [];
handles.info_array = cell(1);
%% initialize gabor and ANN
if ~exist('gabor.mat','file')    
    create_gabor;
    load gabor;
    handles.G = G;
end
if exist('net.mat','file')
    load net;
    handles.net = net;
else
    createffnn
    load net;
    handles.net = net;
end
if exist('imgdb.mat','file')
    load imgdb;
    handles.IMGDB = IMGDB;
else
    handles.IMGDB = loadimages(1); % default face folder = face
end
%% initialize status of some gui components
set(handles.edtStatus,'String','Ready');
set(handles.menu_detection_test,'Visible','off');
set(handles.menu_recognition_face,'Visible','off');

%% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FaceRecognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FaceRecognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_detection_Callback(hObject, eventdata, handles)
% hObject    handle to menu_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_detection_database_Callback(hObject, eventdata, handles)
% hObject    handle to menu_detection_database (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Detection->Create Database
handles.IMGDB = loadimages(2);
guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function menu_detection_initialize_Callback(hObject, eventdata, handles)
% hObject    handle to menu_detection_initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Detection->Initialize Network
choice = questdlg('Are you sure want to initiate ANN? Learning data will be erased!', ...
	'Face Recognition', ...
	'Yes','No','No');
switch choice
    case 'Yes'
        createffnn;
        load net;
        handles.net = net;
        guidata(handles.figure1, handles);
end

% --------------------------------------------------------------------
function menu_detection_train_Callback(hObject, eventdata, handles)
% hObject    handle to menu_detection_train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Detection->Train Network
handles.net = trainnet(handles.net,handles.IMGDB);
guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function menu_detection_test_Callback(hObject, eventdata, handles)
% hObject    handle to menu_detection_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% btnDetection_Callback(handles);

% --------------------------------------------------------------------
function menu_recognition_select_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Recognition->Select an Image to add to Face Database
[file_name file_path] = uigetfile ('*.jpg');
if file_path ~= 0
    handles.img_single = imread([file_path,file_name]);
    handles.figureSingleImage = figure;
    axs = axes('Parent',handles.figureSingleImage);
    imshow(handles.img_single,'Parent',axs);
    guidata(handles.figure1, handles);    
end

% --------------------------------------------------------------------
function menu_recognition_new_record_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_new_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Recognition->Add Face to Database
if ~isempty(handles.img_single)
    AddFace(handles.img_single);
    handles.img_single = [];
    hx = handles.figureSingleImage;
    if hx ~= 0
        close(hx);
        handles.figureSingleImage = 0;
    end
    guidata(handles.figure1, handles);
else
    h = warndlg('No single image selected !','Face Recognition');
    uiwait(h);
end

% --------------------------------------------------------------------
function menu_recognition_numid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_numid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Recognition->Total Number of ID
numid = datainfo;
if(numid>0)
    g = msgbox(['There are' blanks(1) num2str(numid) blanks(1) 'ID(s) at the database.'],'Face Recognition');
else
    g = msgbox('Database is empty', 'Face Recognition');
end
uiwait(g);

% --------------------------------------------------------------------
function menu_recognition_face_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_face (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% FaceRecognition(1,handles,handles.img_single);

% --------------------------------------------------------------------
function menu_recognition_infoid_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_infoid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_recognition_delete_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Recognition->Delete Database
files = dir('*.dat');
if length(files) == 0
    m = msgbox('Database already empty.','Face Recognition');
    uiwait(m);
    return
end
btn = questdlg('Delete all information (*.dat file) ?','Face Recognition','Yes','No','Yes');
if btn == 'Yes'
    delete('*.dat');
    m = msgbox('Database removed !', 'Face Recognition');
    uiwait(m);
end
    

% --------------------------------------------------------------------
function menu_recognition_eigen_Callback(hObject, eventdata, handles)
% hObject    handle to menu_recognition_eigen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Face Recognition->Mean Face and Eigen Face
EigenFace;

% --- Executes on button press in btnPrevious.
function btnPrevious_Callback(hObject, eventdata, handles)
% hObject    handle to btnPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for button Previous
% if page is 1 then do nothing
if handles.series == 1
    return;
end
% if list of face images are exist
if ~isempty(handles.img_array{1})
    % clear axes first
    cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
    % clear Info ID textbox
    set([handles.edt1 handles.edt2 handles.edt3 handles.edt4],'String','');
    % enable all save buttons 
    set([handles.btns1 handles.btns2 handles.btns3 handles.btns4],'Enable','on');
    % disable all Info ID buttons
    set([handles.btni1 handles.btni2 handles.btni3 handles.btni4],'Enable','off');
    % reset page list of face images to 1
    handles.series = handles.series - 1;
    set(handles.edtp,'String',num2str(handles.series));
    % update structure handles
    guidata(handles.figure1, handles);
    % show face images on list face axes
    for i=1:4
        str = '''Parent''';
        str1 = '''InitialMagnification''';
        str2 = '''fit''';
        expr = ['imshow(handles.img_array{' num2str((handles.series - 1)*4 + i) '},' str1 ',' str2 ',' str ',handles.ax' num2str(i) ')'];
        eval(expr);
        % if user already did Face Recognition, then show the ID information
        if ~isempty(handles.info_array{1})
            a = handles.info_array{(handles.series - 1)*4 + i};
            id = a{2}; found = a{3}; 
            % if face is found
            if found == 1 
                % disable save button
                eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                % enable Info ID button
                eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                % show the ID in Info ID textbox
                eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' num2str(id) ')']); 
            % if face isn't found
            else 
                % if no similarities to other face (new face detected)
                if id == 0 
                    % enable save button
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    % disable Info ID button
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                    % clear Info ID textbox
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' ''' ''' ')']);
                % there is a similarity to another face 
                else 
                    % enable save button
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    % enable also Info ID button
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    % show ID information on textbox
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' '''~' num2str(id) '''' ')']);
                end
            end        
        end
    end    
end

% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% hObject    handle to btnNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for button Next
% if page is the last page then do nothing
if length(handles.img_array) <= handles.series*4
    return;
end
% if list of face images are exist
if ~isempty(handles.img_array{1})  
    % clear face image axes
    cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
    % clear Info ID textbox
    set([handles.edt1 handles.edt2 handles.edt3 handles.edt4],'String','');
    % enable all save buttons
    set([handles.btns1 handles.btns2 handles.btns3 handles.btns4],'Enable','on');
    % disable all Info ID buttons
    set([handles.btni1 handles.btni2 handles.btni3 handles.btni4],'Enable','off');
    % show face images on list face axes
    for i=1:4
        % if last of face image detected then exit from loop
        if (handles.series*4 + i) > length(handles.img_array)
            break;
        end
        % show face images
        str = '''Parent''';
        str1 = '''InitialMagnification''';
        str2 = '''fit''';
        expr = ['imshow(handles.img_array{' num2str(handles.series*4 + i) '},' str1 ',' str2 ',' str ',handles.ax' num2str(i) ')'];
        eval(expr);
        % if user already did Face Recognition, then show the ID
        % information
        if ~isempty(handles.info_array{1})
            a = handles.info_array{handles.series*4 + i};
            id = a{2}; found = a{3}; 
            % if face is found
            if found == 1 
                eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' num2str(id) ')']);                
            else % no face found
                % no similarity to other face (new face detected)
                if id == 0 
                    % enable save button
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    % disable Info ID button
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                    % clear Info ID textbox
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' ''' ''' ')']);
                % there is a similarity to another face
                else 
                    % enable save button
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    % enable also Info ID button
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    % clear Info ID textbox
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' '''~' num2str(id) '''' ')']);
                end
            end        
        end
    end
    % increment page
    handles.series = handles.series + 1;
    % show page
    set(handles.edtp,'String',num2str(handles.series));
    % update structure handles
    guidata(handles.figure1, handles);
end

function edtStatus_Callback(hObject, eventdata, handles)
% hObject    handle to edtStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtStatus as text
%        str2double(get(hObject,'String')) returns contents of edtStatus as a double


% --- Executes during object creation, after setting all properties.
function edtStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btns1.
function btns1_Callback(hObject, eventdata, handles)
% hObject    handle to btns1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for top-left Save button
% if there is no face to be saved
if length(handles.img_array{1}) < 1
    w = warndlg('No image to be saved !', 'Face Recognition');
    uiwait(w);
    return;
end
x = handles.series - 1;
% call function AddFace to save new face image
AddFace(handles.img_array{x*4 + 1});

% --- Executes on button press in btns2.
function btns2_Callback(hObject, eventdata, handles)
% hObject    handle to btns2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for top-right Save button
% if there is no face to be saved
if length(handles.img_array{1}) < 1
    w = warndlg('No image to be saved !', 'Face Recognition');
    uiwait(w);
    return;
end
x = handles.series - 1;
% call function AddFace to save new face image
AddFace(handles.img_array{x*4 + 2});

% --- Executes on button press in btns3.
function btns3_Callback(hObject, eventdata, handles)
% hObject    handle to btns3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for bottom-left Save button
% if there is no face to be saved
if length(handles.img_array{1}) < 1
    w = warndlg('No image to be saved !', 'Face Recognition');
    uiwait(w);
    return;
end
x = handles.series - 1;
% call function AddFace to save new face image
AddFace(handles.img_array{x*4 + 3});

% --- Executes on button press in btns4.
function btns4_Callback(hObject, eventdata, handles)
% hObject    handle to btns4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for bottom-right Save button
% if there is no face to be saved
if length(handles.img_array{1}) < 1
    w = warndlg('No image to be saved !', 'Face Recognition');
    uiwait(w);
    return;
end
x = handles.series - 1;
% call function AddFace to save new face image
AddFace(handles.img_array{x*4 + 4});

% --------------------------------------------------------------------
function menu_face_recog_Callback(hObject, eventdata, handles)
% hObject    handle to menu_face_recog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edtScale_Callback(hObject, eventdata, handles)
% hObject    handle to edtScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtScale as text
%        str2double(get(hObject,'String')) returns contents of edtScale as a double
%% executed when Scale editbox is edited (user scale the photo)
if (str2double(get(hObject,'String')) > 100)||(str2double(get(hObject,'String')) < 0)
    e = errordlg('Maximum value = 100, minimum value = 0 !','Face Recognition');
    uiwait(e);
    return;
end
set(handles.sliderScale,'Value',str2double(get(hObject,'String')));
drawnow;
% rescale the photo
if(length(handles.photo) > 0)    
    im = handles.photo;
    try
        im = rgb2gray(handles.photo);
    end
    scale = str2num(get(hObject,'String'))/100;
    cla(handles.picture);
    handles.imgresized = imresize(im,scale);
    imshow(handles.imgresized,'InitialMagnification','fit','Parent',handles.picture);
    drawnow;    
    guidata(handles.figure1,handles);
    displayImgProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function edtScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sliderScale_Callback(hObject, eventdata, handles)
% hObject    handle to sliderScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%% executed when Scale slider position is changed
set(handles.edtScale,'String',num2str(round(get(hObject,'Value'))));
% drawnow;
% rescale the photo
if(length(handles.photo) > 0)    
    im = handles.photo;
    try
        im = rgb2gray(handles.photo);
    end
    scale = get(hObject,'Value')/100;
    cla(handles.picture);
    handles.imgresized = imresize(im,scale);
    imshow(handles.imgresized,'InitialMagnification','fit','Parent',handles.picture);
    drawnow;    
    guidata(handles.figure1, handles);
    displayImgProperties(handles);
end

% --- Executes during object creation, after setting all properties.
function sliderScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --------------------------------------------------------------------
function menu_tools_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_mcrop_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mcrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Tools->Manually Crop Face
if length(handles.photo) > 1
    % crop the photo
    I = imcrop(handles.picture);
    % if there is no list of face image before, then index of face image array is = 0
    if isempty(handles.img_array{1})
        le = 0;
    % if face image already exist in the list, then index = the number of face images in the list 
    else
        le = length(handles.img_array);
    end
    % prepare to assign a new cropped image to the list
    handles.img_array{le+1} = I;
    imcr = handles.img_array;
    % give the appropriate initial ID information of this new cropped image
    if ~isempty(handles.info_array{1})
        idx = 0; foundx = 0; name = ''; surename = ''; phone = ''; access = 'N'; rimg = [];
        a = [{le+1} {idx} {foundx} {name} {surename} {phone} {access} {rimg}];
        handles.info_array{le+1} = a;
        guidata(handles.figure1, handles);
    end
    % show cropped image to the list
    cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
    for i = 1:length(imcr)
        if i < 5
            str = '''Parent''';
            str1 = '''InitialMagnification''';
            str2 = '''fit''';
            expr = ['imshow(imcr{' num2str(i) '},' str1 ',' str2 ',' str ',handles.ax' num2str(i) ')'];
            eval(expr);
        end
    end
    % re-evaluate and re-display the ID information of each face image
    if ~isempty(handles.info_array{1})
        for i = 1:4
            a = handles.info_array{i};
            id = a{2}; found = a{3}; 
            if found == 1 % if face is found
                eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' num2str(id) ')']);                
            else % if face isn't found
                if id == 0 % no similar
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' ''' ''' ')']);
                else % there is a similarity to another face
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' '''~' num2str(id) '''' ')']);
                end
            end
        end
    end
    % reset page to 1
    handles.series = 1;
    set(handles.edtp,'String','1');
    % update structure handles
    guidata(handles.figure1, handles);  
else
    h = warndlg('No image to be cropped','Face Recognition');
    uiwait(h);
end


function edt1_Callback(hObject, eventdata, handles)
% hObject    handle to edt1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt1 as text
%        str2double(get(hObject,'String')) returns contents of edt1 as a double


% --- Executes during object creation, after setting all properties.
function edt1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edt2_Callback(hObject, eventdata, handles)
% hObject    handle to edt2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt2 as text
%        str2double(get(hObject,'String')) returns contents of edt2 as a double


% --- Executes during object creation, after setting all properties.
function edt2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edt3_Callback(hObject, eventdata, handles)
% hObject    handle to edt3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt3 as text
%        str2double(get(hObject,'String')) returns contents of edt3 as a double


% --- Executes during object creation, after setting all properties.
function edt3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edt4_Callback(hObject, eventdata, handles)
% hObject    handle to edt4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt4 as text
%        str2double(get(hObject,'String')) returns contents of edt4 as a double


% --- Executes during object creation, after setting all properties.
function edt4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRecognize.
function btnRecognize_Callback(hObject, eventdata, handles)
% hObject    handle to btnRecognize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% executed when user click button Recognize Face 
if isempty(handles.img_array{1})
    w = warndlg('No face are detected. Please perform Face Detection first !','Face Recognition');
    uiwait(w);
    return;
end
Recognize(2,handles,handles.img_array);

function Recognize(mode,handles,data)
%% function for face recognition
% this function will be called when the user click Recognize Face button
% parameters to be parsing: 
% 1. mode: default = 2
% 2. handles: current figure handles
% 3. data: face image array
if mode == 2
    % if face image array exist
    if ~isempty(data{1})
        imcr = data;
        % iterate all face images in image array
        for i = 1: length(imcr)
            % resize to 250 x 250 pixel for each face image
            img_r = imresize(imcr{i},[250 250]);
            % call original function of Face Recognition
            [found id] = RecognizeFace(img_r);
            % % % img_r is face image in 250x250 pixel            
            % % % if found=1 & id>0 -> face identified
            % % % if found=0 & id>0 -> face unidentified but similar face exist
            % % % if found=0 & id=0 -> error 
            
            % get ID information based on ID number found
            [name surename phone access rimg exception] = ldinfo(id);
            % save ID information
            a = [{i} {id} {found} {name} {surename} {phone} {access} {rimg}];
            info_array{i} = a;
        end
        % update handles structure
        handles.info_array = info_array;
        handles.series = 1;
        set(handles.edtp,'String',num2str(handles.series));
        guidata(handles.figure1, handles);
        
        % prepare to display the face images
        % clear list face axes
        cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
        % display face images in list
        for i = 1:length(imcr)
            if i < 5
                str = '''Parent''';
                str1 = '''InitialMagnification''';
                str2 = '''fit''';
                expr = ['imshow(imcr{' num2str(i) '},' str1 ',' str2 ',' str ',handles.ax' num2str(i) ')'];
                eval(expr);
                a = info_array{i};
                id = a{2}; found = a{3}; 
                if found == 1 % if face is found
                    eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                    eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                    eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' num2str(id) ')']);                
                else % if face isn't found
                    if id == 0 % no similar
                        eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                        eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'off''' ')']);
                        eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' ''' ''' ')']);
                    else % there is a similarity to another face
                        eval(['set(handles.btns' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                        eval(['set(handles.btni' num2str(i) ',''' 'Enable''' ',''' 'on''' ')']);
                        eval(['set(handles.edt' num2str(i) ',''' 'String''' ',' '''~' num2str(id) '''' ')']);
                    end
                end
            end
        end
    end
elseif mode == 1
end

% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for button Load Photo
[file_name file_path] = uigetfile ('*.jpg');
if file_path ~= 0
    cla(handles.picture);
    cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
    % read input image
    handles.photo = imread ([file_path,file_name]);
    % read scale
    scale = str2num(get(handles.edtScale,'String'))/100;
    % convert to gray image
    im = handles.photo;
    try
        im = rgb2gray(handles.photo);
    end
    cla(handles.picture);
    % scale the photo
    c = imresize(im,scale);
    handles.imgresized = c;
    % display photo
    imshow(c,'InitialMagnification','fit','Parent',handles.picture);
    handles.filedir = fullfile(file_path,file_name);
    guidata(handles.figure1, handles);
    % show photo properties
    displayImgProperties(handles);
    btnClear_Callback([], [], handles)
end

% --- Executes on button press in btnDetect.
function btnDetect_Callback(hObject, eventdata, handles)
% hObject    handle to btnDetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% executed when user click button Detect Face
% this routine will perform Face Detection
set(handles.btnRecognize,'Enable','off');
% if photo to be detected is exist
if(length(handles.photo) > 0)  
    % if scale is 100 %
    if strcmp((get(handles.edtScale,'String')),'100') == 1
        choice = questdlg('Are you sure to run Face Detection in 100% scale? This will take a long time processing depending on image size.', ...
        'Face Recognition', ...
        'Yes','No','No');
        % if user insist to perform face detection in 100 % scale
        if strcmp(choice,'Yes') == 1
            % clear all variables: face image array, ID information array, 
            handles.acenter = [];
            handles.img_array = {[]};
            handles.info_array = {[]};
            % reset page to 1
            handles.series = 1;
            set(handles.edtp,'String',num2str(handles.series));    
            % assign input image to a temporary variable
            im_gray = handles.photo;
            % update structure handles
            guidata(handles.figure1, handles); 
            % get scale
            scale = str2double(get(handles.edtScale,'String'))/100;
            % convert input image to gray and re-scale
            [rx cx px] = size(im_gray);
            if px == 1
                im_resize = imresize(im_gray,scale);
            else
                im_gray = rgb2gray(im_gray);
                im_resize = imresize(im_gray,scale);
            end
            % perform scanning for face detection
            set(handles.edtStatus,'String','Face detection in progress, please wait ...');
            [im_out, acenter, t] = imscan(handles.net,im_resize,handles.picture);
            handles.acenter = acenter;
            % get coordinate of each face that found in the input image => (lutm lutn w1 h1)
            % crop faces found in input image => imcr
            [imcr lutm lutn w1 h1] = getrect(acenter, im_gray, scale, handles.width, handles.height);
            % show input image in gray mode
            imshow(im_gray,'InitialMagnification','fit','Parent',handles.picture);
            % create rectangle around the face for each face on input image
            for j = 1:length(lutm)
                rectangle('EdgeColor','g','Position',[lutn(j)-round(w1/2) lutm(j)-round(h1/2) w1 h1],'Parent',handles.picture);
            end
            % clear list face axes
            cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
            % show faces in the list face axes
            for i = 1:length(imcr)
                if i < 5
                    str = '''Parent''';
                    str1 = '''InitialMagnification''';
                    str2 = '''fit''';
                    expr = ['imshow(imcr{' num2str(i) '},' str1 ',' str2 ',' str ',handles.ax' num2str(i) ')'];
                    eval(expr);
                else
                    break;
                end
            end
            % update variable handles
            handles.img_array = imcr;
            handles.series = 1;
            set(handles.edtp,'String',num2str(handles.series));
            % update structure handles
            guidata(handles.figure1, handles);   
            set(handles.edtStatus,'String',['Scanning face completed, number of face found:' blanks(1) num2str(length(imcr)) blanks(1) ', time elapse' blanks(1) num2str(t) blanks(1) 'second']);
        end
    % if scale is not 100%
    else
        % clear all variables: face image array, ID information array, 
        handles.acenter = [];
        handles.img_array = {[]};
        handles.info_array = {[]};
        % reset page to 1
        handles.series = 1;
        set(handles.edtp,'String',num2str(handles.series));
        % assign input image to a temporary variable
        im_gray = handles.photo;
        % update structure handles
        guidata(handles.figure1, handles); 
        % get scale
        scale = str2double(get(handles.edtScale,'String'))/100;
        % convert input image to gray and re-scale
        [rx cx px] = size(im_gray);
        if px == 1
            im_resize = imresize(im_gray,scale);
        else
            im_gray = rgb2gray(im_gray);
            im_resize = imresize(im_gray,scale);
        end
        % prepare to perform face detection
        set(handles.edtStatus,'String','Face detection in progress, please wait ...');
        try
            % do face detection
            [im_out, acenter, t] = imscan(handles.net,im_resize,handles.picture);
        catch me
            % if error occur regarding face detection
            e = errordlg(me.message,'Face Recognition');
            uiwait(e);
            set(handles.edtStatus,'String','Face detection in cancelled with error !');
            set(handles.btnRecognize,'Enable','on');
            return;
        end
        handles.acenter = acenter;
        % get coordinate of each face that found in the input image => (lutm lutn w1 h1)
        % crop faces found in input image => imcr
        [imcr lutm lutn w1 h1] = getrect(acenter, im_gray, scale, handles.width, handles.height);
        % show input image in gray mode
        imshow(im_gray,'InitialMagnification','fit','Parent',handles.picture);
        % create rectangle around the face for each face on input image
        for j = 1:length(lutm)
            rectangle('EdgeColor','g','Position',[lutn(j)-round(w1/2) lutm(j)-round(h1/2) w1 h1],'Parent',handles.picture);
        end
        % clear list face axes            
        cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4);
        % show faces in the list face axes
        for i = 1:length(imcr)
            if i < 5
                str = '''Parent''';
                str1 = '''InitialMagnification''';
                str2 = '''fit''';
                expr = ['imshow(imcr{' num2str(i) '},' str1 ',' str2 ',' str ',handles.ax' num2str(i) ')'];
                eval(expr);
            else
                break;
            end
        end
        % update variable handles
        handles.img_array = imcr;
        handles.series = 1;
        set(handles.edtp,'String',num2str(handles.series));
        % update structure handles
        guidata(handles.figure1, handles);          
        set(handles.edtStatus,'String',['Scanning face completed, number of face found:' blanks(1) num2str(length(imcr)) blanks(1) ', time elapse' blanks(1) num2str(t) blanks(1) 'second']);
    end
    set(handles.edtScale,'String','100');
    set(handles.sliderScale,'Value',100);
else
    w = warndlg('No image for performing Face Detection','Face Recognition');
    uiwait(w);
end
set(handles.btnRecognize,'Enable','on');

% --- Executes on button press in btni1.
function btni1_Callback(hObject, eventdata, handles)
%% event for top-left Info ID button
% hObject    handle to btni1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(get(handles.edt1,'String'))
    return
end  
showInfo(handles,1);

% --- Executes on button press in btni2.
function btni2_Callback(hObject, eventdata, handles)
% hObject    handle to btni2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for top-right Info ID button
if isempty(get(handles.edt2,'String'))
    return
end
showInfo(handles,2);

% --- Executes on button press in btni3.
function btni3_Callback(hObject, eventdata, handles)
% hObject    handle to btni3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for bottom-left Info ID button
if isempty(get(handles.edt3,'String'))
    return
end
showInfo(handles,3);

% --- Executes on button press in btni4.
function btni4_Callback(hObject, eventdata, handles)
% hObject    handle to btni4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for bottom-right Info ID button
if isempty(get(handles.edt4,'String'))
    return
end
showInfo(handles,4);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function infoid_info_Callback(hObject, eventdata, handles)
% hObject    handle to infoid_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for Face Recogntion->ID Information->Display Information
dinfo;

% --------------------------------------------------------------------
function infoid_showdbfile_Callback(hObject, eventdata, handles)
% hObject    handle to infoid_showdbfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for Face Recogntion->ID Information->Show Database File
files = dir('*.dat');
if length(files) == 0
    e = warndlg(['Database doesn''' 't exist.'],'Face Recognition');
    uiwait(e);
    return
end
s = '';
for i = 1:length(files)
    str = files(i).name;
    s = [s blanks(3) str];
end
m = msgbox(s,'Face Recognition');
uiwait(m);

function showInfo(handles,id)
%% function to show ID Information in ID Information listbox and photo of a
%% person in the axes axm
if isempty(handles.info_array{1})
    return
end
cla(handles.axm);
% set(handles.axm,'Color',[1 1 1]);
strs = eval(['get(handles.edt' num2str(id) ',' '''String''' ')']);
if strs(1) == '~'
    id_in_edt = str2double(strs(2:length(strs)));
else
    id_in_edt = eval(['str2num(get(handles.edt' num2str(id) ',' '''String''' '))']);
end
for i = 1: length(handles.info_array)
    a = handles.info_array{i};
    if a{2} == id_in_edt
        if length(a{8}) > 1
            imshow(a{8},'Parent',handles.axm);
        end
        id = num2str(a{2});
        name = (a{4});
        surename = (a{5});
        phone = (a{6});
        access = (a{7});
        set(handles.listbox1,'String',{strcat('ID:',id),...
            strcat('Name:',name),...
            strcat('Surename:',surename),...
            strcat('Ph:',phone)});
%             strcat('Allow Access:',access)});
        break
    end
end

% --- Executes on button press in btnClear.
function btnClear_Callback(hObject, eventdata, handles)
% hObject    handle to btnClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for button Refresh
% clear all variables
handles.img_array = {[]};
handles.info_array = {[]};
handles.figureSingleImage = [];
handles.acenter = [];
% clear all face axes
cla(handles.ax1); cla(handles.ax2); cla(handles.ax3); cla(handles.ax4); cla(handles.axm);
% reset buttons, listbox, editboxes
set([handles.btns1 handles.btns2 handles.btns3 handles.btns4],'Enable','on');
set([handles.btni1 handles.btni2 handles.btni3 handles.btni4],'Enable','off');
set([handles.btnDetect handles.btnRecognize],'Enable','on');
set(handles.listbox1,'String','');
set([handles.edt1 handles.edt2 handles.edt3 handles.edt4],'String','');
% reset page to 1
handles.series = 1;
set(handles.edtp,'String',num2str(handles.series));
% reload the photo (input image) to axes and resize based on scale
if length(handles.photo > 1)
    im = handles.photo;
    try
        im = rgb2gray(handles.photo);
    end
    scale = str2num(get(handles.edtScale,'String'))/100;
    cla(handles.picture);
    imshow(imresize(im,scale),'InitialMagnification','fit','Parent',handles.picture);
    drawnow;
end
% update structure handles
guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function menu_setframe_Callback(hObject, eventdata, handles)
% hObject    handle to menu_setframe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu Tools->Set Width/Height Face Frame
prompt = {'Width:','Height:'};
title = 'Please fill width/height of face frame';
numlines = 1;
defaultanswer = {'24','32'};
options.Resize = 'on';
answer = inputdlg(prompt,title,numlines,defaultanswer,options);
if ~isempty(answer)
    handles.width = str2double(answer{1});
    handles.height = str2double(answer{2});
    guidata(handles.figure1,handles);
end


% --- Executes on button press in btnCrop.
function btnCrop_Callback(hObject, eventdata, handles)
% hObject    handle to btnCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% executed when user click Manual Crop button
menu_mcrop_Callback([],[],handles);


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function displayImgProperties(handles)
%% function to display information about the photo that has been loaded for
%% testing Face Detection/Face Recognition
if size(handles.photo,3) == 3
    rstr = '24bit RGB';
elseif size(handles.photo,3) == 1
    rstr = '8bit Gray';
else
    rstr = 'Unknown';
end
img = handles.imgresized;
% display image properties in listbox
set(handles.listbox2,'String',{['Filename :' blanks(1) handles.filedir],...
    ['Original Size :' blanks(1) num2str(size(handles.photo,1)) 'x' num2str(size(handles.photo,2)) blanks(1) 'pixels'],...
    ['Size after resized :' blanks(1) num2str(size(img,1)) 'x' num2str(size(img,2)) blanks(1) 'pixels'],...
    ['Resolution :' blanks(1) rstr]});

% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% event for menu File->Exit Program
close;



function edtp_Callback(hObject, eventdata, handles)
% hObject    handle to edtp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtp as text
%        str2double(get(hObject,'String')) returns contents of edtp as a double


% --- Executes during object creation, after setting all properties.
function edtp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
