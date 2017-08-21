(

(
SynthDef(\boop,
  {
    arg freq, dur;
    var sig, env;
    sig = SinOsc.ar(freq: freq);
    env = EnvGen.kr(Env.perc(attackTime: dur), doneAction: 2);
    sig = sig * env;
    Out.ar(0, sig);
}).add;
);

(
SynthDef(\bloop,
  {
    arg freq, dur, amp=1.0;
    var sig, env, amp_parts, num_parts=20;
    sig = 0.0;
    amp_parts = (1..num_parts).collect{ |i|
      i.linexp(1, num_parts, 1.0, 0.01)
    };
    amp_parts = amp * amp_parts / amp_parts.sum;
    num_parts.do{ |i|
      sig = sig + (SinOsc.ar(freq: freq * i) *
        amp_parts[i])
    };
    env = EnvGen.kr(Env.perc(attackTime: dur), doneAction: 2);
    sig = sig * env;
    Out.ar(0, sig);
}).add;
);

  w = Window.new("GUI Intro",
  Rect(200, 200, 200, 200));
  v = TextView(w, Rect(0, 0, 200, 200));
  ~pressed = [];
  ~base = 110;
  v.keyDownAction_{|i, char, modifiers, unicode, keycode, key|
    var freq, step, new_base;
    key.post; ", ".post;
  step = ~keys.at(key).post;
  if (step.notNil,
    {
      freq = ~base * step;
      ", ".post; freq.post;
      Synth(\bloop, [\freq, freq, \dur, 0.01]);
  });

  "\nTop row:".post;
  new_base = ~toprow.at(key).post;
  if (new_base.notNil,
    {
      ~base = new_base;
  });
  "".postln;

  };
  v.editable = false;
  w.front;
)


~pressed.postln;

(~toprow = Dictionary[
1-> 110,
87->130,
69->150,
82->170,
84->190,
89->210,
85->220,
73->240,
79->260,
80->280
]
)
(~keys = Dictionary[
  65->1,
  83->2,
  68->3,
  70->4,
  71->5,
  72->6,
  74->7,
  75->8,
  76->9,
  59->10,
  39->11 ];
)

(

Synth(\boop, [\freq, 330,
  \dur, 0.09
]);
)

0.25.exp + 0.5.exp + 0.75.exp + 1.exp

(1..4).collect{|i| 1/i.exp}.sum
(1..5) / 5

s.boot;
s.scope
2.linexp(1.0, 40.0, 100.0, 0.0)