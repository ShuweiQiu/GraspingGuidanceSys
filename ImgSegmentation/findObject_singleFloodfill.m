% This is the function for salience detection and contour extraction

function object_interest = findObject_singleFloodfill(imRe1,seedPoint)
% Input:
% im: the image of interest
% Output:
% contour: the contour of the object

% % Load test data
% clear;clc;tic
% load('stereoParams.mat');
% load('.\imDrill.mat');
% 
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

threshold_distance = 150;

%convert RGB to CIEL*a*b
Labimg = rgb2lab(imRe1,'WhitePoint','d65');

[row,col,~] = size(Labimg);

% K = 300;%desired number of super-pixels
% N = row*col;%number of pixels
% s = sqrt(2*sqrt(3)*N/(9*K));%the length of side of a hexagonal super-pixel
% 
% %% Sample K initial seed points with hexagonal arrengement
% x_offset = s*sqrt(3);
% y_offset = s+s/2;
% num_along_rows = round(row/y_offset);
% num_along_cols = round(col/x_offset);
% %determine the center locations
% x_centers = repmat((0:(num_along_cols-1)),num_along_rows,1);
% x_centers = x_centers*x_offset + 1;
% 
% y_centers = repmat((0:(num_along_rows-1))',1,num_along_cols);
% y_centers = y_centers*y_offset + 1;
% 
% %now shift odd rows over
% odd_offset = s*sqrt(3)/2;
% x_centers(2:2:end,:) = x_centers(2:2:end,:) + odd_offset;
% 
% x_centers = round(x_centers);
% y_centers = round(y_centers);
% 
% seedPoints = cat(2,x_centers(:),y_centers(:));
% 

[Labels,num_superpixels] = superpixels(imRe1,350,'Compactness',5);

% %Show original super-pixels
% BW = boundarymask(Labels);
% figure;imshow(imoverlay(imRe1,BW));

%Compute super-pixels based global contrast

superpixel_all = label2idx(Labels);

%Compute the attribute of each super-pixel
%the attribute of each super-pixel is described by the mean [l a b x y]'
%vector of all pixels belonging to this super-pixel
attributes = cell(1,num_superpixels);
for i = 1:num_superpixels
    L_idx = superpixel_all{i};
    a_idx = superpixel_all{i} + row*col;
    b_idx = superpixel_all{i} + 2*row*col;
    [y,x] = ind2sub([row,col],superpixel_all{i});
    attributes{i} = [ mean(Labimg(L_idx)), mean(Labimg(a_idx)),...
                        mean(Labimg(b_idx)), mean(x), mean(y)];
end

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

% %Determining the focal super-pixels via an adaptive value T_alpha
% %For each super-pixel, if its salience value > T_alpha, then we add it into
% %focal super_pixels set.
% K = num_superpixels;
% alpha = 0.7;%alpha influences the num of key super-pixels. 
% tmpT = zeros(1,num_superpixels);
% max_salience = max(salience);
% for i = 1:num_superpixels
%     tmpT(i) = salience(i) + (1-alpha)*max_salience;
% end
% T_alpha = alpha*sum(tmpT)/K;
% 
% focal_idx = superpixel_idx(salience>T_alpha);

% %Show the salience map
% salienceMap = zeros(size(imRe1),'like',imRe1);
% for i = 1:length(focal_idx)
%     redIdx = focal_idx{i};
%     greenIdx = focal_idx{i} + row*col;
%     blueIdx = focal_idx{i} + 2*row*col;
%     salienceMap(redIdx) = imRe1(redIdx);
%     salienceMap(greenIdx) = imRe1(greenIdx);
%     salienceMap(blueIdx) = imRe1(blueIdx);
% end
% figure;
% imshow(salienceMap)

%Show the super-pixel of interest
object_interest = zeros(size(imRe1),'like',imRe1);

%show the super-pixel having the greatest salience value
% [~,idx_max_sal] = max(salience);
% object_interest(superpixel_idx{idx_max_sal}) = imRe1(superpixel_idx{idx_max_sal});%red channel
% object_interest(superpixel_idx{idx_max_sal}+row*col) = imRe1(superpixel_idx{idx_max_sal}+row*col);%green channel
% object_interest(superpixel_idx{idx_max_sal}+2*row*col) = imRe1(superpixel_idx{idx_max_sal}+2*row*col);%blue channel

%Filter the super-pixels based on the distance between each of the super-pixels of interest to the
%seed point

%Using the distance to narrow the num of super-pixels and
%then find the ones having greatest n salience values

%Firstly,calculate the distance between each of the super-pixels of interest to the
%seed point
distance_to_seedPoint = zeros(1,num_superpixels);
for i = 1:num_superpixels
       distance_to_seedPoint(i) = sqrt(...
       (attributes{i}(4)-seedPoint(1))^2 ...
       + (attributes{i}(5)-seedPoint(2))^2 ); 
end
superpixels_interest = superpixel_all(distance_to_seedPoint<threshold_distance);
salience_interest = salience(distance_to_seedPoint<threshold_distance);

%Then, find the super-pixels that have the greatest "n" salience values
[~,index_interest] = sort(salience_interest,'descend');
num_greatest_superpixels = 50;
superpixels_interest = superpixels_interest(index_interest(1:num_greatest_superpixels));


%show the super-pixels having the greatest n salience values
for i = 1:length(superpixels_interest)
    object_interest(superpixels_interest{i}) = imRe1(superpixels_interest{i});%red channel
    object_interest(superpixels_interest{i}+row*col) = imRe1(superpixels_interest{i}+row*col);%green channel
    object_interest(superpixels_interest{i}+2*row*col) = imRe1(superpixels_interest{i}+2*row*col);%blue channel
end

% figure;imshow(object_interest)


%Get a point from the background: point_BG
%Use the location of the super-pixel which is the farest one from the seed
%point as point_BG

%Get the distance between all the super-pixel of interest and the seed point
attributes_interest = attributes(distance_to_seedPoint<threshold_distance);
attributes_interest = attributes_interest(index_interest(1:num_greatest_superpixels));
distance_interest = distance_to_seedPoint(distance_to_seedPoint<threshold_distance);
distance_interest = distance_interest(index_interest(1:num_greatest_superpixels));
[~,idx_point_BG] = max(distance_interest);

point_BG = round(attributes_interest{idx_point_BG}(4:5));

%Use flood-fill function to get the mask of the background
[mask_background,~] = floodfill(object_interest,point_BG);
mask_object = ~mask_background;
mask_object = uint8(repmat(mask_object,[1,1,3]));

%Get rid of the background
object_interest = object_interest.*mask_object;

figure;
imshow(object_interest)
% toc

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