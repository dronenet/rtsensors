function serialEventHandler(serialConnection, event)
global ADSB_planes new_data

persistent Data  N      % Static storage class variables
if isempty(N)
     Data = uint8([]);  % Initialize the serial Data stream buffer
     N = 0;             % Number of planes
end

bytes = get(serialConnection, 'BytesAvailable');
if bytes > 0            % we may have alread read the data
    Data = uint8(fread(serialConnection, bytes));   % Read the serial data (binary read)
end
        
%% MAVLink frame  http://qgroundcontrol.org/mavlink/start
% Byte 	Content         Value       Explanation
%   1	Packet start    0xFE        Indicates the start of a new packet.
%   2	Payload length	0 - 255     Indicates length of the following payload.
%   3	Packet sequence	0 - 255     Each component counts up his send sequence. Allows to detect packet loss
%   4	System ID       1 - 255     ID of the SENDING system. Allows to differentiate different MAVs on the same network.
%   5	Component ID	0 - 255     ID of the SENDING component. Allows to differentiate different components of the same system, e.g. the IMU and the autopilot.
%   6	Message ID      0 - 255     ID of the message - the id defines what the payload “means” and how it should be correctly decoded.
%   7.. Data                        Data of the message, depends on the
%   message (payload) n-bytes
%  n+8  Checksum
%  n+9  Checksum        
        
% Find the start of  MAVLink data packet = first occurance of a 0xFE = 254 = 'þ' (start packet)
i = find(254 == Data, 1, 'first');      % Index of Packet start
Data = Data(i:end);     % Truncate the Data to begin with the MAVLink Packet Start Byte

while length(Data) >= 46  % The Message ID 246 has a minimum payload length of 38 + 8 (MavLink) = 46

% Extract the MAVLink metadata
    Payload_length  = double(Data(2));
    Message_ID      = double(Data(6));
    %fprintf('Payload_length = %d  and  Message_ID = %d\n', Payload_length, Message_ID);
    t_stamp = clock;    % A crude timestamp: year month day hour min sec.sec
    t_stamp = t_stamp(4)*3600+t_stamp(5)*60+t_stamp(6); % Convert to seconds elapsed today
    
% Extract the payload    
    switch Message_ID
        case 66         % DataStream Request: Length = 6
            %fprintf('\nDataStream Request: Payload length = %d  Message ID = %d \n', Payload_length, Message_ID);
            
        case 246        % Traffic Report: Length = 38
            %fprintf('\nTraffic Report:     Payload length = %d  Message ID = %d \n', Payload_length, Message_ID);
            ICAO    = sprintf('%02X%02X%02X%02X',Data(10:-1:7));        % ICAO Address  (uint32) -> HEX string
            lat     = double(typecast(Data(11:14),  'int32'))*1e-7 ;    % Latitude  in ° (int32) * 1E7
            lon     = double(typecast(Data(15:18),  'int32'))*1e-7 ;    % Longitude in ° (int32) * 1E7
            altitude= double(typecast(Data(19:22),  'int32'))*1e-3 ;    % Altitude in m  (int32) * 1E3
            heading = double(typecast(Data(23:24), 'uint16'))*1e-2 ;    % Heading  in ° (uint16) * 1E2
            hor_vel = double(typecast(Data(25:26), 'uint16'))*1e-2 ;    % Horiz Vel in m/s (uint16) * 1E2
            vert_vel= double(typecast(Data(27:28),  'int16'))*1e-2 ;    % Vert  Vel in m/s (uint16) * 1E2
            try
                callsign= char(Data(34:42));                                % Callsign (char(9))
            catch
                callsign= char(Data(34:end));
            end
            try
                tslc    = typecast(Data(44), 'uint8');                      % Time since last communication in sec
            catch
                disp('Data missing in ADSB-transmit message');
            end
            
            % Check to see if this is an existing aircraft
            if any(strcmp({ADSB_planes.ICAO},  ICAO))
                k = find(strcmp({ADSB_planes.ICAO},  ICAO), 1, 'first');
            else
                N = N + 1;
                k = N;
            end
            
            % Update the array of structures containing the ADS-B list of planes
            ADSB_planes(k).ICAO     = ICAO;
            ADSB_planes(k).lat      = lat;
            ADSB_planes(k).lon      = lon;
            ADSB_planes(k).altitude = altitude;
            ADSB_planes(k).heading  = heading;
            ADSB_planes(k).hor_vel  = hor_vel;
            ADSB_planes(k).vert_vel = vert_vel;
            ADSB_planes(k).callsign = callsign;
            ADSB_planes(k).tslc     = tslc;
            ADSB_planes(k).TimeStamp= t_stamp; % in sec
            
            new_data = true;
                
            % Remove ADS-B reports that are too "old" - Optional
%             old = 30; % Maximum allowable time since last report => "old"
%             ii = find([ADSB_planes.tslc] > old)
%             ADSB_planes(ii) = [];       % Remove the "old" array elements
            
        case 203        % Status: Length = 1
            %fprintf('\nStatus: Payload length = %d  Message ID = %d \n', Payload_length, Message_ID);
            
        case 202        % Ownship: Length = 42
            %fprintf('\nOwnship: Payload length = %d  Message ID = %d \n', Payload_length, Message_ID);
            
        case 201        % Static
            fprintf('\nShould Not occur!!'\n);
            
        otherwise
            fprintf('\nNOT a valid uAvionix message: Payload length = %d  Message ID = %d \n', Payload_length, Message_ID);
    end
    % MAVLINK metadata = 6 Bytes + CheckSum = 2 Bytes + Payload
    Data = Data(Payload_length + 6 + 2 + 1:end);     % Truncate the Data
end

end