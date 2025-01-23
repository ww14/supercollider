(
x = {
	f = 220;
	a = SinOsc.ar(f);
	p = MouseY.kr(0,pi/2).clip(0,pi/2).poll(10,"phase");
	b = SinOsc.ar(110,p);
	LeakDC.ar([a*b]!2 * -51.dbamp);
}.play;
)

Hilbert
// https://scsynth.org/t/frequency-shifting-with-hilbert-transform-and-ring-modulation/10251/3

(
var raisedCos = { |phase, index|
	var cosine = cos(phase * 2pi);
	exp(index.abs * (cosine - 1));
};

SynthDef(\hilbert, {
	var rate, modRatio, index, modPhase, mod, raisedCosWindow, carrPhase, carr, sig, perc_env, perc, env;
	rate = \rate.kr(80).lag3 * [1,1.01];
	modRatio = \modRatio.kr(2.5);
	index = SinOsc.ar(\speed.kr(0.3)).linlin(-1, 1, \indexLower.kr(0), \indexUpper.kr(30));

	modPhase = Phasor.ar(DC.ar(0), rate * modRatio * SampleDur.ir);
	mod = sin(modPhase * 2pi);
	raisedCosWindow = raisedCos.(modPhase, index);

	carrPhase = Phasor.ar(DC.ar(0), rate * SampleDur.ir);
	carr = sin(carrPhase * 2pi + (mod * index));

	sig = carr * raisedCosWindow;

	/*
	perc_env = Env.perc.ar;
	perc = sig.fold2;
	perc = BHiShelf.ar(perc,1200,0.3,-5);
	perc = sig + PitchShift.ar(perc,0.09,1+(0.3*perc_env));
	perc = sig + PitchShift.ar(perc,0.012,0.5+perc_env);
	perc = FreqShift.ar(perc,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	perc = perc.tanh;
	perc = sig + CombC.ar(perc * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	perc = FreqShift.ar(perc,perc_env.linlin(0,1,0,\upshift.kr(300)));
	perc = perc.tanh;
	//perc = perc * Env.linen(0.01,duration,0.1,curve:-4).ar(Done.freeSelf);

	sig = sig + perc;
*/
	env = Env.asr(1, \amp.kr(1), \release.kr(1)).kr(2, \gate.kr(1));

	//sig = BBandPass.ar(sig,700,\bw.kr(1));

	sig = LeakDC.ar(sig);

	sig = sig * env * 0.5;
	sig = Pan2.ar(sig,\pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)


a = Synth(\hilbert);
a.set(\indexLower,1,\indexUpper,20,\speed,3,\rate,43.midicps,\modRatio,2.5,\bwr_1,0.1);
a.release;


Pbindef(\hilbert, \instrument, \hilbert,\rate,Pseg([45,45,43,47].midicps,[8,4,4],\step,inf))
Pbindef(\hilbert).play
Pbindef(\hilbert, \gate,0)



(
Tdef(\z, Pseq([1, 1, 1, 0.5, 0.5], inf));
Tdef(\z, Pseries(1, 4, 6).loop.asStream);


Pset(\instrument, \hilbert,
    Ppar([
        Pbind(
			\dur, Tdef(\z),
            \rate,43.midicps,
			\modRatio,2.5,
			\indexLower,0,
			\indexUpper,Pwrand([30,20,10],[3,2,1].normalizeSum,inf),
			\speed,Pwrand([0.25,0.5],[0.75,0.25],inf),
            \x, Pfunc { TempoClock.default.elapsedBeats.postln } // posts the onset times
        ),
        Pbind(
			\dur, Tdef(\z), // reference beat
          \indexLower,0,
		\indexUpper,8,
			\speed,0.5,
			\rate,55.midicps,
			\modRatio,1.5,
			\amp,0.075
        ),
		Pbind(
			\dur, Tdef(\z), // reference beat
          \indexLower,0,
		\indexUpper,3,
			\speed,Phprand(0,1),
			\rate,Pwrand([43,55],[0.5,0.5],inf).midicps,
			\modRatio,2.5,
			\amp, 0.05
        ),
		Pbind(
			\dur, Tdef(\z), // reference beat
          \indexLower,20,
		\indexUpper,30,
			\speed,Prand([43,55],inf).midicps,
			\rate,43.midicps,//Pwrand([43,55],[0.5,0.5],inf).midicps,
			\modRatio,4,
			\amp, 0.01
        )

    ])
).play(quant:1);
)

Tdef(\z, Pseries(1, 1, 10).loop.asStream); // pattern stays in sync.
Tdef(\z, 4 * Pseq([3, 2, 3, 2, 4], inf));