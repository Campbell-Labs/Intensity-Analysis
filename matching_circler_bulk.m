%%This script when given a file containing Raw Data should go inside of
%%that file and find all of the Locations/Spots and run the function in
%%intensity values ranging from 1 to 20 and print all of the results to a
%%excel file
    %Note that this is fairly simple file management, no real analysis
    %happens here either and hence this is a very quick function (except it
    %runs the deeper matching_flor_pol_circle which is slow)
    %THIS WORKS ON AS MANY LOCATIONS AS YOU WANT
function [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
    matching_circler_bulk(datafile,resultsfile)
    %this function will run the circular matching on a whole Raw Data file
    
% datafile = 'C:\Glenda\Glenda LE';
% resultsfile = 'C:\Glenda\Glenda LE';
global maxfound location_counter mem name printfile sub_nums; %bringing in globals

addpath('basic_functions','specific_functions');

%Will supress outputs and attempt to make the function less memory
%intensive
is_fun = 1;

if is_fun == 0
    datafile = input('Where is the Raw Data folder stored?');
    resultsfile = datafile;
    maxfound = 1;
    printfile = 1;
end

if is_fun == 0 || (maxfound == 1 && printfile == 1);
    makefile_path({'Intensity based circle matching analysis'},resultsfile);
end
if isempty(sub_nums)
     samp_struc = dir([datafile,'\','*S *']);
     samples = samp_struc.name;
else
    samples = {};
    failed = [];
    for num = sub_nums
        samp_struc = dir([datafile,'\','*S ',num2str(num,'%0.2d'),'*']);
        if isempty(samp_struc);
            failed = [failed num];
        else
            samples = [samples, {samp_struc.name}];
        end
    end
end
folderlist = {};
namelist = {};
for sub_cell = samples;
    subject = char(sub_cell);
    sub_file = [datafile,'\',subject];
    exp_struc = dir([sub_file,'\','E *']);
    for exper_cell = extractfield(exp_struc,'name');
        exper = char(exper_cell);
        exp_file = [sub_file,'\',exper];
        quarter_struc = dir([exp_file,'\','Q *']);
        for quart_cell = extractfield(quarter_struc,'name');
            quart = char(quart_cell);
            quart_file = [exp_file,'\',quart];
            loc_struc = dir([quart_file,'\','L *']);
            for loc_cell = extractfield(loc_struc,'name');
                loc = char(loc_cell);
                loc_file = [quart_file,'\',loc];
                capture = dir([loc_file,'\','CS 001*']);
                capture_file = [loc_file,'\',capture.name];
                folderlist = [folderlist, {capture_file}];
                namelist = [namelist, {[subject,' ',exper,' ', quart, ' ',loc]}];
            end
        end
    end
end
home=cd(datafile);

%folderlist = [folderlist_location,folderlist_spot];
size_struct = size(folderlist);
n=size_struct(1);

%%MEMORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
empty = zeros(n,1);
empty2 = zeros(n,2);
mem = struct('flor_edge_crop',empty,'flor_min_convexarea',empty,'flor_min_minoraxislength',empty,'flor_min_area',empty,... 
            'flor_min_solidity',empty,'flor_diffmax_length',empty,'flor_filtersize',empty,'flor_precent',empty,'pol_edge_crop',empty,'pol_min_convexarea',empty, ...
            'pol_min_minoraxislength',empty,'pol_min_area',empty,'pol_min_solidity',empty,'pol_diffmax_length',empty,'pol_filtersize',empty,'pol_precent',empty,...
            'flor_boolean',empty,'flor_centroid',empty2,'flor_minoraxis',empty,'flor_majoraxis',empty,...
           'pol_boolean',empty,'pol_centroid',empty2,'pol_minoraxis',empty,'pol_majoraxis',empty);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(home);
location_counter=0;
full_results = {'filename','pol_boolean','flor_boolean','overall_overlap_precent','good_precent', ...
    'great_precent','AWESOME_precent','area_covered'};
truepos_results = full_results;
trueneg_results = full_results;
falseneg_results = full_results;
falsepos_results = full_results;
truepos_count = 0;
trueneg_count = 0;
falseneg_count = 0;
falsepos_count = 0;
%this loops through every single location and gives us overlap and a yes or
%no to seeing the deposit (given by matching_flor_pol_circle)
while location_counter<n;
    location_counter=location_counter+1;
    name = char(namelist(location_counter));
    location_path = char(folderlist(location_counter));
    if is_fun == 0 || (maxfound == 1 && printfile == 1);
        try home = cd([[resultsfile,'\Intensity based circle matching analysis'],'/','circle comparisons','/']);
            cd(home);
        catch
            makefile_path({'circle comparisons'},[resultsfile,'\Intensity based circle matching analysis']);
        end
        results_path = [[resultsfile,'\Intensity based circle matching analysis'],'/','circle comparisons','/'];
    else
        results_path = location_path;
    end
    [pol_boolean,flor_boolean,overall_overlap_precent,good_precent, ...
    great_precent,AWESOME_precent,area_covered ] = matching_flor_pol_circle( location_path,results_path ); %this is where the analysis actually happens in this function (even deeper)
    full_results = [full_results;{namelist(location_counter),pol_boolean,flor_boolean,overall_overlap_precent,good_precent, ...
    great_precent,AWESOME_precent,area_covered}];
    %prints into different files if they are truepos,trueneg....
    if flor_boolean == 1 && pol_boolean==1
        if is_fun == 0 || (maxfound == 1 && printfile == 1);
        truepos_results = [truepos_results;{namelist(location_counter),pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        truepos_count = truepos_count+1;
    elseif flor_boolean == 0 && pol_boolean==0
        if is_fun == 0 || (maxfound == 1 && printfile == 1);
        trueneg_results = [trueneg_results;{namelist(location_counter),pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        trueneg_count = trueneg_count+1;
    elseif flor_boolean == 1 && pol_boolean==0
        if is_fun == 0 || (maxfound == 1 && printfile == 1);
        falseneg_results = [falseneg_results;{namelist(location_counter),pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        falseneg_count = falseneg_count+1;
    elseif flor_boolean == 0 && pol_boolean==1
        if is_fun == 0 || (maxfound == 1 && printfile == 1);
        falsepos_results = [falsepos_results;{namelist(location_counter),pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        falsepos_count = falsepos_count+1;
    end
    if is_fun ==0
        disp([namelist(location_counter),' has been analysed']);
    end
end
sens_prec = (truepos_count/(truepos_count + falseneg_count))*100;
spec_prec = (trueneg_count/(trueneg_count + falsepos_count))*100;
npp_prec = (trueneg_count/(falseneg_count + trueneg_count))*100;
ppp_prec = (truepos_count/(falsepos_count + truepos_count))*100;
if isnan(sens_prec)
    sens_prec = 0;
end
if isnan(spec_prec)
    spec_prec = 0;
end
if isnan(npp_prec)
    npp_prec = 0;
end
if isnan(ppp_prec)
    ppp_prec = 0;
end
if is_fun == 0 || (maxfound == 1 && printfile == 1);
    full_results = [full_results;{'truepos (A)','falsepos (B)','falseneg (C)','trueneg (D)','Sensitivity','Specificity','Negative Predictive Value','Positive Predictive Value '}];
    full_results = [full_results;{'','','','','','','',''}];
    full_results = [full_results;{truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','fullcir_results.xlsx'],full_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','trueposcir_results.xlsx'],truepos_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','truenegcir_results.xlsx'],trueneg_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','falsenegcir_results.xlsx'],falseneg_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','falseposcir_results.xlsx'],falsepos_results);
    disp(['A result has been printed to ',resultsfile]);
    if printfile == 1;
        global printhere printchange;
        printhere = [resultsfile,'\Intensity based circle matching analysis\','Settings_Used.xlsx'];
    end
end
if is_fun ==0
    disp('DONE');
end