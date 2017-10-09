%1D Phase-only correlation

%% Load the original images & do rectification
tic
clear all
 

% Load test images
% load('.\Images\testImages\imRe1test.mat');
% load('.\Images\testImages\imRe1testTranslated50.mat');
% imRe1 = imRe1test;
% imRe2 = imRe1testTranslated50;

% Load real images

load('.\Images\imDrill.mat');

% Seperate the stereo image into left and right images
[im1,im2] = SeparateImage(im);

% Load stereo parameters
load('stereoParams.mat');

[imRe1,imRe2] = rectifyStereoImages(im1,im2,stereoParams);

%% Get the area of interest on the left image (moving image) & find a good match on the right image (fixed image) 


% Get the area of interest from the left image and Get the corresponding
% area from the right image only with the same height and Ymin

disp('Cut the area of interest');
h = figure;
imshow(imRe1);
rect = getrect(h);% rect is a four-element vector with the form [xmin ymin width height].
close(h)

jMin = round(rect(1));
iMin = round(rect(2));

disparityMap = zeros(size(imRe1,1),size(imRe1,2));

imRe1= imcrop(imRe1, rect);
imRe2= imcrop(imRe2, rect);
figure;
imshow([imRe1,imRe2]);

%Deal with 1 channel only
imRe1 = rgb2gray(imRe1);
imRe2 = rgb2gray(imRe2);

% Define the length of the interval
interval = 40;

% Divide the pixels from cropped image into different groups according to
% the defined interval
numinv = floor(size(imRe1,2)/interval);

% Define the number of 1D images that we wanna extract for averaging
B = 13;%B should be odd
rr = zeros(B,interval);

peak = zeros(1,(size(imRe2,2)-interval+1));
inx = zeros(1,(size(imRe2,2)-interval+1));

han = hann(interval)';%create a row vector of Hanning window for reducing boundary effects

b = figure;

for i = 1:size(imRe1,1)                         % For each row
    for j = 1:numinv                            % For each interval in left image  
        for k = 1:(size(imRe2,2)-interval+1)    % Sliding Search
           
            % For averaging
            if i > floor(B) && i <= (size(imRe1,1) - floor(B))
                for l = 1:B
                    im1temp = imRe1(i-floor(B)+l-1,(1+interval*(j-1)):interval*j);
                    im1temp = double(im1temp).*han;
                    im1fft = fft(im1temp,[],2);
                    im2temp = imRe2(i-floor(B)+l-1,k:k+interval-1);   % Get fixed interval for right image
                    im2temp = double(im2temp).*han;
                    im2fft = fft(im2temp,[],2);
                    FconjG = im1fft.*conj(im2fft);       % Get the normalized cross-phase spectrum R
                    R = FconjG./abs(FconjG);
                    rr(l,:) = ifft(R,[],2);             % Get the 1D POC function r between im1 and im2(1D inverse DFT of R)
                    
                end
            else
                if i <= floor(B)
                    for l = 1:B
                        im1temp = imRe1(i+l-1,(1+interval*(j-1)):interval*j);
                        im1temp = double(im1temp).*han;
                        im1fft = fft(im1temp,[],2);
                        im2temp = imRe2(i+l-1,k:k+interval-1);   % Get fixed interval for right image
                        im2temp = double(im2temp).*han;
                        im2fft = fft(im2temp,[],2);
                        FconjG = im1fft.*conj(im2fft);       % Get the normalized cross-phase spectrum R
                        R = FconjG./abs(FconjG);
                        rr(l,:) = ifft(R,[],2);
                    

                    end
                else
                    for l = 1:B
                        im1temp = imRe1(i-B+l,(1+interval*(j-1)):interval*j);
                        im1temp = double(im1temp).*han;
                        im1fft = fft(im1temp,[],2);
                        im2temp = imRe2(i-B+l,k:k+interval-1);   % Get fixed interval for right image
                        im2temp = double(im2temp).*han;
                        im2fft = fft(im2temp,[],2);
                        FconjG = im1fft.*conj(im2fft);       % Get the normalized cross-phase spectrum R
                        R = FconjG./abs(FconjG);
                        rr(l,:) = ifft(R,[],2);

                    end
                end
            end
            
           r = mean(rr);
           [peak(k), inx(k)] =  max(r,[],2);

        end
                
        [maxPeak,idxPeak] = max(peak); % Get the best match from the test of im1temp the whole row i of imRe2 in im2temp intervals
        
%         if j == 1
%             plot(peak);
%             hold on;
%         end
%             
        if j == numinv
           disparityMap(iMin+i-1,(jMin+interval*(j-1)):size(imRe1,2)) = idxPeak + inx(idxPeak) - interval*(j-1);
        else
           disparityMap(iMin+i-1,(jMin+interval*(j-1)):(jMin+interval*j-1)) = idxPeak + inx(idxPeak) - interval*(j-1);
        end
    end
    
    
    
   
end

figure;imshow(uint8(disparityMap));

% figure
points3D = reconstructScene(disparityMap,stereoParams);
pc = pointCloud(points3D);
% 
pcIndx = findPointsInROI(pc,[-500,500;-1100,200;-3000,200]); % mm val
pcSelected = select(pc,pcIndx);

pcshow(pcSelected,'markersize',60);

pcwrite(pcSelected,'test.ply');

toc