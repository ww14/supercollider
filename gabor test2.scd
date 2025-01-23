(
SynthDef(\gabor, {

	var trig = \trig.tr;

	var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig, doneAction: Done.none);
	var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig, doneAction: Done.none);
	var gainEnv = EnvGen.kr(Env([0,1,0], [\atk.kr(0.01), \rel.kr(0.3)], \lin), trig, doneAction: Done.none);

	var numPartials = 50;
	var n = (1..numPartials);
	var freqs = \freq.kr(150) * (n + (n * n * 0.05));
	var cutoff, amps, sig;
	var perc_env = Env.perc.ar;

	cutoff = fltEnv * \fltRange.kr(8000);

	amps = (
		(freqs.log2 - cutoff.log2).squared
		* \slope.kr(-5)
	).dbamp;

	sig = SinOsc.ar(freqs * freqEnv.midiratio, 0, amps).sum * -25.dbamp;

	sig = sig * gainEnv;



	sig = sig * (1+ SinOsc.ar(\cycle.kr(2.reciprocal)*(1+perc_env)));
	sig = BHiShelf.ar(sig,1200,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,1200,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.03,1+(0.3*perc_env));
	sig = sig + PitchShift.ar(sig,0.012,0.5+perc_env);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(30)));
	sig = sig.tanh;


	sig = HPF.ar(sig,30);
	sig = LPF.ar(sig,7000);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;
)

(
Pbindef(\gabor,
		\instrument, \gabor,

	\dur, 3,

		\atk, 0.01,
		\rel, 2.5,



		// Bandpass Filter sweep
		\slope, -5,
		\fltRange, 1000,

		\fAtk, 0.1,
		\fRel, 1,

	    \freq, 68,

		\amp, 0.30,
		\pan, 0,
		\out, 0,
	)
);

Pbindef(\gabor).play;
Pbindef(\gabor,\freq,68,\fAtk,0.05,\fRel,1,\slope,-3,\cycle,0.5)
Pbindef(\gabor,\freq,64,\fAtk,0.5,\fRel,4,\slope,-5,\cycle,5)
Pbindef(\gabor,\freq,64,\fAtk,0.05,\fRel,4,\slope,-1,\cycle,50)
Pbindef(\gabor,\freq,64,\fAtk,0.5,\fRel,1,\slope,-1,\cycle,5)


Pdef(\gabor).stop;



(
SynthDef(\bass, {
	var snd, auto, freq, trig;
	freq = \freq.kr(40);
	trig = ToggleFF.ar(Dust.ar(8));
	auto = trig.lagud(0.1, 0.3);
	snd = Saw.ar(freq);
	snd = Splay.ar(snd);
	snd = (snd * 3).fold2;
	snd = RLPF.ar(snd, freq * 10, 0.1);
	snd = (snd * 5).fold2;
	snd = RLPF.ar(snd, freq * 8 * TRand.ar(1, 4, trig), 0.5);
	snd = (snd * 5).fold2;
	snd = MoogFF.ar(snd, auto.linexp(0, 1, 100, 8000), 0);
	snd = snd + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	snd = (snd * 3.dbamp).tanh;
	Out.ar(\out.kr(0), snd);
}).play;
)