% clear all
 
% function ptCloud = GetPc(im)

% Load real images

% load('.\imDrill.mat');

% Seperate the stereo image into left and right images
im1 = im(:,1:end/2,:);
im2 = im(:,end/2+1:end,:);

% Load stereo parameters
load('stereoParams.mat');

[imRe1,imRe2] = rectifyStereoImages(im1,im2,stereoParams);

% Get the region of interest from the left image and Get the corresponding
% area from the right image only with the same height and Ymin

% disp('Select the region of interest');
% h = figure;
% imshow(imRe1);
% rect = getrect(h);% rect is a four-element vector with the form [xmin ymin width height].
% close(h)

%Deal with 1 channel only
imRe1 = rgb2gray(imRe1);
imRe2 = rgb2gray(imRe2);

%% Matching Process (feature matching)

% Detect features

% % BRISK features
% points1 = detectBRISKFeatures(imRe1);
% points2 = detectBRISKFeatures(imRe2);

% % SURF features
% points1 = detectSURFFeatures(imRe1,'MetricThreshold',1000,'NumOCtaves',6,'NumScaleLevels',6);
% points2 = detectSURFFeatures(imRe2,'MetricThreshold',1000,'NumOctaves',6,'NumScaleLevels',6);

% % MSER features
% points1 = detectMSERFeatures(imRe1);
% points2 = detectMSERFeatures(imRe2);

% % FAST features
% points1 = detectFASTFeatures(imRe1);
% points2 = detectFASTFeatures(imRe2);

% % Harris features
% points1 = detectHarrisFeatures(imRe1);
% points2 = detectHarrisFeatures(imRe2);

% % Min Eigen features
% points1 = detectMinEigenFeatures(imRe1);
% points2 = detectMinEigenFeatures(imRe2);


% Extract features
[features1, validpoints1] = extractFeatures(imRe1, points1);
[features2, validpoints2] = extractFeatures(imRe2, points2);


% Matching features
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validpoints1(indexPairs(:, 1));
matchedPoints2 = validpoints2(indexPairs(:, 2));
 
% Show matched features
figure; ax = axes;
showMatchedFeatures(imRe1,imRe2,matchedPoints1,matchedPoints2,'Parent',ax);

% % Get 3D locations
% worldPoints = triangulate(matchedPoints1,matchedPoints2,stereoParams);
% ptCloud = pointCloud(worldPoints);
% 
% % Improve this point cloud
% ptCloud = pcdenoise(ptCloud,'NumNeighbors',5,'Threshold',.85);%denoising
% 
% %show this point cloud
% figure;pcshow(ptCloud,'markersize',500);
% 
% end