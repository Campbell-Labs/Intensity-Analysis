function [ output_args ] = edge_boxer( impath)
%Should box the deposit in based off of it's edges
%DOES NOT WORK ATM
%   http://www.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html?prodcode=IP
impath = 'Y:\shared\Alzheimer_s Project\Dog\Control\Control(+)\Glenda\Glenda LE\Aligned\Location 1\reg_Glenda_LE_loc1_-4545.bmp';

im = imread(impath);
%the sensitivity which should be set outside this function is how much
%sensitive the edge detection is. Higher number = less sensative
sensitivity=2.5;

%%Uncomment if you would like to see the OG image
%figure, imshow(im), title('original image');


[~, threshold] = edge(im, 'Canny');
imedged = edge(im,'Canny', sensitivity * threshold);

%%Uncomment if you would like to see the edgedetected image
%figure, imshow(imedged), title('binary gradient mask');
















%Attempt to find the image and create a full outline of the image- left
%large holes, so this may be explored later
% se90 = strel('line', 3, 90);
% se0 = strel('line', 3, 0);
% 
% imoversat = imdilate(imedged, [se90 se0]);
% 
% imfilled = imfill(imdilate(imedged, [se90 se0]), 'holes');
% figure, imshow(imfilled);
% title('binary image with filled holes');

end

