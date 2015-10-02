%%This script when given a file containing Raw Data should go inside of
%%that file and find all of the Locations/Spots and run the function in
%%intensity values ranging from 1 to 20 and print all of the results to a
%%excel file
addpath('basic_functions','specific_functions');

datafile = input('Where is the Raw Data folder stored?');

makefile_path({'Intensity based circle matching analysis'},datafile)

raw_file = [datafile,'\Raw Data'];

home=cd(raw_file);

folderlist_location=dir(['./','*ocation*']);
folderlist_spot=dir(['./','*pot*']);
folderlist = [folderlist_location,folderlist_spot];
size_struct = size(folderlist);
n=size_struct(1);

cd(home)
a=0;
full_results = {'filename','pol_boolean','flor_boolean','overall_overlap_precent','good_precent', ...
    'great_precent','AWESOME_precent','area_covered'};
truepos_results = full_results;
trueneg_results = full_results;
falseneg_results = full_results;
falsepos_results = full_results;
while a<n;
    a=a+1;
    location_path = [raw_file,'\',folderlist(a).name];
    makefile_path({'circle comparisons'},location_path);
    results_path = [location_path,'/','circle comparisons','/'];     
    [pol_boolean,flor_boolean,overall_overlap_precent,good_precent, ...
    great_precent,AWESOME_precent,area_covered ] = matching_flor_pol_circle( location_path,results_path );
    full_results = [full_results;{folderlist(a).name,pol_boolean,flor_boolean,overall_overlap_precent,good_precent, ...
    great_precent,AWESOME_precent,area_covered}];
    
    if flor_boolean == 1 && pol_boolean==1
        truepos_results = [truepos_results;{folderlist(a).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
    elseif flor_boolean == 0 && pol_boolean==0
        trueneg_results = [trueneg_results;{folderlist(a).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
    elseif flor_boolean == 1 && pol_boolean==0
        falseneg_results = [falseneg_results;{folderlist(a).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
    elseif flor_boolean == 0 && pol_boolean==1
        falsepos_results = [falsepos_results;{folderlist(a).name,pol_boolean,...
            flor_boolean,overall_overlap_precent,good_precent, ...
            great_precent,AWESOME_precent,area_covered}];
    end
    disp([folderlist(a).name,' has been analysed']);
end

xlswrite([datafile,'\Intensity based circle matching analysis\','fullcir_results.xlsx'],full_results);
xlswrite([datafile,'\Intensity based circle matching analysis\','trueposcir_results.xlsx'],truepos_results);
xlswrite([datafile,'\Intensity based circle matching analysis\','truenegcir_results.xlsx'],trueneg_results);
xlswrite([datafile,'\Intensity based circle matching analysis\','falsenegcir_results.xlsx'],falseneg_results);
xlswrite([datafile,'\Intensity based circle matching analysis\','falseposcir_results.xlsx'],falsepos_results);

disp('DONE');