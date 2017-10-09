% This is the complete version of 2D Phase-only correlation
% This function employs windowing technique, function fitting and spectral
% weighting

function delta = POC2D(moving,fixed,winleft,winright)
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

fixed = fixed.*winleft;
moving = moving.*winright;

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

% Function fitting
% NOT DONE!

rmax = max(max(r));
[x , y] = find(r == rmax);
delta_row = ceil(n/2)-y; 
delta_col = ceil(m/2)-x;

delta = [delta_row,delta_col];


end