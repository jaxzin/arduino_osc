#include <Ethernet.h>
#include <Udp.h>
/* UdpSend.pde: Example how to send packets over UDP 
 * to check for received packets on Unix-ish setup, execute:
 * sudo tcpdump -ien0 "udp port 8000"
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

/* TARGET: set this to IP/Port of computer that will receive
 * UDP messages from Arduino */
byte targetIp[] = { 192, 168, 11, 15};
int targetPort = 8000;
/***************************************************************/

byte packet[] = { 'h','e','l','l','o' };
int packetLen = 5;

void setup() {
  Ethernet.begin(mac,ip,gw);
  Udp.begin(localPort);
}

void loop() {
  //send one packet a second
  delay(1000);
  Udp.sendPacket(packet,packetLen,targetIp,targetPort);
}
