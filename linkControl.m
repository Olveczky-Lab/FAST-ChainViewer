function varargout = linkControl(varargin)
% LINKCONTROL MATLAB code for linkControl.fig
%      LINKCONTROL, by itself, creates a new LINKCONTROL or raises the existing
%      singleton*.
%
%      H = LINKCONTROL returns the handle to a new LINKCONTROL or the handle to
%      the existing singleton*.
%
%      LINKCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LINKCONTROL.M with the given input arguments.
%
%      LINKCONTROL('Property','Value',...) creates a new LINKCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before linkControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to linkControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help linkControl

% Last Modified by GUIDE v2.5 07-May-2015 20:12:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @linkControl_OpeningFcn, ...
                   'gui_OutputFcn',  @linkControl_OutputFcn, ...
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


% --- Executes just before linkControl is made visible.
function linkControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to linkControl (see VARARGIN)

% Choose default command line output for linkControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes linkControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = linkControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% Chains 1.
chainsEnter = str2double(get(hObject,'string'));

if isnan(chainsEnter)
    errordlg('You must enter a numeric value', 'Invalid Input', 'modal')
    uicontrol(hObject)
    return
else
    display(chainsEnter);
end

handles.chain1 = chainsEnter;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% Chains 2.
chainsEnter = str2double(get(hObject,'string'));

if isnan(chainsEnter)
    errordlg('You must enter a numeric value', 'Invalid Input', 'modal')
    uicontrol(hObject)
    return
else
    display(chainsEnter);
end

handles.chain2 = chainsEnter;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Create link.
global manualModifications;
manualModifications{end + 1} = [handles.chain1, handles.chain2, 1];
manualModifications{end + 1} = [handles.chain2, handles.chain1, 1];

disp('Link created')
handles.manualModifications = manualModifications;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% Delete link.
global manualModifications;
manualModifications{end + 1} = [handles.chain1, handles.chain2, 0];
manualModifications{end + 1} = [handles.chain2, handles.chain1, 0];

disp('Link deleted')
handles.manualModifications = manualModifications;

