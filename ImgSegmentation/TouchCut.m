




%% Load the test data
% load('C:\Shuwei\Project_CameraOnHand\Guidance\Segmentation\Code\imDrill.mat');
% load('C:\Shuwei\Project_CameraOnHand\Guidance\ObjectDetection\validationImages\WebcamImg\Keyboard');

% % Seperate the stereo image into left and right images
% im1 = im(:,1:end/2,:);
% im2 = im(:,end/2+1:end,:);


% % Load stereo parameters
% load('stereoParams.mat');
% [imRe1,~] = rectifyStereoImages(im1,im2,stereoParams);

imRe1 = imread('C:\Shuwei\Project_CameraOnHand\Guidance\Segmentation\Code\giraffe-08.jpg');

%% Edge Based Energy

%1. Extracting Dominant Color

% 1.0 Get the histogram in a CIE Lab color space
imRe1_Lab = rgb2lab(imRe1);
[hist_L,bins_L_limits,bins_L] = histcounts(imRe1_Lab(:,:,1),100);
% [hist_a,bins_a_limits,bins_a] = histcounts(imRe1_Lab(:,:,2),100);
% [hist_b,bins_b_limits,bins_b] = histcounts(imRe1_Lab(:,:,3),100);

% 1.1 Peak labeling
% The index of each peak is the label
[pks_L,pkLocs_L] = findpeaks(hist_L); num_pks_L = length(pks_L);
% [pks_a,pkLocs_a] = findpeaks(hist_a); num_pks_a = length(pks_a);
% [pks_b,pkLocs_b] = findpeaks(hist_b); num_pks_b = length(pks_b);

% 1.2 Label spreading

% For L channel
i = 1;%iteration counting
while ~all(ismember(unique(bins_L),pkLocs_L))
%Check if bins_L contains any number that is not in pkLocs_L. If there are some number
%that are not in pkLocs_L, continue this iterative process
    
% For each iteration
% 1st: get the arrays of spreading locations
spreadlocs_L_left = pkLocs_L - i;
spreadlocs_L_right = pkLocs_L + i;

% 2nd: check if spreading locations include peak locations
[~,idx_spreadpk_left,~] = intersect(spreadlocs_L_left,pkLocs_L);
if ~isempty(idx_spreadpk_left)
    for x = 1:length(idx_spreadpk_left)
       spreadlocs_L_left(idx_spreadpk_left(x)) = nan; 
    end
end
[~,idx_spreadpk_right,~] = intersect(spreadlocs_L_right,pkLocs_L);
if ~isempty(idx_spreadpk_left)
    for x = 1:length(idx_spreadpk_right)
       spreadlocs_L_right(idx_spreadpk_right(x)) = nan; 
    end
end


% 3rd: check if multiple labels arrive at the same position x
% if it's ture, then x is labeled as the same as the neighboring bin with
% the larger histogram value.
[cmPosi_L,idx_left_L,idx_right_L] = intersect(spreadlocs_L_left,spreadlocs_L_right);
if ~isempty(cmPosi_L)
   compare = pks_L(idx_left_L) > pks_L(idx_right_L);
   spreadingPeaks = [pkLocs_L(idx_left_L(compare)),pkLocs_L(idx_right_L(~compare))];
   for j = 1:length(cmPosi_L)
      bins_L(bins_L == cmPosi_L(j)) = spreadingPeaks(j);%replace the positon x with the peak position
      spreadlocs_L_left(spreadlocs_L_left == cmPosi_L(j)) = NaN;%delete the common position from the arrays of spreading locations
      spreadlocs_L_right(spreadlocs_L_right == cmPosi_L(j)) = NaN;
   end
end

% 4th: replace the spreading position x with corresponding peak positions
for m = 1:num_pks_L
   bins_L(bins_L == spreadlocs_L_left(m)) = pkLocs_L(m);
   bins_L(bins_L == spreadlocs_L_right(m)) = pkLocs_L(m);
end
i = i + 1;
end

% % For a channel
% i = 1;
% while ~all(ismember(unique(bins_a),pkLocs_a))
% % For each iteration
% % 1st: get the arrays of spreading locations
% spreadlocs_a_left = pkLocs_a - i;
% spreadlocs_a_right = pkLocs_a + i;
% 
% % 2nd: check if spreading locations include peak locations
% [~,idx_spreadpk_left,~] = intersect(spreadlocs_a_left,pkLocs_a);
% if ~isempty(idx_spreadpk_left)
%     for x = 1:length(idx_spreadpk_left)
%        spreadlocs_a_left(idx_spreadpk_left(x)) = nan; 
%     end
% end
% [~,idx_spreadpk_right,~] = intersect(spreadlocs_a_right,pkLocs_a);
% if ~isempty(idx_spreadpk_left)
%     for x = 1:length(idx_spreadpk_right)
%        spreadlocs_a_right(idx_spreadpk_right(x)) = nan; 
%     end
% end
% 
% 
% % 3rd: check if multiple labels arrive at the same position x
% % if it's ture, then x is labeled as the same as the neighboring bin with
% % the larger histogram value.
% [cmPosi_a,idx_left_a,idx_right_a] = intersect(spreadlocs_a_left,spreadlocs_a_right);
% if ~isempty(cmPosi_a)
%    compare = pks_a(idx_left_a) > pks_a(idx_right_a);
%    spreadingPeaks = [pkLocs_a(idx_left_a(compare)),pkLocs_a(idx_right_a(~compare))];
%    for j = 1:length(cmPosi_a)
%       bins_a(bins_a == cmPosi_a(j)) = spreadingPeaks(j);%replace the positon x with the peak position
%       spreadlocs_a_left(spreadlocs_a_left == cmPosi_a(j)) = NaN;%delete the common position from the arrays of spreading locations
%       spreadlocs_a_right(spreadlocs_a_right == cmPosi_a(j)) = NaN;
%    end
% end
% 
% % 4th: replace the spreading position x with corresponding peak positions
% for m = 1:num_pks_a
%    bins_a(bins_a == spreadlocs_a_left(m)) = pkLocs_a(m);
%    bins_a(bins_a == spreadlocs_a_right(m)) = pkLocs_a(m);
% end
% i = i + 1;
% end
% 
% % For b channel
% i = 1;
% while ~all(ismember(unique(bins_b),pkLocs_b))
% % For each iteration
% % 1st: get the arrays of spreading locations
% spreadlocs_b_left = pkLocs_b - i;
% spreadlocs_b_right = pkLocs_b + i;
% 
% % 2nd: check if spreading locations include peak locations
% [~,idx_spreadpk_left,~] = intersect(spreadlocs_b_left,pkLocs_b);
% if ~isempty(idx_spreadpk_left)
%     for x = 1:length(idx_spreadpk_left)
%        spreadlocs_b_left(idx_spreadpk_left(x)) = nan; 
%     end
% end
% [~,idx_spreadpk_right,~] = intersect(spreadlocs_b_right,pkLocs_b);
% if ~isempty(idx_spreadpk_left)
%     for x = 1:length(idx_spreadpk_right)
%        spreadlocs_b_right(idx_spreadpk_right(x)) = nan; 
%     end
% end
% 
% 
% % 3rd: check if multiple labels arrive at the same position x
% % if it's ture, then x is labeled as the same as the neighboring bin with
% % the larger histogram value.
% [cmPosi_b,idx_left_b,idx_right_b] = intersect(spreadlocs_b_left,spreadlocs_b_right);
% if ~isempty(cmPosi_b)
%    compare = pks_b(idx_left_b) > pks_b(idx_right_b);
%    spreadingPeaks = [pkLocs_b(idx_left_b(compare)),pkLocs_b(idx_right_b(~compare))];
%    for j = 1:length(cmPosi_b)
%       bins_b(bins_b == cmPosi_b(j)) = spreadingPeaks(j);%replace the positon x with the peak position
%       spreadlocs_b_left(spreadlocs_b_left == cmPosi_b(j)) = NaN;%delete the common position from the arrays of spreading locations
%       spreadlocs_b_right(spreadlocs_b_right == cmPosi_b(j)) = NaN;
%    end
% end
% 
% % 4th: replace the spreading position x with corresponding peak positions
% for m = 1:num_pks_b
%    bins_b(bins_b == spreadlocs_b_left(m)) = pkLocs_b(m);
%    bins_b(bins_b == spreadlocs_b_right(m)) = pkLocs_b(m);
% end
% i = i + 1;
% end

% 1.3 Connection value searching

% 1.4 Cluster merging
% Considering the peaks as islets in a lake, some of small islets will be
% connected to form larger islets as the water level in the lake decreases.

% <1> All the histogram values are sorted in descending order

% <2> Scan the sorted values one by one to simulate the water level
% decreasing. Only consider merging the connected clusters during the
% scanning.

%% Statistical prior energy


%% Geometry energy


%% Distance regularization

