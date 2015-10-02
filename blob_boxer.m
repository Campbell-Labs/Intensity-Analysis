function [ biggiedim,biggiearea,im,I2 ] = blob_boxer( impath, minintens)

%Max intensity is commented out because it is currently non-functiontional 
%, maxintens )

%This function will take a image and the minintensity and max intensity and
%if the image falls within those bounds it will give the coords of the box
%which bounds it.
%impath = 'Y:\shared\Alzheimer_s Project\Dog\Control\Control(+)\Glenda\Glenda LE\Processed\Location 7\Entire Image\reg_Glenda_LE_loc7_4545.bmp';

im = imread(impath);

%making sure that only images above a certain intensity should be grabbed
%VERY LAZY -REDO-
%maybe try imadjust?
%disp(minintens);
imbw = im > minintens;

%%max intensity is not working atm FIX NEEDED
%imbw = imbw < maxintens;

%%show the bwimage
%imshow(imbw)

improp=regionprops(imbw,'basic');
imlen=length(improp);
i=0;
biggiearea=0;
biggiedim=[0,0,0,0];
while i<imlen;
    i = i+1;
    if improp(i).Area <biggiearea;
    else
            biggiearea=improp(i).Area;
            biggiedim=improp(i).BoundingBox;
    end


end
%disp(biggiedim);
%%Cropping if the image is 24 bit(and of the normal dimensions
if i==0
    I2 = zeros(1024,1280);
    biggiedim = [0,0,0,0,0,0];
else
    try if size(size(im))==[1,3]
            I2=imcrop(im,[biggiedim(1),biggiedim(2),biggiedim(4),biggiedim(5)]);
        end
    catch
        if size(size(im))==[1,2]
            I2=imcrop(im,biggiedim);
        end
    end
end
%imshow(I2);
