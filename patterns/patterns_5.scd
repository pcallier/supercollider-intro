//Server madness
(
s.boot;
s.status.postln;
s.plotTree;
)

//Freesound auth
(
Freesound.authType = "oauth2";
Freesound.clientId = "GMAA40PAVC8AFTG6jKEM";
Freesound.clientSecret = File("/home/patrick/src/supercollider-intro/freesound-token",
 "r").readAllString.stripWhiteSpace;

// Auth anew
//Freesound.getAuthorizationPage;
//Freesound.getToken("token");
// Or refresh old auth
Freesound.refreshToken;
)


// SynthDef
(
SynthDef.new(\sine,
  {
    arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
    var sig, env;
    sig = SinOsc.ar(freq);
    env = EnvGen.kr(Env.new([0, 1, 0], [atk, rel], [1, -1]),
      doneAction: 2);
    sig = Pan2.ar(sig, pan, amp);
    sig = sig * env;
    Out.ar(0, sig);
}).add;
)

// Patterns
(
Pdef(
  \sinepat,
  Pbind(
    \type, \note,
    \instrument, \sine,
    \dur, Pwhite(0.03, 0.13, inf),
    \midinote, Pseq([30], inf).trace,
    \harmonic, Pexprand(1, 10, inf).round.trace,
    \atk, Pwhite(0.005, 0.01, inf),
    \rel, Pwhite(0.2, 0.3, inf),
    \amp, Pkey(\harmonic).reciprocal * 0.5,
    \pan, Pwhite(-0.8, 0.8, inf),
  );
).stop;
)

// Load sounds
(
~snds = Dictionary.new;

[[13954, \tap], [13953, \tap2], [13955, \tap3]].do{
  |snd_info|
  var snd_id = snd_info[0],
      snd_tag = snd_info[1];
  FSSound.getSound(snd_id, {|f|
    f["name"].postln;
    f.retrieve("/home/patrick/Downloads/", {
    ~snds.add(snd_tag ->
      Buffer.read(s, "/home/patrick/Downloads/" ++ f.name))
    });
  });
};

)

(
p = Pbind(
    \degree, Ptuple([
        Pseries(7, -3, 8),
        Pseq([9, 7, 7, Rest, 4, 4, 2, 2], 1),
        Pseq([4, 4, 4, 2, 2, 0, 0, -3], 1)
    ], 1),
    \dur, 1
).play;
)
(
{PlayBuf.ar(1, 0)}.play;
{PlayBuf.ar(1, 1)}.play;
{PlayBuf.ar(1, 2)}.play;
)

(
SynthDef(\playbuf_test,
  {
    |out = 0, bufnum=0|
    var trig;
    trig = PinkNoise.ar(MouseX.kr(0.005, 0.009));
    Out.ar(out,
      PlayBuf.ar(1, bufnum, rate: BufRateScale.kr(bufnum) * MouseY.kr(0.6, 1.2), trigger: trig)
    )
  }
).play(s, [\out, 0, \bufnum, 2]);
)
{Logistic.ar(MouseX.kr(3,4.0), MouseY.kr(1,100).round(10).linexp(1,100,10,1000) , mul:0.25)!2}.scope(2);
p.next(())
(
SynthDef(\bass, { |freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var    sig,
        env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: 2);
    sig = LPF.ar(sig, ffreq);
    Out.ar(0, sig ! 2)
}).add;
)
(
TempoClock.default.tempo = 132/60;
p = Pxrand([
    Pbind(            // repeated notes
        \instrument, \bass,
        \midinote, 36,
        \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
        \legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,        // octave jump
        \midinote, Pseq([36, 48, 36], 1),
        \dur, Pseq([0.25, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,        // tritone jump
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
        \amp, 0.5, \detune, 1.005
    ),
    Pmono(\bass,        // diminished triad
        \midinote, Pseq([36, 39, 36, 42], 1),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
        \amp, 0.5, \detune, 1.005
    )
], inf).play(quant: 1);
)
0.1!7
~snds.at(\tap2).play;
p.stop
p.set(\midinote, 30);
{Pan2.ar(Gendy1.ar)}.play
play{f=LFPar.kr(0.22,0,100,150).round(50).lag;Gendy2.ar(6,6,0.5,0.01,f,f+[1,2],1/2,1/2,19,f/4)*SetResetFF.ar(Impulse.ar(4),Dust.ar(4)).lag}
{Pan2.ar(RLPF.ar(Gendy1.ar(2,3,minfreq:20,maxfreq:MouseX.kr(100,1000),durscale:0.0,initCPs:40),500,0.3,0.2),0.0)}.play

(
{
    var mx, my;

    mx= MouseX.kr(220,440);
    my= MouseY.kr(0.0,1.0);

    Pan2.ar(Gendy1.ar(2,3,1,1,minfreq:mx, maxfreq:8*mx, ampscale:my, durscale:my, initCPs:7, mul:0.3), 0.0)
}.play
)


(
{
    Pan2.ar(
        SinOsc.ar(
            Gendy1.kr(2, 4,
                SinOsc.kr(0.1,0,0.49,0.51),
                SinOsc.kr(0.13,0,0.49,0.51),
                3.4, 3.5,
                SinOsc.kr(0.17,0,0.49,0.51),
                SinOsc.kr(0.19,0,0.49,0.51),
                10,10,50, 350),
        0, 0.3),
    0.0)
}.play
)

play{a=0;6.do{x=Sweep.ar(Dust2.kr(0.1+2.0.rand),9.rand+9)+LFNoise1.kr(0.1,60,80);a=a+Pan2.ar(Gendy1.ar(1,1,1,1,x,x+9),LFNoise2.kr(1))};a}
play{LeakDC.ar(CompanderD.ar(LPF.ar(Normalizer.ar(CompanderD.ar(BrownNoise.ar!2,0.1,0.1,4)),LFDNoise3.kr(8,90,150)),0.1,1,0.5))}
