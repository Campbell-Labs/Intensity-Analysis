%This script should when given the path which includes a file named Entire Image should go into it and find the file which ends at 4545 and then run blob_boxer then create the Positive and Negative files and crop all the files to those coords
function crop_auto(Entire_path)
addpath('basic_functions','specific_functions');

foldernames = cellstr(['Positive';'Negative']);
makefile_path(foldernames,Entire_path);
clear foldernames;
%Now we will go into the Entire Image file and run blob_boxer on it, and
%then we will crop all of the images to these coords

[filepath_4545,file4545] = find_file(Entire_path,'Entire Image','4545.bmp');

%Now that we have the location of the 4545 image we can run blob_boxer to
%get the coords that we will crop to 

positions = cellstr(char('4545','4545','4500','4530','4560','0045','0000','0030','0060','3045','3000','3030','3060','6045','6000','6030','6060'));
pos_cropcoords = blob_boxer( filepath_4545, 12 );

len = length(positions);

%This section crops the pictutres to the coords that are given by
%blob_boxer
i = 0;
while i<len
    i=i+1;
    position_indexed=char(positions(i));
     I = imread(strrep(filepath_4545,'4545',position_indexed));
     pos_I = imcrop(I, pos_cropcoords);
%     %need to figure out how to find negative coords
%     %neg_I = imcrop(I, neg_cropcoords);
     imwrite(pos_I, strcat(Entire_path,'/Positive/',strrep(file4545,'4545',['_pos_',position_indexed])));
%     imwrite(neg_I, strcat(Entire_path,'/Negative/',strrep(file4545,'4545',['_neg_',positionindexed])));
end

%clearing the variables to free up RAM- I dont know if this helps
clear I;
clear pos_I;
clear i;
clear len;
clear pos_cropcoords;
clear file4545;
clear filepath_4545;
clear Entire_path_inside;
clear position_indexed;
