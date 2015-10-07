disp(fix(clock));
datafile = input('Where is the Raw Data folder stored?');

addpath('basic_functions','specific_functions');

makefile_path({'Sensitivity_Specificty'},datafile);

global pol_edge_crop pol_min_convexarea pol_min_minoraxislength pol_min_area ... 
    pol_min_solidity pol_diffmax_length flor_edge_crop flor_min_convexarea ...
    flor_min_minoraxislength flor_min_area flor_min_solidity flor_diffmax_length;

resultsfile = [datafile,'\Sensitivity_Specificty'];

steps_per = 11;

%initilize variables
%%POL
flor_edge_crop = 9; % 10 amount of pixels to crop from edge
flor_min_convexarea = 300; %300 minimum area the polygon can cover 
flor_min_minoraxislength = 20;%20 minimum length of the short size
flor_min_area = 10; %10 minimum number of pixels which must show up in the polygon
flor_min_solidity = .0005; %.001 minimmum amount of pixels per the area of the plygon (pixel density)
flor_diffmax_length = 100; % 100 how large the largest blob can be (photo size minus this #)

low_flor_edge_crop = 0;
high_flor_edge_crop = 20;

low_flor_min_convexarea = 0;
high_flor_min_convexarea = 1000;

low_flor_min_minoraxislength = 0;
high_flor_min_minoraxislength = 50;

low_flor_min_area = 0;
high_flor_min_area = 100;

low_flor_min_solidity = 0;
high_flor_min_solidity = 0.05;

low_flor_diffmax_length = 0;
high_flor_diffmax_length = 200;

%%pol
pol_edge_crop = 10; % 10 amount of pixels to crop from edge
pol_min_convexarea = 300; %300 minimum area the polygon can cover 
pol_min_minoraxislength = 20;%20 minimum length of the short size
pol_min_area = 10;%10 minimum number of pixels which must show up in the polygon
pol_min_solidity = .001;  %.001 minimmum amount of pixels per the area of the plygon (pixel density)
pol_diffmax_length = 100;% 100 how large the largest blob can be (photo size minus this #)

low_pol_edge_crop = 0;
high_pol_edge_crop = 50;

low_pol_min_convexarea = 0;
high_pol_min_convexarea = 1000;

low_pol_min_minoraxislength = 10;
high_pol_min_minoraxislength = 40;

low_pol_min_area = 0;
high_pol_min_area = 30;

low_pol_min_solidity = 0;
high_pol_min_solidity = 0.01;

low_pol_diffmax_length = 0;
high_pol_diffmax_length = 200;



low_row = [low_flor_edge_crop,low_flor_min_convexarea,low_flor_min_minoraxislength,...
    low_flor_min_area,low_flor_min_solidity,low_flor_diffmax_length...
    low_pol_edge_crop,low_pol_min_convexarea,low_pol_min_minoraxislength,...
    low_pol_min_area,low_pol_min_solidity,low_pol_diffmax_length];

high_row = [high_flor_edge_crop,high_flor_min_convexarea,high_flor_min_minoraxislength,...
    high_flor_min_area,high_flor_min_solidity,high_flor_diffmax_length...
    high_pol_edge_crop,high_pol_min_convexarea,high_pol_min_minoraxislength,...
    high_pol_min_area,high_pol_min_solidity,high_pol_diffmax_length];

start_row = [flor_edge_crop,flor_min_convexarea,flor_min_minoraxislength, ...
    flor_min_area,flor_min_solidity,flor_diffmax_length,...
    pol_edge_crop,pol_min_convexarea,pol_min_minoraxislength, ...
    pol_min_area,pol_min_solidity,pol_diffmax_length];

results = {'flor_edge_crop','flor_min_convexarea','flor_min_minoraxislength','flor_min_area','flor_min_solidity','flor_diffmax_length',...
    'pol_edge_crop','pol_min_convexarea','pol_min_minoraxislength','pol_min_area','pol_min_solidity','pol_diffmax_length',...    
    'max_num','truepos_count','falsepos_count','falseneg_count','trueneg_count','sens_prec','spec_prec','npp_prec','ppp_prec'};

disp('Initialized');
max_max_num = 0;
finished = 0;
while finished == 0
%This while loop allows the re-running of the important parts of the
%function if we ever set the finished bool to be 0.
finished = 1;
%This section just makes a matrix out of the high, low and start points and
%steps to find what the best values are
high_low_matrix = (ones(size(low_row,2),steps_per+2));

high_low_matrix(:,1)=low_row;
if size(start_row,2) == 13
    start_row(13)=[];
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
if size(start_row,2) == 12
    start_row = [start_row,[0]];
end
%assigning the size of the array
var_array = zeros(size(start_row,2),steps_per+2,size(start_row,2)-1);
var_depth=size(var_array,3);
var_width=size(var_array,2);
j=0;
loopcount = 0;
secdiffarray = [];
while j<var_depth
    j=j+1;
    i=0;
    while i<var_width
        runclock = clock;
        loopcount = loopcount+1;
%         %Using the high_low array to set the value which will be run and
%         %running it all (its just a bunch of variables so it looks
%         %complicated)
        i=i+1;
        var_array(:,i,j) = start_row;
        var_array(j,i,j) = high_low_matrix(j,i);
        a = num2cell(var_array(:,i,j));
        [flor_edge_crop,flor_min_convexarea,flor_min_minoraxislength, ...
        flor_min_area,flor_min_solidity,flor_diffmax_length,...
        pol_edge_crop,pol_min_convexarea,pol_min_minoraxislength, ...
        pol_min_area,pol_min_solidity,pol_diffmax_length] = a{:};
        [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                                   matching_circler_bulk(datafile,resultsfile);
        %Number which we are attempting to maximize:
        max_num = sens_prec + spec_prec + npp_prec + ppp_prec;
        
        new_results = {flor_edge_crop,flor_min_convexarea,flor_min_minoraxislength, ...
        flor_min_area,flor_min_solidity,flor_diffmax_length,...
        pol_edge_crop,pol_min_convexarea,pol_min_minoraxislength, ...
        pol_min_area,pol_min_solidity,pol_diffmax_length,max_num,...
        truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec};

        results = [results;new_results];

        var_array(size(start_row,2),i,j) = max_num;
        if max_num> max_max_num
            max_max_num = max_num;
            finished = 0;
            start_row(j) = high_low_matrix(j,i);
        elseif max_num < max_max_num - 50
            if high_low_matrix(j,i)>start_row(j)
                high_row(j) = high_low_matrix(j,i);
            elseif high_low_matrix(j,i)<start_row(j)
                low_row(j) = high_low_matrix(j,i);
            end
        end
        
        %Section to time the loops so we can give a approximate runtime
        diffclock = clock-runclock;
        secdiff=(diffclock(3)*24*60*60)+(diffclock(4)*60*60)+(diffclock(5)*60)+(diffclock(6));
        secdiffarray = [secdiffarray;secdiff];
        avg_time = mean(secdiffarray);

        %messages to be displayed every 5 loops
        if loopcount/5 == floor(loopcount/5)
            disp(['Loop ',int2str(loopcount),' of ',int2str(var_depth*var_width),' completed'])
            disp(['This means that the function is ', int2str(fix(loopcount/(var_depth*var_width)*100)),' % complete']);
            disp(['This means that there is approximately ',int2str((avg_time*((var_depth*var_width)-loopcount))/60),' min remaining']);
        end
    end
    if finished == 0
        disp(['BREAKING.... TIMERS RESET because of '])
        disp(results(1,j));
        disp(['which was changed']);
        break
    end
end
end
xlswrite([datafile,'\Sensitivity_Specificty\','results.xlsx'],results);
disp('DONE!!');
disp(fix(clock));