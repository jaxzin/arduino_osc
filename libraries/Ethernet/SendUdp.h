/*
 *  SendUdp.h
 *  
 *
 *  Created by Bjoern Hartmann on 12/28/08.
 *  Copyright 2008 Stanford Computer Science. All rights reserved.
 *
 */
#ifndef SendUdp_h
#define SendUdp_h

#include "Print.h"

class SendUdp {
private:
	uint8_t _sock;
	uint8_t *_ip;
	uint16_t _port;
public:
	void begin(uint8_t *, uint16_t);
	uint16_t sendPacket(const uint8_t *, uint16_t);
};

extern SendUdp Udp;

#endif
