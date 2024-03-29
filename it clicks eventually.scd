("Setup/Setup.scd").loadRelative



(
SynthDef.new(\fm1, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	iScale=5,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=0.2, pan=0,
	lsf=200, ldb=0, cutoff=1500, bits=24;
	var car, mod, env, iEnv, mod2, auto, trig, delay;
	iEnv =EnvGen.kr(
		Env.new(
			[index, index *iScale, index],
			[atk,rel],
			[cAtk,cRel]
		)
	);//envelope on index allows for more control of a single note shape, imitate acoustic
	env = EnvGen.kr(
		Env.perc(atk,rel,curve:[cAtk,cRel]),
		doneAction:2
	);
	// mod2 = SinOsc.ar(freq/10,mul:freq/10 * iEnv); //additive modulation
	mod = SinOsc.ar(freq * mRatio , mul:freq * mRatio * iEnv);
	//filter sound for clipping/distortion
	car = SinOsc.ar([freq,freq/2,freq/4] * cRatio + mod);
	car = BLowShelf.ar(car, lsf, 0.5, ldb);

	delay = -10.dbamp * BMoog.ar(DelayC.ar(car, 0.1, VarSaw.ar(30.reciprocal, [0, pi]).range(0, 0.05)),cutoff,0.5);
	delay = Decimator.ar(delay,44100,bits);

	car = car + delay;

	car = car * env * amp;
	car = -10.dbamp * Pan2.ar(car, pan);
	car = Splay.ar(car);
	car = LPF.ar(car,3500);
	car = LeakDC.ar(car);
	car =
	Out.ar(0,car);
}).add;
);

/////////////////////////////////////////////////////////////////
//testing

(Pbindef(\test,\instrument, \fm1,
	\dur,Pseq([0.25,0.25,0.125,0.25,0.125],inf),
	\degree,8+Pseq([[1,4,7],[1,3,8],[0,1,5],[0,-31]],inf),
				\root,-2,
				//\detune,a.reciprocal,
				\index,1,
				\iScale,4,//Pseg([1,0.5,1],60,\lin,inf),
				\cRatio,32,
				\mRatio,10,
				\atk,0.01,
				\rel,0.5,//Pseg([0.1,10],150,4,inf),
				\cAtk,4,
				\cRel,-6,
				\cutoff,3000,
				\bits,24,
				\amp, 0.5 * 0.4,
	\pan,Pkey(\degree).fold(0,8).linlin(0,8,-0.7,0.7).trace,
				\out,~bus[\nhhall],
))
Pbindef(\test).play;

/////////////////////////////////////////////////////////////////
//the routine

//Pfinval(7500=val) ~= 2min35sec
// the clicks start around 1min
( TempoClock.tempo = 1;
~a = Pfindur(165,
	Pspawn(
		Pbind(\method,\par,
			\delta,Pseg([0,1,1/2,1/4,2,1/2,1],[4,12,80,16,32,12],\step), //slow down at the end
			\pattern,{Pbind(\instrument, \fm1,
				\dur,a=Pseq((1..9).sputter),
				\degree,a,
				\root,-2 + Pseg([0,0,[0,12]],45,\step,inf),
				//\detune,a.reciprocal,
				\index,1500,
				\iScale,1,//Pseg([1,0.5,1],60,\lin,inf),
				\cRatio,Pseg([1,1,0.5,1.5,2],30,\step,inf),
				\mRatio,1000,
				\atk,0.065,
				\rel,Plprand(0.1,Plprand(1.5,10)),//Pseg([0.1,10],150,4,inf),
				\cAtk,4,
				\cRel,Phprand(-3,-12),
				\cutoff,Pseg([3000,5,500],180,\wel),
				\bits,Pwhite(1,24),
				\amp, Pseg([0.5,0.75,0.5],180,\wel)* Plprand(0.1,0.4),
				\pan,Pwhite(-0.7,0.7),//a.fold(0,4).linlin(0,4,-0.9,0.9),
				\out,~bus[\nhhall],
			)}
))).play)
~a.play;
~a.free;
~a.release;
~a.reject;


/////////////////////////////////////////////////////////////////
//testing

(
~numPartials = 50;
~bufAmps = Buffer.alloc(s, ~numPartials, 1);

SynthDef(\additive, {
	arg index=1, iScale=3, gate=1, time=1;

	var numPartials = ~numPartials;
	var bufAmps = ~bufAmps;
	var f0 = \freq.kr(68);
	var sig, mod;

	var iEnv = EnvGen.kr(Env([index, index * iScale, index], [\iAtk.kr(0.2), \iRel.kr(0.5)], \lin), gate, timeScale: time, doneAction: Done.none);
	var gainEnv = EnvGen.kr(Env.linen(\atk.kr(0.1), \sus.kr(0.5), \rel.kr(1), curve: \sine), gate, doneAction: Done.freeSelf);

	BufWr.ar(
		LFGauss.ar(
			duration: SampleDur.ir * numPartials * \factor.kr(1, 0.5).reciprocal,
			width: \width.kr(0.2, 0.5),
			iphase: LFTri.ar(\phaseModFreq.kr(0.5)).linexp(-1, 1, 1, 2),
		),
		bufnum: bufAmps,
		phase: Phasor.ar(end: numPartials)
	);

	mod = SinOsc.ar(f0 * \mRatio.kr(1), mul: iEnv);

	sig = Array.fill(numPartials, {|i|
		var freqs, partials;
		freqs = f0 * (i + (i * i * 0.05));
		partials = SinOsc.ar(
			freq: freqs * \cRatio.kr(1),
			phase: mod.wrap(0, 4pi),
			mul: Index.ar(bufAmps, i)
		) / numPartials;
	}).sum;

	sig = LeakDC.ar(sig);

	sig = sig * gainEnv;

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;



Pspawn(Pbind(\method,\par,\delta,4,\pattern,{Pbind(\instrument, \additive,\degree,a=Pseq([1,7,5,4,9,4,5]),\sus,1,\dur,Pseq([3,0.5,0.25,0.25,0.5,1,1],inf),\out,~bus[\nhhall],\rel,2)})).play//#SuperCollider