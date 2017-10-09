% Coarse-to-fine function using image pyramid
% Pixel-level correspondence estimation

function q0 = C2F(I0,J0,p0)
% Input:
% I0: the original left image (gray-level image)
% J0: the original right image (gray-level image)
% p0: the original reference points in I0: [X,Y]
% Output:
% q0: corresponding points in J0

% I0 = rgb2lab(I0);
% J0 = rgb2lab(J0);

%% Step 1: create an image pyramid
                                                                                                                                                                                                                                                                                                                           
% Define the number of layers, lmax.
% We need to carefully choose lmax such that the disparity at the coarsest
% layer is amply small compared to the size of input images for the
% calculate of the POC function.
lmax = 6;

I1 = impyramid(I0,'reduce');
I2 = impyramid(I1,'reduce');
I3 = impyramid(I2,'reduce');% the creation of the lmax-layer could be omitted.
I4 = impyramid(I3,'reduce');
I5 = impyramid(I4,'reduce');
I6 = impyramid(I5,'reduce');

J1 = impyramid(J0,'reduce');
J2 = impyramid(J1,'reduce');
J3 = impyramid(J2,'reduce');% the creation of the lmax-layer could be omitted.
J4 = impyramid(J3,'reduce');
J5 = impyramid(J4,'reduce');
J6 = impyramid(J5,'reduce');

%% Step 2: calculate the reference points for each layer
p1 = floor(p0/2);
p2 = floor(p1/2);
p3 = floor(p2/2);
p4 = floor(p3/2);
p5 = floor(p4/2);
p6 = floor(p5/2);

% What if some of the points become 0? What should I do??

%% Step 3: Initial guess of the corresponding points q
ql = floor(p6/2);% We assume that q_lmax = p_lmax in the coarsest layer.
l = lmax - 1;
% Define the width of the squared image blocks
% The width should be odd
width = 53;%83;

%% Iteration begins
while( l >= 0 )

%% Step 4: image block extraction
% For the l-th layer images Il and Jl, extract two image blocks fl and gl
% with their centers on pl and 2*q_l+1.
% For accurate matching, the size of image blocks should be reasonably
% large.

switch l
    case 6
        q6 = 2*ql;
        imblocksofI = imblockextraction(I6,p6,width);
        imblocksofJ = imblockextraction(J6,q6,width);

    case 5
        q5 = 2*ql;
        imblocksofI = imblockextraction(I5,p5,width);
        imblocksofJ = imblockextraction(J5,q5,width);

    case 4
        q4 = 2*ql;
        imblocksofI = imblockextraction(I4,p4,width);
        imblocksofJ = imblockextraction(J4,q4,width);
    case 3
        q3 = 2*ql;
        imblocksofI = imblockextraction(I3,p3,width);
        imblocksofJ = imblockextraction(J3,q3,width);
    case 2
        q2 = 2*ql;
        imblocksofI = imblockextraction(I2,p2,width);
        imblocksofJ = imblockextraction(J2,q2,width);
    case 1
        q1 = 2*ql;
        imblocksofI = imblockextraction(I1,p1,width);
        imblocksofJ = imblockextraction(J1,q1,width);
    case 0
        q0 = 2*ql;
        imblocksofI = imblockextraction(I0,p0,width);
        imblocksofJ = imblockextraction(J0,q0,width);   
end

%% Step 5: POC-based image matching

% POC-based matching
% The result of POC-based matching should be delta = [delta_row,delta_col].
delta = cellfun(@(im1,im2) POC2D_simplified(im1,im2),imblocksofI,imblocksofJ,'uniformoutput',0);
delta = cat(1,delta{:});


% Get the l-th layer correspondence ql
ql = 2*ql - delta;

%% Step 6

l = l - 1;


end

%% Step 7: Sub-pixel correspondence estimation
imblocksofI = imblockextraction(I0,p0,width);
imblocksofJ = imblockextraction(J0,ql,width);

delta = cellfun(@(im1,im2) POC2D_simplified(im1,im2),imblocksofI,imblocksofJ,'uniformoutput',0);
delta = cat(1,delta{:});

% % Step 8: Update
q0 = ql - delta;
% q0 = ql;
end

