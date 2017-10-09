% function ptCloud = Guidance(im,stereoParams)


% Load real images
load('C:\Shuwei\Project_CameraOnHand\Guidance\Segmentation\Code\imDrill.mat');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\ObjectDetection\validationImages\WebcamImg\Keyboard');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\Mouse.mat');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\photos\tomatoes');

% Seperate the stereo image into left and right images
im1 = im(:,1:end/2,:);
im2 = im(:,end/2+1:end,:);

% % Load stereo parameters
% load('stereoParams_KUKA.mat');
load('stereoParams.mat');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\stereoParams3.0.mat');

[imRe1,imRe2] = rectifyStereoImages(im1,im2,stereoParams);

% % Select the object of interest by selecting one seed point on the object
% disp('Please select only one seed point. And please press Enter to end the selection');
% seedPoint_ref = zeros(1,2);
% h = figure;
% imshow(imRe1);
% [x,y] = getpts(h);
% close(h)
% seedPoint_ref(1) = double(x); seedPoint_ref(2) = double(y);
seedPoint_ref = [382,299];

% Get reference points from the left image
% object_image = findObject_singleFloodfill(imRe1,seedPoint_ref);
object_image = findObject_IterativeFloodfill(imRe1,seedPoint_ref);

object_image = rgb2gray(object_image);
[y,x] = find(object_image);

%choose reference points
x = x(1:2:end);
y = y(1:2:end);
numofpoints = length(x);
refpoints = zeros(numofpoints,2);
refpoints(:,1) = x;% the first col is X
refpoints(:,2) = y;% the second col is Y

% Match reference points

%Deal with 1 channel only
imRe1 = rgb2gray(imRe1);
imRe2 = rgb2gray(imRe2);

%pixel level correspondence estimation

%First method: applying image pyramid + POC
% 1st method: 2D POC enhanced by image pyramid
matchedpoints = C2F(imRe1,imRe2,refpoints);
% seedPoint_matched = C2F(imRe1,imRe2,seedPoint_ref);

% Get 3D locations
worldPoints = triangulate(refpoints,matchedpoints,stereoParams);
% seedPoint_world = triangulate(seedPoint_ref,seedPoint_matched,stereoParams);

% %Using the distance between each point and the seed point in z axis to
% %filter the world points
% threshold_z = 80;
% worldPoints_below_threshold = abs(worldPoints(:,3)-seedPoint_world) < threshold_z;
% [idx_below_threshold_row,~] = find(worldPoints_below_threshold);
% worldPoints = worldPoints(idx_below_threshold_row,:);

%Get the point cloud
ptCloud = pointCloud(worldPoints);

% Improve this point cloud
ptCloud = pcdenoise(ptCloud,'NumNeighbors',6,'Threshold',.85);%denoising

% pc = findPointsInROI(ptCloud,[900,1100;900,1100;900,1100]);
% ptCould = select(ptCloud,pc);

% show this point cloud
figure;pcshow(ptCloud,'markersize',30);

% end