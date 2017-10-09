% Using image registration to get initial guess and using POC to correct
% the guess

function q0 = regPOC(imRe1,imRe2,refPoints)

%Detect SURF features
points1 = detectSURFFeatures(imRe1,'MetricThreshold',600,'NumOCtaves',6,'NumScaleLevels',6);
points2 = detectSURFFeatures(imRe2,'MetricThreshold',600,'NumOctaves',6,'NumScaleLevels',6);

% Extract features
[features1, validpoints1] = extractFeatures(imRe1, points1);
[features2, validpoints2] = extractFeatures(imRe2, points2);


% Matching features
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validpoints1(indexPairs(:, 1));
matchedPoints2 = validpoints2(indexPairs(:, 2));
 
% % Show matched features
% figure; ax = axes;
% showMatchedFeatures(imRe1,imRe2,matchedPoints1,matchedPoints2,'Parent',ax);

%Image registration
%Using the matched point pairs to get geometric transformation
tform = fitgeotrans(matchedPoints1.Location,matchedPoints2.Location,'Similarity');

%Get the initial guess
q0_guess = double(transformPointsForward(tform,refPoints));

%2D POC
width = 353;
imblocks_imRe1 = imblockextraction(imRe1,refPoints,width);
imblocks_imRe2 = imblockextraction(imRe2,q0_guess,width);

% Non-vecterization
numofblocks = size(refPoints,1);
delta = zeros(size(refPoints));

for i = 1:numofblocks
    delta(i,:) = POC2D_simplified(imblocks_imRe1{i},imblocks_imRe2{i});
end

q0 = q0_guess - delta;


end