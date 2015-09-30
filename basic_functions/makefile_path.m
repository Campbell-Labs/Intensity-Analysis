%creating folders and displaying if they are succesful or not
%this function works in the current directory only
%backup file is created with the time that it is attempted to be
%rewritten,so these dates may be confusing, but I cannot think of a better
%fix

%the makefile_path differs from makefile as it jumps to the given directory
%and creates the files and then jumps back to the origonal directory
function makefile_path(foldernames,path)

outputs = 0;

oldpath = cd(path);

n=numel(foldernames);
a=0;
while a<n
    a=a+1;
    foldername = foldernames{a};
    [~,~,messageid] = mkdir(foldername);
    if strcmp(messageid,'MATLAB:MKDIR:DirectoryExists') == 1
        c=fix(clock);
        cstr=strcat('_',int2str(c(1)),'_',int2str(c(2)),'_',int2str(c(3)),'_',int2str(c(4)),'_',int2str(c(5)),'_',int2str(c(6)));
        if outputs == 1
            folderstate = ['A backup of ',foldername,' will be created and will be named ',strcat(foldername,cstr)];
            disp(folderstate);
        end
        movefile(foldername,strcat(foldername,cstr));
        a=a-1;
    else 
        if outputs == 1
            folderstate = [foldername,' has been created'];
            disp(messageid)
            disp(folderstate);
        end
    end   
end

cd(oldpath);