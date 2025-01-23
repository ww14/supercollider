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

~a = [40,45,44,47,39];
)

~a = ~a.scramble;
~b =5;

Synth(\gabor,[\freq,150,\dur,1])


TempoClock.default.tempo_(105/60);

Pbind(\instrument,\gabor,\dur,3,\slope,-4,\fltRange,8000).play


(
Pdef.removeAll;
//~bus = Bus.audio(s,2);
//Synth(\reverb_ef,[\in, ~bus, \out, 0,\rt60,0.1]);
Pbindef(\gabor,
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
		\out, ~bus[\reverb2],
	)
);
)

Pbindef(\gabor).play;
Pbindef(\gabor,\dur,2,\slope,2,\rel,1,\fRel,0.9,\out,0,\freq,48.midicps);
Pbindef(\gabor,\freq,[55,110,440],\rel,0.3,\atk,0.01,\slope,-0.1);
Pbindef(\gabor,\dur,l);


(
(
l = Prewrite(0.25,
    (
        0.25: #[0.25,0.25,0.25,0.25,0.5],
        0.5: #[0.125,0.5,0.125,0.125,0.125],
        0.125: #[0.375,0.125],
        //0.375: #[0.375,0.375,1],
        1: #[0.75,0.25],
        0.75: #[8]
),64);
);

(
k = Prewrite(1, // start with 1
        (    1: [0.25,2,0.25,2],
            0.25: [3,3,2]/4,
		3/4: [0.25,1,0.125,0.125],
		0.5: [1,1,1,1,1,1]/8
        ), 4);
);

j = [1, 0.7, 1, 0.25]
)






Pdef(\gabor).stop;