% This is the function for salience detection and contour extraction

function object_interest = findObject_IterativeFloodfill(imRe1,seedPoint)
% Input:
% im: the image of interest
% Output:
% contour: the contour of the object

% % Load test data
% clear;clc;tic
% load('stereoParams.mat');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\Segmentation\Code\imDrill.mat');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\ObjectDetection\validationImages\WebcamImg\Keyboard');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\ObjectDetection\validationImages\WebcamImg\Mouse');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\ObjectDetection\validationImages\WebcamImg\Mouse1');


% % Seperate the stereo image into left and right images
% im1 = im(:,1:end/2,:);
% im2 = im(:,end/2+1:end,:);
% 
% [imRe1,~] = rectifyStereoImages(im1,im2,stereoParams);
% 
% %Select the seed point
% h = figure;
% imshow(imRe1);
% [x,y] = getpts(h);
% close(h)
% seedPoint(1) = double(x); seedPoint(2) = double(y);

% seedPoint = [382,299];


%convert RGB to CIEL*a*b
Labimg = rgb2lab(imRe1,'WhitePoint','d65');

[row,col,~] = size(Labimg);


[Labels,num_superpixels] = superpixels(imRe1,350,'Compactness',5);

% %Show original super-pixels
% BW = boundarymask(Labels);
% figure;imshow(imoverlay(imRe1,BW));


%Compute super-pixels based global contrast
superpixels_all = label2idx(Labels);

%Compute the attribute of each super-pixel
%the attribute of each super-pixel is described by the mean [l a b x y]'
%vector of all pixels belonging to this super-pixel

attributes = cell(1,num_superpixels);
tic
for i = 1:num_superpixels
    L_idx = superpixels_all{i};
    a_idx = superpixels_all{i} + row*col;
    b_idx = superpixels_all{i} + 2*row*col;
    [y,x] = ind2sub([row,col],superpixels_all{i});
    attributes{i} = [ mean(Labimg(L_idx)), mean(Labimg(a_idx)),...
                        mean(Labimg(b_idx)), mean(x), mean(y)];
end
toc
%Compute the global contrast for each super-pixel
salience = zeros(1,num_superpixels);
for i = 1:num_superpixels
    tmp_contrast = zeros(1, num_superpixels - 1);
    m = 1;
   for j = 1:num_superpixels
      if i == j
          continue
      else
          tmp_contrast(m) = SC(attributes{i},attributes{j});
          m = m + 1;
      end
   end
   salience(i) = sum(tmp_contrast);
end



%Filter the super-pixels based on the distance between each of the super-pixels of interest to the
%seed point
threshold_distance_superpixel = 280;

%Firstly,calculate the distance between each of the super-pixels of interest to the
%seed point
distance_to_seedPoint = zeros(1,num_superpixels);
for i = 1:num_superpixels
       distance_to_seedPoint(i) = sqrt(...
       (attributes{i}(4)-seedPoint(1))^2 ...
       + (attributes{i}(5)-seedPoint(2))^2 ); 
end
superpixels_interest = superpixels_all(distance_to_seedPoint<threshold_distance_superpixel);
salience_interest = salience(distance_to_seedPoint<threshold_distance_superpixel);

% Determining the focal super-pixels via an adaptive value T_alpha
% For each super-pixel, if its salience value > T_alpha, then we add it into
% focal super_pixels set.
K = length(superpixels_interest);
alpha = 0.7;%alpha influences the num of key super-pixels. 
tmpT = zeros(1,K);

%Using the salience of the super-pixel closest to the seed point as the
%seed point salience
[~,ind_seedPoint_superpixel] = min(distance_to_seedPoint);
seedPoint_salience = salience(ind_seedPoint_superpixel);

%Calculate the alpha value
for i = 1:K
    tmpT(i) = salience_interest(i) + (1-alpha)*seedPoint_salience;
end
T_alpha = alpha*sum(tmpT)/K;

%Determine the focal super-pixels
focal_superpixels_interest = superpixels_interest(salience_interest>T_alpha);

% Show the focal super-pixels map
focal_superpixels_Map = zeros(size(imRe1),'like',imRe1);
for i = 1:length(focal_superpixels_interest)
    redIdx = focal_superpixels_interest{i};
    greenIdx = focal_superpixels_interest{i} + row*col;
    blueIdx = focal_superpixels_interest{i} + 2*row*col;
    focal_superpixels_Map(redIdx) = imRe1(redIdx);
    focal_superpixels_Map(greenIdx) = imRe1(greenIdx);
    focal_superpixels_Map(blueIdx) = imRe1(blueIdx);
end
% figure;
% imshow(focal_superpixels_Map)

%Determine the centriod of the focal pixels
%using the seedPoint as the centroid of the focal pixels
x_centroid = seedPoint(1); y_centroid = seedPoint(2);

%Calculate the distance between the pixels in focal super-pixels set and
%the centroid
focal_pixels = cat(1,focal_superpixels_interest{:});
[y_focal_pixels, x_focal_pixels] = ind2sub([row,col],focal_pixels);
distance_to_centroid_focal_pixels = sqrt(...
    (x_focal_pixels - x_centroid).^2 + (y_focal_pixels - y_centroid).^2 );

%Get preliminary backgound pixels/background points
threshold_distance_pixel = mean(distance_to_centroid_focal_pixels);
BGpixels_idx = focal_pixels(...
    distance_to_centroid_focal_pixels > threshold_distance_pixel );
[y_BGpixels, x_BGpixels] = ind2sub([row,col],BGpixels_idx);
points_BG_all = cat(2,x_BGpixels,y_BGpixels);

%Iterative flood fill
object_interest = focal_superpixels_Map;
while 1
    
    %firstly, select the first point in "points_BG_all"
    point_for_floodfill = points_BG_all(1,:);

    %secondly, do flood fill
    [tmp_mask,~] = floodfill(object_interest, point_for_floodfill);

    %Update the image by setting the output region of flood fill to 255 
    idx_points_removal = find(tmp_mask);
    object_interest(idx_points_removal) = 255;%setting the red channel
    object_interest(idx_points_removal + row*col) = 255;%setting the green channel
    object_interest(idx_points_removal + 2*row*col) = 255;%setting the blue channel

    %then, remove the points result from the flood fill algorithm in
    %"points_BG_all"
    idx_points_removal = find(ismember(BGpixels_idx,idx_points_removal));
    BGpixels_idx(idx_points_removal) = [];
    points_BG_all(idx_points_removal,:) = [];




    %if "points_BG_all" is not empty, go back to the first step, else end the
    %iteration
    if isempty(points_BG_all)
    %final flood fill to change the background color from white to black
        [tmp_mask,~] = floodfill(object_interest,point_for_floodfill);
        object_mask = ~tmp_mask;
        object_mask = uint8(repmat(object_mask,[1,1,3]));
        object_interest = object_interest .* object_mask;
        break
    end

end

% figure;
% imshow(object_interest)
% toc

% % Draw a circle around the seed point in the original image
% radius = mean(distance_to_centroid_focal_pixels);
% figure;imshow(imRe1)
% hold on
% viscircles(seedPoint,radius);

end

function contrast = SC(v1,v2)
%The function is for the computation of contrast between two super-pixels
l1=v1(1); a1=v1(2); b1=v1(3); x1=v1(4); y1=v1(5);
l2=v2(1); a2=v2(2); b2=v2(3); x2=v2(4); y2=v2(5);
contrast = sqrt((l1-l2)^2 + (a1-a2)^2 + (b1-b2)^2)/sqrt((x1-x2)^2 + (y1-y2)^2);
end

function [BW,maskedImage] = floodfill(RGB,point_BG)
%  [BW,MASKEDIMAGE] = floodfill(RGB) segments image RGB using
%  auto-generated code from the imageSegmenter App. The final segmentation
%  is returned in BW, and a masked image is returned in MASKEDIMAGE.
%  point_BG is a point from the background(BG) = [x,y]


% Convert RGB image into L*a*b* color space.
X = rgb2lab(RGB);

% Create empty mask.
BW = false(size(X,1),size(X,2));

% Flood fill
row = point_BG(2);
column = point_BG(1);
tolerance = 5.000000e-02;
normX = sum((X - X(row,column,:)).^2,3);
normX = mat2gray(normX);
addedRegion = grayconnected(normX, row, column, tolerance);
BW = BW | addedRegion;

% Create masked image.
maskedImage = RGB;
maskedImage(repmat(~BW,[1 1 3])) = 0;
end