#include <Ethernet.h>
#include <SendUdp.h>


/**************************************************************
 * ARDUINO_OSC_UDP 0001
 * based on ARDUINO_OSC 0005
 *
 * Firmware to send OSC messages from an Arduino board to a PC
 * over UDP using the Ethernet Shield.
 *
 * Right now, only messages with a single integer argument
 * are supported, and only sending is supported.
 *
 * Uses the standard OSC packet format (no serial wrapping)
 * 
 * PROTOCOL DETAILS
 * Digital pins 0..9 and analog inputs 0..5 are supported.
 * No output yet.
 * Below, the notation [0..9] means: any number from 0 to 9.
 * The notation [0|1] means: either 0 or 1.
 * Pin numbers are always part of the OSC address. 
 * The single integer argument for each OSC message
 * represents either HIGH/LOW, or an 8bit analog value.
 *
 * 
 * ARDUINO->PC PROTOCOL 
 * /in/[0..9] [0|1]    - a digital input pin changed to [high|low]
 * /adc/[0..5] [0..255] - analog input value changed to [0..255]
 * NOTE: input pins use pull-up resistors and are HIGH by default.
 * Therefore, 0 means HIGH, 1 means LOW (pulled to ground). 
 *
 *
 * EXAMPLES: ARDUINO->PC
 * /in/4 1              - digital input pin 4 pulled to ground
 * /adc/2 128           - analog input pin2 read 128 (=2.5V)
 * 
 * DEFAULT STARTUP CONFIGURATION
 *   - Pins 0..9 are all set to input, digital reporting enabled
 *     (change variable reportDigital to False to disable by default)
 *   - Analog reporting is disabled 
 *     (change variable reportAnalog to 0xFF to enable by default)
 *
 * NOTES:
 *   - Pins 10-13 cannot be used
 *   - Resolution on analog in and out is 8 bit.
 * 
 * MIT License:
 * Copyright (c) 2008 Bjoern Hartmann, Stanford HCI Group
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
 * bjoern@cs.stanford.edu 12/28/2008
 **************************************************************/

#define VERSION 1

#define MIN_A2D_DIFF 4  // threshold for reporting a2d changes
#define MAX_LENGTH 24   // size of buffer for building OSC msgs


#define FIRST_DIGITAL_PIN 0
#define LAST_DIGITAL_PIN 9
#define NUM_DIGITAL_PINS 10

#define FIRST_ANALOG_PIN 0
#define LAST_ANALOG_PIN 5
#define NUM_ANALOG_PINS 6


int k = FIRST_ANALOG_PIN;

int inputBuffer = 0xFFFF; // holds previous values of PORTB and PORTD (pins 0..7); start all high because of pull-ups
int a2dBuffer[6] = {0x00};   // holds previous A2D conversion values
char oscBuffer[MAX_LENGTH]={0x00}; // holds outgoing OSC message

unsigned int pinDir = 0x0000; //buffer that saves pin directions 0=input; 1=output; default: all in

char prefixReport[] = "/report/";
char prefixPinmode[] = "/pinmode/";
char prefixOut[] = "/out/";
char prefixPwm[] = "/pwm/";
char prefixIn[]="/in/";
char prefixA2d[]="/adc/";
char prefixReset[]="/reset"; //TODO: implement

char oscOutAddress[10]={0x00}; //string that holds outgoing osc message address

char* numbers[] = {"0","1","2","3","4","5","6","7","8","9","10","11","12"};

/* CONFIGURE ETHERNET INTERFACE HERE */
byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED }; //MAC address to use
byte ip[] = { 192, 168, 11, 200 }; // Arduino's IP address
byte gw[] = { 192, 168, 11, 1 };   // Gateway IP address

/* TARGET FOR UDP MESSAGES */
byte targetIp[] = {192,168,11,15};
int targetPort = 8000;

// which values should be reported? configured in setup()
byte reportAnalog; //bitmask - 0=off, 1=on - default:all off 
boolean reportDigital; //no per-pin reporting for analog

/* timer variables */
int a2dReportFrequency = 10; //report frequency for analog data in ms
unsigned long currentMillis=1;
unsigned long nextExecuteTime=0; // for comparison with timer0_overflow_count


/***********************************************
 * SETUP - open serial comm and initialize pins
 ***********************************************/
void setup() {
  int i;
  reportAnalog=0x01;
  reportDigital=true;

  // set pins 0..9 as inputs   
  for(i=FIRST_DIGITAL_PIN; i<=LAST_DIGITAL_PIN; i++) {
    pinMode(i,INPUT);
    digitalWrite(i,HIGH); // use pull-ups
  } 
  Ethernet.begin(mac,ip,gw);
  SendUdp.begin(targetIp,targetPort);
}

/***********************************************
 * LOOP - poll pin values and read incoming 
 * serial communication
 ***********************************************/
void loop() {

  // check all digital inputs
  if(reportDigital) {
    checkDiscreteInputs();
  }
	// check analog inputs every 10ms
	currentMillis = millis();
	if(currentMillis > nextExecuteTime) {  
		nextExecuteTime = currentMillis + (a2dReportFrequency -1); // run this every 10ms (arbitrary?)
		for(k=0;k<NUM_ANALOG_PINS;k++) {
			if(reportAnalog & (1<<k)) {
		    checkAnalogInput(k);
		  }
		}
	}
}

/***********************************************
 * Check all digital inputs and call 
 * oscSendMessageInt() if values has changed
 ***********************************************/
void checkDiscreteInputs() {
  int i;

  //read PORT B (13..8) and PORT D (pins 7..0) into one int
  unsigned int state = 0x0000 | (PINB << 8) | PIND;

  // if the state of a pin has changed since last time, 
  // and that pin is an input pin, send a message
  for(i=FIRST_DIGITAL_PIN;i<=LAST_DIGITAL_PIN;i++) {
    if(!(pinDir & (1<<i))) { //if pin is input
      if  ((state & (1<<i)) != (inputBuffer &(1<<i))) {
        strcpy(oscOutAddress,prefixIn);
        strcat(oscOutAddress,numbers[i]);
        oscSendMessageInt(oscOutAddress, !(state & (1<<i)));
      }
    }
  }

  //save current state to buffer
  inputBuffer= state;
}


/***********************************************
 * Check one analog input channel and call 
 * oscSendMessageInt() if its value has changed
 ***********************************************/
void checkAnalogInput(byte channel) {
  int result;
  int diff;
  // read a2d
  result = analogRead(channel) >> 2; //only use 8 MSBs

  // compare to last reading - if delta big enough,
  // send message
  //diff = result - a2dBuffer[channel];
  //if(diff>MIN_A2D_DIFF || diff<(int)((-1)*MIN_A2D_DIFF)) {
  if(result!=a2dBuffer[channel]) {
    a2dBuffer[channel]=result;
    strcpy(oscOutAddress,prefixA2d);
    strcat(oscOutAddress,numbers[channel]);
    oscSendMessageInt(oscOutAddress, result);
  }
}


/***********************************************
 * Send an OSC message with the passed in
 * address and a single integer argument
 ***********************************************/
void oscSendMessageInt(char * address, unsigned long value){
  byte offset=0;
  byte i=0;

  // clear buffer
  for(i=0; i<MAX_LENGTH; i++) {
    oscBuffer[i]=0x00;
  }

  //compute message length 
  //first compute address string length and padd if necessary
  byte addrlen = strlen(address);
  if(addrlen&0x03)				
    addrlen += 4-(addrlen&0x03);

  //then add type-tag length and arg length (both 4 for a simple int message)
  byte typetaglen=4;
  byte arglen = 4;

  //final length is sum of the three
  byte len = addrlen+typetaglen+arglen;


  //write address
  strcpy(oscBuffer+offset,address); 
  offset+=addrlen;

  //write typetag
  oscBuffer[offset++]=',';
  oscBuffer[offset++]='i';
  oscBuffer[offset++]=0x00;
  oscBuffer[offset++]=0x00;

  //write argument
  oscBuffer[offset++]=*(((unsigned char *)(&value))+3);
  oscBuffer[offset++]=*(((unsigned char *)(&value))+2);
  oscBuffer[offset++]=*(((unsigned char *)(&value))+1);
  oscBuffer[offset++]=*(((unsigned char *)(&value))+0);

  //send message as one packet
  for(i=0;i<offset;i++) {
		SendUdp.sendPacket((const byte *)oscBuffer,offset);
  }
}
