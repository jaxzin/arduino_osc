/*
 *  Udp.h: Library to send/receive UDP packets with the Arduino ethernet shield.
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

#ifndef Udp_h
#define Udp_h

class UdpClass {
private:
	uint8_t _sock;  // socket ID for Wiz5100
	uint16_t _port; // local port to listen on
	
public:
	void begin(uint16_t);				// initialize, start listening on specified port
	uint16_t sendPacket(uint8_t *, uint16_t, uint8_t *, uint16_t); //send a packet to specified peer 
	uint16_t sendPacket(const char[], uint8_t *, uint16_t);  //send a string as a packet to specified peer
	int available();								// has data been received?
	uint16_t readPacket(uint8_t *, uint16_t);		// read a received packet 
	uint16_t readPacket(uint8_t *, uint16_t, uint8_t *, uint16_t *);		// read a received packet, also return sender's ip and port 
};

extern UdpClass Udp;

#endif
