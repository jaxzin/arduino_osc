Unfortunately, you cannot currently build all three UDP libraries simultaneously because of their different #includes. For example, if UdpString.cpp exists in your $ARDUINO/hardware/libraries/Ethernet directory, the examples for UdpRaw will not build, because their PDE files don't #include<WString.h>. 

Yes, this is confusing.

The workaround for now: Only copy one of the set of Udp*.h/.cpp files into $ARDUINO/hardware/libraries/Ethernet at a time and compile its examples. All example .pde files can co-exist in $ARDUINO/hardware/libraries/Ethernet/examples. You just can't compile them all at the same time.
