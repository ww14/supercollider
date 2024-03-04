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
	lsf=200, ldb=0;
	var car, mod, env, iEnv, mod2, auto, trig;
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
	car = SinOsc.ar(freq * cRatio + mod);
	car = BLowShelf.ar(car, lsf, 0.5, ldb);

	car = car + DelayC.ar(car, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.01));

	car = car * env * amp;
	car = Pan2.ar(car, pan);
	car = LeakDC.ar(Splay.ar(car));
	Out.ar(0,car);
}).add;
);


//Pfinval(7500=val) ~= 2min35sec
(~a = Pfindur(150,Pspawn(Pbind(\method,\par,\delta,Pseg([0,1/4,1/2,1],[120,15,15],\step),
	\pattern,{Pbind(\instrument, \fm1,
	\dur,a=Pseq((1..9).sputter),
	\sustain,1/a,
	\degree,a,
	\root,-2,
	//\detune,a.reciprocal,
	\index,1500,
	\iScale,1,//Pseg([1,0.5,1],60,\lin,inf),
	\cRatio,Pseg([50,1,50],60,\step,1),
	\mRatio,1000,
	\atk,0.06,
	\rel,Plprand(0.1,1),//Pseg([0.1,10],150,4,inf),
	\cAtk,4,
	\cRel,-12,
	\amp, Plprand(0.1,0.4),
	\pan,Pwhite(-0.7,0.7), //a.fold(0,4).linlin(0,4,-0.9,0.9),
	\out,~bus[\nhhall],
)}
))).play)
~a.play;
~a.free;
~a.release;
~a.reject;




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



Pspawn(Pbind(\method,\par,\delta,4,\pattern,{Pbind(\instrument, \additive,\dur,a=Pseq((1..9).lace),\sus,1/8/a,\degree,a,\out,~bus[\nhhall],\rel,2)})).play//#SuperCollider