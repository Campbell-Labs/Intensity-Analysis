disp(fix(clock));
datafile = input('Where is the Raw Data folder stored?');

addpath('basic_functions','specific_functions');

makefile_path({'Sensitivity_Specificty'},datafile);

global edge_crop min_convexarea min_minoraxislength min_area min_solidity ...
        diffmax_length;
resultsfile = [datafile,'\Sensitivity_Specificty'];

steps_per = 0;

low_edge_crop = 0;
high_edge_crop = 40;
stepsize_edge_crop = fix((high_edge_crop-low_edge_crop)/steps_per);

low_min_convexarea = 0;
high_min_convexarea = 1000;
stepsize_min_convexarea = fix((high_min_convexarea-low_min_convexarea)/steps_per);

low_min_minoraxislength = 0;
high_min_minoraxislength = 50;
stepsize_min_minoraxislength = fix((high_min_minoraxislength-low_min_minoraxislength)/steps_per);

low_min_area = 0;
high_min_area = 100;
stepsize_min_area = fix((high_min_area-low_min_area)/steps_per); 

low_min_solidity = 0;
high_min_solidity = 0.01;
stepsize_min_solidity = ((high_min_solidity-low_min_solidity)/steps_per); 

low_diffmax_length = 0;
high_diffmax_length = 200;
stepsize_diffmax_length = fix((high_diffmax_length-low_diffmax_length)/steps_per); 

results = {'edge_crop','min_convexarea','min_minoraxislength','min_area','min_solidity',...
        'diffmax_length','truepos_count','falsepos_count','falseneg_count','trueneg_count','sens_prec','spec_prec','npp_prec','ppp_prec'};
tot_count = (6^(steps_per+1));
a=0;
count = 0;
truepos_count = 0;
falsepos_count= 0; 
falseneg_count= 0; 
trueneg_count= 0; 
sens_prec= 0; 
spec_prec= 0; 
npp_prec= 0; 
ppp_prec = 0;
while a<steps_per || a == steps_per;
    count = count+1;
    edge_crop = low_edge_crop + (stepsize_edge_crop*a);
    b=0;
    [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
    matching_circler_bulk(datafile,resultsfile);

    results = [results;{edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,...
        diffmax_length,truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
    a = a+1;
    while b<steps_per || b == steps_per;
        count = count+1;
        min_convexarea = low_min_convexarea + (stepsize_min_convexarea*b);
        c=0;
        
            [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
            matching_circler_bulk(datafile,resultsfile);

            results = [results;{edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,...
                diffmax_length,truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
        b = b+1;
        while c<steps_per || c == steps_per
           count = count+1;
            min_minoraxislength = low_min_minoraxislength + (stepsize_min_minoraxislength*c);
            d=0;
            
                [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                matching_circler_bulk(datafile,resultsfile);

                results = [results;{edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,...
                    diffmax_length,truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];

            c = c+1;
            while d<steps_per || d == steps_per
                count = count+1;
                min_area = low_min_area + (stepsize_min_area*d);
                e=0;
                
                    [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                    matching_circler_bulk(datafile,resultsfile);

                    results = [results;{edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,...
                        diffmax_length,truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
                d = d+1;
                while e<steps_per || e == steps_per
                    count = count+1;
                    min_solidity = low_min_solidity + (stepsize_min_solidity*e);
                    f=0;
                    
                        [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                        matching_circler_bulk(datafile,resultsfile);

                        results = [results;{edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,...
                            diffmax_length,truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
                    e = e+1;
                    while f<steps_per || f == steps_per
                        count = count+1;
                        diffmax_length = low_diffmax_length + (stepsize_diffmax_length*f);
                        
                            [truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec] = ...
                            matching_circler_bulk(datafile,resultsfile);

                            results = [results;{edge_crop,min_convexarea,min_minoraxislength,min_area,min_solidity,...
                                diffmax_length,truepos_count,falsepos_count,falseneg_count,trueneg_count,sens_prec,spec_prec,npp_prec,ppp_prec}];
                        f = f+1;
                    end
                    disp(['The analysis is ',num2str((count/tot_count)*100),'% complete']);
                end
            end
        end
    end
    disp(['Loop ',int2str(a+1),' of ',int2str(steps_per+1),' is complete']);
end
xlswrite([datafile,'\Intensity based circle matching in bulk\','results.xlsx'],results);
disp('DONE!!');
disp(fix(clock));