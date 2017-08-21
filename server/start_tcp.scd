(

r=Server(name: \tcpHDMI,
	addr: NetAddr("127.0.0.1", 5700));
//r.protocol_(\tcp);
//r.addr.connect;
//r.startAliveThread( 0 );
r.options.protocol = \tcp;
r.doWhenBooted({ "connected".postln; r.notify; r.initTree; Server.default=r; });
r.boot;

)

(
x = {SinOsc.ar}.play;
x.free;

)

(
r.freeAll;
r.quit;

)
