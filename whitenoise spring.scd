// https://sccode.org/1-5hv

(
SynthDef(\vink,{
var sig,env;

	env = Env.linen(0.1,\dur.kr(1),\rel.kr(1),50).kr(2);

	sig = WhiteNoise.ar;
	sig = BPF.ar(sig,\freq.kr(440),1e-4,env).tanh;
	sig = Friction.ar(sig, friction: 5.41322e-5, mass: 8.05501);
	sig = IIRFilter.ar(sig, freq: 600.0, rq:0.51, mul: 1.0, add: 0.0);
	sig = Pan2.ar(sig,\pan.kr(0));
	Out.ar(\out.kr(0),sig);


}).add;
)

(
Pbind(
	\instrument, \vink,
	\dur, 7+Pwhite(-2,2).round(1),
	\rel,Pwhite(1,3),
	\midinote,Pseq([
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[71,80],[69,80.5],[74,80],
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[74,80],[69,74],[61,68,73,80],[81,69,57]
	],1)
).play;
)