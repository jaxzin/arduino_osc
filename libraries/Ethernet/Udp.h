/*
 *  Udp.h
 *  
 *
 *  Created by Bjoern Hartmann on 12/28/08.
 *  Copyright 2008 Stanford Computer Science. All rights reserved.
 *
 */

#ifndef Udp_h
#define Udp_h

class UdpClass {
private:
	uint8_t _sock;  // socket ID for Wiz5100
	uint8_t *_ip;   // peer's IP address
	uint16_t _port; // peer's port
	
public:
	void begin(uint8_t *, uint16_t);				// initialize
	uint16_t sendPacket(const uint8_t *, uint16_t); // send a packet
	int available();								// has data been received?
	uint16_t readPacket(uint8_t *, uint16_t);		// read a received packet 
	uint16_t readPacket(uint8_t *, uint16_t, uint8_t *, uint16_t *);		// read a received packet 
};

extern UdpClass Udp;

#endif
