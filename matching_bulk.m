%%This script when given a file containing Raw Data should go inside of
%%that file and find all of the Locations/Spots and run the function in
%%intensity values ranging from 1 to 20 and print all of the results to a
%%excel file
addpath('basic_functions','specific_functions');

datafile = input('Where is the Raw Data folder stored?');

makefile_path({'Intensity based matching analysis'},datafile)

raw_file = [datafile,'\Raw Data'];

home=cd(raw_file);

folderlist_location=dir(['./','*ocation*']);
folderlist_spot=dir(['./','*pot*']);
folderlist = [folderlist_location,folderlist_spot];
size_struct = size(folderlist);
n=size_struct(1);

cd(home)
a=0;
full_results = {'filename','goodmatch', 'pol_boolean','flor_boolean','precent_match','florintensity','polintensity','timestamp'};
good_results = full_results;
while a<n;
    a=a+1;
    location_path = [raw_file,'\',folderlist(a).name];
    makefile_path({'comparisons'},location_path);
    results_path = [location_path,'/','comparisons','/']; 
    int_count = 0;
    maxintens = 20;
    intensdiff=(maxintens-int_count);
    while int_count < maxintens
        int_count = int_count+1;
        [goodmatch,pol_boolean,flor_boolean,precent_match,florintensity,polintensity,timestamp] = matching_flor_pol(location_path,results_path,int_count);
        full_results = [full_results;{folderlist(a).name,goodmatch,pol_boolean,flor_boolean,precent_match,florintensity,polintensity,timestamp}];
        if goodmatch == 1;
            good_results = [good_results;{folderlist(a).name,goodmatch,pol_boolean,flor_boolean,precent_match,florintensity,polintensity,timestamp}];
        end
        if floor(int_count/5) == int_count/5
            s=int2str(fix((int_count/intensdiff)*100));
            disp(['Intensity analysis of ',folderlist(a).name,' is ' s ,'% completed']);
        end
    end
    disp([folderlist(a).name,' has been analysed']);
end

xlswrite([datafile,'\Intensity based matching analysis\','full_results.xlsx'],full_results);
xlswrite([datafile,'\Intensity based matching analysis\','good_results.xlsx'],good_results);