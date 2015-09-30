%%This script when given a file containing Raw Data should go inside of
%%that file and find all of the Locations/Spots and run the function in
%%intensity values ranging from 1 to 20 and print all of the results to a
%%excel file

datafile = input('Where is the Raw Data folder stored?');

makefile_path({'Intensity based matching analysis'},datafile)

raw_file = [datafile,'\Raw Data'];

home=cd(raw_file);

folderlist=dir(['./','\Location*']);

size_struct = size(folderlist);
n=size_struct(1);
cd(home)
a=0;
results = zeros(1,8);
while a<n;
    a=a+1;
    location_path = [raw_file,'\',folderlist(a).name];
    int_count = 0;
    while int_count < 20
        int_count = int_count+1;
        [goodmatch,pol_boolean,flor_boolean,precent_match,florintensity,polintensity] = matching_flor_pol(location_path,int_count);
        c=fix(clock);
        cint=str2num(sprintf('%d%d%d%d%d%d',c(1),c(2),c(3),c(4),c(5),c(6)));
        results = [results;[a,goodmatch pol_boolean flor_boolean precent_match florintensity polintensity,cint]];
        if floor(int_count/5) == int_count/5
            s=int2str(int_count);
            disp(['Intensity analysis of ', s ,' has been completed']);
        end
    end
    disp([folderlist(a).name,' has been analysed']);
end

xlswrite([datafile,'\Intensity based matching analysis\','results.xlsx'],results);