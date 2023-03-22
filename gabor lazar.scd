(
~bus = Bus.audio(s,2);

SynthDef(\gabor, {

	var trig = Impulse.ar(LFNoise2.kr(\trig.tr(1)).linexp(-1,1,\trig_low.kr(1),\trig_high.kr(1000)));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); //Dust.kr(15,0.5);//; //LFNoise2.kr(\trig.tr(1)

	var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig, doneAction: 2);
	var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig, doneAction: 2);
	var gainEnv = EnvGen.kr(Env([0,1,0], [\atk.kr(0.01), \rel.kr(0.3)], \lin), trig, doneAction: 2);

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

	//sig = LPF.ar(sig, 1600);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;


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


)

a = Synth(\reverb_ef, [\in, ~bus, \out, 0]);

(
Pbindef(\gabor,

		\instrument, \gabor,

		\atk, 0.01,
		\rel, 0.8,

		// Bandpass Filter sweep
		\slope, 5,
		\fltRange, 8000, //1400 lower bound at slope 5

		\trig_low,1,
		\trig_high, 1000,

		\fAtk, 0.3,
		\fRel, 0.08,

		\freq, 100,//Pseq([[256,8]!8,[128,4]!4].flatten,inf), //Pseq([100,50],inf),// 400,//

		\amp, 0.70,
		\pan, 0,
		\out, 0,
	)
;
)

Pbindef(\gabor).play;


(Pbindef(\gabor,
		\slope, 1,
		\fltRange, 750, //1400 lower bound at slope 5
	\freq,Pseq([[30,10],[30,50],[30,60],[10,60]],inf),
		\trig_low,5,
		\trig_high, 100,
);)


(Pbindef(\gabor,
		\slope, 2,
		\fltRange, 30, //1400 lower bound at slope 5
	//\freq,1000,
		\trig_low,50,
		\trig_high, 200,
);)


(Pbindef(\gabor,
		\slope, -5,
		\fltRange, 8000, //1400 lower bound at slope 5

	\freq,Prand([[30,10],[30,50],[30,60]],inf),
		\trig_low,5,
		\trig_high, 10,
);)


(Pbindef(\gabor,
	\freq,Pseq([[250,100,30],[100,30]],inf),
	\trig_low, 1,
	\trig_high, 40000,
);)


Pdef(\gabor).stop;

a.set(\mix,0.1);
a.set(\preDel,0.1);




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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
	snd = (snd * -30.dbamp).tanh;
	Out.ar(\out.kr(0), snd);
});
)


b = Synth(\bass, [\freq,70]);

b.set(\freq,7);
b.set(\freq,[24,22]);
b.set(\out,0);


(Pdef(\gabor_bass,
	Pbind(\instrument, \bass,
		\freq,Pseq([40!16,80!2,40!4,120!2].flatten,inf)
)
);
)

Pdef(\gabor_bass).play;

(
SynthDef(\phase, {
	arg out=0, pan=0, amp=0.25, freq=110,
	mRatio=1.5, cRatio=1, widthMod=0.5;

	var sig, saw, sine;
	var width = SinOsc.ar(widthMod!2).range(\widthMin.kr(0.15), \widthMax.kr(0.50).clip(0.001,0.999));

	saw = LFSaw.ar(mRatio * freq, 1).linlin(-1,1, width.neg, 1-width);
	saw = saw.bilin(0, width.neg, 1-width, 0, -0.5, 1);
	sine = (Select.ar(saw>0, [0.5+saw, saw]) * 2pi).sin;

	sig = SinOsc.ar(
		cRatio * freq * [1.001, 1],
		phase: sine * MouseY.kr(0, 7)
	);

	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

(instrument: \phase, midinote: [57,60,64,65,70]).play;



(
(1..50).do({|partials|
	SynthDef(\additive ++ partials, {

		var sig, freqs, gainEnv;

		gainEnv = EnvGen.ar(Env.adsr(
			\atk.kr(0.07),
			\dec.kr(0.5),
			\sus.kr(1),
			\rel.kr(2),
			curve: \curve.kr(-4)
		), \gate.kr(1), doneAction:2);

		freqs = Array.fill(partials, {|i|
			\freq.kr(20) * (i+1); // even partials
		});

		sig = freqs.collect({|freq, i|
			var amps = \decay.kr(0.5) / (i+1); // even partials
			SinOsc.ar(freq) * amps;
		});

		sig = Mix(sig);

		sig = sig * gainEnv * \amp.kr(0.3) * \vel.kr(1);
		sig = Splay.ar(sig);
		Out.ar(\out.kr(0), sig)
	}).add;
});
)




x = Synth(\additive10, [\freq, 220, \decay, 0.5]);
x.set(\decay,1);
x.set(\gate, 0);