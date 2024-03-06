/// beatboxing and bach
// https://sccode.org/1-5aN
("Setup/Setup.scd").loadRelative

(

// Basic drum kit
SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: PinkNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;

// Basic saw synth for chords and bass
SynthDef("sawSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = BPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;

SynthDef("pulseSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Pulse.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = BPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;

)

// Bach's Invention No. 13 in A Minor
(
Pbind(
	\instrument, Pwrand(["hat","openhihat"],[0.8,0.2],inf),
	\dur, Pseq([

		Pseq([Rest(1/4), 1/4], 44), //bars 1-6(first half)
		Rest(2), //bar 6
		Pseq([Rest(1/4), 1/8, 1/8, 1/4, 1/4, Pn(1/4, 4)], 1),
		Pseq([Rest(1/4), 1/4], 4),
		Pseq([Rest(1/4), 1/8, 1/8, 1/4, 1/4, Pn(1/4, 4)], 1),
		Pseq([Rest(1/4), 1/4], 4), //bars 7-8
		Pseq([Rest(1/4), 1/4], 40), //bars 9-13
		Pseq([Rest(2), Pseq([Rest(1/4), 1/4], 4)], 4), //bars 14-17
		Pseq([Rest(1/4), 1/4], 62) //bars 18-end

	], 1),
	\att, 0.05,
	\rel, 0.1,
	\ffreq, 11000,
	\pan, 0,
	\amp, 0.3
).play;

Pbind(
	\instrument, Pwrand(["sn","cymbal"],[0.8,0.2],inf),
	\dur, Pseq([

		Pseq([Rest(1/2), 1/2], 52), //bars 1-13
		Pseq([Rest(3), Rest(1/2), 1/2], 4), //bars 14-17
		Pseq([Rest(1/2), 1/2], 31) //bars 18-end

	], 1),
	\att, 0.01,
	\rel, 0.1,
	\sinfreq, 180,
	\ffreq, 2000,
	\amp, 0.6

).play;

Pbind(
	\instrument, "bd",
	\dur, Pseq([

		Pn(1/2, 199) //bars 1-25

	], 1),
	\att, 0.01,
	\rel, 0.5,
	\sinfreq, 55,
	\glissf, 0.9,
	\amp, 0.4,
).play;


//Right hand
Pbind(
	\instrument, "harpsichord_pluck",
	\midinote, Pseq([

		\rest, 64, 69, 72, 71, 64, 71, 74, 72, 76, 68, 76, //bar 1
		69, 64, 69, 72, 71, 64, 71, 74, 72, 69, \rest, //bar 2
		\rest, 76, 72, 76, 69, 72, 64, 67, 65, 69, 74, 77, //bar 3
		\rest, 74, 71, 74, 67, 71, 62, 65, 64, 67, 72, 76, //bar 4
		\rest, 72, 69, 72, 65, 74, \rest, 71, 67, 71, 64, 72, //bar 5
		\rest, 69, 65, 69, 62, 71, 72, \rest, //bar 6
		\rest, 67, 72, 76, 74, 67, 74, 77, 76, 79, 71, 79, //bar 7
		72, 67, 72, 76, 74, 67, 74, 77, 76, 72, 79, 76, //bar 8

		84, 81, 76, 81, 72, 76, 69, 72, 74, 78, 81, 84, //bar 9
		83, 79, 74, 79, 71, 74, 67, 71, 72, 76, 79, 83, //bar 10
		81, 78, 75, 78, 71, 75, 66, 69, 67, 79, \rest, 76, 72, 76, //bar 11
		69, 78, \rest, 74, 71, 74, 67, 76, \rest, 72, 69, 72, //bar 12
		66, 79, 78, 76, 75, 78, 71, 75, 76, \rest, \rest, \rest, //bar 13
		\rest,  79, 82, 79, 76, 79, 73, 76, 79, 76, 73, 76, 69, \rest, \rest, //bar 14
		\rest, 77, 81, 77, 74, 77, 71, 74, 77, 74, 71, 74, 67, \rest, \rest, //bar 15
		\rest, 76, 79, 76, 72, 76, 69, 72, 75, 72, 69, 72, 66, \rest, \rest, //bar 16

		\rest, 74, 77, 74, 71, 74, 68, 71, 74, 71, 68, 71, 64, \rest, \rest, //bar 17
		\rest, 64, 69, 72, 71, 64, 71, 74, 72, 69, 68, 64, //bar 18
		69, 72, 76, 72, 69, 72, 66, 69, 72, 69, 66, 69, 63, 72, 71, 69, //bar 19
		68, 71, 74, 71, 68, 71, 62, 65, 68, 65, 62, 65, 59, 65, 64, 62, //bar 20
		60, 64, 69, 64, 60, 64, 57, 60, 63, 60, 57, 60, 54, 60, 59, 57, //bar 21
		56, 71, 68, 64, \rest, 64, 69, 72, 71, 64, 71, 74, //bar 22
		72, 69, 72, 76, 74, 71, 74, 77, 76, 72, 76, 79, 77, 76, 74, 72, //bar 23
		71, 72, 74, 76, 77, 74, 80, 74, 83, 74, 72, 81, 77, 74, 71, 74, //bar 24
		68, 71, 72, 69, 64, 69, 71, 68, 69, 64, 60, 64, 57 //bar 25

	], 1),

	\dur, Pseq([

		Pn(1/4, 8), Pn(1/2, 4), //bar 1
		Pn(1/4, 8), Pn(1/2, 2), 1, //bar 2
		Pn(1/4, 8), Pn(1/2, 4), //bar 3
		Pn(1/4, 8), Pn(1/2, 4), //bar 4
		Pn(1/4, 4), Pn(1/2, 2), Pn(1/4, 4), Pn(1/2, 2), //bar 5
		Pn(1/4, 4), Pn(1/2, 3), 1.5, //bar 6
		Pn(1/4, 8), Pn(1/2, 4), //bar 7
		Pn(1/4, 8), Pn(1/2, 4), //bar 8

		Pn(1/4, 8), Pn(1/2, 4), //bar 9
		Pn(1/4, 8), Pn(1/2, 4), //bar 10
		Pn(1/4, 8), Pn(1/2, 2), Pn(1/4, 4), //bar 11
		Pn(1/2, 2), Pn(1/4, 4), Pn(1/2, 2), Pn(1/4, 4), //bar 12
		Pn(1/4, 8), Pn(1/2, 4), //bar 13
		Pn(1/4, 14), 1/2, //bar 14
		Pn(1/4, 14), 1/2, //bar 15
		Pn(1/4, 14), 1/2, //bar 16

		Pn(1/4, 14), 1/2, //bar 17
		Pn(1/4, 8), Pn(1/2, 4), //bar 18
		Pn(1/4, 16), //bar 19
		Pn(1/4, 16), //bar 20
		Pn(1/4, 16), //bar 21
		Pn(1/2, 4), Pn(1/4, 8), //bar 22
		Pn(1/4, 16), //bar 23
		Pn(1/4, 16), //bar 24
		Pn(1/4, 12), 1 //bar 25

	], 1),

	\att, 0.1,
	\rel, Pkey(\dur)+0.5,
	\amp, 0.3

).play;

//Left hand
Pbind(
	\instrument, "harpsichord_pluck",
	\midinote, Pseq([

		45, 57, 56, 57, 52, 57, 60, 59, 52, 59, 62, //bar 1
		60, 57, 56, 52, 57, 52, 57, 60, 59, 52, 59, 62, //bar 2
		60, 57, 60, 57, 62, 57, 53, 57, 50, 53, 45, 48, //bar 3
		47, 50, 55, 59, \rest, 55, 52, 55, 48, 52, 43, 47, //bar 4
		45, 48, 50, 53, 47, 50, 43, 47, 48, 52, 45, 48, //bar 5
		41, 38, 43, 55, 53, 55, 48, 55, 60, 64, 62, 55, 62, 65, //bar 6
		64, 60, 59, 55, 60, 55, 60, 64, 62, 55, 62, 65, //bar 7
		64, 60, \rest, \rest, \rest, 67, 64, 67, 60, 64, 55, 59, //bar 8

		57, 60, 64, 67, 66, 69, 62, 66, 57, 62, 54, 57, //bar 9
		55, 59, 62, 66, 64, 67, 60, 64, 55, 60, 52, 55, //bar 10
		54, 57, 59, 63, \rest, 64, 60, 64, 57, 60, 64, 67, //bar 11
		66, 62, 59, 62, 55, 59, 62, 66, 64, 60, 57, 60, 54, 57, 60, //bar 12
		\rest, 59, 60, 57, 59, 47, 52, 64, 59, 55, 52, 47, 43, 47, //bar 13
		40, 52, 55, 58, 49, \rest, \rest, 67, 65, 64, //bar 14
		62, 50, 53, 56, 47, \rest, \rest, 65, 64, 62, //bar 15
		60, 48, 52, 54, 45, \rest, \rest, 64, 63, 61, //bar 16

		59, 47, 50, 53, 44, \rest, \rest, 62, 60, 59, //bar 17
		60, 57, 56, 52, 57, 52, 57, 60, 59, 52, 59, 62, //bar 18
		60, 64, 69, 64, 60, 64, 57, 60, 54, 57, 60, 57, 54, 57, 51, 54, //bar 19
		52, 56, 59, 56, 52, 47, 44, 40, //bar 20
		45, 48, 52, 48, 45, 48, 39, \rest, //bar 21
		\rest, 59, 56, 52, 50, 59, 56, 50, 48, 52, 44, 52, //bar 22
		45, 54, 47, 56, 48, 57, 50, 58, //bar 23
		56, 53, 50, 47, 44, 45, 38, 40, //bar 24
		41, 39, 40, 52, 45 //bar 25

	], 1),

	\dur, Pseq([

		1/2, 1, 1/2, Pn(1/4, 8), //bar 1
		Pn(1/2, 4), Pn(1/4, 8), //bar 2
		Pn(1/2, 4), Pn(1/4, 8), //bar 3
		Pn(1/2, 4), Pn(1/4, 8), //bar 4
		Pn(1/2, 2), Pn(1/4, 4), Pn(1/2, 2), Pn(1/4, 4), //bar 5
		Pn(1/2, 2), Pn(1/4, 12), //bar 6
		Pn(1/2, 4), Pn(1/4, 8), //bar 7
		Pn(1/2, 4), Pn(1/4, 8), //bar 8

		Pn(1/2, 4), Pn(1/4, 8), //bar 9
		Pn(1/2, 4), Pn(1/4, 8), //bar 10
		Pn(1/2, 4), Pn(1/4, 8), //bar 11
		Pn(1/4, 14), 1/2, //bar 12
		Pn(1/4, 4), Pn(1/2, 2), Pn(1/4, 8), //bar 13
		Pn(1/2, 6), Pn(1/4, 4), //bar 14
		Pn(1/2, 6), Pn(1/4, 4), //bar 15
		Pn(1/2, 6), Pn(1/4, 4), //bar 16

		Pn(1/2, 6), Pn(1/4, 4), //bar 17
		Pn(1/2, 4), Pn(1/4, 8), //bar 18
		Pn(1/4, 16), //bar 19
		Pn(1/2, 8), //bar 20
		Pn(1/2, 8), //bar 21
		Pn(1/4, 8), Pn(1/2, 4), //bar 22
		Pn(1/2, 8), //bar 23
		Pn(1/2, 8), //bar 24
		Pn(1/2, 4), 2 //bar 25

	], 1),

	\att, 0.1,
	//\rel, Pkey(\dur),
	\amp, 0.3

).play;

)