//******************************************************************************
//
// Dakota Burklund
// ADS-B for DroneNet
//
//******************************************************************************
//
//******************************************************************************
//
// standard libraries
#include <stdlib.h>
#include <stdio.h>
#include <time.h>



//global variables
int new_data
char* Data
int N

typedef struct {
    char* 'ICAO';
    float 'lat';
    float 'lon';
    float 'altitude';
    float 'heading'; 
    float 'hor_vel';
    float 'vert_vel';
    char* 'callsign';
    float 'tslc';
    float 'TimeStamp';
} ADSB_planes;


int main(void)
{
//******************************************************************************
// MAVLink frame  http://qgroundcontrol.org/mavlink/start
// Byte 	Content         Value       Explanation
//  1	Packet start    0xFE        Indicates the start of a new packet.
//  2	Payload length	0 - 255     Indicates length of the following payload.
//  3	Packet sequence	0 - 255     Each component counts up his send sequence. Allows to detect packet loss
//  4	System ID       1 - 255     ID of the SENDING system. Allows to differentiate different MAVs on the same network.
//  5	Component ID	0 - 255     ID of the SENDING component. Allows to differentiate different components of the same system, e.g. the IMU and the autopilot.
//  6	Message ID      0 - 255     ID of the message - the id defines what the payload “means” and how it should be correctly decoded.
//  7.. Data                        Data of the message, depends on the
//  message (payload) n-bytes
//  n+8  Checksum
//  n+9  Checksum
//******************************************************************************   

//get bits from serial connection
Data=...

char find='11111110';
Data = Data(find:NULL);

while( sizeof (Data)) >= 46*8){

Payload_length  = double(Data(2*8-1:3*8));
Message_ID      = double(Data(6*8-1:7*8));

clock_t Date_time = clock(NULL);


switch (Message_ID) {
    case 66:
    case 246:
    // NEED TO WORK THIS PART OUT AS THE THINGS HERE ARE BYTES AND BITS ARE NEEDED
        ICAO    = sprintf('%02X%02X%02X%02X',Data(10:-1:7));        // ICAO Address  (uint32) -> HEX string
        lat     = double(typecast(Data(11:14),  'int32'))*1e-7 ;    // Latitude  in ° (int32) * 1E7
        lon     = double(typecast(Data(15:18),  'int32'))*1e-7 ;    // Longitude in ° (int32) * 1E7
        altitude= double(typecast(Data(19:22),  'int32'))*1e-3 ;    // Altitude in m  (int32) * 1E3
        heading = double(typecast(Data(23:24), 'uint16'))*1e-2 ;    // Heading  in ° (uint16) * 1E2
        hor_vel = double(typecast(Data(25:26), 'uint16'))*1e-2 ;    // Horiz Vel in m/s (uint16) * 1E2
        vert_vel= double(typecast(Data(27:28),  'int16'))*1e-2 ;    // Vert  Vel in m/s (uint16) * 1E2

    case 203:
    case 202:
    case 201:
        printf('\nShould Not occur!!'\n);
    default:
        printf('\nNOT a valid uAvionix message: Payload length = %d  Message ID = %d \n', Payload_length, Message_ID);
}





















}

return(0);

}