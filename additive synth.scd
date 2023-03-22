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
)

(
Pdef(\additive,
	Pbind(
		\instrument, \additive,

		\dur, 4,

		\width, 0.20,
		\phaseModFreq, 0.5,

		\atk, 1.5,
		\sus, 4,
		\rel, 2.5,

		\time, Pfunc { |ev| ev.use { ~sustain.value } / thisThread.clock.tempo },

		//Phase Modulation
		\iAtk, 1.5,
		\iRel, 2.5,
		\mRatio, 1.96417,
		\cRatio, 2.28158,
		\index, 1,
		\iScale, 1,

		\amp, 0.30,
		\out, 0,
	)
).play;
)

~sustain = 0.0001;