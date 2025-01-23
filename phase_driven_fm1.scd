{ SinOsc.ar(800, SinOsc.ar(XLine.kr(1, 1000, 9), 0, 2pi), 0.25)!2 }.play;


(
SynthDef.new(\fm1, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	iScale=5,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=1, pan=0,
	lsf=200, ldb=0, hsf=100,hdb=0,phaseLen=8;
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
	phase = -6.dbamp * SinOsc.ar(XLine.kr(1,3,phaseLen), 0, 0.5pi);
	// mod2 = SinOsc.ar(freq/10,mul:freq/10 * iEnv); //additive modulation
	mod = SinOsc.ar(freq * mRatio , mul:freq * mRatio * iEnv);
	//filter sound for clipping/distortion
	car = SinOsc.ar(freq * cRatio + mod, phase );
	car = BLowShelf.ar(car, lsf, 0.5, ldb);
	car = BHiShelf.ar(car, hsf, 0.5,hdb);
	snd = MoogFF.ar(car, LFNoise2.kr(0.75).linexp(-1, 1, 500, 1600), 0);
	snd = snd * env * amp;
	snd = Pan2.ar(snd, pan);

	Out.ar(0,snd);
}).add;
);

TempoClock.default.tempo = 60/60;

Pbind(\instrument,\fm1, \dur,Pseq([3,3,2],inf), \rel,Pkey(\dur)*1.4,\phaseLen,Pkey(\dur)*1,\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,57,62],[54,50,62]],inf),\iScale,0.1,\index,1,\mRatio,Pwrand([[0.5,1,5],[1,2],[1,10]],[3,2,1].normalizeSum,inf),\cRatio,2).play;

Pbind(\instrument,\fm1, \dur,Pseq([2,1,2,2,1],inf)/8, \rel,Pkey(\dur)*1.4,\phaseLen,Pkey(\dur)*0.5,\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,50,62]],inf),\iScale,0.75,\index,2,\mRatio,[0.5,1],\cRatio,0.5).play;

Pbind(\instrument,\fm1, \dur,Pseq([2,1,1,1,2,1],inf)/8, \rel,Pkey(\dur)*1.1,\phaseLen,Pkey(\dur),\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,50,62]],inf),\iScale,1,\index,10,\mRatio,10,\cRatio,2).play


// a beat
o

(Pbind(\instrument,\fm1,
	\dur,Pseq([
		3,3,2,
		3,3,2,
		3,3,2,
		3,3,2,
		3,3,2,
		3,2,1,2]/8,inf),
	\atk,0.021,
	\rel,Pkey(\dur)*1.25,
	\phaseLen,Pkey(\dur)*0.51,
	\midinote,50,
	\iScale,50,
	\index,25, //15, 45
	\mRatio,15,
	\cRatio,Pwrand([0.6,6,24],[5,2,0.5].normalizeSum,inf),
	\amp,-6.dbamp,
	\lsf,150,
	\ldb,-8,
	\hsf,2500,
	\hdb,-8,
).play);


Pbind(\instrument,\fm1, \dur,Pseq([3,3,2],inf), \rel,Pkey(\dur)*1.4,\phaseLen,Pkey(\dur)*1,\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,57,62],[54,50,62]],inf),\iScale,0.1,\index,1,\mRatio,Pwrand([[0.5,1,5],[1,2],[1,10]],[3,2,1].normalizeSum,inf),\cRatio,2,\out,~bus[\reverb2]).play;

Pbind(\instrument,\fm1, \dur,Pseq([2,1,2,2,1],inf)/8, \rel,Pkey(\dur)*1.4,\phaseLen,Pkey(\dur)*0.5,\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,50,62]],inf),\iScale,0.75,\index,2,\mRatio,[0.5,1],\cRatio,0.5,\out,~bus[\reverb2]).play;


(Pbind(\instrument,\fm1,
	\dur,Pbjorklund2(9,16)/3,
/*	Pseq([
		3,3,2,
		3,3,2,
		3,3,2,
		3,3,2,
		3,3,2,
		3,2,1,2]/3,inf), */
	\atk,0.025,
	\rel,Pkey(\dur)*1.1,
	\phaseLen,Pkey(\dur)*0.51,
	\midinote,50,
	\iScale,25,
	\index,11, //7-12
	\mRatio,200,
	\cRatio,Pwrand([0.05,1,10],[5,2,0.5].normalizeSum,inf),
	\amp,1.dbamp,
	\lsf,1000,
	\ldb,-8
).play);