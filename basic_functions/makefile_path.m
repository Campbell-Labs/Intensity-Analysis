%creating folders and displaying if they are succesful or not
%this function works in the current directory only
%backup file is created with the last time that was stored in memory... its
%a mediocre fix...but should work for writing multiple files in a row


%the makefile_path differs from makefile as it jumps to the given directory
%and creates the files and then jumps back to the origonal directory
function[cstr] = makefile_path(foldernames,path)

outputs = 0;

oldpath = cd(path);

n=numel(foldernames);
a=0;
c=fix(clock);
cstr=strcat('_',int2str(c(1)),'_',int2str(c(2)),'_',int2str(c(3)),'_',int2str(c(4)),'_',int2str(c(5)),'_',int2str(c(6)));
while a<n
    a=a+1;
    foldername = foldernames{a};
    [~,~,messageid] = mkdir(foldername);
    if strcmp(messageid,'MATLAB:MKDIR:DirectoryExists') == 1
            if outputs == 1
            folderstate = ['A backup of ',foldername,' will be created and will be named ',strcat(foldername,cstr_memory)];
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
%     %this is the memory section
%     global cstr_memory
%     cstr_memory=cstr;
%     c=fix(clock);
%     cstr=strcat('_',int2str(c(1)),'_',int2str(c(2)),'_',int2str(c(3)),'_',int2str(c(4)),'_',int2str(c(5)),'_',int2str(c(6)));
end

cd(oldpath);