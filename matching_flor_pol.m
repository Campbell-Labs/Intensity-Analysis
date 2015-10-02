% %Sensitivity and Specificity
% %This function when pointed at a the location file within Raw data should go into
% %Florecence and MM photos and give yes or a no to if there is a deposit and
% %if there are on both it should compare their approximate area
function[goodmatch,pol_boolean,flor_boolean,precent_match,florintensity ...
    ,polintensity,timestamp,full_florintes,crop_florintes,full_polintes,crop_polintes] = matching_flor_pol(location_path,results_path,polintensity)
addpath('basic_functions','specific_functions');

%This is a toggle which will show what is happening so that it is easier to
%explain (1=on,0=off)
  show  = 1;

  %This will check if the cropped vs the uncropped images are too close in intensity and set boolean to 0 if it is too close 
intenslim = .25;

global florintensity;

timestamp=makefile_path({'comparison'},results_path); 

comp_path=[results_path,'/','comparison','/'];

%This porition will go and find the image that we want to look at and
%give us the path to this location. This is based off of the naming
%conventions which I know are commonly used for the Raw Data dump
try
    [filepath_flor,flor_file] = find_file(location_path,'F','mono.bmp');
catch 
    %hopfully it's justr looking at the wrong file name
    [filepath_flor,flor_file] = find_file(location_path,'F','bandw.bmp');
end
try
    [filepath_pol,pol_file] = find_file(location_path,'MM','4545.bmp');
catch 
    %hopfully it's justr looking at the wrong file name... lets try 
    [filepath_pol,pol_file] = find_file(location_path,'MM','4545.bmp');
end    
    

%%Conversion to 8-bit images is currently non-functional and does not seem
%%to be worthwhile as we actually lose information
% convert_24to8_bmp(filepath_flor);
% convert_24to8_bmp(filepath_pol);

copyfile(filepath_flor,comp_path);
flor_comp_path = [comp_path,flor_file];
copyfile(filepath_pol,comp_path);
pol_comp_path = [comp_path,pol_file];

%FIRST WE WILL DO BASIC TOLERENCES
[flordim,florarea,florim,florcrop] = blob_boxer(filepath_flor,florintensity);
[poldim,polarea,polim,polcrop] = blob_boxer(filepath_pol,polintensity);
avg_area = ((florarea+polarea)/2);
up=0;
down=0;
stop_loop = 0;


full_florintes = mean(mean(mean(florim,2)));
crop_florintes = mean(mean(mean(florcrop,2)));

full_polintes = mean(mean(mean(polim,2)));
crop_polintes = mean(mean(mean(polcrop,2)));

%this first checks if the deposists which we are looking at are smaller
%than 3 microns squared
if sqrt(polarea) < 20 || sqrt(polarea) < 20
   if  sqrt(polarea) < 20
       pol_boolean = 0;
       if sqrt(florarea) < 20
           flor_boolean = 0;
       else %this condition is not great for determining false positives
           flor_boolean = 1;
       end
   else 
       flor_boolean = 0;
       pol_boolean = 1;
   end
%Taking the average intensity of the image vs the cropped image and if it
%is +- intenslim intensity we will set boolean = 0 & stop the loop(triple mean is
%there because it gives a single number)
elseif abs(full_polintes-crop_polintes) < intenslim
    pol_boolean = 0;
    %we can set the flor_bool to positive as it passed the intensity test
    %above
    if abs(full_florintes-crop_florintes) < intenslim
        flor_boolean = 0;
    else
        flor_boolean = 1;
    end  
else
    while stop_loop == 0 && (avg_area > florarea + .1*avg_area || avg_area < florarea - .1*avg_area) 
        if up == 1 && down==1
            stop_loop = 1; 
        elseif sqrt(florarea) > sqrt(polarea);
            florintensity = florintensity+1;
            [flordim,florarea] = blob_boxer(filepath_flor,florintensity);
            up=1;
        elseif sqrt(florarea) < sqrt(polarea);
            florintensity = florintensity-1;
            [flordim,florarea] = blob_boxer(filepath_flor,florintensity);
            down=1;
        end
        avg_area = ((florarea+polarea)/2);
    end
    clear avg_area;
    clear down;
    clear up;
    clear stop_loop;
    flor_boolean = 1;
    pol_boolean = 1;
end
clear florim;
clear florcrop;
clear polim;
clear polcrop;

if show == 1 && pol_boolean == 1 && flor_boolean == 1
    %flor_im = imread(flor_comp_path);
    tol_flor_im = insertShape(imread(flor_comp_path), 'rectangle',[flordim(1),flordim(2),flordim(4),flordim(5)]);
    imwrite(tol_flor_im,strrep(flor_comp_path,' mono',' flor rectangle'));
    clear tol_flor_im;
    %pol_im = imread(p_comp_path);
    tol_pol_im = insertShape(imread(pol_comp_path), 'rectangle',[poldim(1),poldim(2),poldim(4),poldim(5)]);
    imwrite(tol_pol_im,strrep(pol_comp_path,'_4545','_pol_rectangle'));
    clear tol_pol_im;
end

%Now I will find the areas which it overlaps
%looks weird, but its just converting to the dimensions the function likes
if pol_boolean == 0 || flor_boolean ==0
    precent_match = 0;
else
    flor_bw_comp  = poly2mask([flordim(1), flordim(1)+flordim(4),flordim(1)+flordim(4),flordim(1),flordim(1)],[flordim(2),flordim(2),flordim(2)+flordim(5),flordim(2)+flordim(5),flordim(2)],1024,1280);
    pol_bw_comp  = poly2mask([poldim(1), poldim(1)+poldim(4),poldim(1)+poldim(4),poldim(1),poldim(1)],[poldim(2),poldim(2),poldim(2)+poldim(5),poldim(2)+poldim(5),poldim(2)],1024,1280);
    bw_comp = flor_bw_comp+pol_bw_comp;

    if show ==1
        bw_comp_adjust = bw_comp/2;
        %imshow(bw_comp_adjust);
        imwrite(bw_comp_adjust,strrep(flor_comp_path,' mono',' bw_comp_adjust'));
    end
    comp0 = sum(bw_comp(:) == 0);
    comp1 = sum(bw_comp(:) == 1);
    comp2 = sum(bw_comp(:) == 2);
    
    precent_match = 1-(comp1/(comp2+comp1));
    if precent_match ==1
        precent_match=0;
    end
    if comp0/(comp1+comp2) < .2
        precent_match = 0;
        pol_boolean = 0;
        flor_boolean = 0;
    end
end

if precent_match > .6 && comp0/(comp1+comp2) > .25
    goodmatch = 1;
elseif precent_match > .4 && comp0/(comp1+comp2) > .33
    goodmatch = 1;
elseif precent_match > .3 && comp0/(comp1+comp2) > 1
    goodmatch = 1;
elseif precent_match > .2 && comp0/(comp1+comp2) > 2
    goodmatch = 1;
else
    goodmatch =0;
end

%The Results will be all numbers for ease of importing pulling through the
%program (since csvwrite is used to that) so detailed notes on what the
%numbers mean is nessecary
results = [goodmatch pol_boolean flor_boolean precent_match florintensity polintensity];


home = cd(comp_path);

csvwrite(['S_S_',(strrep(pol_file,'_4545.bmp','.csv'))],results);

cd(home);
