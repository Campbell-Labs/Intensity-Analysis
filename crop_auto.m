%This script should when given the path which includes a file named Entire Image should go into it and find the file which ends at 4545 and then run blob_boxer then create the Positive and Negative files and crop all the files to those coords

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%~~~~~AS OF DEC 02 2015 THIS IS NOT FUNCTIONING PROPERLY~~~~~%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function crop_auto(Entire_path)
addpath('basic_functions','specific_functions');

foldernames = cellstr(['Positive';'Negative']);
makefile_path(foldernames,Entire_path);
clear foldernames;
%Now we will go into the Entire Image file and run blob_boxer on it, and
%then we will crop all of the images to these coords

[filepath_4545,file4545] = find_file(Entire_path,'Entire Image','4545.bmp');
[filepath_3045,file3045] = find_file(Entire_path,'Entire Image','3045.bmp');

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
     I3045 = imread(filepath_3045);
     I4545 = imread(filepath_4545);
     Isize=size(I);
     pos_I = imcrop(I, pos_cropcoords);
     firstrun=0;
     if firstrun == 0
         firstrun=1;
%     %need to figure out how to find negative coords
    neg_cropcoords = zeros(1,4);
    %First I will check if pos/neg overlap is needed by finding the biggest
    %rectangles we can and comparing if the OG pic will fit in it
    %[onebool,twobool,threebool,fourbool,...
        [index,index2,sum4545,sizeemp4545,sum3045,sizeemp3045] = deal(0);
%     if (pos_cropcoords(1)-pos_cropcoords(3))>0 %assuming size gives [x,y]
%         onebool=1; %checking if neg can be left of deposit
%     end
%     if (pos_cropcoords(1)+(2*(pos_cropcoords(3))))<Isize(1) %assuming size gives [x,y]
%         twobool=1;%checking if neg can be right of deposit
%     end
%     if (pos_cropcoords(2)-pos_cropcoords(4))>0 %assuming size gives [x,y]
%         threebool=1; %checking if neg can be above deposit
%     end
%     if (pos_cropcoords(2)+(2*(pos_cropcoords(4))))<Isize(2) %assuming size gives [x,y]
%         fourbool=1;%checking if neg can be below deposit
%     end
%     
        %find biggest side to start corner overlap
        left = pos_cropcoords(1);
        right = (Isize(1)-(pos_cropcoords(1)+pos_cropcoords(3)));
        top = pos_cropcoords(2);
        bot = (Isize(2)-(pos_cropcoords(2)+pos_cropcoords(4)));
    %taking the edges and checking their mean intensity 
        mean4545 = cell(4,4);
        mean4545{1,1} = imcrop(I4545,[0,0,left,Isize(2)]);
        mean4545{2,1} = imcrop(I4545,[(pos_cropcoords(1)+pos_cropcoords(3)),0,right,Isize(2)]);
        mean4545{3,1} = imcrop(I4545,[0,0,Isize(1),top]);
        mean4545{4,1} = imcrop(I4545,[0,(pos_cropcoords(2)+pos_cropcoords(4)),Isize(1),bot]);
            while index<4
                index = index+1;
                mean4545{index,2} = mean(mean(im2double(mean4545{index,1})));
                mean4545{index,3} = size((mean4545{index,1}),1)*size((mean4545{index,1}),2);
                mean4545{index,4} = mean4545{index,2}*mean4545{index,3};
                sum4545 = mean4545{index,4}+sum4545;
                sizeemp4545 = mean4545{index,3}+sizeemp4545;
            end
        avgintens4545 = sum4545/sizeemp4545;

        mean3045 = cell(4,4);
        mean3045{1,1} = imcrop(I3045,[0,0,left,Isize(2)]);
        mean3045{2,1} = imcrop(I3045,[(pos_cropcoords(1)+pos_cropcoords(3)),0,right,Isize(2)]);
        mean3045{3,1} = imcrop(I3045,[0,0,Isize(1),top]);
        mean3045{4,1} = imcrop(I3045,[0,(pos_cropcoords(2)+pos_cropcoords(4)),Isize(1),bot]);
            while index2<4
                index2 = index2+1;
                mean3045{index2,2} = mean(mean(im2double(mean3045{index2,1})));
                mean3045{index2,3} = size((mean3045{index2,1}),1)*size((mean3045{index2,1}),2);
                mean3045{index2,4} = mean3045{index2,2}*mean3045{index2,3};
                sum3045 = mean3045{index2,4}+sum3045;
                sizeemp3045 = mean3045{index2,3}+sizeemp3045;
            end
        avgintens3045 = sum3045/sizeemp3045;
        
    %if none of them fit we will need to make an overlapping negative area
    %%actually we can just do this method for all deposists
%     if onebool+twobool+threebool+fourbool == 0
        %we will check all the corners and compare intensity, & amount of
        %overlap with pos
 
        %we will start at the biggest corner section
        crop = zeros(4);
        crop(1,:) = [0,0,pos_cropcoords(3),pos_cropcoords(4)];
        crop(2,:) = [(Isize(1)-pos_cropcoords(3)),0,pos_cropcoords(3),pos_cropcoords(4)];
        crop(3,:) = [(Isize(1)-pos_cropcoords(3)),(Isize(2)-pos_cropcoords(4)),pos_cropcoords(3),pos_cropcoords(4)];
        crop(4,:) = [0,(Isize(2)-pos_cropcoords(4)),pos_cropcoords(3),pos_cropcoords(4)];
        
        index3=0;
        locs = cell(4,11);
        while index3<4
            index3=index3+1;
            loc{index3,1} = imcrop(I4545,crop(index3,:));
            loc{index3,2} = mean(mean(im2double(loc{index3,1})));
            loc{index3,3} = abs(loc{index3,2}-avgintens4545);
            
            loc{index3,5} = imcrop(I3045,crop(index3,:));
            loc{index3,6} = mean(mean(im2double(loc{index3,5})));
            loc{index3,7} = abs(loc{index3,6}-avgintens3045);
            
            loc{1,9} = left*top;
            loc{2,9} = right*top;
            loc{3,9} = left*bot;
            loc{4,9} = right*bot;
            
        end
        [~,four] = sort(cell2mat(loc(:,3)));
        [~,eight] = sort(cell2mat(loc(:,7)));
        [~,ten] = sort(cell2mat(loc(:,9)));
        index4=0;
        while index4 < 4
            index4=index4+1;
            loc{index4,4} = four(index4);
            loc{index4,8} = eight(index4);
            loc{index4,10} = ten(index4);
            loc{index4,11} = loc{index4,4}+loc{index4,8}-2*loc{index4,10};
        end
        index5=0;
        while index5 < 4
            	index5=index5+1;
                [~,a] = sort(cell2mat(loc(index5,11)));
                 coodmatrix = [0,0,pos_cropcoords(3),pos_cropcoords(4);...
                     (Isize(1)-pos_cropcoords(3)),0,pos_cropcoords(3),pos_cropcoords(4);...
                     (Isize(1)-pos_cropcoords(3)),(Isize(2)-pos_cropcoords(4)),pos_cropcoords(3),pos_cropcoords(4);...
                     0,(Isize(2)-pos_cropcoords(4)),pos_cropcoords(3),pos_cropcoords(4)];
            if a==1
                neg_cropcoods = coodmatrix(index5,:);
            end
        end
 %   end
     end
    neg_I = imcrop(I, neg_cropcoods);
     imwrite(pos_I, strcat(Entire_path,'/Positive/',strrep(file4545,'4545',['_pos_',position_indexed])));
     imwrite(neg_I, strcat(Entire_path,'/Negative/',strrep(file4545,'4545',['_neg_',position_indexed])));
end