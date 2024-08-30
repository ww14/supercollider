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

(	SynthDef(\alarm, { |out=0, freq = 440| // changed
		var sig, filter, env;
		env = Env.perc(0.01, 0.25).kr;
	sig = BrownNoise.ar(10) * env;
		filter = { |source, freq = 440, bwr = 0.001, amp = 1|
			Resonz.ar(source, freq, bwr, amp)
		};
	sig = filter.(sig, freq, \bwr_1.kr(0.001), 9);
	FreeSelf.kr(TDelay.kr(env, \delay.kr(3)));
	sig = filter.(sig, freq, \bwr_2.kr(0.5));
	    sig = Pan2.ar(sig,\pan.kr(0));
	sig = LeakDC.ar(sig);
	sig = BLowPass4.ar(sig,1100,\rq.kr(1));
	sig = BBandPass.ar(sig,700,\bw.kr(1));
	OffsetOut.ar(out, sig*\amp.kr(1))
	}
).add;)


);



Synth(\gurgle_perc,[\dur,3,\dust,1e3]);


(Pdef.removeAll;
Pbindef(\t,\instrument,\gurgle_perc,
	\dur,Pseq([Rest(1),
		Pseq([Rest(0.5),Pwrand(
			[1.5,
			Pseq([0.5,0.5,0.5],1),
			Pseq([0.5,1],1),
		],[0.8,0.05,0.15],1)
		],inf),
	],1),
	\amp,8.dbamp,
	\dust,3e4);

/*\dur,Pseq([
Rest(1),
Pwrand([
Pseq([Rest(0.5),1.5],1),
Pseq([Rest(0.5),0.375,1.125],1),
Pseq([Rest(0.5),1.125,0.375],1),
Pseq([Rest(0.5),0.5,0.5,0.5],1)
],
[4,2,1,1].normalizeSum,inf)
],1),*/

Pbindef(\u,
	\instrument,\gurgle_perc,
	\dur,Pseq([Rest(1),1],inf),//Psubdivide(Pseq([1!4,1,1,1,2,1!8,1,1,1,2].flatten,inf),Pseq([Rest(1),1],inf)),
	\amp,-8.dbamp,\dust,1e4
);
Pbindef(\v,\instrument,\gurgle_perc,\dur,Pseq([2],inf),\amp,-10.dbamp,\dust,4.409e4,\noise,Pxrand([(1..10)].flatten,inf));
)
(Pbindef(\test,
		\instrument, \alarm,
		\bwr_1,7e-3,
		\bwr_2,5e-3,//0.25,
	\freq, ([45,57] + Pseq([
		Pseq([[2, 5, 10]],2),
		Pseq([[0, 3, 8]], 3),
		Pseq([[1, 4, 9]] ,2),
		Pseq([[2, 5, 10]] ,2),
		Pseq([[4, 7, 12]] ,3),
		Pseq([[3, 6, 11]],2),
	],inf)).midicps,
	\amp, -20.dbamp,
	\dur, Psubdivide(Pseq([1!2,3,2,1!2,3,2].flatten,inf),Pseq([4],inf)),//0.5*Pseq([1,2,1],inf),
	\pan,Pwhite(-0.1,0.1),
);


Pbindef(\fm1,
	\instrument,\fm1,
	\midinote,45+Pseg([0,2,0,1,2,4,3],[8,4,4,8,4,4],\step,inf)+Pseq([Rest(1),45,Rest(1),40,Rest(1),41,Rest(1),36,Rest(1),38,Rest(1),44],inf)+[-2,0,3,7,12],
	\dur,0.05*Pseq([Rest(1),2],inf),
	\rel,0.1,
	\atk,0.5,
	\iScale,0.1,
	\cRatio,30,
	\mRatio,20,
	\amp,-30.dbamp
);

)





t = TempoClock.default.tempo_(72/60);




Pbindef(\t).play(t,quant:8);
Pbindef(\u).play(t,quant:1);
Pbindef(\v).play(t,quant:5);
Pbindef(\test).play(quant:24);
//Pbindef(\fm1).play(quant:1);

//Pbindef(\fm1).stop;

Pbindef(\t).stop


Pbindef(\test,\amp,-6.dbamp);
Pbindef(\u,\amp,-8.dbamp);

Pbindef(\v,\dust,4.408e4);
Pbindef(\v,\noise,3);
Pbindef(\v,\dur,Pseq([8],inf));
Pbindef(\v,\dur,Pseq([Rest(1),1,Rest(1),1],inf));
Pbindef(\u,\dust,3.8e4,\dur,Pseq([0.5,1,0.25,Pwrand([Pseq([0.5]),Pseq([0.25,0.25])],[0.75,0.25],1),0.25,1.5],inf),\noise,Pwhite(40,60));
Pbindef(\t,\dur,Pseq([0.5,0.5,Rest(0.5),0.5,0.5,0.5,Rest(0.5),0.5],inf));
Pbindef(\t,\dur,Pseq([2],inf));
Pbindef(\u,\dust,8.9e1);
Pbindef(\u,\dust,3.8e2);
Pbindef(\u,\dust,3.8e4);


Pbindef(\t,\dust,Pwrand([2.9e4,3.1e4,2.3e4],[0.6,0.2,0.1],inf));
Pbindef(\t,\dust,3.1e4);
Pbindef(\t,\dur,Pseq([Rest(1),1,Rest(1),1],inf));
Pbindef(\t,\dust,2.45e4);
Pbindef(\v,\noise,20);
Pbindef(\v,\dust,4.408e1);