% This is the complete version of 2D Phase-only correlation with sub-pixel
% resolution
% This function employs Hanning window, spectral weighting and surface
% interpolation

function delta = POC2D_interpolation(moving,fixed)
% Input:
% moving denotes the moving image (the left image)
% fixed denotes the fixed image (the right image)
% winleft: the window function for the left image which is going to be applied before IDFT
% winright: the window function for the right image
% Output:
% delta = [delta_row,delta_col] denotes the translation in both directions


[n,m]=size(fixed);
N = min(n,m);

%% Apply Hanning window to these two images
% Using built-in function to create Hanning window 
% wn = hann(n,'periodic');
% wm = hann(m,'periodic');
% han = wn*wm';

% Program a Hanning window
% M1 = floor(n/2);
% n1 = -M1:M1;
% M2 = floor(m/2);
% n2 = -M2:M2;
% [n1,n2] = meshgrid(n1,n2);
% han = 0.5*(1+cos(pi*n1/M1)).*(0.5*(1+cos(pi*n2/M2)));

fixed = double(fixed);
moving = double(moving);

% %Put the two images into GPU
% fixed = gpuArray(fixed);
% moving = gpuArray(moving);

F=fftshift(fft2(im2double(fixed)));
M=fftshift(fft2(im2double(moving)));
R=(F.*conj(M))./abs((F.*conj(M)));

%% Apply spectral weighting function

% Using the simplest weighting function
U = ceil(N/2);% Define the width of a square low-pass filter
       % U should be in the range of [0, (N-1)/2]
Mask = ones(U,U);
Mask = imresize(padarray(Mask, [floor((n/2)-floor(U/2)) floor((m/2)-floor(U/2))], 0, 'both'), [n m]);
Mask = Mask ~= 0;
R(Mask==0)=0;


%% Find the peak location
r = fftshift(abs(ifft2(R)));

% %Retrieve r from the GPU to the workspace
% r = gather(r);

% surface interpolation
rmax = max(max(r));
[x_peak , y_peak] = find(r == rmax);%Get the initial peak location
x = 1:m; y = 1:n;
[x,y] = meshgrid(x,y);

refineRange = 1;
resolution = 0.01;
x_query = (x_peak - refineRange):resolution:(x_peak + refineRange);
y_query = (y_peak - refineRange):resolution:(y_peak + refineRange);
r_query = griddata(x,y,r,x_query,y_query,'natural');
r_query_max = max(max(r_query));
[x_peak_query,y_peak_query] = find(r_query == r_query_max);
x_peak = x_peak - refineRange + resolution*x_peak_query;
y_peak = y_peak - refineRange + resolution*y_peak_query;





delta_row = ceil(n/2)-y_peak; 
delta_col = ceil(m/2)-x_peak;

delta = [delta_row,delta_col];


end