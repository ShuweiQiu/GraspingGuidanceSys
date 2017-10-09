%Get images from camera

imaqreset;%delete all image acquisition objects

cam = videoinput('winvideo',1);%create video input object

cam.ReturnedColorspace = 'rgb';%Specify color space used in MATLAB

To Trigger frames immediatelly - Set manual trigger
triggerconfig(cam,'manual');
cam.TriggerRepeat = Inf;
cam.FramesPerTrigger = 1;

Camera calibration
CameraCalibration;
load('stereoParams.mat');

Start the camera
start(cam);

Trigger the camera to get one image
trigger(cam);
im = getdata(cam);

Show the original image
figure;imshow(im);

Separate a single stereo image into two images
[im1,im2] = SeparateImage(im);

Image rectification
[imRe1,imRe2] = rectifyStereoImages(im1,im2,stereoParams);

%Deal with 1 channel only
imRe1 = rgb2gray(imRe1);
imRe2 = rgb2gray(imRe2);

% Get the image that only contains the edge of the object


%Get the disparity map
disparityMap = disparity(imRe1,imRe2);

%Get 3D points
points3D = reconstructScene(disparityMap,stereoParams);

%Point clouds
pc = pointCloud(points3D);


%Show the result
figure;imshow(uint8(disparityMap));
figure;pcshow(pc,'markersize',60);

stop(cam);