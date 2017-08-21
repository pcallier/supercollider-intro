s.boot; s.scope;
(
(3..8).choose.do{{
  BPF.ar(Saw.ar(SinOsc.ar(30, rrand(0, 1)).exprange(150, 500)),
    LFTri.kr(0.05, rrand(0, 1)).exprange(150, 600),
    LFTri.kr(1, rrand(0, 1)).exprange(0.05, 0.25),
  );
}.play;}
)

s.boot;
{f=[220,240,300,500,607,900]; DynKlang.ar(`[f, f.reciprocal.normalizeSum, nil])}.play;

f.reciprocal

{f=[700,1200,3000, 5000]; Formant.ar([140,280,420], f, [10,20,30])}.play;
(
{
  GrainSin.ar(
    freq: [440,560,670],
    trigger: Dust.kr(Stepper.kr(Dust.kr(0.5), Dust.kr(0.05), 5, 20, 5)),
    dur: 0.1, maxGrains: 20, mul: 0.2)}.play;
)

List.newUsing(Scale.major.ratios*220)