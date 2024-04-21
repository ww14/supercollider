// https://sccode.org/1-5hv

(
SynthDef(\vink,{
var sig,env;

	env = Env.linen(0.1,\dur.kr(1),\rel.kr(1),\curve.kr(50)).kr(2);

	sig = WhiteNoise.ar;
	sig = BPF.ar(sig,\freq.kr(440),1e-4,env).tanh;
	sig = Friction.ar(sig, friction: 5.41322e-5, mass: 8.05501);
	sig = IIRFilter.ar(sig, freq: 600.0, rq:\rq.kr(0.51), mul: 1.0, add: 0.0);
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(1));
	Out.ar(\out.kr(0),sig);


}).add;
)
(
SynthDef(\gurgle_perc,{
	var snd, duration, trigger,env;
	duration = \dur.kr(3.0);
	env = Env.perc.ar;
	trigger = Dust.ar(\dust.kr(100) * (1+env));
	snd = Latch.ar(WhiteNoise.ar,trigger);
	snd = BPF.ar(
		snd,
		[400,3500,4240]*TExpRand.ar(0.6,1.2,snd!3)*(LFNoise2.kr(16!3)*10).midiratio * ((env-1)*\noise.kr(125)).midiratio,
		env.linexp(0,1,0.03,0.2)
	) *8.dbamp;
	snd = snd.sum;
	snd = snd * (1+ SinOsc.ar(20*(1+env)));
	snd = BHiShelf.ar(snd,1200,0.3,5);
	snd = snd.fold2;
	snd = BHiShelf.ar(snd,1200,0.3,-5);
	snd = snd + PitchShift.ar(snd,0.03,1+(0.3*env));
	snd = snd + PitchShift.ar(snd,0.012,0.5+env);
	snd = FreqShift.ar(snd,env.linlin(0,1,0,\downshift.kr(-30)));
	snd = snd.tanh;
	snd = snd + CombC.ar(snd * -10.dbamp,0.1,1/(60 * (1+env)),0.15);
	snd = FreqShift.ar(snd,env.linlin(0,1,0,\upshift.kr(30)));
	snd = snd.tanh;
	snd = snd * Env.linen(0.01,duration,0.1,curve:-4).ar(Done.freeSelf);
	snd = snd * -7.dbamp;
	snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	Out.ar(\out.kr(0),snd);s
}).add;

)

(
SynthDef(\gurgle,{
	var snd, duration, trigger,env;
	duration = \dur.kr(3.0);
	env = Env([0,0.9,0,1,0],[1,2,1,5].normalizeSum*duration,\sine).ar;
	trigger = Dust.ar(\dust.kr(100) * (1+env));
	snd = Latch.ar(WhiteNoise.ar,trigger);
	snd = BPF.ar(
		snd,
		[400,3500,4240]*TExpRand.ar(0.6,1.2,snd!3)*(LFNoise2.kr(16!3)*10).midiratio * ((env-1)*\noise.kr(125)).midiratio,
		env.linexp(0,1,0.03,0.2)
	) *8.dbamp;
	snd = snd.sum;
	snd = snd * (1+ SinOsc.ar(20*(1+env)));
	snd = BHiShelf.ar(snd,1200,0.3,5);
	snd = snd.fold2;
	snd = BHiShelf.ar(snd,1200,0.3,-5);
	snd = snd + PitchShift.ar(snd,0.03,1+(0.3*env));
	snd = snd + PitchShift.ar(snd,0.012,0.5+env);
	snd = FreqShift.ar(snd,env.linlin(0,1,0,\downshift.kr(-30)));
	snd = snd.tanh;
	snd = snd + CombC.ar(snd * -10.dbamp,0.1,1/(60 * (1+env)),0.15);
	snd = FreqShift.ar(snd,env.linlin(0,1,0,\upshift.kr(30)));
	snd = snd.tanh;
	snd = snd * Env.linen(0.01,duration,0.1,curve:-4).ar(Done.freeSelf);
	snd = snd * -7.dbamp;
	snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	Out.ar(\out.kr(0),snd);s
}).add;

)

Synth(\gurgle_perc,[\dur,1,\dust,1e3]);



Pbind(\instrument,\gurgle,
	\dur,Pseq([Rest(1),5],inf),
	\amp,-9.dbamp,
	\noise,50,
	\dust,10,
	\downshift,Pseg([-30,-150,-6].mirror,[20,10,10,20],\sin,inf),
	\upshift,Pseg([30,150,6].mirror,[20,10,10,20],\sin,inf),
).play;

Pbind(\instrument,\gurgle,\dur,Pseq([Rest(1),1],inf),\amp,Pseg([-100,-12,-6].mirror.dbamp,[20,10,10,20],\sin,inf)).play;

Pdef.removeAll;

Pbind(\instrument,\gurgle,\dur,Pseq([Rest(1),Pseq([Rest(0.5),1.5],inf)],1),\amp,-8.dbamp,\dust,8).play;
Pbindef(\t,\instrument,\gurgle_perc,\dur,Pseq([Rest(1),Pseq([Rest(0.5),1.5],inf)],1),\amp,8.dbamp,\dust,3e4);
Pbindef(\u,\instrument,\gurgle_perc,\dur,Pseq([Rest(1),1],inf),\amp,-8.dbamp,\dust,1e4);
Pbindef(\v,\instrument,\gurgle_perc,\dur,Pseq([2],inf),\amp,-10.dbamp,\dust,4.409e4,\noise,Pxrand([(1..10)].flatten,inf));

Pbindef(\t).play(quant:1);Pbindef(\u).play(quant:1);Pbindef(\v).play(quant:1);
Pbindef(\u,\amp,0);
Pbindef(\u,\amp,-8.dbamp);

Pbindef(\v,\noise,Pxrand([(1..10)].flatten,inf));

u.stop

Pbind(\instrument,\gurgle_perc,\dur,Pbjorklund2(5,8,inf)/4,\dust,1e3,\downshift,-100,\upshift,100).play;



(a = [
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[71,80],[69,80.5],[74,80],
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[71,80],[69,78],[68,80],
		[73,81],[74,80],[69,74],[61,68,73,80],[81,69,57]
	]
);

Pbind(
	\instrument, \vink,
	\dur, 7+Pwhite(-2,2).round(1),
	\rel,Pwhite(1,3),
	\midinote,Pseq(a,1),
	\amp,-2.dbamp
).play;


(Pbind(
	\instrument, \vink,
  \degree, Pclump(Pseq([3, 3, 4, 2, 4, 2, 4], inf), Pseq([1, 3, 5, 7, 9], inf), inf),
	\dur, 1/8,
	\rel,1/8,
	\curve,2,
	\rq,Pwhite(0.1,0.2),
	\amp, 10.dbamp
).play;
);


Pbind(
	\instrument, \vink,
	\dur, 1,
	\rq,2.1,
	\rel,0.1,
	\midinote,Pclump(Pseq([3, 3, 4, 2, 4, 2, 4], inf), Pseq([a].flatten, inf), inf), //Pseq([a.reverse,a.sputter,a.scramble,a.lace,a.pyramidg].flatten,inf),
	\amp,0.dbamp
).play;

