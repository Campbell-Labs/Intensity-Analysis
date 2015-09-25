function [ output_args ] = blob_boxer( input_args )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
impath = 'Y:\shared\Alzheimer_s Project\Dog\Control\Control(+)\Glenda\Glenda LE\Processed\Location 7\Entire Image\reg_Glenda_LE_loc7_4545.bmp';

im = imread(impath);

%making sure that only images above a certain intensity should be grabbed
%VERY LAZY -REDO-
%maybe try imadjust?
imbw = im > 12;

%%show the bwimage
%imshow(imbw)

improp=regionprops(imbw,'basic');
imlen=length(improp);
i=0;
biggie=0;
biggiedim=[0,0,0,0];
while i<imlen;
    i = i+1;
    if improp(i).Area <biggie;
    else
            biggie=improp(i).Area;
            biggiedim=improp(i).BoundingBox;
    end


end
%disp(biggiedim);
I2=imcrop(im,biggiedim);
imshow(I2);
