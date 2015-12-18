    %Since this uses a lot of global variables I will clear memory before
    %anything runs
input('Press Enter to start');%this is here as we have a clear all which a user may not want to initiate
%%IF YOU ARE DEBUGGING REMOVE THE CLEAR ALL
clear all;

addpath('basic_functions','specific_functions');

disp(fix(clock));
datafile = input('Where is the Raw Data folder stored?');

makefile_path({'Sensitivity_Specificty'},datafile);

home = cd(datafile);
[FileName,PathName] = uigetfile('*.xlsx','Select the Excel high_low file, or cancel for defaults',datafile);
cd(home);

global flor_var_struct pol_var_struct maxfound printfile filter intalt; %initailizing global variables to pass through the functions
resultsfile = [datafile,'\Sensitivity_Specificty'];

%%%%%%%%%%%%%%%%OPTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_steps_per = 51; %how many steps should the options go through during the last loop?
start_steps_per = 5;%how many steps should the options start off as?
courseness = 20; %how large should the difference in steps per loop be?

%%%%%~~WARNING--These will signficantly increase runtime~~%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filter = 1;%should the images be filtered?
    intalt = 1;%should intensity be altered?
    printfile = 1;%should output files be copied and drawn on?
    show = 1;%should the function be outputting stuff to the command window?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%these are the settings used if nothing is specified%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(FileName) == 1 && isnumeric(PathName)== 1
%initilize variables
%%FLOR
flor_start_var_struct=struct(...
    'flor_edge_crop',89,... % 50-100 amount of pixels to crop from edge
    'flor_min_convexarea',0,... %100-500 minimum area the polygon can cover
    'flor_min_minoraxislength',6.66,...%30-50 minimum length of the short size
    'flor_min_area',34.5,... %5-50 minimum number of pixels which must show up in the polygon
    'flor_min_solidity',0.0036719,... %.0001-.005 minimmum amount of pixels per the area of the plygon (pixel density)
    'flor_diffmax_length',104.84,... % 50-200 how large the largest blob can be (photo size minus this #)
    'flor_filtersize',38.7778, ... %5-20 how finely the image should be filtered
    'flor_precent',100 ... %precent at which the inensity is cutoff (arbitarily large number to ignore this effect)
    );
flor_low_var_struct=struct(...
    'flor_edge_crop',0,... %amount of pixels to crop from edge
    'flor_min_convexarea',0,... %minimum area the polygon can cover
    'flor_min_minoraxislength',0,...%minimum length of the short size
    'flor_min_area',0,... %minimum number of pixels which must show up in the polygon
    'flor_min_solidity',0,... %minimmum amount of pixels per the area of the plygon (pixel density)
    'flor_diffmax_length',100,... % how large the largest blob can be (photo size minus this #)
    'flor_filtersize',0, ... %how finely the image should be filtered
    'flor_precent',0 ... %precent at which the inensity is cutoff (arbitarily large number to ignore this effect)
    );
flor_high_var_struct=struct(...
    'flor_edge_crop',400,... %amount of pixels to crop from edge
    'flor_min_convexarea',0,... %minimum area the polygon can cover
    'flor_min_minoraxislength',40,...%minimum length of the short size
    'flor_min_area',200,... %minimum number of pixels which must show up in the polygon
    'flor_min_solidity',0.026875,... %minimmum amount of pixels per the area of the plygon (pixel density)
    'flor_diffmax_length',800,... % how large the largest blob can be (photo size minus this #)
    'flor_filtersize',40, ... %how finely the image should be filtered
    'flor_precent',500 ... %precent at which the inensity is cutoff (arbitarily large number to ignore this effect)
    );
flor_var_struct = [flor_start_var_struct,flor_low_var_struct,flor_high_var_struct];
%%POL
pol_start_var_struct=struct(...
    'pol_edge_crop',6,... % 5-10 amount of pixels to crop from edge
    'pol_min_convexarea',650,... %100-300 minimum area the polygon can cover
    'pol_min_minoraxislength',10,...%10-20 minimum length of the short size
    'pol_min_area',8.5,...%2-10 minimum number of pixels which must show up in the polygon
    'pol_min_solidity',.000125,...  %0.0001-.001 minimmum amount of pixels per the area of the plygon (pixel density)
    'pol_diffmax_length',250,...% 50-100 how large the largest blob can be (photo size minus this #)
    'pol_filtersize',3, ...%5-20 how finely the image should be filtered
    'pol_precent',100 ... %precent at which the inensity is cutoff (arbitarily large number to ignore this effect)
    );

pol_low_var_struct=struct(...
    'pol_edge_crop',0,... %amount of pixels to crop from edge
    'pol_min_convexarea',0,... %minimum area the polygon can cover
    'pol_min_minoraxislength',0,...%minimum length of the short size
    'pol_min_area',0,... %minimum number of pixels which must show up in the polygon
    'pol_min_solidity',0,... %minimmum amount of pixels per the area of the plygon (pixel density)
    'pol_diffmax_length',5,... % how large the largest blob can be (photo size minus this #)
    'pol_filtersize',0, ... %how finely the image should be filtered
    'pol_precent',0 ... %precent at which the inensity is cutoff (arbitarily large number to ignore this effect)
    );
pol_high_var_struct=struct(...
    'pol_edge_crop',8,... %amount of pixels to crop from edge
    'pol_min_convexarea',1200,... %minimum area the polygon can cover
    'pol_min_minoraxislength',100,...%minimum length of the short size
    'pol_min_area',60,... %minimum number of pixels which must show up in the polygon
    'pol_min_solidity',0.04,... %minimmum amount of pixels per the area of the plygon (pixel density)
    'pol_diffmax_length',1000,... % how large the largest blob can be (photo size minus this #)
    'pol_filtersize',40, ... %how finely the image should be filtered
    'pol_precent',500 ... %precent at which the inensity is cutoff (arbitarily large number to ignore this effect)
    );

pol_var_struct = [pol_high_var_struct,pol_start_var_struct,pol_low_var_struct];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    %this just reads in the settings files
    [high_low,hdr] = xlsread([PathName,FileName]);
    cd(resultsfile);
    settingsused = [hdr;num2cell(high_low)];
    xlswrite('Initial_Settings_Used.xlsx',settingsused);
    cd(home);
    iteration_max = size(hdr,2);
    iteration = 0;
    while iteration<iteration_max
        iteration = iteration + 1;
        name = hdr{iteration};
        if strcmp(name(1:4),'flor')
            count23 = 0;
            while count23 <3 % my code loves me :D
                count23 = count23 + 1;
                eval(['flor_var_struct(',num2str(count23),').',genvarname(name),'= high_low(',num2str(count23),',',num2str(iteration),');'])
            end
        elseif strcmp(name(1:3),'pol')
            count23 = 0;
            while count23 <3
                count23 = count23 + 1;
                eval(['pol_var_struct(',num2str(count23),').',genvarname(name),'= high_low(',num2str(count23),',',num2str(iteration),');'])
            end
        end
    end
    cd(home);
end
%initalizing matrices of variables
start_row = [round(flor_var_struct(2).flor_edge_crop),round(flor_var_struct(2).flor_min_convexarea),round(flor_var_struct(2).flor_min_minoraxislength), ...
    round(flor_var_struct(2).flor_min_area),flor_var_struct(2).flor_min_solidity,round(flor_var_struct(2).flor_diffmax_length),round(flor_var_struct(2).flor_filtersize),round(flor_var_struct(2).flor_precent),...
    round(pol_var_struct(2).pol_edge_crop),round(pol_var_struct(2).pol_min_convexarea),round(pol_var_struct(2).pol_min_minoraxislength), ...
    round(pol_var_struct(2).pol_min_area),pol_var_struct(2).pol_min_solidity,round(pol_var_struct(2).pol_diffmax_length),round(pol_var_struct(2).pol_filtersize),round(pol_var_struct(2).pol_precent)];

low_row = [round(flor_var_struct(3).flor_edge_crop),round(flor_var_struct(3).flor_min_convexarea),round(flor_var_struct(3).flor_min_minoraxislength), ...
    round(flor_var_struct(3).flor_min_area),flor_var_struct(3).flor_min_solidity,round(flor_var_struct(3).flor_diffmax_length),round(flor_var_struct(3).flor_filtersize),round(flor_var_struct(3).flor_precent),...
    round(pol_var_struct(3).pol_edge_crop),round(pol_var_struct(3).pol_min_convexarea),round(pol_var_struct(3).pol_min_minoraxislength), ...
    round(pol_var_struct(3).pol_min_area),pol_var_struct(3).pol_min_solidity,round(pol_var_struct(3).pol_diffmax_length),round(pol_var_struct(3).pol_filtersize),round(pol_var_struct(3).pol_precent)];

high_row = [round(flor_var_struct(1).flor_edge_crop),round(flor_var_struct(1).flor_min_convexarea),round(flor_var_struct(1).flor_min_minoraxislength), ...
    round(flor_var_struct(1).flor_min_area),flor_var_struct(1).flor_min_solidity,round(flor_var_struct(1).flor_diffmax_length),round(flor_var_struct(1).flor_filtersize),round(flor_var_struct(1).flor_precent),...
    round(pol_var_struct(1).pol_edge_crop),round(pol_var_struct(1).pol_min_convexarea),round(pol_var_struct(1).pol_min_minoraxislength), ...
    round(pol_var_struct(1).pol_min_area),pol_var_struct(1).pol_min_solidity,round(pol_var_struct(1).pol_diffmax_length),round(pol_var_struct(1).pol_filtersize),round(pol_var_struct(1).pol_precent)];

results = {'flor_edge_crop','flor_min_convexarea','flor_min_minoraxislength','flor_min_area','flor_min_solidity','flor_diffmax_length','flor_filtersize','flor_intensityprec',...
    'pol_edge_crop','pol_min_convexarea','pol_min_minoraxislength','pol_min_area','pol_min_solidity','pol_diffmax_length','pol_filtersize','pol_intensityprec',...
    'max_num','truepos_count','falsepos_count','falseneg_count','trueneg_count','sens_prec','spec_prec','npp_prec','ppp_prec'};

%creating the waitbar
h=waitbar(0,'Initilizing Variables, Press Cancel to cleanly close the program (may take several minutes)','CreateCancelBtn','setappdata(gcbf,''canceling'',1)','Resize','on');
setappdata(h,'canceling',0)

maxfound = 1;
total_loopcount = 0;
%esitmating runtime and giving inital estimates
steps_per = start_steps_per;
[numlist,fin] = deal(0);
while steps_per <= max_steps_per %to find out how many loops will run
    height = steps_per+2;
    width = size(start_row,2)-1;
    numlist = [numlist,height*width];
    if fin == 1;
        break
    end
    steps_per = steps_per + courseness;
    if steps_per>max_steps_per;
        steps_per = max_steps_per;
        fin=1;
    end
end
totloop = sum(numlist);
steps_per = start_steps_per;
%this now runs the analysis program for the first time (calling
%matching_circler_bulk is the actual program, the rest is simply variable
%and file management)
[truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = matching_circler_bulk(datafile,resultsfile);
max_max_num = sens_prec + spec_prec + (npp_prec*0.5) + (ppp_prec*0.5); %this is how we define a good vs a bad run, by comparing this one number

[bestsens,bestspec] = deal(sens_prec,spec_prec);%setting the inital run as the best, so now we can assume that every run is the same (hence this is initalization)

disp('Initialized');
try %the whole program sits inside of a try block as it can take days to run, so if it crashes it will still print the results up until that point
    [finished,jadd] = deal(0);
    while finished == 0 || steps_per <= max_steps_per
    maxfound = 0;
    %This while loop allows the re-running of the important parts of the
    %function if we ever set the finished bool to be 0.
    finished = 1;
    %This section just makes a matrix out of the high, low and start points and
    %steps to find what the best values are
    high_low_matrix = (ones(size(low_row,2),steps_per+2));

    high_low_matrix(:,1)=low_row;
    if size(start_row,2) == (size(low_row,2)+1)
        start_row(size(start_row,2))=[];
    end

    high_low_matrix(:,(fix((steps_per+2)/2)))= start_row;
    high_low_matrix(:,(steps_per+2))= high_row;

    count = 0;
%just creating a spread of variables across the range, I really dont like
%how I did this(equal distribution of points when it should be weighted to 
%be more spread near the initalization variable), but I couldnt think of a simple way to do it better...
    while count < size(high_low_matrix,1);
        count = count +1;
        ent_count = 1;
        while ent_count < size(high_low_matrix,2);
            ent_count = ent_count + 1;
            if ent_count<(fix((steps_per+2)/2));
                diff = high_low_matrix(count,(fix((steps_per+2)/2))) - high_low_matrix(count,1);
                %this creates an equal distribution of points across the range
                delta = (diff/((fix((steps_per+2)/2))));
                entry_value = ent_count*delta;
            elseif ent_count == (fix((steps_per+2)/2));
                entry_value = high_low_matrix(count,(fix((steps_per+2)/2)));
            elseif ent_count <(steps_per+2);
                diff = high_low_matrix(count,(steps_per+2)) - high_low_matrix(count,(fix((steps_per+2)/2)));
                %this creates an equal distribution of points across the range
                delta = (diff/((steps_per+2) - (fix((steps_per+2)/2))));
                entry_value = ((ent_count-fix((steps_per+2)/2))*delta) + high_low_matrix(count,(fix((steps_per+2)/2)));
            elseif ent_count == (steps_per+2);
                entry_value = high_low_matrix(count,(steps_per+2));
            else
                error('You have not caught a variable. This should not happen. Program will die now.')
            end
            high_low_matrix(count,ent_count) = entry_value;
        end
    end

    %initializing more variables
    [truepos_count ,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec, ppp_prec]...
        = deal(0);
    %%%HURRAY LETS MAKE AN ARRAY!!!!
    %%%There whould be 12 columns (+1 empty that the sens/spec will input into)
    %%%and steps_per(+1) rows and it should be 12 layers deep. (12 is not
    %%%hardcoded to allow the introduction of more variables)
    if size(start_row,2) == size(low_row,2)
        start_row = [start_row,0];
    end
    %assigning the size of the array
    var_array = zeros(size(start_row,2),steps_per+2,size(start_row,2)-1);
    var_depth=size(var_array,3);
    var_width=size(var_array,2);
    jOG=0;
    jadd = 1+jadd;
    loopcount = 0;
    secdiffarray = [];
    while jOG<var_depth
        jOG=jOG+1;
        newj = jOG+jadd;
        while newj > var_depth
            newj = newj-var_depth;
        end
        [i,loop_pass,high_change]=deal(0);
        while i<var_width
            runclock = clock;
            loopcount = loopcount+1;
            total_loopcount = total_loopcount+1;
    %       %Using the high_low array to set the value which will be run and
    %       %running it all (its just a bunch of variables so it looks
    %       %long)
            i=i+1;
            var_array(:,i,newj) = start_row;
            var_array(newj,i,newj) = high_low_matrix(newj,i);
            a=zeros(size(var_array,1),1);
            k = 0;
            while k < size(var_array,1)
                k=k+1;
                if var_array(k,i,newj) < 1 %this checks if the number is less than 1(should only apply to solidity)
                    a(k) = (var_array(k,i,newj));
                else
                    a(k) = (round(var_array(k,i,newj)));%and it should roumd the number (for speed) if it is more than one. (this will speed up runtime as later on the program will throw out repeated runs, so this insures that there will be repeat in variables which it is useless to have decimals)
                end
            end
            a = num2cell(a);
            [flor_var_struct(2).flor_edge_crop,flor_var_struct(2).flor_min_convexarea,flor_var_struct(2).flor_min_minoraxislength, ...
            flor_var_struct(2).flor_min_area,flor_var_struct(2).flor_min_solidity,flor_var_struct(2).flor_diffmax_length,flor_var_struct(2).flor_filtersize,flor_var_struct(2).flor_precent,...
            pol_var_struct(2).pol_edge_crop,pol_var_struct(2).pol_min_convexarea,pol_var_struct(2).pol_min_minoraxislength, ...
            pol_var_struct(2).pol_min_area,pol_var_struct(2).pol_min_solidity,pol_var_struct(2).pol_diffmax_length,pol_var_struct(2).pol_filtersize,pol_var_struct(2).pol_precent] = a{:};
            [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                                       matching_circler_bulk(datafile,resultsfile); %this is where the real analysis runs
            %Number which we are attempting to maximize:
            %I am adding them all up but giving more weight to the sens/spec
            %for obvious reasons
            max_num = sens_prec + spec_prec + (npp_prec*0.5) + (ppp_prec*0.5);

            new_results = {flor_var_struct(2).flor_edge_crop,flor_var_struct(2).flor_min_convexarea,flor_var_struct(2).flor_min_minoraxislength, ...
            flor_var_struct(2).flor_min_area,flor_var_struct(2).flor_min_solidity,flor_var_struct(2).flor_diffmax_length,flor_var_struct(2).flor_filtersize,flor_var_struct(2).flor_precent,...
            pol_var_struct(2).pol_edge_crop,pol_var_struct(2).pol_min_convexarea,pol_var_struct(2).pol_min_minoraxislength, ...
            pol_var_struct(2).pol_min_area,pol_var_struct(2).pol_min_solidity,pol_var_struct(2).pol_diffmax_length,pol_var_struct(2).pol_filtersize,pol_var_struct(2).pol_precent,max_num,...
            truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec};
                global printhere printchange;
                if printchange == 1;
                    xlswrite(printhere,[results(1,:);new_results]);
                    printchange = 0;
                end
            results = [results;new_results];

            var_array(size(start_row,2),i,newj) = max_num;
            %loop_pass is to make sure that we dont keep looping over the same
            %image over and over and so I can reset the maxfound back to 0 as
            %it prints out the results if they find a max.
            if loop_pass == 1
                loop_pass = 0;
                maxfound = 0;
                %this elseif loop is how I dynamically change variables if
                %they are good
            elseif max_num> max_max_num ||(finished == 0 && max_num == max_max_num) 
                if show == 1;
                    disp(results{1,newj});
                end
                max_max_num = max_num;
                bestsens=sens_prec;
                bestspec=spec_prec;
                finished = 0;
                [loop_pass,maxfound] = deal(1);
                start_row(newj) = high_low_matrix(newj,i);
                if start_row(newj) == high_row(newj)
                    high_row(newj) = (high_row(newj)*4);
                    if show ==1;
                    disp(['The high row of ',results{1,newj},' was changed to ',num2str(high_row(newj)),'[adjusting max]']);
                    end
                    break;
                 end
    %             if start_row(newj) == 0 
    %                 start_row(newj) = (high_row(newj)/2);
    %                 high_row(newj) = high_row(newj)*2;
    %                 if show ==1
    %                 disp(['The start row of ',results{1,newj},' was changed to ',num2str(start_row(newj)),'[zeroed]']);
    %                 end
    %             end
                if start_row(newj) == low_row(newj);
                    low_row(newj) = (low_row (newj) - high_row(newj)*.5);
                    if low_row (newj) < 0;
                        low_row (newj) = 0;
                    end
                    if show ==1;
                    disp(['The low row of ',results{1,newj},' was changed to ',num2str(low_row(newj)),'[adjusting max]']);
                    end
                end
                i=i-1;
                %this elseif loop is where I dynamically change variables
                %if they are bad
            elseif max_num < (max_max_num-(.1*(300-max_max_num))) 
                if high_low_matrix(newj,i)>start_row(newj) && high_change == 0
                    high_change = 1;
                    high_row(newj) = high_low_matrix(newj,i);
                    if show ==1;
                    disp(['The high row of ',results{1,newj},' was changed to ',num2str(high_row(newj)),'[bad max]']);
                    end
                    break;
                elseif high_low_matrix(newj,i)<start_row(newj) && high_low_matrix(newj,i)>low_row(newj)
                    low_row(newj) = high_low_matrix(newj,i);
                    if show ==1;
                    disp(['The low row of ',results{1,newj},' was changed to ',num2str(low_row(newj)),'[bad max]']);
                    end
               end
            end

            %Section to time the loops so we can give a approximate runtime
            diffclock = clock-runclock;
            secdiff=(diffclock(3)*24*60*60)+(diffclock(4)*60*60)+(diffclock(5)*60)+(diffclock(6));
            secdiffarray = [secdiffarray;secdiff];
            avg_time = mean(secdiffarray);

            %messages to be displayed every 20 loops so we dont spam the
            %console
            waitbar(loopcount/(var_depth*var_width),h,['Best Sensitivity is ',num2str(bestsens),'% and Specificity is ',num2str(bestspec),'%',char(10),'Current Sensitivity is ',num2str(sens_prec),'% and Specificity is ',num2str(spec_prec),'% - using ',results{1,newj},char(10),'Cancel cleanly closes program (may take several minutes) -- ',num2str((fix((total_loopcount/totloop)*10000))/100),'% complete OVERALL.']);
            if getappdata(h,'canceling')
                error('Cancel has been hit');
            end
            if show ==1;
                every = 10;
            else
                every = 50;
            end
            if loopcount/every == floor(loopcount/every) || loopcount == 1
                if show ==1;
                disp(['Loop ',int2str(loopcount),' of ',int2str(var_depth*var_width),' completed. WITH ',num2str((floor((max_steps_per-steps_per)/courseness))+1),' of ',num2str(floor((max_steps_per-start_steps_per)/courseness)+1),' PASSES remaining']);
                disp(['This means that the function is ', int2str(fix(loopcount/(var_depth*var_width)*100)),' % complete in this loop , and ',num2str((fix((total_loopcount/totloop)*10000))/100),'% complete overall']);
                end
                disp(['There is approximately ',int2str((avg_time*((totloop)-loopcount))/60),' min remaining overall.']);
            end
        end
        if finished == 0
            disp([char(10),'BREAKING.... TIMERS RESET because of ',char(10),results{1,newj},' which was changed to: ',num2str(start_row(newj)),char(10)]);
            totloop = totloop - loopcount;
            total_loopcount = total_loopcount - loopcount;
            break
        end
    end
        if finished == 1
            steps_per = steps_per + courseness;
                if steps_per>max_steps_per;
                    steps_per = max_steps_per;
                end
        end
    end
catch ME %catching errors
    
    %result printing section. IF THE FUNCTION DIES RUN THIS SECTION
    delete(h);
    xlswrite([datafile,'\Sensitivity_Specificty\','results.xlsx'],results);
    if size(start_row,2) == (size(low_row,2)+1)
        start_row(size(start_row,2))=[];
    end
    high_start_low = {'flor_edge_crop','flor_min_convexarea','flor_min_minoraxislength','flor_min_area','flor_min_solidity','flor_diffmax_length','flor_filtersize','flor_precent',...
        'pol_edge_crop','pol_min_convexarea','pol_min_minoraxislength','pol_min_area','pol_min_solidity','pol_diffmax_length','pol_filtersize','pol_precent'};
    high_start_low = [high_start_low;num2cell(high_row);num2cell(start_row);num2cell(low_row)];
    xlswrite([datafile,'\Sensitivity_Specificty\','high_start_low.xlsx'],high_start_low);
    
    disp('DONE!!');
    disp(fix(clock));
    rethrow(ME); %throwing the error at the end so we can actually read what happened in the end
end