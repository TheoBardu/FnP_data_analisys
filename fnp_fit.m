% Program that import data file generated from raspberry pi and
% plot time vs T and H

%clear; close all;

initial_date = [2026 03 24] ; 
final_date = [2026 03 25]; 

file_dir = "/Volumes/FnP/Fish&Plants/data/TH" + "/";

str_format_date = "yyyy_mm_dd"; 
str_format_name_data = "TH_%s.txt";

str_irrigation = "irrigation_data";


compute_stats = 1; %compute max, min, mean. 0= false, 1=true


% [plot T and H vs time, plot VPD vs time]
%  1 = yes, 0 = no
plotting = [1,0];
plot_comparison_ext_int = 1; %compare external and internal T and H: 0 no, 1 yes



% ARPAE dataset
file_temp_ext_dir = "/Volumes/FnP/Fish&Plants/data/TH_ext" +  "/";
cell_number = "01945";
type_measure = "h";



% Plotting Variable

font_size = 22;

% ------------------------------------------------------
%
% Starting Program  
%
% ------------------------------------------------------


%control the date
status = control_date(initial_date, final_date);


start = datetime(initial_date(1),initial_date(2),initial_date(3));
stop = datetime(final_date(1), final_date(2), final_date(3));

% d = string(caldiff([start,stop])); d = str2num(d(1)); %days for separation
d = caldiff([start,stop],"days"); d = split(d,{'days'}); %days for separation

days = start + caldays(0:d);
days = datestr(days,str_format_date);




if status == 1 % no errors in dates
    
    data_set = timetable(); %initialize the dataset
    
    
    % Set up the Import Options
    opts = delimitedTextImportOptions("NumVariables", 4);
    
    % Specify range and delimiter
    opts.DataLines = [1, Inf];
    opts.Delimiter = "\t";
    
    % Specify column names and types
    opts.VariableNames = ["datetime", "Tint", "Hint", "VPD"];
    opts.VariableTypes = ["datetime", "double", "double", "double"];
    
    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Specify variable properties
    %opts = setvaropts(opts, "M1", "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "datetime", "InputFormat", "yyyy/MM/dd HH:mm:ss");
    opts = setvaropts(opts, ["Tint", "Hint","VPD"], "TrimNonNumeric", true);
    opts = setvaropts(opts, ["Tint", "Hint", "VPD"], "ThousandsSeparator", ",");


    %Taking the values 
    for i=1:size(days,1)
    
        file_name = sprintf(str_format_name_data,days(i,:)); 
        fid = file_dir + file_name; %full string for the file, dir + name
        
        
        try
            % Import the data in to the workspace
            data_temp = readtimetable(fid, opts);
        catch ME
            warning('%s file not present. Anable to read this', file_name)
            continue
        end
            
        %Putting all the values in a table
        data_set = [data_set; data_temp];
        
        
        %Delete the errors during the acquisition
        % for e.g when H is > than 100
        where_H_over = find(data_set.Hint > 100);
        if length(where_H_over)>= 1
            data_set(where_H_over,:) = [];
            fprintf('There were some data in -INTERNAL DHT22- corrupted. I have deleted them.\n')
        end

        % where_H_over = find(data_set.Hext > 100);
        % if length(where_H_over)>= 1
        %     data_set(where_H_over,:) = [];
        %     fprintf('There were some data in -External DHT22- corrupted. I have deleted them.\n')
        % end
    
    
    
     
    end
                                          
  
     % Clear temporary variables
    clear opts fid data_temp
            
end

% max_dText = max(data_set.Text) - min(data_set.Text);
% max_dHext = max(data_set.Hext) - min(data_set.Hext);


% disp("################")
% disp("External")
% disp("################")
% fprintf("Mean:  T = %.1f °C    H = %.1f %%\n", mean(data_set.Text), mean(data_set.Hext));
% fprintf("Tmax = %.1f °C \tHmax = %.1f %% \n", max(data_set.Text),max(data_set.Hext));
% fprintf("Tmin = %.1f °C \tHmin = %.1f %% \n", min(data_set.Text), min(data_set.Hext));
% fprintf("ΔTmax = %.1f °C \tΔHmax = %.1f %%\n", max_dText, max_dHext);

max_dTint = max(data_set.Tint) - min(data_set.Tint);
max_dHint = max(data_set.Hint) - min(data_set.Hint);

disp("################")
disp("Internal")
disp("################")
fprintf("Mean:  T = %.1f °C    H = %.1f %%\n", mean(data_set.Tint), mean(data_set.Hint));
fprintf("Tmax = %.1f °C \tHmax = %.1f %% \n", max(data_set.Tint),max(data_set.Hint));
fprintf("Tmin = %.1f °C \tHmin = %.1f %% \n", min(data_set.Tint), min(data_set.Hint));
fprintf("ΔTmax = %.1f °C \tΔHmax = %.1f %%\n", max_dTint, max_dHint);



if plot_comparison_ext_int
    dataset_ext = import_data_ext(file_temp_ext_dir + cell_number + "_" + initial_date(1) + "_" + type_measure, [2,Inf]);
    if istimetable(dataset_ext)
        subset_dataset_ext = dataset_ext(timerange(start,stop+1, 'closed'),:);
    
        disp("Data file ARPAE succefully readed")
    
        disp("################")
        disp("External")
        disp("################")
        fprintf("Mean:  T = %.1f °C    H = %.1f %%\n", mean(subset_dataset_ext.TAVG), mean(subset_dataset_ext.RHAVG));
        fprintf("Tmax = %.1f °C \tHmax = %.1f %% \n", max(subset_dataset_ext.TAVG),max(subset_dataset_ext.RHAVG));
        fprintf("Tmin = %.1f °C \tHmin = %.1f %% \n", min(subset_dataset_ext.TAVG), min(subset_dataset_ext.RHAVG));
        fprintf("ΔTmax = %.1f °C \tΔHmax = %.1f %%\n", max(subset_dataset_ext.TAVG) - min(subset_dataset_ext.TAVG), max(subset_dataset_ext.RHAVG) - min(subset_dataset_ext.RHAVG));
    end
end


if compute_stats
    data_set_max_daily = retime(data_set, 'daily', 'max');
    data_set_min_daily = retime(data_set, 'daily', 'min');
    data_set_avg_daiy = retime(data_set, 'daily', 'mean');
    disp('=========================')
    disp('Averages Computed')
    disp('=========================')
end



%% Plotting tools

% str2printEXT = sprintf("EXTERNAL\n" + ...
%     "<T> = %.1f °C    <H> = %.1f %%\n" + ...
%     "T_{max} = %.1f °C \tH_{max} = %.1f %% \n" +...
%     "T_{min} = %.1f °C \tH_{min} = %.1f %% \n" +...
%     "ΔT_{max} = %.1f °C \tΔH_{max} = %.1f %%", mean(data_set.Text), mean(data_set.Hext), +...
%     max(data_set.Text),max(data_set.Hext), +...
%     min(data_set.Text), min(data_set.Hext), +...
%     max_dText, max_dHext);


str2printINT = sprintf("INTERNAL\n" + ...
    "<T> = %.1f °C    <H> = %.1f %%\n" + ...
    "T_{max} = %.1f °C \tH_{max} = %.1f %% \n" +...
    "T_{min} = %.1f °C \tH_{min} = %.1f %% \n" +...
    "ΔT_{max} = %.1f °C \tΔH_{max} = %.1f %%", mean(data_set.Tint), mean(data_set.Hint), +...
    max(data_set.Tint),max(data_set.Hint), +...
    min(data_set.Tint), min(data_set.Hint), +...
    max_dTint, max_dHint);


if plotting(1) == 1
    % This part plot the results
    fig1 = figure(1);
    ax1 = axes(fig1);
    hold(ax1,'on');
    xlabel('Time')
    
    yyaxis left
    % plot(data_set.datetime,data_set.Text,'+-','LineWidth',1.5,'DisplayName',"Texternal",'Color',[0 0.7 0.8]);
    plot(data_set.datetime,data_set.Tint,'+-','LineWidth',1.5,'DisplayName',"Tinternal");
    ylabel('Temperature [°C]')
    yyaxis right
    % plot(data_set.datetime,data_set.Hext,'+-','LineWidth',1.5, 'DisplayName',"Hexternal",'Color',[0.7 0.6 0]);
    plot(data_set.datetime,data_set.Hint,'+-','LineWidth',1.5, 'DisplayName',"Hinternal");
    ylabel('Humidity [%]')
    
    set(ax1,'FontSize',font_size)
    hold(ax1,"off")
    box(ax1,"on")
       
    legend()

    % % Create textbox
    % annotation(fig1,'textbox',...
    % [0.175733836624081 0.138081273565144 0.103730449090205 0.10062840385421],...
    % 'String',{str2printEXT},...
    % 'FontSize', 14, ...
    % 'FitBoxToText','off');

    annotation(fig1,'textbox',...
    [0.771428571428571 0.136405529953917 0.101339285714286 0.100460829493088],...
    'String',{str2printINT},...
    'FontSize', 14, ...
    'FitBoxToText','off');

end

if plotting(2) == 1
    fig2 = figure(2);
    ax2 = axes(fig2);

    plot(data_set.datetime,data_set.VPD,'+-','LineWidth',1.5);
    xlabel('Time'); ylabel('VPD [kPa]')

    set(ax2,'FontSize',font_size)
    box(ax2,"on")
end


if plot_comparison_ext_int
    % Temperature: indoor vs outdoor
    fig3 = figure(3);
    ax3 = axes(fig3);
    box(ax3,'on')
    hold(ax3,'on')
    plot(data_set.datetime, data_set.Tint,'+-','LineWidth',1.5,'DisplayName','Internal')
    plot(subset_dataset_ext.Time, subset_dataset_ext.TAVG,'+-','LineWidth',1.5,'DisplayName','External')
    hold(ax3,'off')

    legend()
    ylabel('Temperature [°C]')
    set(ax3,'FontSize',font_size)
 

    % Humidity: indoor vs outdoor
    fig4 = figure(4);
    ax4 = axes(fig4);
    box(ax4,'on')
    hold(ax4, 'on')

    plot(data_set.datetime, data_set.Hint,'+-','LineWidth',1.5,'DisplayName','Internal')
    plot(subset_dataset_ext.Time, subset_dataset_ext.RHAVG,'+-','LineWidth',1.5,'DisplayName','External')
    hold(ax4,'off')
    legend()
    ylabel('Humidity [%]')
    set(ax4,'FontSize',font_size)

        
    %solar radiation vs indoor temperature
    fig5 = figure(5);
    ax5 = axes(fig5);
    box(ax5,'on');
    hold(ax5,'on');

    yyaxis left
    plot(subset_dataset_ext.Time, subset_dataset_ext.RAD,'+-','LineWidth',1.5)
    ylabel('Global Radiation Flux [W/m^2]')
    
    yyaxis right
    plot(data_set.datetime, data_set.Tint,'+-','LineWidth',1.5)
    ylabel('Indoor temperature [°C]')

    hold(ax5,'off');
    set(ax5,'FontSize',font_size)


end






%% Fit

% %using posixtime in seconds
% x = posixtime(data_set.datetime);
% x = x - x(1);

%using minutes
x1 = minutes(data_set.datetime - data_set.datetime(1));
y1= data_set.Tint;

x2 = minutes(subset_dataset_ext.Time - subset_dataset_ext.Time(1));
y2 = subset_dataset_ext.RAD;


figure, plot(x1,y1)






%% Functions

function [status] = control_date(initial_date, final_date)
%
% Function that control if the date are in good order or not
% 
% INPUT
%      iniatial_date = <array> with 3 component: [year month, day]
%      final_date = <array> with 3 component: [year month, day]
% OUTPUT
%       status = <logical>, 2 no errors different month,  
%                           1 no errors same month, 
%                           0 some errors
%


if final_date(1) == initial_date(1) && ...
   final_date(2) == initial_date(2) && ...
   final_date(3) >= initial_date(3)
   status = 1;

elseif final_date(1) == initial_date(1) && ...
       final_date(2) > initial_date(2)
       status = 1;
elseif final_date(1) > initial_date(1)
    status = 1;
else
    status = 0;
    error('Initial date has to be lower that final')
end

end


function data_set_ext = import_data_ext(filename, dataLines)
%IMPORTFILE Import data from a text file
%  DATA_SET_EXT = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a timetable.
%
%  DATA_SET_EXT = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  data_set_ext = importfile("/Volumes/FnP/Fish&Plants/data/TH_ext/01945_2025_h.csv", [2, Inf]);
%
%  See also READTIMETABLE.
%
% Auto-generated by MATLAB on 04-Jan-2026 08:30:04

% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 10);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Time", "TAVG", "PREC", "RHAVG", "RAD", "W_SCAL_INT", "W_VEC_DIR", "W_VEC_INT", "LEAFW", "ET0"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Time", "InputFormat", "yyyy-MM-dd HH:mm:ss", "DatetimeFormat", "preserveinput");

% Import the data
data_set_ext = readtimetable(filename, opts, "RowTimes", "Time");
end




