function [ ] = plot_ADSB( ADSB_planes )
% A function which plots all of the ADS-B objects seen
global KEY_IS_PRESSED
persistent no_of_fn_calls Prescott_airport C_e__t start_time

if isempty(no_of_fn_calls)  % Is this the first call to this function?
    no_of_fn_calls = 1;     % set the var to not empty
    
    Lat_Prescott = 34.6498 * pi/180;    % Latitude of Prescott airport (rad)
    Lon_Prescott = -112.4272 * pi/180;  % Latitude of Prescott airport (rad)
    Height_Prescott = 1527.3;           % Altitude of Prescott airport (m)
    
    % ECEF coordinates of the Prescott airport [x, y, z]
    Prescott_airport = llh2xyz(Lat_Prescott, Lon_Prescott, Height_Prescott);
    
    % Rotation matrix: ECEF to Tangential (Navigation Frame)
    [C_e__t] = Lat_Lon_2C_e__n(Lat_Prescott, Lon_Prescott);
    
    start_time = ADSB_planes(1).TimeStamp;
        
    figure,
    scatter3(0, 0, 0);
    title(['ADS-B Objects in the Sky: t = ', num2str(ADSB_planes(1).TimeStamp-start_time, '%3.0f'), ' (sec)']);
    xlabel('North (m)')
    ylabel('West (m)')
    zlabel('Up (m)')
    hold on;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn);
end

%% Plot all of the ADS-B Objects in the sky
N = length(ADSB_planes);
if N > 2
    title(['ADS-B Objects in the Sky: t = ', num2str(ADSB_planes(1).TimeStamp-start_time, '%3.0f'), ' (sec)']);
    for k = 1: N
            Lat = ADSB_planes(k).lat * pi/180;     % Latitude  of obj (rad)
            Lon = ADSB_planes(k).lon * pi/180;     % Longitude of obj (rad)
            Hb  = ADSB_planes(k).altitude;         % Altitude of obj (m)

            if ((Lat ~= 0) && (Lon ~= 0) && (Hb ~= 0))  % Sometimes we get junk!!
                obj_xyz = C_e__t' * (llh2xyz(Lat, Lon, Hb) - Prescott_airport); % Obj local coordinates;
                if strfind(ADSB_planes(k).callsign', 'ICARUS')
                    scatter3(obj_xyz(1), -obj_xyz(2), -obj_xyz(3), 46, 'k', 'Marker', '*');  % Negative z/y-coord required (NED -> NWU)
                else
                    ADSB_color = ADSB_planes(k).ICAO(6:8);      % Use the last 3 characters of the ICAO
                    ADSB_color = [hex2dec(ADSB_color(1)),hex2dec(ADSB_color(2)),hex2dec(ADSB_color(3))]/15;
                    scatter3(obj_xyz(1), -obj_xyz(2), -obj_xyz(3), 36, ADSB_color);         % Negative z/y-coord required (NED -> NWU)
                end
            end
    end
end
end

function myKeyPressFcn(hObject, event)
global KEY_IS_PRESSED
KEY_IS_PRESSED  = true;
disp('Stopped collecting ADS-B data');
end