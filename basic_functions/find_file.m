%this function will go into the specified folder and find the file that
%ends with the specified name
function[file_path,file] = find_file(location_path,foldername,endname)

path = strcat(location_path,'\',foldername);

try
    home = cd(path);
catch
    error('find_file:no_such_path','Error \n \nThis path does not exist');
end

%these two lines are simply parsing from a structure to a string... was a
%pain to figure out. First we translate to a cell array and then we take
%the first element of that and change it into a string using the char
%function

try 
    cell = struct2cell(dir(['./','\*',endname]));
    file = char(cell(1));
catch
    cd(home);
    error('find_file:no_such_file','Error \n \nThis file does not exist');
end

clear cell;

file_path = (strcat(path,'/',file));

cd(home);