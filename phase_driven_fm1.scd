{ SinOsc.ar(800, SinOsc.ar(XLine.kr(1, 1000, 9), 0, 2pi), 0.25)!2 }.play;


(
SynthDef.new(\fm1, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	iScale=5,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=0.2, pan=0,
	lsf=200, ldb=0, phaseLen=8;
	var car, mod, env, iEnv, mod2, phase,snd;
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
	phase = SinOsc.ar(XLine.kr(1,3,phaseLen), 0, 0.5pi);
	// mod2 = SinOsc.ar(freq/10,mul:freq/10 * iEnv); //additive modulation
	mod = SinOsc.ar(freq * mRatio , mul:freq * mRatio * iEnv);
	//filter sound for clipping/distortion
	car = SinOsc.ar(freq * cRatio + mod, phase );
	car = BLowShelf.ar(car, lsf, 0.5, ldb);
	snd = MoogFF.ar(car, LFNoise2.kr(0.75).linexp(-1, 1, 500, 1600), 0);
	snd = snd * env * amp;
	snd = Pan2.ar(snd, pan);

	Out.ar(0,snd);
}).add;
);

Pbind(\instrument,\fm1, \dur,Pseq([1.666,0.33,0.5,0.5],inf), \rel,Pkey(\dur)*1.4,\phaseLen,Pkey(\dur)*1,\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[48,50],[61,50,64],[57,62],[54,50,62]],inf),\iScale,0.1,\index,1,\mRatio,1,\cRatio,1).play