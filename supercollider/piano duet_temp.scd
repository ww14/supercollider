
(
~piano_bus = Bus.audio(s,2);
~bus = Bus.audio(s,2);
~bus2 = Bus.audio(s,2);

(
SynthDef(\chord, {
		var sig, trig, freq, cycle, env;
		trig = \trig.tr;
	env = EnvGen.ar(Env.perc,doneAction:Done.freeSelf); //EnvGen.ar(Env([0.1,1,1,0],[0.01]++((\dur.kr(0.5)-0.001)*[0.4,0.6])),doneAction:2);//([0,1,1,0],[0.001]++((\dur.kr(1)-0.001)*[0.4,0.6])),doneAction:2);
		//EnvGen.ar(Env([0.1,1,1,0],[0.01]++((\dur.kr(0.5)-0.001)*[0.4,0.6])),doneAction:2);


	    sig = VOSIM.ar(1,\freq.kr(440),\ncycles.kr(50));
	    sig = RLPF.ar(sig,2000);
	   // sig = MembraneHexagon.ar(sig,0.518,0.999999999);
		sig = Mix.ar(sig);

	    // sig = CombC.ar(sig,1,0.1,1.2,1);

		sig = sig * env;

		Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(-6.dbamp)));
	}).add;
);

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
	sig = amp * Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1);
	Out.ar(out, sig);
}).add;



SynthDef(\help_blowhole, {
	var env = EnvGen.ar(Env([0,1,1,0],[0.01]++((\dur.kr(1)-0.001)*[0.4,0.6])),doneAction:2);
	var sig = StkBlowHole.ar(\freq.kr(440),\reedstiffness.kr(64), \noisegain.kr(20), \tonehole.kr(64), \register.kr(11), \breathpressure.kr(64), \mul.kr(5.0), \add.kr(0.0));
	Out.ar(\out.kr(0), Pan2.ar(sig * 0.1, \pan.kr(0)));
}).add;




SynthDef(\help_dwgpluckedstiff, { |out=0, freq=440, amp=0.5, gate=1, c1=1,c3=20, pan=0, rel=1, fB = 80|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPluckedStiff.ar(freq, amp, gate,0.1,c1,c3,inp,rel,fB);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;



//Define piano synthdef and soundboard

SynthDef(\help_oteypianostring, { |out=0, freq=440,gate=1, amp=0.5,rho=1, e=1, rel=0.1|
    var son = OteyPianoStrings.ar(freq, amp, rho:rho, e:e)*EnvGen.ar(Env.asr(0,1,rel),gate,doneAction:2);
	//son = OteySoundBoard.ar(In.ar([20,21],2));
	Out.ar(out, Pan2.ar(son * 1,\pan.kr(0)));
}).add;

SynthDef(\piano_soundboard,{
	arg gain=2;
    var audio = In.ar([20, 21], 2), reverb;
    audio = OteySoundBoard.ar(audio);
	audio = LeakDC.ar(audio,0.99);//;
	reverb = MoogFF.ar(audio,1500,gain);
	audio = Mix.ar(audio + reverb);
    Out.ar(0,audio);
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


SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, amp = 0.8, beater_noise_level = 0.025;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}
).add;
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

TempoClock.default.tempo = 1;
(
var a, b, c, d;
Synth.tail(1,\piano_soundboard); //,[\in, ~piano_bus,\out,~bus]);
y = Synth(\reverb_ef, [\in, ~bus, \out, 0]);

a = Pbind(
	\instrument, \help_dwgpluckedstiff,
    \degree, Pswitch(#[0, 5b, 3], Ptime(8).round(2) / 2),
    \dur, Prand(#[0.2, 0.5, 1.1, 0.25, 0.15], inf),
	\ctranspose, Pwrand([0,0],[0.8,0.2],inf),
);
b = Pbind(
	\instrument, \help_dwgpluckedstiff,
	\degree, Pseq(#[0, 2b, 3],1),
	//\delta,Pwrand([2,1,0],[6,2,1].normalizeSum,inf),
	//\rel,1,
	\dur, 2 +Pwhite(-0.05,0.05),
	\ctranspose, [-7,0,7],
	\amp, -20.dbamp,
);

c = Pbind(
	\instrument, \chord,
	\degree, Pswitch(#[0, 2b, 3],Ptime(8).round(2)),
	\dur,Pwrand([1,0.5,0.25],[6,2,1].normalizeSum,inf),
	//\rel,1,
    //\dur, 2,
	\ncycles,Phprand(30,50), /// Pwrand([1,2,3,4],[4,3,2,1].normalizeSum,inf),
	\ctranspose, [-7,0,7],
	\amp, -25.dbamp,
	\out,~bus,
);


d = Pbind(
	\instrument, \technokick,
	\degree, Pswitch(#[0, 5b, 3],Ptime(8).round(2)),
	\dur,Prand(#[0.2, 0.5, 1.1, 0.25, 0.15], inf),
	//\rel,1,
    //\dur, 2,
	//\ncycles,Plprand(1,10), /// Pwrand([1,2,3,4],[4,3,2,1].normalizeSum,inf),
	\ctranspose, [-28],
	\amp, -20.dbamp,
	\out,~bus2,
);

Pseq([
/*	Prand([Event.silent(1.25)],1),
	Ppar([a, b]),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.5,b],1),
	Prand([Event.silent(1.25)],1),
	Ppar([a, b]),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.5,b],1),
	Prand([Event.silent(1.25)],1),
	Ppar([a, b]),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.5,b],1),
	Prand([Event.silent(1.25)],1),
	Ppar([a, b, c]), */
	Prand([Event.silent(0.75)],1),
	Ptpar([0.5,a,0,c],1),
	Prand([Event.silent(0.5)],1),
	Ppar([c,d]),
	Prand([Event.silent(0.5)],1),
	Ppar([c,d]),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,d,0.5,c],1),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.0,d],1),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.5,d],1),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.5,d,0,c],1),
	Prand([Event.silent(0.5)],1),
	Ptpar([0,a,0.5,b,0,c],1),
	], inf).play;
)


y = Synth(\reverb_ef, [\in, ~bus, \out, 0]);
d.play;