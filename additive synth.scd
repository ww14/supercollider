(
//~bus = Bus.audio(s,2);
Server.killAll;
("Setup/Setup.scd").loadRelative;
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////)
// enveloped


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

SynthDef(\twotube,{arg preamp=0, delay1=100, delay2=50, k=0.0, loss=0.999, dur=0.5, pan=0.0, out=0, amp=1, minCf=30, maxCf=6000, minBpfHz=0.02, maxBpfHz=0.25,minRq=0.005, maxRq=0.04;
		var sig, env, senv;

		//k from -1 to 1

		senv = EnvGen.ar(Env([1,1,0,0],[(delay1+delay2)/SampleRate.ir,0.0,1.0]));
		sig = WhiteNoise.ar(preamp) * senv;


		env = EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2);
		sig = TwoTube.ar(sig,k,loss,delay1,delay2);
		//sig = Compander(sig);

		sig = BPF.ar(
			sig,
			LFNoise1.kr({LFNoise1.kr(0.13).exprange(minBpfHz,maxBpfHz)}!8).exprange(minCf, maxCf),
			LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(minRq, maxRq)
		);

		sig = sig * env *amp;
		sig = Pan2.ar(sig,pan);

		Out.ar(out,sig);
	}).add;



)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
Pdef(\additive,
	Pbind(
		\instrument, \additive,

		//\freq,Pstep([68,68,30,40],[70,70,30,40],inf), //[20.midicps,6.midicps,12.midicps,6.midicps]

		\dur,Pstep([1/4,1,1/4,1/3,1/2,1],[10,10,5,10,5,10],inf),

		\width, 0.20,
		\phaseModFreq, 0.5, //0.5 or 0.05

		\atk, 1.5,
		\sus, 2,
		\rel, 2.5,

		\time, Pfunc { |ev| ev.use { ~sustain.value } / thisThread.clock.tempo },

		//Phase Modulation
		\iAtk, 2.5,
		\iRel, 2.5,
		\mRatio, 1.96417,
		\cRatio, 2.28158,
		\index, 0.9,
		\iScale, 10,

		\amp, 0.30,
		\out, 0,
	)
).play;
)

~sustain = 0.1;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
//Pdef.removeAll;
//c=TempoClock(60/60);

(
Pbindef(\additive_env,
	\instrument, \additive,
	//\freq, 30,// Pstep([45.midicps,33.midicps,45.midicps,33.midicps],[70,70,30,40]/4,inf), //30
	\phaseModFreq,1,//Pstep([1,0.1,1/4,1/3,1/2,0.1],[40,10,5,10,5,10]/4,inf),//Pseg([0.01,1,0.01],70,\exp,inf),
	\dur,4,//Pstep([1/4,6,1/4,1/3,1/2,10],[40,10,5,10,5,10]/4,inf),//Pseq([Pseq([2,1,2,4]/2, 8),Pseq([2,1,2,4].reverse/4, 8),8,Pseq([1]/8, 32)],inf),
	\cRatio, 2.296417,
	\mRatio, 0.051,
	//\factor,40,
	//\time, Pfunc { |ev| ev.use { ~sustain.value } / thisThread.clock.tempo },
	\width,0.25,//Pstep([0.051,0.12,0.051,0.01],[16,8,4,4],inf), //0.01,//
	\amp,-10.dbamp,
	\freq,60,//Pwrand([60,67,65,72],[4,2,1,1].normalizeSum,inf)

));



//old school
(
Pbindef(\oldschool,\instrument, \twotube,
	\dur,1/10,//Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/6,3),inf),
	\k, 0.5,
	\preamp,Pseq([1,2].mirror*100,inf),
	\amp,-65.dbamp,
	\minRq,0.2,
	\maxRq,0.21,
	\minBpfHz,1/300,
	\maxBpfHz,100, //31
	\minCf,100,
	\maxCf,4001,
	\pan,0,
	\delay1,1,
	\delay2,2,
	\out,0,
);
)



/*
a=Pbind(
	\instrument, \snare,
	\dur, Pstep([1/2,1/4],70,inf),
	\sus, 0.01,
	\amp,-40.dbamp
);
b=Pbind(
	\instrument, \snare,
	\dur, 1,

	//\sus, Pseq([0.02, 0.01],inf), // single
	//\sus, Pseq([0.02, 0.01, 0.01],inf), // double
	//\sus, Pseq([0.02, 0.01, 0.01, 0.01],inf), // triple
	\sus,Pstep([Pseq([0.02, 0.01],inf),Pseq([0.02, 0.01, 0.01],inf),Pseq([0.02, 0.01, 0.01, 0.01],inf)],[70,70,70],inf),
	\pan,Pwhite(0,1),
	\amp,-40.dbamp,
	\out,0
); */
);


(
c=TempoClock(60/60);
Pbindef(\additive_env).play(c,quant:8);
Pbindef(\oldschool).play(c,quant:1);

//Ppar([a, b]).play(c,quant:1);
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// vocal
(
Pbindef(\additive_env,
	\instrument, \additive,
	//\freq, 30,// Pstep([45.midicps,33.midicps,45.midicps,33.midicps],[70,70,30,40]/4,inf), //30
	\phaseModFreq,1,//Pstep([1,0.1,1/4,1/3,1/2,0.1],[40,10,5,10,5,10]/4,inf),//Pseg([0.01,1,0.01],70,\exp,inf),
	\dur,0.25,//Pstep([1/4,6,1/4,1/3,1/2,10],[40,10,5,10,5,10]/4,inf),//Pseq([Pseq([2,1,2,4]/2, 8),Pseq([2,1,2,4].reverse/4, 8),8,Pseq([1]/8, 32)],inf),
	\cRatio, 1.96417,
	\mRatio, 0.04,
	\factor, 24,
	\time, Pfunc { |ev| ev.use { ~sustain.value } / thisThread.clock.tempo },
	\width,Pstep([0.051,0.12,0.051,0.01],[16,8,4,4],inf), //0.01,//
	\amp,-10.dbamp,
	\freq,50,//Pwrand([60,67,65,72],[4,2,1,1].normalizeSum,inf)

));

