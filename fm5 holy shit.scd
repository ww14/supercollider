//https://gist.github.com/scztt/f889e72d11ddcfb0879dbff82d531747
// why is the melody fucked?
s.boot;

(
SynthDef(\fm5, {
	var sig, env, gate, freqs, freqEnv, freqCurve, octs, phases, amps, matrix, freq;
	var seed, seedA, seedB, seedBlend, sigA, sigB, params;
	var freqMin, freqMax, partialMin, partialMax, freqRound, matrixMin, matrixMax, matrixCurve;
	var attack, feed, sustain, inputFreq, pan;
	var rand;

	sustain = \sustain.kr(1);
	seed = \seed.kr(0);
	seed = seed + (\seedDrift.kr(0.05) * Env([0, 1], [sustain], [\seedDriftCurve.kr(0)]).kr(gate:1));
	// seed = seed + MouseX.kr(-3, 3);

	rand = {
		|seed, name, count|
		count.collect {
			|i|
			Hasher.kr(
				seed + i + ("name".hash % 1000.nthPrime)
			)

		}
	};

	freqMin = \freqMin.kr(-1);
	freqMax = \freqMax.kr(1);
	freqRound = \freqRound.kr(0);

	partialMin = \partialMin.kr(-1);
	partialMax = \partialMax.kr(1);

	inputFreq = \freq.kr;
	freq = inputFreq; // * (ExpRand(0.01, 48) * Env([1, 0], [Rand(0.03, 0.2)], [-10]).kr(gate:1)).midiratio;

	matrixMin = \matrixMin.kr(-1);
	matrixMax = \matrixMax.kr(1);
	matrixCurve = \matrixCurve.kr(0);

	feed = \feed.kr(0);

	gate = \gate.kr(1);
	attack = \attack.kr(0.001).linlin(0, 1, 0.001, 1 - 0.001);
	env = Env.adsr(attack, 1 - attack, \sustainLevel.kr(0.4), 0.3, curve:-9).kr(gate:gate, timeScale:sustain, doneAction:2);

	freqs = seed.fadeSteps({
		|seed|
		rand.(seed, "freqs", 6)
	}, warp:\sin);
	freqCurve = \freqCurve.kr(20);
	freqEnv = Env.adsr(
		attack, 1 - attack, 0, 0.3, curve:freqCurve * [1, -1, -1]
	).kr(gate:gate, timeScale:sustain, doneAction:2);
	freqs = freqs.linlin(-1, 1, freqMin, freqMax).round(freqRound);

	amps = seed.fadeSteps({
		|seed|
		[
			rand.(seed, "ampsScale", 6),
			rand.(seed, "ampsEnv", 6),
			rand.(seed, "ampsSustain", 6)
		]
	}, warp:\sin);
	amps = [
		amps[0].linexp(-1, 1, 0.001, 1),
		amps[1],
		amps[2].lincurve(-1, 1, 0, 1, \ampSustainCurve.kr(-4)),
	];
	amps[1] = ((amps[1] > 0) * (attack.pow(1 + (amps[1].linlin(0, 1, 0, 2)))))
	+ ((amps[1] < 0) * (attack.pow(1 / (1 + (amps[1].linlin(0, 1, 0, 2))))));

	amps = amps.flop.collect {
		|amp|
		amp[0] * Env.adsr(
			amp[1], 1 - amp[1], amp[2], 0.3
		).kr(gate:gate, timeScale:sustain);
	};

	matrix = seed.fadeSteps({
		|seed|
		rand.(seed, "matrix", 6*6)
		* (rand.(seed, "matrixCut", 6*6) < \matrixCut.kr(1))
	}, warp:\sin);
	matrix = matrix.lincurve(-1, 1, matrixMin, matrixMax, matrixCurve);

	feed = feed * (1 + (env * 0.2));
	(7 * [0, 1, 2, 3, 4, 5]).do {
		|i|
		matrix[i] = matrix[i] + feed;
	};

	sig = seed.fadeSteps({
		|seed|
		var partial;

		partial = rand.(seed, "partial", 6);
		partial = partial.linlin(-1, 1, partialMin, partialMax).round(1);
		partial = (1 + ((partial > 0) * partial))
		+ ((partial < 0) * (1 / (1 + partial.abs)));

		// octs = [0, 0, 0, (0.188.ratiomidi), 0, 0];

		phases = rand.(seed, "phases", 6);
		phases = phases.linexp(-1, 1, 0.001, 3);

		FM7.ar(
			[
				(freq * partial) + freqs,
				phases,
				amps
			].flop,
			matrix.clump(6)
		).sum;
	}, warp:\sin);

	sig = env * sig;

	pan = \pan.kr(0);
	sig = Pan2.ar(sig, pan);
	// sig = 24.dbamp * PanBin.ar(sig, 1.0, pan);
	sig = Balance2.ar(sig[0], sig[1], pan * 0.3);
	sig = \amp.kr(1) * sig;

	OffsetOut.ar(\out.kr(0), sig);
}).add;
)

Synth(\fm5);

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
)
TempoClock.default.tempo = 1;


Pdef(\fmBase).play(quant:4);

Pdef(\fm).play(quant:4);
Pdef(\fm).stop;

(
// more interesting
Pdef(\fm, Pbind(
	\dur, Pbjorklund2(5, 8) / 8,


	\scale, Scale.dorian,
	\octave, Pseq([
		3,
		[3, 4]
	], inf).stutter(4),
	\strum, 1/8,

	\degree, Pstep(Pseq([0, -2], inf), 4, inf),
	\degree, Pkey(\degree) + Pstep(
		Pseq([0, 5], inf),
		Pseq([3.6, 0.4], inf)
	),

	\seed, 53 + Pseg([0, 0.1], [4]).repeat,
	\seedDrift, Pseg([-0.1, 0.9], [4]).repeat,
	\seedDriftCurve, Pseg([-4, 4, -4], [16, 16]).repeat,

	[\freqMin, \freqMax], Prand([
		[-0.2, 0.2],
		[-2, 2],
		[-8, 8]
	], inf),

	\partialMin, Pstep(
		Pseq([0, -1], inf),
		Pseq([5.5, 0.5], inf),
	),
	\partialMax, 2

) <> Pdef(\fmBase)
)
)

Pdef(\fm1).play(quant:4);
Pdef(\fm).stop;

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
		[-200,200]
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
)
)

(
Pdef(\fm1).play(quant:4);
Pdef(\fm).stop;
)


Pdef(\fm3).stop(quant:4);

(
// more interesting
Pdef(\fm3, Pbind(
	\partialMax, 3,
	\degree, Pstep(Pseq([0, -2,[0,2]], inf), [4,4,8], inf),
	\amp,0.03,
) <> Pdef(\fmBase)
)
)

(
Pdef(\fm3).play(quant:1);
Pdef(\fm1_a).stop(quant:1);
)

(
// more interesting
Pdef(\fm1_a, Pbind(
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
		Pseq([0,-2,2,-2], inf),
		Pseq([1,0.5,2,0.5], inf)
	),

	\seed, 53 + Pseg([0, 0.1,0], [4]).repeat,
	\seedDrift, Pseg([0, 2,0], 100).repeat, //0.5
	\seedDriftCurve, Pseg([0, 100], 100).repeat,//Pseg([-4, 4, -4], [16, 16]).repeat,

	[\freqMin, \freqMax], Pwrand([
		[-0.2, 0.2],
		[-2, 2],
		[-4, 4],
		[-200,200]
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
)
)

(
Pdef(\fm1_a).play(quant:4);
Pdef(\fm1).stop;
)