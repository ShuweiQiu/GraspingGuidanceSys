% Simplified version of 2D Phase-only correlation
% employs Hanning window and the simplest spectral weighting function

function delta = POC2D_simplified(moving,fixed)

% Input:
% moving denotes the moving image (the left image)
% fixed denotes the fixed image (the right image)
% Output:
% delta = [delta_row,delta_col] denotes the translation in both directions

% Convert the format of input images into double
moving = double(moving);
fixed = double(fixed);

% Create a 2D Hanning window
[n,m]=size(fixed);
N = min(n,m);

% Using built-in function to create Hanning window 
wn = hann(n,'periodic');
wm = hann(m,'periodic');
han = wn*wm';

% Program a Hanning window
% M1 = floor(n/2);
% n1 = -M1:M1;
% M2 = floor(m/2);
% n2 = -M2:M2;
% [n1,n2] = meshgrid(n1,n2);
% han = 0.5*(1+cos(pi*n1/M1)).*(0.5*(1+cos(pi*n2/M2)));

% Apply Hanning window to these two images
fixed = fixed.*han;
moving = moving.*han;

F=fftshift(fft2(fixed));
M=fftshift(fft2(moving));
R=(F.*conj(M))./abs((F.*conj(M)));

%% Apply spectral weighting function

% Using the simplest weighting function

U = ceil(2*N/3);% Define the width of a square low-pass filter
              % U should be in the range of [0, (N-1)/2]
Mask = ones(U,U);
Mask = imresize(padarray(Mask, [floor((n/2)-floor(U/2)) floor((m/2)-floor(U/2))], 0, 'both'), [n m]);
Mask = Mask ~= 0;
R(Mask==0)=0;


r = fftshift(abs(ifft2(R)));
rmax = max(max(r));
[row, col] = find(r == rmax);

delta_x = ceil(n/2)- col; 
delta_y = ceil(m/2)- row;

delta = [delta_x,delta_y];

end