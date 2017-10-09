function imblock = imblockextraction(im,cen,width)
% the function for extracting an image block with its center on cen
% Input:
% "im" is the target image
% "cen" is the matrix of centers of size Mx2. For each row of cen, (X,Y).
% "width" is the width of the image block. width should be odd

halfwidth = floor(width/2);

im = padarray(im,[width,width],0,'both');
cen = cen + width;
num_cen = size(cen,1);

xmin = floor(cen(:,1) - halfwidth);
ymin = floor(cen(:,2) - halfwidth);
height = repmat(width,num_cen,1);
width = repmat(width,num_cen,1);

imblock = arrayfun(@(xmin,ymin,w,h) imcrop(im,[xmin,ymin,w,h]),...
    xmin,ymin,width,height,'UniformOutput',0);

end