/*
 *  Udp.cpp: Library to send/receive UDP packets with the Arduino ethernet shield.
 *  Drop Udp.h/.cpp into the Ethernet library directory at hardware/libraries/Ethernet/ 
 *
 * MIT License:
 * Copyright (c) 2008 Bjoern Hartmann
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * bjoern@cs.stanford.edu 12/29/2008
 */

extern "C" {
#include "types.h"
#include "w5100.h"
#include "socket.h"
}

#include "Ethernet.h"
#include "UdpRaw.h"

/* Start UDP socket, listening at local port PORT */
void UdpRawClass::begin(uint16_t port) {
	_port = port;
	_sock = 0; //TODO: should not be hardcoded
	socket(_sock,Sn_MR_UDP,_port,0);
}

/* Send packet contained in buf of length len to peer at specified ip, and port */
/* Use this function to transmit binary data that might contain 0x00 bytes*/
/* This function returns sent data size for success else -1. */
uint16_t UdpRawClass::sendPacket(uint8_t * buf, uint16_t len,  uint8_t * ip, uint16_t port){
	return sendto(_sock,(const uint8_t *)buf,len,ip,port);
}

/* Send  zero-terminated string str as packet to peer at specified ip, and port */
/* This function returns sent data size for success else -1. */
uint16_t UdpRawClass::sendPacket(const char str[], uint8_t * ip, uint16_t port){	
	// compute strlen
	const char *s;
	for(s = str; *s; ++s);
	uint16_t len = (s-str);
	// send packet
	return sendto(_sock,(const uint8_t *)str,len,ip,port);
}
/* Is data available in rx buffer? Returns 0 if no, number of available bytes if yes. */
int UdpRawClass::available() {
	return getSn_RX_RSR(_sock);
}


/* Read a received packet into buffer buf (whis is of maximum length len); */
/* store calling ip and port as well. Call available() to make sure data is ready first. */
/* NOTE: I don't believe len is ever checked in implementation of recvfrom(),*/
/*       so it's easy to overflow buf. */
uint16_t UdpRawClass::readPacket(uint8_t * buf, uint16_t len, uint8_t *ip, uint16_t *port) {
	return recvfrom(_sock,buf,len,ip,port);
}

/* Read a received packet, throw away peer's ip and port.  See note above. */
uint16_t UdpRawClass::readPacket(uint8_t * buf, uint16_t len) {
	uint8_t ip[4];
	uint16_t port[1];
	return recvfrom(_sock,buf,len,ip,port);
}




/* Create one global object */
UdpRawClass UdpRaw;
