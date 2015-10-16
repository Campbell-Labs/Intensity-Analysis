%%This script when given a file containing Raw Data should go inside of
%%that file and find all of the Locations/Spots and run the function in
%%intensity values ranging from 1 to 20 and print all of the results to a
%%excel file
function [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
    matching_circler_bulk(datafile,resultsfile)
    %this function will run the circular matching on a whole Raw Data file
    
% datafile = 'C:\Glenda\Glenda LE';
% resultsfile = 'C:\Glenda\Glenda LE';
global maxfound location_counter mem name;

addpath('basic_functions','specific_functions');

%Will supress outputs and attempt to make the function less memory
%intensive
is_fun = 1;

if is_fun ==0
    datafile = input('Where is the Raw Data folder stored?');
    resultsfile = datafile;
    maxfound = 1;
end

if is_fun == 0 || maxfound == 1;
    makefile_path({'Intensity based circle matching analysis'},resultsfile);
end
raw_file = [datafile,'\Raw Data'];

home=cd(raw_file);

folderlist_location=dir(['./','*ocation*']);
folderlist_spot=dir(['./','*pot*']);
folderlist = [folderlist_location,folderlist_spot];
size_struct = size(folderlist);
n=size_struct(1);

%%MEMORY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
empty = zeros(n,1);
empty2 = zeros(n,2);
mem = struct('flor_edge_crop',empty,'flor_min_convexarea',empty,'flor_min_minoraxislength',empty,'flor_min_area',empty,... 
            'flor_min_solidity',empty,'flor_diffmax_length',empty,'flor_filtersize',empty,'pol_edge_crop',empty,'pol_min_convexarea',empty, ...
            'pol_min_minoraxislength',empty,'pol_min_area',empty,'pol_min_solidity',empty,'pol_diffmax_length',empty,'pol_filtersize',empty,...
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
while location_counter<n;
    location_counter=location_counter+1;
    name = folderlist(location_counter).name;
    location_path = [raw_file,'\',folderlist(location_counter).name];
    if is_fun == 0 || maxfound == 1;
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
    great_precent,AWESOME_precent,area_covered ] = matching_flor_pol_circle( location_path,results_path );
    full_results = [full_results;{folderlist(location_counter).name,pol_boolean,flor_boolean,overall_overlap_precent,good_precent, ...
    great_precent,AWESOME_precent,area_covered}];
    
    if flor_boolean == 1 && pol_boolean==1
        if is_fun == 0 || maxfound == 1;
        truepos_results = [truepos_results;{folderlist(location_counter).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        truepos_count = truepos_count+1;
    elseif flor_boolean == 0 && pol_boolean==0
        if is_fun == 0 || maxfound == 1;
        trueneg_results = [trueneg_results;{folderlist(location_counter).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        trueneg_count = trueneg_count+1;
    elseif flor_boolean == 1 && pol_boolean==0
        if is_fun == 0 || maxfound == 1;
        falseneg_results = [falseneg_results;{folderlist(location_counter).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        falseneg_count = falseneg_count+1;
    elseif flor_boolean == 0 && pol_boolean==1
        if is_fun == 0 || maxfound == 1;
        falsepos_results = [falsepos_results;{folderlist(location_counter).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
        end
        falsepos_count = falsepos_count+1;
    end
    if is_fun ==0
        disp([folderlist(location_counter).name,' has been analysed']);
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
if is_fun == 0 || maxfound == 1;
    full_results = [full_results;{'truepos (A)','falsepos (B)','falseneg (C)','trueneg (D)','Sensitivity','Specificity','Negative Predictive Value','Positive Predictive Value '}];
    full_results = [full_results;{'','','','','','','',''}];
    full_results = [full_results;{truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','fullcir_results.xlsx'],full_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','trueposcir_results.xlsx'],truepos_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','truenegcir_results.xlsx'],trueneg_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','falsenegcir_results.xlsx'],falseneg_results);
    xlswrite([resultsfile,'\Intensity based circle matching analysis\','falseposcir_results.xlsx'],falsepos_results);
    disp(['A result has been printed to ',resultsfile]);
end
if is_fun ==0
    disp('DONE');
end