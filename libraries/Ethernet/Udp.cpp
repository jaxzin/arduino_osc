/*
 *  Udp.cpp
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
#include "Udp.h"

void UdpClass::begin(uint8_t *ip, uint16_t port) {
	_ip = ip;
	_port = port;
	_sock = 0;
	socket(_sock,Sn_MR_UDP,8888,0);
}

uint16_t UdpClass::sendPacket(const uint8_t * buf, uint16_t len){
	return sendto(_sock,buf,len,_ip,_port);
}

/* is data available in rx buffer? 0 if no, non-zero if yes */
int UdpClass::available() {
	return getSn_RX_RSR(_sock);
}

/*
 * read a received packet into buffer buf; store calling ip 
 */
uint16_t UdpClass::readPacket(uint8_t * buf, uint16_t len, uint8_t *ip, uint16_t *port) {
	return recvfrom(_sock,buf,len,ip,port);
}

/* read a received packet, throw away peer's ip and port */
uint16_t UdpClass::readPacket(uint8_t * buf, uint16_t len) {
	uint8_t ip[4];
	uint16_t port[1];
	return recvfrom(_sock,buf,len,ip,port);
}

UdpClass Udp;
