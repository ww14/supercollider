(
SynthDef(\gabor, {

	var trig = \trig.tr;

	var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig, doneAction: Done.freeSelf);
	var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig, doneAction: Done.freeSelf);
	var gainEnv = EnvGen.kr(Env([0,1,0], [\atk.kr(0.01), \rel.kr(0.3)], \lin), trig, doneAction: Done.freeSelf);

	var numPartials = 50;
	var n = (1..numPartials);
	var freqs = \freq.kr(150) * (n + (n * n * 0.05));
	var cutoff, amps, sig;

	cutoff = fltEnv * \fltRange.kr(8000);

	amps = (
		(freqs.log2 - cutoff.log2).squared
		* \slope.kr(-5)
	).dbamp;

	sig = SinOsc.ar(freqs * freqEnv.midiratio, 0, amps).sum * -25.dbamp;

	sig = sig * gainEnv;

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;
)

(
Pdef(\gabor,
	Pbind(
		\instrument, \gabor,

		\atk, 0.01,
		\rel, 0.5,

		// Bandpass Filter sweep
		\slope, -5,
		\fltRange, 8000,

		\fAtk, 0.3,
		\fRel, 0.01,

		\freq, Pn(Pshuf([151,309,407,561,774,821,864,1173,1984,51],3),inf),

		\amp, 0.30,
		\pan, 0,
		\out, 0,
	)
);
)

Pdef(\gabor).play;

Pdef(\gabor).stop;