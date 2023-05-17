(
//~bus = Bus.audio(s,2);
Server.killAll;
("Setup/Setup.scd").loadRelative;
)

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



~a = [40,45,44,47,39];

~a = ~a.scramble;
~b =5;


TempoClock.default.tempo_(105/60);

(
~bus = Bus.audio(s,2);
//Synth(\reverb_ef,[\in, ~bus, \out, 0,\rt60,0.1]);
Pdef(\gabor,
	Pbind(
		\instrument, \gabor,

		\atk, 0.01,
		\rel, 0.5,
		\dur,1/Pn(Pshuf([1,3,6,6,6,3,1],3),inf),

		// Bandpass Filter sweep
		\slope, -5,
		\fltRange, Pstep([2000,8000,800,2000],[14,14,14,14],inf),

		\fAtk, 0.3,
		\fRel, 0.01,

		\freq, Pstep(~a.midicps,[5,1,3,2,1],inf), //Pn(Pshuf([151,309,407,561,774,821,864,1173,1984,51],3),inf),

		\amp, 0.30,
		\pan, 0,
		\out, ~bus[\reverb],
	)
);
)

Pdef(\gabor).play;

Pdef(\gabor).stop;