function varargout = GuidanceSysApp(varargin)
% GuidanceSysApp MATLAB code for GuidanceSysApp.fig
%      GuidanceSysApp, by itself, creates a new GuidanceSysApp or raises the existing
%      singleton*.
%
%      H = GuidanceSysApp returns the handle to a new GuidanceSysApp or the handle to
%      the existing singleton*.
%
%      GuidanceSysApp('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GuidanceSysApp.M with the given input arguments.
%
%      GuidanceSysApp('Property','Value',...) creates a new GuidanceSysApp or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuidanceSysApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuidanceSysApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuidanceSysApp

% Last Modified by GUIDE v2.5 18-Sep-2017 16:09:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuidanceSysApp_OpeningFcn, ...
                   'gui_OutputFcn',  @GuidanceSysApp_OutputFcn, ...
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



% --- Executes just before GuidanceSysApp is made visible.
function GuidanceSysApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuidanceSysApp (see VARARGIN)
% imaqreset; vid = videoinput('winvideo');
% handles.currentCam = vid;

set(handles.message_GuidanceSystem, 'String', 'Waiting for acquisition');

% load('C:\Shuwei\Project_CameraOnHand\Guidance\stereoParams_KUKA.mat');
load('C:\Shuwei\Project_CameraOnHand\Guidance\stereoParams3.0.mat');
handles.stereoParams = stereoParams;
% set(handles.popupmenu_AvailableCams,'string','no cam');
% set(handles.popupmenu_AvailableResolutions,'string','no cam')

%Set up the labels for camera parameters
set(handles.label_Contrast,'String',num2str(handles.slider_Contrast.Value));
set(handles.label_Brightness,'String',num2str(handles.slider_Brightness.Value));
set(handles.label_Exposure,'String',num2str(handles.slider_Exposure.Value));
set(handles.label_Gamma,'String',num2str(handles.slider_Gamma.Value));
set(handles.label_Sharpness,'String',num2str(handles.slider_Sharpness.Value));
set(handles.label_WhiteBalance,'String',num2str(handles.slider_WhiteBalance.Value));
set(handles.label_Hue,'String',num2str(handles.slider_Hue.Value));
set(handles.label_Saturation,'String',num2str(handles.slider_Saturation.Value));

% Choose default command line output for GuidanceSysApp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GuidanceSysApp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuidanceSysApp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton_ShowImage.
function pushbutton_ShowImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ShowImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
switch class(handles.shownimg)
    case 'uint8'
        imshow(handles.shownimg)
    case 'pointCloud'
        xyz = handles.ptCloud.Location;
        scatter3(xyz(:,1),xyz(:,2),xyz(:,3),'.')

end


% --- Executes on button press in pushbutton_TriggerCam.
function pushbutton_TriggerCam_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_TriggerCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.message_GuidanceSystem, 'String','Getting the image');
pause(0.1)
vid = handles.currentCam;

% %Trigger configuration
% triggerconfig(vid,'manual');
% vid.TriggerRepeat = Inf;
% vid.FramesPerTrigger = 1;
% start(vid);
% trigger(vid);
% im = getdata(vid);

im = snapshot(vid);
handles.currentimg = im;
handles.shownimg = im;
handles.savedimg = im;

set(handles.pushbutton_FindObject,'Enable','on');
set(handles.pushbutton_ShowImage,'Enable','on');
set(handles.pushbutton_SaveImage,'Enable','on');
set(handles.popupmenu_ShowImage,'Enable','on');
set(handles.popupmenu_SaveImage,'Enable','on');
set(handles.message_GuidanceSystem, 'String', 'Finish acquisition');
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in pushbutton_SaveImage.
function pushbutton_SaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = handles.savedimg;
assignin('base','im',im);

% --- Executes on button press in pushbutton_FindObject.
function pushbutton_FindObject_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_FindObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = handles.currentimg;
stereoParams = handles.stereoParams;
im1 = im(:,1:end/2,:);
im2 = im(:,end/2+1:end,:);
[imRe1,imRe2] = rectifyStereoImages(im1,im2,stereoParams);
handles.imRe1 = imRe1; handles.imRe2 = imRe2;

set(handles.message_GuidanceSystem, 'String','Identify the target');
axes(handles.axes1);
imshow(imRe1)
seedPoint_ref = zeros(1,2);[x,y] = ginput(1);
set(handles.message_GuidanceSystem, 'String','Doing object segmentation');
pause(0.1)
seedPoint_ref(1) = double(x); seedPoint_ref(2) = double(y);

object_image = findObject_IterativeFloodfill(imRe1,seedPoint_ref);
handles.objimg = object_image;
handles.seedPoint_ref = seedPoint_ref;

% if handles.togglebutton_Preview.Value == 1
%     vid = handles.currentCam

set(handles.message_GuidanceSystem, 'String','Object segmentation is done');
set(handles.pushbutton_GetPtCloud,'Enable','on');

pause(0.01)

guidata(hObject,handles);

function message_GuidanceSystem_Callback(hObject, eventdata, handles)
% hObject    handle to message_GuidanceSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of message_GuidanceSystem as text
%        str2double(get(hObject,'String')) returns contents of message_GuidanceSystem as a double


% --- Executes during object creation, after setting all properties.
function message_GuidanceSystem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to message_GuidanceSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Set this edit text box to a multi-line edit text box
set(hObject,'Max',2);

guidata(hObject,handles);


% --- Executes on selection change in popupmenu_ShowImage.
function popupmenu_ShowImage_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_ShowImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Determine the selected data set
val = get(hObject,'Value');


switch val
    case 1 %Original iamge
        handles.shownimg = handles.currentimg;
    case 2 %Object image
        if isfield(handles,'objimg')
            handles.shownimg = handles.objimg;
        end
    case 3 %Point cloud
        if isfield(handles,'ptCloud')
            handles.shownimg = handles.ptCloud;
        end
end
% Save the handles structure.
guidata(hObject,handles)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_ShowImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_ShowImage


% --- Executes during object creation, after setting all properties.
function popupmenu_ShowImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_ShowImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_SaveImage.
function popupmenu_SaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject,'Value');


switch val
    case 1 %Original iamge
        handles.savedimg = handles.currentimg;
    case 2 %Object image
        if isfield(handles,'objimg')
            handles.savedimg = handles.objimg;
        end
    case 3 %Point cloud
        if isfield(handles,'ptCloud')
            handles.savedimg = handles.ptCloud;
        end
end
% Save the handles structure.
guidata(hObject,handles) 
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_SaveImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_SaveImage


% --- Executes during object creation, after setting all properties.
function popupmenu_SaveImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_GetPtCloud.
function pushbutton_GetPtCloud_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GetPtCloud (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.message_GuidanceSystem, 'String', 'Generating Point Cloud');
pause(0.01);

Object_image = handles.objimg; Object_image = rgb2gray(Object_image);

[y,x] = find(Object_image);
%choose reference points
x = x(1:5:end);
y = y(1:5:end);
numofpoints = length(x);
refpoints = zeros(numofpoints,2);
refpoints(:,1) = x;% the first col is X
refpoints(:,2) = y;% the second col is Y

%Deal with 1 channel only
imRe1 = rgb2gray(handles.imRe1);
imRe2 = rgb2gray(handles.imRe2);
seedPoint_ref = handles.seedPoint_ref;


matchedpoints = C2F(imRe1,imRe2,refpoints);

seedPoint_matched = C2F(imRe1,imRe2,seedPoint_ref);

stereoParams = handles.stereoParams;
worldPoints = triangulate(refpoints,matchedpoints,stereoParams);
seedPoint_world = triangulate(seedPoint_ref,seedPoint_matched,stereoParams);

%Using the distance between each point and the seed point in z axis to
%filter the world points
threshold_z = 50;
worldPoints_below_threshold = abs(worldPoints(:,3)-seedPoint_world) < threshold_z;
[idx_below_threshold_row,~] = find(worldPoints_below_threshold);
worldPoints = worldPoints(idx_below_threshold_row,:);

%Get the point cloud
ptCloud = pointCloud(worldPoints);

handles.ptCloud = ptCloud;

set(handles.message_GuidanceSystem, 'String', 'Point Cloud Generation is done');
pause(0.01)

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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


% --- Executes on button press in pushbutton_AvailableCamsDetection.
function pushbutton_AvailableCamsDetection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_AvailableCamsDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.togglebutton_Preview == 1
    ClosePreview(handles.currentCam);
end

imaqreset;

set(handles.popupmenu_AvailableResolutions,'Enable','on');
set(handles.popupmenu_AvailableCams,'Enable','on');
set(handles.pushbutton_TriggerCam,'Enable','on');
set(handles.togglebutton_Preview,'Enable','on');


cams_list = webcamlist;num_cams = length(cams_list);
cams = cams_list{1};

for i = 2:num_cams
    cams = strvcat(cams,cams_list{i});
end


set(handles.popupmenu_AvailableCams,'string',cams)
% handles.availableCams = cams;
currentCam = strtrim(cams(1,:));

while 1
      cam = webcam(currentCam);
      if length(properties(cam)) > 3
          break
      end
      clear cam
end
handles.currentCam = cam;
available_resolutions = cam.AvailableResolutions;
resolutions = available_resolutions{1};
for i = 2 : length(available_resolutions)
resolutions = char(resolutions,available_resolutions{i});
end
set(handles.popupmenu_AvailableResolutions,'string',resolutions);


guidata(hObject,handles);


% --- Executes on selection change in popupmenu_AvailableCams.
function popupmenu_AvailableCams_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_AvailableCams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_cam = hObject.Value;
if selected_cam > 1
    cam_name = strtrim(hObject.String(selected_cam,:));
    
    while 1
        clear cam
        cam = webcam(cam_name);
        if length(properties(cam)) > 3
            break
        end
    end
    handles.currentCam = cam;
    available_resolutions = cam.AvailableResolutions;
    resolutions = 'Available Resolutions';
    for i = 1 : length(available_resolutions)
        resolutions = char(resolutions,available_resolutions{i});
    end
    set(handles.popupmenu_AvailableResolutions,'string',resolutions);
end

guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_AvailableCams contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_AvailableCams


% --- Executes during object creation, after setting all properties.
function popupmenu_AvailableCams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_AvailableCams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_AvailableResolutions.
function popupmenu_AvailableResolutions_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_AvailableResolutions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_resolution = hObject.Value;
resolution = hObject.String(selected_resolution,:);


handles.currentCam.Resolution = strtrim(resolution);

if handles.togglebutton_Preview.Value == 1
    vid = handles.currentCam;
    closePreview(vid);
    vidRes = vid.Resolution; x_location = find(vidRes == 'x');
    imWidth = str2double(vidRes(1:x_location-1));
    imHeight = str2double(vidRes(x_location+1:end));
    % nBands = vid.NumberOfBands;
    hImage = image( zeros(imHeight, imWidth, 3) );

    % Specify the size of the axes that contains the image object
    % so that it displays the image at the right resolution and
    % centers it in the figure window.
    figSize = handles.axes1.Position;
    figWidth = figSize(3);
    figHeight = figSize(4);
    gca.unit = 'pixels';
    gca.position = [ ((figWidth - imWidth)/2)... 
               ((figHeight - imHeight)/2)...
               imWidth imHeight ];
    axes(handles.axes1);
    preview(vid,hImage);
end


guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_AvailableResolutions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_AvailableResolutions


% --- Executes during object creation, after setting all properties.
function popupmenu_AvailableResolutions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_AvailableResolutions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos_size = get(handles.figure1,'Position');
user_response = closeConfirmWindow('Title','Confirm Close');
switch user_response
    case {'No'}
        %no action
    case 'Yes'
        delete(handles.figure1)
end


% --- Executes on slider movement.
function slider_Exposure_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Exposure = round(hObject.Value);
label_Exposure = sprintf('%d',Exposure);
set(handles.label_Exposure,'String',label_Exposure);
handles.currentCam.Exposure = Exposure;
guidata(hObject,handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu_ExposureMode.
function popupmenu_ExposureMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_ExposureMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ExposureModes = hObject.String;
selectedExposureMode = hObject.Value;
switch selectedExposureMode
    case 1
        set(handles.slider_Exposure,'Enable','off');
    case 2
        set(handles.slider_Exposure,'Enable','on');
end

handles.currentCam.ExposureMode = ExposureModes{selectedExposureMode};

guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_ExposureMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_ExposureMode


% --- Executes during object creation, after setting all properties.
function popupmenu_ExposureMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_ExposureMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_Gamma_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Gamma = round(hObject.Value);
label_Gamma = sprintf('%d',Gamma);
set(handles.label_Gamma,'String',label_Gamma);
handles.currentCam.Gamma = Gamma;

guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Sharpness_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Sharpness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Sharpness = round(hObject.Value);
label_Sharpness = sprintf('%d',Sharpness);
set(handles.label_Sharpness,'String',label_Sharpness);
handles.currentCam.Sharpness = Sharpness;

guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Sharpness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Sharpness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu_WhiteBalanceMode.
function popupmenu_WhiteBalanceMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_WhiteBalanceMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WhiteBalanceModes = hObject.String;
selectedWhiteBalanceMode = hObject.Value;

switch selectedWhiteBalanceMode
    case 1
        set(handles.slider_WhiteBalance,'Enable','off');
    case 2
        set(handles.slider_WhiteBalance,'Enable','on');
end


handles.currentCam.WhiteBalanceMode = WhiteBalanceModes{selectedWhiteBalanceMode};

guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_WhiteBalanceMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_WhiteBalanceMode


% --- Executes during object creation, after setting all properties.
function popupmenu_WhiteBalanceMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_WhiteBalanceMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_WhiteBalance_Callback(hObject, eventdata, handles)
% hObject    handle to slider_WhiteBalance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
WhiteBalance = round(hObject.Value);
label_WhiteBalance = sprintf('%d',WhiteBalance);
set(handles.label_WhiteBalance,'String',label_WhiteBalance);
handles.currentCam.WhiteBalance = WhiteBalance;

guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_WhiteBalance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_WhiteBalance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Saturation_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Saturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Saturation = round(hObject.Value);
label_Saturation = sprintf('%d',Saturation);
set(handles.label_Saturation,'String',label_Saturation);
handles.currentCam.Saturation = Saturation;

guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Saturation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Saturation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Hue_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Hue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Hue = round(hObject.Value);
label_Hue = sprintf('%d',Hue);
set(handles.label_Hue,'String',label_Hue);
handles.currentCam.Hue = Hue;

guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Hue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Hue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Brightness_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Brightness = round(hObject.Value);
label_Brightness = sprintf('%d',Brightness);
set(handles.label_Brightness,'String',label_Brightness);
handles.currentCam.Brightness = Brightness;

guidata(hObject,handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Contrast_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Contrast = round(hObject.Value);
label_Contrast = sprintf('%d',Contrast);
set(handles.label_Contrast,'String',label_Contrast);
handles.currentCam.Contrast = Contrast;

guidata(hObject,handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_Contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglebutton_Preview.
function togglebutton_Preview_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status = get(hObject,'Value');
vid = handles.currentCam;
if status == 1
    set(handles.message_GuidanceSystem, 'String', 'Wait for acquisition');
    set(handles.PreviewStatus,'String','On');pause(0.01);
    
    set(handles.popupmenu_ExposureMode,'Enable','on');
    set(handles.slider_Gamma,'Enable','on');
    set(handles.slider_Sharpness,'Enable','on');
    set(handles.popupmenu_WhiteBalanceMode,'Enable','on');
    set(handles.slider_Hue,'Enable','on');
    set(handles.slider_Saturation,'Enable','on');
    set(handles.slider_Brightness,'Enable','on');
    set(handles.slider_Contrast,'Enable','on');
    
    % Create the image object in which you want to
    % display the video preview data.
    vidRes = vid.Resolution; x_location = find(vidRes == 'x');
    imWidth = str2double(vidRes(1:x_location-1));
    imHeight = str2double(vidRes(x_location+1:end));
    % nBands = vid.NumberOfBands;
    hImage = image( zeros(imHeight, imWidth, 3) );

    % Specify the size of the axes that contains the image object
    % so that it displays the image at the right resolution and
    % centers it in the figure window.
    figSize = handles.axes1.Position;
    figWidth = figSize(3);
    figHeight = figSize(4);
    gca.unit = 'pixels';
    gca.position = [ ((figWidth - imWidth)/2)... 
               ((figHeight - imHeight)/2)...
               imWidth imHeight ];
    axes(handles.axes1);
    preview(vid,hImage)
else
    closePreview(vid);
    set(handles.PreviewStatus,'String','Off');pause(0.01);
    set(handles.popupmenu_ExposureMode,'Enable','off');
    set(handles.slider_Exposure,'Enable','off');
    set(handles.slider_Gamma,'Enable','off');
    set(handles.slider_Sharpness,'Enable','off');
    set(handles.popupmenu_WhiteBalanceMode,'Enable','off');
    set(handles.slider_WhiteBalance,'Enable','off');
    set(handles.slider_Hue,'Enable','off');
    set(handles.slider_Saturation,'Enable','off');
    set(handles.slider_Brightness,'Enable','off');
    set(handles.slider_Contrast,'Enable','off');

end

guidata(hObject,handles);
    
% Hint: get(hObject,'Value') returns toggle state of togglebutton_Preview
