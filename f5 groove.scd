//https://gist.github.com/scztt/f889e72d11ddcfb0879dbff82d531747

Server.killAll;
("Setup/Setup.scd").loadRelative

Synth(\fm5);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
SynthDef(\moth_fm,
	{
		|amp=0.1,out=0,pan=0,carfreq=200,mod1freq=200,mod1amt=0.1,mod2freq=200,mod2amt=0.1,mod3freq=200,mod3amt=0.1,att=0.005,attCurve=0,dec=0.1,decCurve=0,hpfFreq=2000|
		var car, mod1, mod2, mod3, env, audio;
		env = EnvGen.kr(Env([0,1,0],[att,dec],[attCurve,decCurve]),1,amp,doneAction:2);
		mod3 = SinOsc.ar(mod3freq,0,mod3amt);
		mod2 = SinOsc.ar(mod2freq + (mod2freq * mod3), 0, mod2amt);
		mod1 = SinOsc.ar(mod1freq + (mod1freq * mod2), 0, mod1amt);
		car = SinOsc.ar(carfreq + (carfreq * mod1), 0, env);
		car = HPF.ar(car,hpfFreq);
		audio = Pan2.ar(car,pan);
		Out.ar(out,audio);
	}
).add;

SynthDef(\moth_snare,
	{
		|carfreq=200,mod1freq=200,mod1amt=0.1,mod2freq=200,mod2amt=0.1,mod3freq=200,mod3amt=0.1,jump=10,amp=0.1,out=0,pan=0,att=0.02,attCurve=2,dec=0.1,decCurve= -3,noiseHpfFreq=440,boost=5,overallHpfFreq=2000|
		var env, car, mod1, mod2, mod3, beatEnv, noise, noiseEnv, audio;
		env = EnvGen.kr(Env([0,1,0],[att,dec],[attCurve,decCurve]),1,amp);
		beatEnv = EnvGen.kr(Env([0,1,0],[0.005,0.02],[1,-2]),1,carfreq*jump);
		//beat = LFTri.ar(freq + beatEnv, 0, env);
		mod3 = SinOsc.ar(mod3freq,0,mod3amt);
		mod2 = SinOsc.ar(mod2freq + (mod2freq * mod3), 0, mod2amt);
		mod1 = SinOsc.ar(mod1freq + (mod1freq * mod2), 0, mod1amt);
		car = SinOsc.ar(carfreq + (carfreq * mod1) + beatEnv, 0, env);
		noiseEnv = EnvGen.kr(Env([0,1,0],[0.04,0.25],[-3,-9]),1,amp,doneAction:2);
		noise = WhiteNoise.ar(noiseEnv);
		noise = HPF.ar(noise,noiseHpfFreq);
		audio = car + noise;
		audio = (audio * boost).tanh / boost * amp;
		audio = HPF.ar(audio,overallHpfFreq);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;

SynthDef(\moth_kick,
	{
		|freq=50,amp=0.1,out=0,pan=0,att=0.01,dec=0.4,attCurve=2,decCurve= -2,freqAtt=0.01,freqDec=0.2,freqAttCurve=2,freqDecCurve= -2,freqJump=1,boost=10|
		var env, freqEnv, audio;
		env = EnvGen.kr(Env([0,1,0],[att,dec],[attCurve,decCurve]),1,amp,doneAction:2);
		freqEnv = EnvGen.kr(Env([0,1,0],[freqAtt,freqDec],[freqAttCurve,freqDecCurve]),1,freq*freqJump,freq);
		audio = SinOsc.ar(freqEnv,0,env);
		audio = (audio * boost).tanh / boost;
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
TempoClock.default.tempo = 1;


(
~w=1;~h=0.5;~q=0.25;~e=0.125;~t=0.3;~u=0.4;
);


(
Pdef(\hats);
Pdef(\hats,
	Ppar([
		Pbind(
			\instrument, \moth_kick,
			\freq,Pseq([1,\,\,\, \,\,\,\, 1,\,\,\, \,\,\,1],inf) * 30,
			//\freq, \,
			\dur, ~q,
			\amp, 1/4 * Pseq([1,\,\,\, \,\,\,\, 1,\,\,\, \,\,\,0.4],inf) * 0.1,
			\att,0.001,
			\dec,0.4,
			\attCurve,2,
			\decCurve,3,
			\freqAtt,0.001,
			\freqDec,0.2,
			\freqAttCurve,2,
			\freqDecCurve,-10,
			\freqJump, 10,
			\boost,4
		),
		Pbind(
			\instrument, \moth_snare,
			\amp, 1/4 * 0.1,
			\att, 0.004,
			\attCurve, 2,
			\dec, 0.14,
			\decCurve, -3,
			\amp, 1/2* 1,
			\dur, ~w,
			\freq, Pseq([\,1,\,1],inf) * 130,
			//\freq, \,
			\carfreq, Pseq([\,1,\,1],inf) * 130 * Pgauss(1,0.03,inf),
			\mod1freq, 414 * Pgauss(1,0.02,inf),
			\mod1amt, 0.6,
			\mod2freq, 200,
			\mod2amt, 0.7,
			\mod3freq, 50,
			\mod3amt, 0.8,
			\jump, 13,
			\timingOffset, Pbrown(-0.02,0.02,0.001,inf),
			\noiseHpfFreq, 1000,
			\boost, 8,
			\overallHpfFreq,500
		),
		Pbind(
			\instrument, \moth_fm,
			\amp, 0.1,
			\carfreq, 5000 * Pgauss(1,0.03,inf),
			\mod1freq, 883 * Pgauss(1,0.02,inf),
			\mod1amt, 0.6,
			\mod2freq, 283,
			\mod2amt, 0.7,
			\mod3freq, 487,
			\mod3amt, 0.8,
			\att, 0.003,
			\attCurve, 2,
			\dec, 0.3,
			\decCurve, -7,
			//\freq, \,
			\amp, 1/4 * Pseq([0.1,0.02,Pwrand([0,0.02],[9,11].normalizeSum)],inf) * Pgauss(1,0.08,inf),
			\dur, Pseq([~h * 1.05, ~q * 0.95, ~q * 0.95],inf),
			\timingOffset, Pbrown(-0.02,0.02,0.001,inf),
			\hpfFreq, 3000,
			\out,~bus[\reverb],
		),
		Pbind(
			\instrument, \moth_fm,
			\freqCoefficient, 3,
			\carfreq, 2000 * Pgauss(1,0.01,inf) * Pkey(\freqCoefficient),
			\mod1freq, 500 * Pgauss(1,0.02,inf) * Pkey(\freqCoefficient),
			\mod1amt, 0.1,
			\mod2freq, 700 * Pkey(\freqCoefficient),
			\mod2amt, 0.2,
			\mod3freq, 300 * Pkey(\freqCoefficient),
			\mod3amt, 0.8,
			\dur, Pseq([~h,~w,~q,~q, ~q,~q,~q,~q, ~q,~q,~q,~q],inf),
			\amp, 1/4 * Pseq([5,8,7,1, 3,1,5,1, 3,1,7,1],inf) / 140,
			\att, Pseq([1,4,1,1, 1,1,1,1, 1,1,1,1],inf) * 0.003,
			\attCurve, 2,
			\dec, Pseq([1,2,1,1, 1,1,1,1, 1,1,1,1],inf) * 0.3,
			\decCurve, -7,
			//\freq, \,
			\timingOffset, Pseq([1,2,7,7, 6,6,5,5, 4,4,3,2],inf) / 70 + Pbrown(-0.02,0.02,0.001,inf),
			\hpfFreq, 400,
			\out,~bus[\reverb],
		)
	])
);
);


(
Pdef(\fmBase, Pbind(
	\instrument, \fm5,

	// seed value
	// Each integer increment of the seed is a different random configuration for the
	// FM matrix. Non-integral values are cross-faded between adjacent integers (so 45.5 is
    // 50% of 45 and 50% of 46).
	// /seedDrift and /seedCurve affect how much the seed changes over the duration of the note.
	\seed, 53,
	\seedDrift, 0.3,
	\seedDriftCurve, 4,

	// freq offset of each operator, in hz
	\freqMin, -10,
	\freqMax, 10,
	\freqRound, 0,

	// freq multiplier for each op, where 0 is the fundamental, -1 is 1/2 fundamental.
	// 1 is 2x fundamental, 2 is 3x fundamental etc.
	\partialMin, 0,
	\partialMax, 2,

	// amount of the amp value for each slot in tbe matrix
	\matrixMin, 0,
	\matrixMax, 1,
	\matrixCurve, 1,

	// an extra amount to bump amp values for operator "feedback", e.g.
	// the amount the operator gets from itself
	\feed, 1,

	// env
	\attack, 0.01,
	\sustainLevel, 0.25,

	// randomly zero some matrix amp's, where 1 means none
	// and 0 means all of them
	\matrixCut, 0.8,


	\dur, 1/2,
	\legato, 2,
	\amp,0.2,


));
);



(
// slowed down
Pdef(\fm1, Pbind(
	\dur, Pbjorklund2(Pwrand([2,3],[0.8,0.2],inf), 8)/4,   //Pwrand([2,3],[0.8,0.2],inf)

	\sustainLevel, 0.25,

	\scale, Scale.dorian,
	\octave, Pseq([
		3,
		[3, 2,4,1]
	], inf),
	\strum, 1/Pwrand([2,4],[0.8,0.2],inf),

	\degree, Pstep(Pseq([0, [-3,4],[0,2],[4,6],[2,4]], inf), 8, inf),
	\degree, Pkey(\degree) + Pstep(
		Pseq([0, 2,4,2], inf),
		Pseq([1,1,1,1], inf)
	),

	\seed, 53 + Pseg([0, 0.1,0], [4]).repeat,
	\seedDrift, Pseg([0, 2,0], 100).repeat, //0.5
	\seedDriftCurve, Pseg([0, 100], 100).repeat,//Pseg([-4, 4, -4], [16, 16]).repeat,

	[\freqMin, \freqMax], Pwrand([
		[-0.2, 0.2],
		[-2, 2],
		[-4, 4],
		[-8,8]
	], [50,25,25,1].normalizeSum,inf),

	\partialMin, Pstep(
		Pseq([0, -1], inf),
		Pseq([5.5, 0.5], inf),
	),
	\partialMax, Pstep(
		Pseq([2, 3], inf),
		Pseq([7.5, 0.5], inf),
	\amp,2,

	),

) <> Pdef(\fmBase)
);
);
)


Pdef(\hats).play;

(
Pdef(\fm1).play(quant:1);
Pdef(\hats).play(quant:32);
)
(
Pdef(\fm1).stop;
Pdef(\hats).stop;
)

TempoClock.default.tempo = 1;


