% Simplified version of 2D Phase-only correlation
% employs Hanning window and the simplest spectral weighting function

function delta = POC2D_simplified_vectorization(moving,fixed)

% Input:
% moving denotes the moving image (the left image)
% fixed denotes the fixed image (the right image)
% Output:
% delta = [delta_row,delta_col] denotes the translation in both directions

% Convert the format of input images into double
moving = im2double(moving);
fixed = im2double(fixed);


% Create a 2D Hanning window
[n,m,leng]=size(fixed);
% Using built-in function to create Hanning window 
wn = hann(n,'periodic');
wm = hann(m,'periodic');
han = wn*wm';
han = repmat(han,1,1,leng);

% % Program a Hanning window
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

N = n;%n = m since all the image blocks are square
U = ceil(N/2);% Define the width of a square low-pass filter
              % U should be in the range of [0, (N-1)/2]
Mask = ones(U,U);
Mask = imresize(padarray(Mask, [floor((n/2)-floor(U/2)) floor((m/2)-floor(U/2))], 0, 'both'), [n m]);
Mask = Mask ~= 0;
Mask = repmat(Mask,1,1,leng);
R(Mask==0)=0;


r = fftshift(abs(ifft2(R)));

% rmax = max(max(r));
% [y , x] = find(r == rmax);% ????? Should I use 'find' to find the subscripts ?? 
% x = x - m*((1:leng)-1)';

[~,tmp_row] = max(r);
[~,col] = max(max(r));
row = tmp_row(col);
row = row(:);
col = col(:);

delta_x = ceil(n/2) - col; 
delta_y = ceil(m/2) - row;


delta = [delta_x,delta_y];

end