%Camera Calibration

imaqreset;

cam = videoinput('winvideo',1);
cam.ReturnedColorspace = 'rgb';


%Set the parameters of the camera
src = getselectedsource(cam);
src.ExposureMode = 'manual';
src.Exposure = -13;
src.WhiteBalanceMode = 'manual';
src.Brightness = 70;
src.Gamma = 55;
src.Saturation = 100;
src.WhiteBalance = 3500;
src.Sharpness = 30;
src.Contrast = 90;


%Trigger configuration
triggerconfig(cam,'manual');
cam.TriggerRepeat = Inf;
cam.FramesPerTrigger = 1;


frames = 40;%set the number of calibration images


%Set the Calibration folder
rootpath = pwd;%set current folder as the root folder

newFolderName = 'TempCalibrationImage';%create calibration folder
mkdir(newFolderName);

calipath = [rootpath,'\',newFolderName];%Get the calibration folder and go to it
cd(calipath);

mkdir('imL');%Create left and right image folders
mkdir('imR');

%Get the calibration images
start(cam);

for i = 1:frames
    %Get the original images from the camera
    trigger(cam);
    im = getdata(cam);
    
    %Seperate the image
    [imL,imR] = SeparateImage(im);
    imshowpair(imL,imR,'montage');
    hold on
    %Save the images
    imwrite(imL,[calipath,'\','imL\','imL_',int2str(i),'.png']);
    imwrite(imR,[calipath,'\','imR\','imR_',int2str(i),'.png']);
    pause(1)
    i/frames*100
end

stop(cam);

stereoCameraCalibrator