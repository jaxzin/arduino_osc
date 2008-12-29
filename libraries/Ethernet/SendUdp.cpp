/*
 *  SendUdp.cpp
 *  
 *
 *  Created by Bjoern Hartmann on 12/28/08.
 *  Copyright 2008 Stanford Computer Science. All rights reserved.
 *
 */
extern "C" {
#include "types.h"
#include "w5100.h"
#include "socket.h"
}

#include "Ethernet.h"
#include "SendUdp.h"

void SendUdpClass::begin(uint8_t *ip, uint16_t port) {
	_ip = ip;
	_port = port;
	_sock = 0;
	socket(_sock,Sn_MR_UDP,8888,0);
}

uint16_t SendUdpClass::sendPacket(const uint8_t * buf, uint16_t len){
	return sendto(_sock,buf,len,_ip,_port);
}

SendUdpClass SendUdp;
