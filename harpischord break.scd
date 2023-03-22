(
~bus = Bus.audio(s,2);

SynthDef(\reverb_ef, {
		arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);

		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		12.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};

		//dry/wet mix
		totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
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

SynthDef(\technokick, {
	| freq=51.913087197493, amp=0.5, rel=0.28571428571429, out=0, click=0.008, spread=0.1, damp=0.6 gate=1 |
	var sig, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -4, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rel/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(rel, rel/2, 1, 0.01, curve: 3),
		gate, doneAction: Done.freeSelf); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: 5,
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq

	verb = BLowPass.ar(verb, 400+freq,2);

	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1);
	Out.ar(out, sig);
}).add;

	SynthDef(\cowbell, {
		var sig, excitation, tension, loss;
		excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.1),doneAction:Done.freeSelf
		) * PinkNoise.ar(1);
		tension = \tension.kr(0.1);
		loss = \loss.kr(0.999);
		sig =  MembraneCircle.ar(excitation, tension, loss);
		Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
	}).add;

)



(

Pdef.removeAll;
Pdef(\pluck,
	Pbind(\instrument, \twotube,
		\dur, Psubdivide(
			Pseq([1!24,2!8,4!4].flatten,inf),
			Pseq(#[0.5, 1, 2,0.25,0.25],inf)
		),//Psubdivide(
			//Pseq([1!24,2!6,1,1,9,1].flat,inf),
			//Pn(Pshuf([Rest(1),1,1,Rest(1),1,1,Rest(1),1,1,Rest(1),1,1],3),inf)
		//)/4,//Pn(Pshuf([1,1,2,2,2,4]/6,3),inf),
		\k, Pseg([-0.1,-0.3,-0.1],150,\exp,inf),
		\preamp,Pseq([1,2,3,4,5].mirror*5,inf),
		\amp,0.2,
		\maxRq,Pseg([0.01,0.9,0.01],50,\wel,inf),
		\minBpfHz,0.1,//0.65,
		\maxBpfHz,Pwrand([0.5,1.5],[0.95,0.05],inf),//0.75,
		\delay1, (Pseq([83!72,95!24,83!12,71!24].mirror.flat,inf) +  Pseq([
        Pshuf(#[-3,0,2,4], 2)+[0,3,5,7],
			Pseq( [0,2,4,7,4,2] )+Pwrand([[0,4,5],[0,2,4],[-1,0,4]],[0.7,0.2,0.1],inf)
	], inf)).midiratio,//Pwrand([47,23],[0.9,0.1],inf) + Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], inf), // Pn(Pn(Pwrand([23,35,47,50,52,59,61,63,64],[23,35,47,50,52,59,61,63,64].reciprocal.normalizeSum,1),inf)),//Pseg([50,45,50],150,\exp,inf).round(1),
		\delay2,1,//Pseg([1,10,1],150,\exp,inf).round(1),
		\out,~bus,
));

Pdef(\kick,
	Pbind(*[
	instrument: \technokick,
	spread: Pseq([0.9,0.8,0.6,0], inf),
	click: Pwhite(0.006, 0.008, inf),
	dur: 4,
	legato: 2,
	midinote: Pseq([Pseq([35], 4), Pseq([23], 4)],inf),
	amp:10;
]));

Pdef(\cowbell,
	Pbind(
		\instrument, \cowbell,
		\dur, Psubdivide(
			Pseq([1!24,2!8,4!4].flat,inf),
			Pseq([0.5,Pseq([1],inf)],1) //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
		),
		\tension,5*Prand([1e-3,1e-2,1e-1],inf), //pitch
		\timeScale,0.3,  //prevent clipping
		\amp,Plprand(0.4,1.2,inf),
		\out,~bus,
));
)


(
TempoClock.default.tempo_(70/60);
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pdef(\pluck).play;
//Pdef(\kick).play;
//Pdef(\cowbell).play;
)