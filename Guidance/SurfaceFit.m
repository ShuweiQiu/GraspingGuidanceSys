clear
load('C:\Shuwei\Project_CameraOnHand\Guidance\photos\tomatoPC.mat')

ptCloudIn = ptCloud;
figure;
pcshow(ptCloudIn,'markersize',40);
title('Original Tomato Point Cloud');

ptCloudDN = pcdenoise(ptCloudIn);
figure;
pcshow(ptCloudDN,'markersize',40);
title('Denoise Tomato Point Cloud');

gridStep = 4; 
ptCloudDS = pcdownsample(ptCloudDN,'gridAverage',gridStep);
figure;
pcshow(ptCloudDS,'markersize',40);
title('Downsampled Tomato Point Cloud');

DT = delaunayTriangulation(ptCloudDS.Location(:,1),ptCloudDS.Location(:,2),ptCloudDS.Location(:,3));
K = convexHull(DT);

figure;
view(-31,14)
trisurf(K,DT.Points(:,1),DT.Points(:,2),DT.Points(:,3),...
       'FaceColor',[.5,.5,.5],'LineWidth',.7)
   set(gca,'LineWidth',2,'TickLength',[0.025 0.025]);
title('Convex Hull of Downsampled Tomato Point Cloud');

maxDistance = 1;
front=unique([K(:,1);K(:,2);K(:,3)]);
[modelSample,inlierIndices] = pcfitsphere(ptCloudDS,maxDistance,'SampleIndices',front);

figure;
pcshow(ptCloudDS,'markersize', 40);
hold on;
plot(modelSample);
title('Fit Sphere to Tomato Point Cloud');

globe = select(ptCloudDS,inlierIndices);
figure
hold on;
pcshow(globe, 'markersize', 60);
title('Sphere Surface Points ONLY of Tomato Point Cloud');

disp('The extracted Tomato Properties are the following: ')
modelSample


[ center, radii, evecs, v, chi2 ] = ellipsoid_fit([globe.Location(:,1),globe.Location(:,2),globe.Location(:,3)], '' );


% draw data
figure,
plot3( globe.Location(:,1),globe.Location(:,2),globe.Location(:,3), '.r' );
hold on;

%draw fit
mind = min( [globe.Location(:,1),globe.Location(:,2),globe.Location(:,3) ] ) - 20;
maxd = max( [globe.Location(:,1),globe.Location(:,2),globe.Location(:,3) ] ) + 20;

nsteps = 50;
step = ( maxd - mind ) / nsteps;

[ x, y, z ] = meshgrid( linspace( mind(1) - step(1), maxd(1) + step(1), nsteps ), linspace( mind(2) - step(2), maxd(2) + step(2), nsteps ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps ) );

Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
          2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
      
[~,v] = isosurface( x, y, z, Ellipsoid, -v(10) );
v = v(1:2:end,:);
ptCloud = pointCloud(v);
pointscolor=uint8(zeros(ptCloud.Count,3));
pointscolor(:,1)=0;
pointscolor(:,2)=0;
pointscolor(:,3)=0;
ptCloud.Color=pointscolor;

view(-31,14)
trisurf(K,DT.Points(:,1)-60,DT.Points(:,2)+20,DT.Points(:,3),...
       'FaceColor',[.5,.5,.5],'LineWidth',.7)
   set(gca,'LineWidth',2,'TickLength',[0.025 0.025]);
hold on
pcshow(ptCloud,'markersize',50);view(-31,14)
ax = gca;ax.FontSize = 18;ax.FontWeight = 'bold';
fsize =14;
xlabel('X (mm)','FontName','Lucida Sans Unicode','FontSize',fsize)
ylabel('Z (mm)','FontName','Lucida Sans Unicode','FontSize',fsize)
zlabel('Y (mm)','FontName','Lucida Sans Unicode','FontSize',fsize)
%xlim([-30 30])
%ylim([-30 30])
%zlim([200 270])
