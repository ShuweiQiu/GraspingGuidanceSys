% clear all
 
% function ptCloud = GetPc(im)

% Load real images

load('C:\Shuwei\Project_CameraOnHand\Guidance\Segmentation\Code\imDrill.mat');

% Seperate the stereo image into left and right images
[im1,im2] = SeparateImage(im);

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
% points1 = detectBRISKFeatures(imRe1cropped);
% points2 = detectBRISKFeatures(imRe2cropped);

% SURF features
points1 = detectSURFFeatures(imRe1,'MetricThreshold',600,'NumOCtaves',6,'NumScaleLevels',6);
points2 = detectSURFFeatures(imRe2,'MetricThreshold',600,'NumOctaves',6,'NumScaleLevels',6);

% % MSER features
% points1 = detectMSERFeatures(imRe1cropped);
% points2 = detectMSERFeatures(imRe2cropped);

% % FAST features
% points1 = detectFASTFeatures(imRe1cropped);
% points2 = detectFASTFeatures(imRe2cropped);

% % Harris features
% points1 = detectHarrisFeatures(imRe1cropped);
% points2 = detectHarrisFeatures(imRe2cropped);

% % Min Eigen features
% points1 = detectMinEigenFeatures(imRe1cropped);
% points2 = detectMinEigenFeatures(imRe2cropped);


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

%Image registration
%Using the matched point pairs
tform = fitgeotrans(matchedPoints1.Location,matchedPoints2.Location,'Similarity');
% imRe1reg = imwarp(imRe1,tform,'OutputView',imref2d(size(imRe2)));
% 
% %Get points from the left image
% leftpoints = zeros(round(rect(4)*rect(3)),2);
% inx = 1;
% for i = rect(1):(rect(1) + rect(3) - 1)
%     for j = rect(2):(rect(2) + rect(4) - 1)
%         leftpoints(inx,:) = [i,j];
%         inx = inx + 1;
%     end
% end
% 
% %Using tform to estimate the corresponding points in the right image
% rightpoints = transformPointsForward(tform,leftpoints);
% 

% % Get 3D locations
% worldPoints = triangulate(matchedPoints1,matchedPoints2,stereoParams);
% % worldPoints = triangulate(leftpoints,double(rightpoints),stereoParams);
% ptCloud = pointCloud(worldPoints);
% 
% % Improve this point cloud
% ptCloud = pcdenoise(ptCloud,'NumNeighbors',5,'Threshold',.85);%denoising
% 
% %show this point cloud
% figure;pcshow(ptCloud,'markersize',500);

% end