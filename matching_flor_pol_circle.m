function [pol_boolean,flor_boolean,overall_overlap_precent,good_precent, ...
    great_precent,AWESOME_precent,area_covered ] = matching_flor_pol_circle( location_path,results_path )
%This function should check if the two images defined in the path fall
%within eachothers circles as defined by the average minor and major axis,
%as defined by the blob_diff_circler function
%   Detailed explanation goes here
debugging = 0;
addpath('basic_functions','specific_functions');

%This is a toggle which will show what is happening so that it is easier to
%explain (1=on,0=off)
  show  = 0;
global maxfound name;
in_bulk = 1;

if in_bulk == 0 || maxfound == 1
    timestamp=makefile_path({['circle comparison ',name]},results_path); 
    comp_path=[results_path,'/','circle comparison ',name,'/'];
end
%This porition will go and find the image that we want to look at and
%give us the path to this location. This is based off of the naming
%conventions which I know are commonly used for the Raw Data dump
try
    [filepath_flor,flor_file] = find_file(location_path,'F','mono.bmp');
catch 
    %hopfully it's justr looking at the wrong file name
    if debugging ==1
        disp(location_path);
    end
    [filepath_flor,flor_file] = find_file(location_path,'F\bmp','mono.bmp');
end
try
    [filepath_pol,pol_file] = find_file(location_path,'MM','4545.bmp');
catch 
    %hopfully it's justr looking at the wrong file name... lets try 
    if debugging ==1
        disp(location_path);
    end
    [filepath_pol,pol_file] = find_file(location_path,'MM\bmp','4545.bmp');
end    

if in_bulk == 0 || maxfound == 1
    copyfile(filepath_flor,comp_path);
    flor_comp_path = [comp_path,flor_file];
    copyfile(filepath_pol,comp_path);
    pol_comp_path = [comp_path,pol_file];
else
    flor_comp_path = filepath_flor;
    pol_comp_path =  filepath_pol;
end
%pulling globals because I dont want to pass 12 variables through 4
%functions and because of memory
if in_bulk ==1
    global flor_var_struct pol_var_struct...
            edge_crop min_convexarea min_minoraxislength min_area min_solidity ...
            diffmax_length filtersize mem location_counter;
    [edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,diffmax_length,filtersize] = ...
        deal(flor_var_struct.flor_edge_crop(1),flor_var_struct.flor_min_convexarea(1),flor_var_struct.flor_min_minoraxislength(1),flor_var_struct.flor_min_area(1),flor_var_struct.flor_min_solidity(1),flor_var_struct.flor_diffmax_length(1),flor_var_struct.flor_filtersize(1));
    if mem.flor_edge_crop(location_counter) == flor_var_struct.flor_edge_crop(1) && mem.flor_min_convexarea(location_counter) == flor_var_struct.flor_min_convexarea(1) ... 
            && mem.flor_min_minoraxislength(location_counter) == flor_var_struct.flor_min_minoraxislength(1) && mem.flor_min_area(location_counter) == flor_var_struct.flor_min_area(1) ...
            && mem.flor_min_solidity(location_counter) == flor_var_struct.flor_min_solidity(1) && mem.flor_diffmax_length(location_counter) == flor_var_struct.flor_diffmax_length(1) && mem.flor_filtersize(location_counter) == flor_var_struct.flor_filtersize(1);
        [flor_boolean,flor_centroid,flor_minoraxis,flor_majoraxis] = deal(mem.flor_boolean(location_counter),mem.flor_centroid(location_counter),mem.flor_minoraxis(location_counter),mem.flor_majoraxis(location_counter));
    else
        [flor_boolean,flor_centroid,flor_minoraxis,flor_majoraxis] = blob_diff_circler(filepath_flor);
        [mem.flor_boolean(location_counter),mem.flor_centroid(location_counter,:),mem.flor_minoraxis(location_counter),mem.flor_majoraxis(location_counter)] = deal (flor_boolean,flor_centroid,flor_minoraxis,flor_majoraxis);
    end
    [edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,diffmax_length,filtersize] = ...
            deal(pol_var_struct.pol_edge_crop(1),pol_var_struct.pol_min_convexarea(1),pol_var_struct.pol_min_minoraxislength(1),pol_var_struct.pol_min_area(1),pol_var_struct.pol_min_solidity(1),pol_var_struct.pol_diffmax_length(1),pol_var_struct.pol_filtersize(1));
    if mem.pol_edge_crop(location_counter) == pol_var_struct.pol_edge_crop(1) && mem.pol_min_convexarea(location_counter) == pol_var_struct.pol_min_convexarea(1) ... 
            && mem.pol_min_minoraxislength(location_counter) == pol_var_struct.pol_min_minoraxislength(1) && mem.pol_min_area(location_counter) == pol_var_struct.pol_min_area(1) ...
            && mem.pol_min_solidity(location_counter) == pol_var_struct.pol_min_solidity(1) && mem.pol_diffmax_length(location_counter) == pol_var_struct.pol_diffmax_length(1) && mem.pol_filtersize(location_counter) == pol_var_struct.pol_filtersize(1);
        [pol_boolean,pol_centroid,pol_minoraxis,pol_majoraxis] = deal(mem.pol_boolean(location_counter),mem.pol_centroid(location_counter),mem.pol_minoraxis(location_counter),mem.pol_majoraxis);

    else
        [pol_boolean,pol_centroid,pol_minoraxis,pol_majoraxis] = blob_diff_circler(filepath_pol);
        [mem.pol_boolean(location_counter),mem.pol_centroid(location_counter,:),mem.pol_minoraxis(location_counter),mem.pol_majoraxis(location_counter)] = deal (flor_boolean,flor_centroid,flor_minoraxis,flor_majoraxis);
    end
        %%MEMORY
        [mem.flor_edge_crop(location_counter),mem.flor_min_convexarea(location_counter),mem.flor_min_minoraxislength(location_counter),mem.flor_min_area(location_counter),... 
        mem.flor_min_solidity(location_counter),mem.flor_diffmax_length(location_counter),mem.flor_filtersize,mem.pol_edge_crop(location_counter),mem.pol_min_convexarea(location_counter), ...
        mem.pol_min_minoraxislength(location_counter),mem.pol_min_area(location_counter),mem.pol_min_solidity(location_counter),mem.pol_diffmax_length(location_counter),mem.pol__filtersize(location_counter)] = ...
        deal(flor_var_struct.flor_edge_crop(1),flor_var_struct.flor_min_convexarea(1),flor_var_struct.flor_min_minoraxislength(1),flor_var_struct.flor_min_area(1),... 
        flor_var_struct.flor_min_solidity(1),flor_var_struct.flor_diffmax_length(1),flor_var_struct.flor_filtersize(1),pol_var_struct.pol_edge_crop(1),pol_var_struct.pol_min_convexarea(1),...
        pol_var_struct.pol_min_minoraxislength(1),pol_var_struct.pol_min_area(1),pol_var_struct.pol_min_solidity(1),pol_var_struct.pol_diffmax_length(1),pol_var_struct.pol_filtersize(1));
end
if flor_boolean == 1  && pol_boolean == 1;
    %in the blob_diff_circler we subtract 11 pixels from each side so we
    %have to add them back to the coords now
    flor_centroid = flor_centroid; %+ [flor_var_struct.flor_diffmax_length(1)+flor_var_struct.flor_edge_crop(1),flor_var_struct.flor_diffmax_length(1)+flor_var_struct.flor_edge_crop(1)];
    pol_centroid = pol_centroid;% + [pol_var_struct.pol_diffmax_length(1)+pol_var_struct.pol_edge_crop(1),pol_var_struct.pol_diffmax_length(1)+pol_var_struct.pol_edge_crop(1)];
    overlap_image = zeros(1024,1280);
    overlap_image_1 = im2bw(rgb2gray(insertShape(overlap_image,'FilledCircle',[flor_centroid,(flor_minoraxis/2)],'Color',[1,1,1],'Opacity', 1)),.5);
    overlap_image_2 = im2bw(rgb2gray(insertShape(overlap_image,'FilledCircle',[flor_centroid,(flor_majoraxis/2)],'Color',[1,1,1],'Opacity', 1)),.5);
    overlap_image_3 = im2bw(rgb2gray(insertShape(overlap_image,'FilledCircle',[pol_centroid,(pol_minoraxis/2)],'Color',[1,1,1],'Opacity', 1)),.5);
    overlap_image_4 = im2bw(rgb2gray(insertShape(overlap_image,'FilledCircle',[pol_centroid,(pol_majoraxis/2)],'Color',[1,1,1],'Opacity', 1)),.5);
    %this section is how I am seperating the matchtypes where we have two
    %columns. The #X column is for pol and X# column is for flor. 2 means
    %it is within the minor circle and 1 means it is within the major
    %circle. We can find overlap from this
    bw_overlap_image = (overlap_image_1 + overlap_image_2 + overlap_image_3*10 + overlap_image_4*10);
    if show ==1 || maxfound == 1;
        show_bw_overlap_image = (overlap_image_1 + overlap_image_2 + overlap_image_3 + overlap_image_4);
    end
    comp00 = sum(bw_overlap_image(:) == 00);
    comp01 = sum(bw_overlap_image(:) == 01);
    comp02 = sum(bw_overlap_image(:) == 02);
    comp10 = sum(bw_overlap_image(:) == 10);
    comp11 = sum(bw_overlap_image(:) == 11);
    comp12 = sum(bw_overlap_image(:) == 12);
    comp20 = sum(bw_overlap_image(:) == 20);
    comp21 = sum(bw_overlap_image(:) == 21);
    comp22 = sum(bw_overlap_image(:) == 22);
    zero_sum = comp00;
    zeros_sum = comp01+comp02+comp10+comp20;
    %this is done for uniformity of naming... looks stupid though
    ones_sum = comp11;
    mixs_sum = comp12 + comp21;
    twos_sum = comp22;
    AWESOME_precent = 100*(twos_sum/(twos_sum + mixs_sum +ones_sum+zeros_sum));
    great_precent = 100*(mixs_sum/(twos_sum + mixs_sum +ones_sum+zeros_sum));
    good_precent = 100*(ones_sum/(twos_sum + mixs_sum +ones_sum+zeros_sum));
    overall_overlap_precent = good_precent + great_precent + AWESOME_precent;
    area_covered = 100*((twos_sum + mixs_sum +ones_sum+zeros_sum)/zero_sum);
else
    overall_overlap_precent = 0;
    good_precent = 0;
    great_precent = 0;
    AWESOME_precent = 0;
    area_covered = 0;
end
if show == 1 && pol_boolean == 1 && flor_boolean == 1
    imshow (show_bw_overlap_image*.25);
    imwrite(bw_overlap_image,strrep(flor_comp_path,' mono',' bw_overlap_image'));
elseif maxfound == 1 && pol_boolean == 1 && flor_boolean == 1
    imwrite(imfuse(imread(flor_comp_path),imread(pol_comp_path)),strrep(flor_comp_path,'mono','_fuse_overlap_image'));
    imwrite((show_bw_overlap_image*.25),strrep(flor_comp_path,'mono','_bw_overlap_image'));
    imwrite((imfuse(imread(flor_comp_path),imread(pol_comp_path))+(repmat((uint8(show_bw_overlap_image*25)),[1,1,3]))),strrep(flor_comp_path,'mono','_overlap_image'))
elseif maxfound == 1;
    imwrite(imfuse(imread(flor_comp_path),imread(pol_comp_path)),strrep(flor_comp_path,'mono','_fuse_overlap_image'));
end

%The Results will be all numbers for ease of importing pulling through the
%program (since csvwrite is used to that) so detailed notes on what the
%numbers mean is nessecary
results = [pol_boolean flor_boolean overall_overlap_precent good_precent ...
    great_precent AWESOME_precent area_covered];




if in_bulk == 0 
    home = cd(comp_path);
    csvwrite(['S_S_',(strrep(pol_file,'_4545.bmp','.csv'))],results);
    cd(home);
end
end

