function [ found,avg_centroid,avg_minoraxis,avg_majoraxis ] = blob_diff_circler( impath )
%blob differentator whould take in the image differentate it and encircle those
%blobs
%   Detailed explanation goes here

show = 0;

im_prefilter = imread(impath);

im=wiener2((rgb2gray(im_prefilter)),[18,18]);

im_size=size(im);
%im_area = im_size(1)*im_size(2);

found = 0;

a=diff(im,1,2);
b=diff(im,1,1);
a(1,:,:)=[];
b(:,1,:)=[];
im_diff = imcrop(((a+b)),[10,10,(im_size(2)-20),(im_size(1)-20)]);
%imshow(im_diff);

%%show the bwimage
%imshow(imbw)
% I=wiener2((rgb2gray(im)),[12,12]);
I=double(im_diff);
%Inorm = (double(I) ./(double(max(max(I)))))*255;
%imshow (I);
improp=regionprops(I,'Area','BoundingBox','Centroid','MinorAxisLength',...
    'MajorAxisLength','image','Convexarea','Conveximage','Solidity');

imlen=length(improp);
i=0;

while i<imlen;
    i = i+1;
    %this should be the size of a 3 micron diameter circle 
    if improp(i).ConvexArea > ((im_size(2)-110)*(im_size(1)-110)) ...
            || improp(i).ConvexArea<300 ||improp(i).MinorAxisLength<20 ...
            || improp(i).Area<10 || improp(i).Solidity<.001 ;
        improp(i)=[];
        imlen=length(improp);
        i=i-1;
    else
        if i==1;
            centroid = improp(i).Centroid;
            minoraxis = improp(i).MinorAxisLength;
            majoraxis = improp(i).MajorAxisLength;
        end
        centroid = ([centroid;[improp(i).Centroid]]);
        minoraxis = ([minoraxis;[improp(i).MinorAxisLength]]);
        majoraxis = ([majoraxis;[improp(i).MajorAxisLength]]);
        if show == 1;
            pairOfImages = [improp(i).Image; improp(i).ConvexImage]; 
            imshow(pairOfImages)
        end
    end
end
if i==imlen && i ~= 0 ;
    found = 1;
    avg_centroid = mean(centroid);
    %max_minoraxis = max(minoraxis);
    avg_minoraxis = mean(minoraxis);
    %max_majoraxis = max(majoraxis);
    avg_majoraxis = mean(majoraxis);
    if show == 1;
        disp(avg_centroid);
        disp(avg_minoraxis);
        disp(majoraxis);
        im_w_lil_circle = insertShape(im, 'circle',[avg_centroid,(avg_minoraxis/2)],'Color','yellow');
        %im_w_big_circle = insertShape(im, 'circle',[avg_centroid,(avg_majoraxis/2)],'Color','green');
        im_w_both_circles = insertShape(im_w_lil_circle, 'circle',[avg_centroid,(avg_majoraxis/2)],'Color','green');
        imshow(im_w_both_circles);
    end
else
    avg_centroid = [0,0];
    avg_minoraxis = 0;
    avg_majoraxis = 0;
end
