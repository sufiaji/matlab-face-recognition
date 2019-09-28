function varargout = gui_eigen(varargin)
% GUI_EIGEN M-file for gui_eigen.fig
%      GUI_EIGEN, by itself, creates a new GUI_EIGEN or raises the existing
%      singleton*.
%
%      H = GUI_EIGEN returns the handle to a new GUI_EIGEN or the handle to
%      the existing singleton*.
%
%      GUI_EIGEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_EIGEN.M with the given input arguments.
%
%      GUI_EIGEN('Property','Value',...) creates a new GUI_EIGEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_eigen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_eigen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_eigen

% Last Modified by GUIDE v2.5 25-Oct-2010 22:37:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_eigen_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_eigen_OutputFcn, ...
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


% --- Executes just before gui_eigen is made visible.
function gui_eigen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_eigen (see VARARGIN)

% Choose default command line output for gui_eigen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

z = get(hObject,'UserData');
if isempty(z{1}), return; end
imshow(z{1},'Parent',handles.axes1); title('Mean Face');
global index;
index = 1;

% set(handles.figure1,'WindowStyle','modal')
% UIWAIT makes gui_eigen wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_eigen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global index;
z = get(handles.figure1,'UserData');
if isempty(z{index}), return; end
if index == 1, return; end
if index == 2
    imshow(z{1},'Parent',handles.axes1); title('Mean Face');
    index = index - 1;
    return;
end
index = index - 1;
load ([num2str(index-1) '.dat'],'-mat');
imshow(z{index},'Parent',handles.axes1); title(strcat('Eigenface of :',{a}));

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global index;
z = get(handles.figure1,'UserData');
if isempty(z{index}), return; end
if index == length(z), return; end
index = index + 1;
load ([num2str(index-1) '.dat'],'-mat');
imshow(z{index},'Parent',handles.axes1); title(strcat('Eigenface of :',{a}));
