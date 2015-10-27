function [ found,avg_centroid,avg_minoraxis,avg_majoraxis ] = blob_diff_circler( impath )
%blob differentator whould take in the image differentate it and encircle those
%blobs
%   Detailed explanation goes here

%These are the parameters which the function regards or disregards the
%points and the commented number is the values which work for Glenda pol

defaultvar = 0; %would you like to use the defaults?

if defaultvar == 1
    edge_crop = 10; % 10 amount of pixels to crop from edge
    min_convexarea = 300; %300 minimum area the polygon can cover 
    min_minoraxislength = 20;%20 minimum length of the short size
    min_area = 10; %10 minimum number of pixels which must show up in the polygon
    min_solidity = .001; %.001 minimmum amount of pixels per the area of the plygon (pixel density)
    diffmax_length = 100; % 100 how large the largest blob can be (photo size minus this #)\
    filtersize = 18; %How finely the photo should be filtered
    precent = 5; %precent at which the value will be altered
    filter = 1;%should the images be filtered?
    intalt = 1;%should intensity be altered?
else
    global edge_crop min_convexarea min_minoraxislength min_area min_solidity ...
        diffmax_length filtersize precent filter intalt;
end

show = 0;


im = imread(impath);
filtersize = fix(filtersize);
if filter == 1;
    try
        im=wiener2((rgb2gray(im)),[filtersize,filtersize]);
    catch
        im=wiener2((im),[filtersize,filtersize]);
    end
end
if intalt == 1;
    try
        im=(rgb2gray(im));
    catch%this means it is grayscale already so we do nothing
    end
    immean = mean2(im);
    for i = 1:numel(im)
        if im(i) > (immean*(1+(precent/100)))
            im(i) = 1.25*im(i);
            if im(i)>255
                im(i) = 255;
            end
        elseif im(i)<(immean*(1-(precent/100)))
            im(i) = im(i)/1.25;
        end
    end
end
im_size=size(im);
%im_area = im_size(1)*im_size(2);

found = 0;

a=diff(im,1,2);
b=diff(im,1,1);
a(1,:,:)=[];
b(:,1,:)=[];
im_diff = imcrop(((a+b)),[edge_crop,edge_crop,(im_size(2)-(2*edge_crop)),(im_size(1)-(2*edge_crop))]);
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
    if improp(i).ConvexArea >= ((im_size(2)-diffmax_length-edge_crop)*(im_size(1)-diffmax_length-edge_crop)) ...
            || improp(i).ConvexArea<=min_convexarea ||improp(i).MinorAxisLength<=min_minoraxislength ...
            || improp(i).Area<=min_area || improp(i).Solidity<=min_solidity ;
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
