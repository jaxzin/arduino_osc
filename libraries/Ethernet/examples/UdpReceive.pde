#include <Ethernet.h>
#include <Udp.h>
/* UdpReceive.pde: Example how to receive packets over UDP 
 * prints received packet to serial port
 *
 * bjoern@cs.stanford.edu 12/29/2008
 */

/* ETHERNET CONFIGURATION *************************************/
/* ARDUINO: set MAC, IP address of Ethernet shield, its gateway,
 and local port to listen on for incoming packets */
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED }; //MAC address to use
byte ip[] = { 192, 168, 11, 200 }; // Arduino's IP address
byte gw[] = { 192, 168, 11, 1 };   // Gateway IP address
int localPort = 8888; //local port to listen on
/***************************************************************/

#define MAX_SIZE 32 //maximum packet size

byte packetBuffer[MAX_SIZE]; //buffer to hold incoming packet
int packetSize; //holds received packet size
byte remoteIp[4]; //holds recvieved packet's originating IP
int remotePort; //holds received packet's originating port

int i;


void setup() {
  Ethernet.begin(mac,ip,gw);
  Udp.begin(localPort);
  Serial.begin(9600); 
}

void loop() {  
  //if there's data available, read a packet
  if(Udp.available()) {
    packetSize = Udp.readPacket(packetBuffer,MAX_SIZE,remoteIp,(uint16_t *)&remotePort);
    if(packetSize <= MAX_SIZE) {
      
      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      
      Serial.print("From IP ");
      for(i=0; i<4; i++) {
        Serial.print(remoteIp[i],DEC);
        Serial.print(".");
      }
      
      Serial.print(" Port ");
      Serial.print((remotePort >> 8),DEC); //this doesn't work yet - should be unsigned
      Serial.println((remotePort & 0xFF),DEC); 
      
      Serial.println("Contents:");
      for(i=0; i<packetSize; i++) {
        Serial.print(packetBuffer[i],BYTE);
      }
      Serial.println("");
      
    } else {
      //PANIC - packet too long!
      // we've already clobbered mem past our buffer boundary
    }
  }
  //wait a bit
  delay(10);  
}
