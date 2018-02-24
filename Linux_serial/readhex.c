#include <stdio.h>
#include <stdlib.h>

void main(int argc, char** argv)
{
    FILE *fp, *logfp;
    unsigned char buffer[80];

    if (argc == 3)
    {
        printf("Will read from %s\n", argv[1]);
        fp=fopen(argv[1], "r");
        printf("Will log to %s\n", argv[2]);
        logfp=fopen(argv[2], "w");
    }
    else
    {
        printf("Will use ttyUSB0\n");
        fp=fopen("/dev/ttyUSB0", "r");
        printf("Will use ADSB_log.bin\n");
        logfp=fopen("ADSB_log.bin", "w");
    }

    if(fp == (FILE *)0)
    {
        perror("opening device or ttyUSB0");  
        exit(-1);
    }

    if(logfp == (FILE *)0)
    {
        perror("opening log file");  
        exit(-1);
    }
   
    while(1)
    {
        fread(buffer, 1, 1, fp);
        printf("%X", buffer[0]);
        fwrite(buffer, 1, 1, logfp); 
    } 

    fclose(fp);
    fclose(logfp);
}
