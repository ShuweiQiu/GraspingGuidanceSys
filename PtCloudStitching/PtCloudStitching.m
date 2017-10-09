%Point Cloud stitching

gridSize = 0.1;
fixed = pcdownsample(pc1,'gridAverage',gridSize);
moving = pcdownsample(pc2,'gridAverage',gridSize);

tform = pcregrigid(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
ptCloudAligned = pctransform(pc2,tform);

mergeSize = 0.015;
ptCloudScene = pcmerge(pc1, ptCloudAligned, mergeSize);

pcshow(ptCloudScene, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
title('Initial world scene')
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
drawnow