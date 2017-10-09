%1D Phase-only correlation function with coarse-to-fine strategy(Not done!)

% function [x,y,peak] = POC(im1,im2)
%x,y denote the peak location

%% Load the original images & do rectification
clear
load('.\Images\im2.mat');
load('.\Images\im1.mat');
load('stereoParams.mat');

%% Get the area of interest on the left image (moving image) & find a good match on the right image (fixed image) 

% Get the area of interest from the left image and Get the corresponding
% area from the right image only with the same height and Ymin
h = figure;
imshow(im1);
rect = getrect(h);% rect is a four-element vector with the form [xmin ymin width height].
% rectim = [0,rect(1,2),size(imRe1,2),rect(1,4)];

im1Cropped= imcrop(im1, rect);
im2Cropped= imcrop(im2, rect);

imshowpair(im1Cropped,im2Cropped,'montage');
hold on

%% Image rectification
[imRe1,imRe2] = rectifyStereoImages(im1Cropped,im2Cropped,stereoParams);

%Deal with 1 channel only
imRe1 = rgb2gray(imRe1);
imRe2 = rgb2gray(imRe2);
%% Employ Hanning window to the image signals before FFT
% han = (hann(size(imRe1,2))');%create a row vector of Hanning window

% for i = 1:size(imRe1,1)%create a matrix of Hanning window
%     hanning(i,:)=han;
% end

% imRe1 = mat2gray(double(imRe1));%convert the type of image from uint8 to double
% imRe2 = mat2gray(double(imRe2));

% imRe1 = imRe1.*hanning;%employ Hanning window to image signals
% imRe2 = imRe2.*hanning;

% imRe1 = im2uint8(imRe1);%Convert to uint8 images
% imRe2 = im2uint8(imRe2);

%% Interation for building disparity map

% 1D Phase only correlation

% Define the disparity map
disparityMap = zeros(size(imRe1));
% Define the number of intervals
numinv = 8;

for i = 1:size(imRe1,1)
    for j = 1:numinv
    
        if j == numinv
           im1temp = imRe1(i,(1+interval*(j-1)):end);
           im2temp = imRe2(i,(1+interval*(j-1)):end);
        else
           im1temp = imRe1(i,(1+interval*(j-1)):interval*j);
           im2temp = imRe2(i,(1+interval*(j-1)):interval*j);
        end
                
% %Get the 1D discrete Fourier Transforms of this two images
        im1fft = fft(im1temp,[],2);%doing Fourier transform row-wise
        im2fft = fft(im2temp,[],2);
% 
%Get the normalized cross-phase spectrum R
        FconjG = im1fft.*conj(im2fft);
        R = FconjG./abs(FconjG);

%Get the 1D POC function r between im1 and im2(1D inverse DFT of R)
        r = ifft(R,[],2);%Get the inverse DFT of each row of R


% Get the peak value and the coordinates
        [peak,inx] = max(abs(r),[],2);%find the maximum of each row
                                      %The peak location n = the distance between
                                      %the two corresponding pixels

        if j == numinv
           disparityMap(i,(1+interval*(j-1)):end) = inx; 
        else
           disparityMap(i,(1+interval*(j-1)):40*j) = inx;
        end
    end
end

% plot(inx);
% [x,y] = ind2sub(size(r),inx);

% disparityMap = zeros(466,672);
% disparityMap(:,floor(673/2)) = inx;
% for i = 1:length(x)
% disparityMap(x(i),y(i)) = peak(i);
% end

% points3D = reconstructScene(disparityMap,stereoParams);

% imshow(disparityMap)
% end
