    %Since this uses a lot of global variables I will clear memory before
    %anything runs

%%IF YOU ARE DEBUGGING REMOVE THE CLEAR ALL
clear all;

disp(fix(clock));
datafile = input('Where is the Raw Data folder stored?');

addpath('basic_functions','specific_functions');

makefile_path({'Sensitivity_Specificty'},datafile);

global flor_var_struct pol_var_struct maxfound ;

resultsfile = [datafile,'\Sensitivity_Specificty'];

max_steps_per = 51;
start_steps_per = 5;
steps_per = start_steps_per;
courseness = 10;

%initilize variables
%%FLOR
flor_var_struct=struct(...
    'flor_edge_crop',89,... % 50-100 amount of pixels to crop from edge
    'flor_min_convexarea',2000,... %100-500 minimum area the polygon can cover
    'flor_min_minoraxislength',6.66,...%30-50 minimum length of the short size
    'flor_min_area',32.5,... %5-50 minimum number of pixels which must show up in the polygon
    'flor_min_solidity',.0025,... %.0001-.005 minimmum amount of pixels per the area of the plygon (pixel density)
    'flor_diffmax_length',500,... % 50-200 how large the largest blob can be (photo size minus this #)
    'flor_filtersize',29 ... %5-20 how finely the image should be filtered
    );
low_flor_edge_crop = 0;
high_flor_edge_crop = 400;

low_flor_min_convexarea = 0;
high_flor_min_convexarea = 10000;

low_flor_min_minoraxislength = 0;
high_flor_min_minoraxislength = 40;

low_flor_min_area = 0;
high_flor_min_area = 200;

low_flor_min_solidity = 0;
high_flor_min_solidity = 0.026875;

low_flor_diffmax_length = 100;
high_flor_diffmax_length = 800;

low_flor_filtersize = 0;
high_flor_filtersize = 40;


%%POL
pol_var_struct=struct(...
    'pol_edge_crop',6,... % 5-10 amount of pixels to crop from edge
    'pol_min_convexarea',100,... %100-300 minimum area the polygon can cover
    'pol_min_minoraxislength',10,...%10-20 minimum length of the short size
    'pol_min_area',8.5,...%2-10 minimum number of pixels which must show up in the polygon
    'pol_min_solidity',.000125,...  %0.0001-.001 minimmum amount of pixels per the area of the plygon (pixel density)
    'pol_diffmax_length',250,...% 50-100 how large the largest blob can be (photo size minus this #)
    'pol_filtersize',3 ...%5-20 how finely the image should be filtered
    );
low_pol_edge_crop = 0;
high_pol_edge_crop = 8;

low_pol_min_convexarea = 0;
high_pol_min_convexarea = 1200;

low_pol_min_minoraxislength = 0;
high_pol_min_minoraxislength = 100;

low_pol_min_area = 0;
high_pol_min_area = 60;

low_pol_min_solidity = 0;
high_pol_min_solidity = 0.04;

low_pol_diffmax_length = 5;
high_pol_diffmax_length = 1000;

low_pol_filtersize = 0;
high_pol_filtersize = 40;

low_row = [low_flor_edge_crop,low_flor_min_convexarea,low_flor_min_minoraxislength,...
    low_flor_min_area,low_flor_min_solidity,low_flor_diffmax_length,low_flor_filtersize...
    low_pol_edge_crop,low_pol_min_convexarea,low_pol_min_minoraxislength,...
    low_pol_min_area,low_pol_min_solidity,low_pol_diffmax_length,low_pol_filtersize];

high_row = [high_flor_edge_crop,high_flor_min_convexarea,high_flor_min_minoraxislength,...
    high_flor_min_area,high_flor_min_solidity,high_flor_diffmax_length,high_flor_filtersize...
    high_pol_edge_crop,high_pol_min_convexarea,high_pol_min_minoraxislength,...
    high_pol_min_area,high_pol_min_solidity,high_pol_diffmax_length,high_pol_filtersize];

start_row = [flor_var_struct.flor_edge_crop(1),flor_var_struct.flor_min_convexarea(1),flor_var_struct.flor_min_minoraxislength(1), ...
    flor_var_struct.flor_min_area(1),flor_var_struct.flor_min_solidity(1),flor_var_struct.flor_diffmax_length(1),flor_var_struct.flor_filtersize(1),...
    pol_var_struct.pol_edge_crop(1),pol_var_struct.pol_min_convexarea(1),pol_var_struct.pol_min_minoraxislength(1), ...
    pol_var_struct.pol_min_area(1),pol_var_struct.pol_min_solidity(1),pol_var_struct.pol_diffmax_length(1),pol_var_struct.pol_filtersize(1)];

results = {'flor_edge_crop','flor_min_convexarea','flor_min_minoraxislength','flor_min_area','flor_min_solidity','flor_diffmax_length','flor_filtersize',...
    'pol_edge_crop','pol_min_convexarea','pol_min_minoraxislength','pol_min_area','pol_min_solidity','pol_diffmax_length','pol_filtersize',...
    'max_num','truepos_count','falsepos_count','falseneg_count','trueneg_count','sens_prec','spec_prec','npp_prec','ppp_prec'};

maxfound = 1;
[truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = matching_circler_bulk(datafile,resultsfile);
max_max_num = sens_prec + spec_prec + (npp_prec*0.5) + (ppp_prec*0.5);

disp('Initialized');
try
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
    %%%and steps_per(+1) rows and it should be 12 layers deep.
    if size(start_row,2) == size(low_row,2)
        start_row = [start_row,[0]];
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
    %       %Using the high_low array to set the value which will be run and
    %       %running it all (its just a bunch of variables so it looks
    %       %long)
            i=i+1;
            var_array(:,i,newj) = start_row;
            var_array(newj,i,newj) = high_low_matrix(newj,i);
            a = num2cell(var_array(:,i,newj));
            [flor_var_struct.flor_edge_crop(1),flor_var_struct.flor_min_convexarea(1),flor_var_struct.flor_min_minoraxislength(1), ...
            flor_var_struct.flor_min_area(1),flor_var_struct.flor_min_solidity(1),flor_var_struct.flor_diffmax_length(1),flor_var_struct.flor_filtersize(1),...
            pol_var_struct.pol_edge_crop(1),pol_var_struct.pol_min_convexarea(1),pol_var_struct.pol_min_minoraxislength(1), ...
            pol_var_struct.pol_min_area(1),pol_var_struct.pol_min_solidity(1),pol_var_struct.pol_diffmax_length(1),pol_var_struct.pol_filtersize(1)] = a{:};
            [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                                       matching_circler_bulk(datafile,resultsfile);
            %Number which we are attempting to maximize:
            %I am adding them all up but giving more weight to the sens/spec
            %for obvious reasons
            max_num = sens_prec + spec_prec + (npp_prec*0.5) + (ppp_prec*0.5);

            new_results = {flor_var_struct.flor_edge_crop(1),flor_var_struct.flor_min_convexarea(1),flor_var_struct.flor_min_minoraxislength(1), ...
            flor_var_struct.flor_min_area(1),flor_var_struct.flor_min_solidity(1),flor_var_struct.flor_diffmax_length(1),flor_var_struct.flor_filtersize(1),...
            pol_var_struct.pol_edge_crop(1),pol_var_struct.pol_min_convexarea(1),pol_var_struct.pol_min_minoraxislength(1), ...
            pol_var_struct.pol_min_area(1),pol_var_struct.pol_min_solidity(1),pol_var_struct.pol_diffmax_length(1),pol_var_struct.pol_filtersize(1),max_num,...
            truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec};

            results = [results;new_results];

            var_array(size(start_row,2),i,newj) = max_num;
            %loop_pass is to make sure that we dont keep looping over the same
            %image over and over and so I can reset the maxfound back to 0 as
            %it prints out the results if they find a max.
            if loop_pass == 1
                loop_pass = 0;
                maxfound = 0;
            elseif max_num> max_max_num ||(finished == 0 && max_num == max_max_num) 
                max_max_num = max_num;
                finished = 0;
                [loop_pass,maxfound] = deal(1);
                start_row(newj) = high_low_matrix(newj,i);
                if start_row(newj) == high_row(newj)
                    high_row(newj) = (high_row(newj)*4);
                    disp(['The high row of ',results{1,newj},' was changed to ',num2str(high_row(newj)),'[adjusting max]']);
                    break;
                 end
    %             if start_row(newj) == 0 
    %                 start_row(newj) = (high_row(newj)/2);
    %                 high_row(newj) = high_row(newj)*2;
    %                 disp(['The start row of ',results{1,newj},' was changed to ',num2str(start_row(newj)),'[zeroed]']);
    %             end
                if start_row(newj) == low_row(newj);
                    low_row(newj) = (low_row (newj) - high_row(newj)*.5);
                    if low_row (newj) < 0;
                        low_row (newj) = 0;
                    end
                    disp(['The low row of ',results{1,newj},' was changed to ',num2str(low_row(newj)),'[adjusting max]']);
                end
                i=i-1;
            elseif max_num < (.9*max_max_num)
                if high_low_matrix(newj,i)>start_row(newj) && high_change == 0
                    high_change = 1;
                    high_row(newj) = high_low_matrix(newj,i);
                    disp(['The high row of ',results{1,newj},' was changed to ',num2str(high_row(newj)),'[bad max]']);
                    break;
                elseif high_low_matrix(newj,i)<start_row(newj) && high_low_matrix(newj,i)>low_row(newj)
                    low_row(newj) = high_low_matrix(newj,i);
                    disp(['The low row of ',results{1,newj},' was changed to ',num2str(low_row(newj)),'[bad max]']);
                end
            end

            %Section to time the loops so we can give a approximate runtime
            diffclock = clock-runclock;
            secdiff=(diffclock(3)*24*60*60)+(diffclock(4)*60*60)+(diffclock(5)*60)+(diffclock(6));
            secdiffarray = [secdiffarray;secdiff];
            avg_time = mean(secdiffarray);

            %messages to be displayed every 5 loops
            if loopcount/20 == floor(loopcount/20) || loopcount == 1
                disp(['Loop ',int2str(loopcount),' of ',int2str(var_depth*var_width),' completed. WITH ',num2str((floor((max_steps_per-steps_per)/courseness))+1),' of ',num2str(floor((max_steps_per-start_steps_per)/courseness)+1),' loops remaining']);
                disp(['This means that the function is ', int2str(fix(loopcount/(var_depth*var_width)*100)),' % complete. FOR THIS LOOP']);
                disp(['This means that there is approximately ',int2str((avg_time*((var_depth*var_width)-loopcount))/60),' min remaining. IN THIS LOOP']);
            end
        end
        if finished == 0
            disp([char(10),'BREAKING.... TIMERS RESET because of ',char(10),results{1,newj},' which was changed to: ',num2str(start_row(newj)),char(10)]);
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
    error('Not actually an error');
catch
    %result printing section. IF THE FUNCTION DIES RUN THIS SECTION
    xlswrite([datafile,'\Sensitivity_Specificty\','results.xlsx'],results);
    if size(start_row,2) == (size(low_row,2)+1)
        start_row(size(start_row,2))=[];
    end
    high_start_low = {'flor_edge_crop','flor_min_convexarea','flor_min_minoraxislength','flor_min_area','flor_min_solidity','flor_diffmax_length','flor_filtersize',...
        'pol_edge_crop','pol_min_convexarea','pol_min_minoraxislength','pol_min_area','pol_min_solidity','pol_diffmax_length','pol_filtersize'};
    high_start_low = [high_start_low;num2cell(high_row);num2cell(start_row);num2cell(low_row)];
    xlswrite([datafile,'\Sensitivity_Specificty\','high_start_low.xlsx'],high_start_low);
    
    disp('DONE!!');
    disp(fix(clock));
end