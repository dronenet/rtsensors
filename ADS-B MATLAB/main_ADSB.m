% Description:
%   This script will collect ADS-B data from a uAvionix PING USB receiver
%   and optionally plot, display on the screen, and write to a time-stamped
%   pair of files (one *.txt and the other *.mat).
%
% Author:  Stephen Bruder
%
% Versions:
% 1.0 07 Feb 2018
%   My still generate errors for malformed ADS-B streams, however, has
% some limited tollerance to source transmission errors.

clear all;  % Clear all variables in the workspace (including global vars)
close all;  % Close all figure windows
clc;        % Clear the Command Window
 
global ADSB_planes KEY_IS_PRESSED new_data  % Global Variables

KEY_IS_PRESSED = false;     % Initialize the globaal variable
ADSB_planes = struct('ICAO', '????????' , 'lat', [], 'lon', [], 'altitude', [], 'heading', [], ...
                     'hor_vel', [], 'vert_vel', [], 'callsign', '', 'tslc', [], 'TimeStamp', []);

Date_Time = clock;  % Obtain a date/time stamp to name files
Save_file_name = sprintf('adsb_data_%d_%02.0f_%02.0f_%02.0f_%02.0f_%02.0f',Date_Time(1), Date_Time(2),Date_Time(3),...
                                               Date_Time(4),Date_Time(5),round(Date_Time(6)));
fid = fopen([Save_file_name, '.txt'], 'w'); % Open the ADS-B data file for writing


%% Start - Configure the serial interface
delete(instrfindall);                       % Close all open Ports
pause(0.1);                                 % A "small" delay
serialInfo = instrhwinfo('serial');         % Query all available serial ports
comPort = serialInfo.AvailableSerialPorts;  % Determine available COM ports
s = serial(comPort(end), 'BaudRate', 57600);% Set BaudRate:Must be 57600 
s.InputBufferSize = 2^16;                   % Set a "large" input buffer
s.Parity = 'none';                          % See uAvionix documentation for Serial port config
s.StopBits = 1;
s.DataBits = 8;
s.BytesAvailableFcnCount = 2^10;
s.BytesAvailableFcnMode = 'byte';           % Can NOT use terminator for binary read!!
s.BytesAvailableFcn = @serialEventHandler;  % Define Serial port event handler (function)
fopen(s);                                   % Open the serial port object
flushinput(s);                              % Clear input buffers
% END - Configure the serial interface

%% Collect the ADS-B Data and store into an array of structures also plot and print
ADSB_history = [];                          % Initialize an array to contain all of the ADS-B data

fprintf(fid, ' Time    ICA0         Lat          Lon       Alt  Head  H_vel V_vel  Callsign TSLC\n');
%fprintf(fid, ' (sec)             (°)       (°)       (m)   (°)   (m/s) (m/s)          (sec)\n');

while ~KEY_IS_PRESSED                       % Print to the screen untill a key is pressed
    if length(ADSB_planes) >= 1             % Wait until the number of planes seen are greater than or eq 1
        if new_data                         % This gets set to true in the serial port event handler
            fprintf('\n\n Time    ICA0      Lat     Lon     Alt  Head  H_vel V_vel  Callsign TSLC\n');
            fprintf(    ' (sec)             (°)     (°)     (m)   (°)   (m/s) (m/s)          (sec)\n');
            
            for k = 1:length(ADSB_planes) 
                fprintf(     '%7.1f %s %7.2f %7.2f  %5.0f %5.1f  %5.1f %5.1f %s  %d\n', ADSB_planes(k).TimeStamp, ADSB_planes(k).ICAO, ...
                    ADSB_planes(k).lat, ADSB_planes(k).lon, ADSB_planes(k).altitude, ADSB_planes(k).heading, ...
                    ADSB_planes(k).hor_vel, ADSB_planes(k).vert_vel, ADSB_planes(k).callsign, ADSB_planes(k).tslc);  
                fprintf(fid, '%7.1f %s %12.7f %12.7f  %5.0f %5.1f  %5.1f %5.1f %s  %d\n', ADSB_planes(k).TimeStamp, ADSB_planes(k).ICAO, ...
                    ADSB_planes(k).lat, ADSB_planes(k).lon, ADSB_planes(k).altitude, ADSB_planes(k).heading, ...
                    ADSB_planes(k).hor_vel, ADSB_planes(k).vert_vel, ADSB_planes(k).callsign, ADSB_planes(k).tslc);
            end
            
            ADSB_history = [ADSB_history, ADSB_planes];     % Concatinate the array
            plot_ADSB( ADSB_planes );       % Function to plot the ADS-B data

            pause(0.2);
            fprintf('\nClick on the plot and enter any key to stop data collection!!\n')

            new_data = false;               % Reset the new data flag
            pause(0.2);                     % Check for new data every 0.2 sec
        end
    else
        fprintf(' Please wait - No ADS-B transmissions received \n');   % Wait for ADS-B data
        pause(1);       % Delay for 1 sec then try again
    end
end

fclose('all');      % This will also close earlier "aborted" instances not properly closed
fclose(s);          % Close the serial port object
save([Save_file_name, '.mat'], 'ADSB_history');     % Save ADS-B data to a binary (*.mat) file