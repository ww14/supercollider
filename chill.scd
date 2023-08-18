// chill
// non-enveloped
(
SynthDef(\chill, {
	var trig, trig2, snd, snd2, fund, freqs, freqs_inverted,cycle, perc, perc2, percVerb, out, env;
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, \lower.kr(1), \upper.kr(8))); //LFDNoise makes the higher freq steps less discrete/quantized
	//trig2 = trig.lag3(1);


	fund = 48 + \fund.kr([0,9,5,7].rotate(2)); //I-VI-iv-V [0,9,5,7] // I-VI-VII-III-VI-II-V-I  [0,9,11,4,9,2,7,0] //
	a = fund +  .t[0, 4, 7, 9, 11, 14, -24]; //[0, 2, 4, 5, 7, 9, 10, 14]; //; //make it an array of chords (t for table)
	//a = a.lag3ud;
	cycle = a.size * 0.5;
	freqs = Select.kr(LFSaw.kr(32.reciprocal,0,cycle,cycle),a.midicps);


	//freqs = (LFNoise2.kr(4.reciprocal).linexp(-1, 1, 52, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]);//
	freqs_inverted = freqs.linlin(48,90,90,48).midicps;
	//freqs = freqs.midicps;
	snd = FMGrain.ar(trig,\snd_tone.kr(0.95),freqs.lag3ud(\lagu.kr(0.05),\lagd.kr(0.3)),\snd_mod.kr(2)*freqs,mul:0.01 * \snd_amp.kr(1).lag3(6));

	snd2 = -50.dbamp * \snd2_amp.kr(1).lag3(2)* Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -15.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		LFNoise2.kr(1).linexp(-1,1,\res_short.kr(0.5),10),
		SinOsc.kr(32.reciprocal,pi).linexp(-1,1,-1,0)
	);

	//snd2 = MoogFF.ar(snd, LFNoise2.kr(0.75).linexp(-1, 1, 500, 16000), 0,0,0.5);
	perc = SinGrain.ar(trig,\drum_tone.kr(0.001).lag3(4),freqs/8,\drum_amp.kr(0.15).lag3(0.3));
	perc2 = SinGrain.ar(trig,\drum_tone2.kr(0.005).lag3(0.1),freqs_inverted/0.1,\drum_amp2.kr(0.005).lag3(2));
	//perc = perc + perc2;
	percVerb = NHHall.ar([perc,perc2],5,0.5);
	perc = XFade2.ar(perc, percVerb, \mix.kr(0.09))
	         + DelayC.ar(percVerb, 1, SinOsc.ar(0.05, [0, pi]).range(0, 1),0.7);
	//snd = CombN.ar(snd,0.9);


	snd = snd + snd2 + perc ;
	snd = snd ! 2;
	//snd = Limiter.ar(snd, 0.95);

	snd = HPF.ar(snd,200); //
	snd = LeakDC.ar(snd);
	//snd = RHPF.ar(snd,200,0.99);
	snd = IIRFilter.ar(snd,4000);
	env = Env.asr(1, \amp.kr(1), \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd * env;
	snd = Pan2.ar(snd,\pan.kr(0));
	Out.ar(\out.kr(0), snd);
}).add;
)

// testing
a = Synth(\chill,[\lower,1,\upper,3,\drum_amp,0.2,\drum_tone,0.001,\mix,0.9,\snd2_amp,2]);

a.set(\lower,1,\upper,4,\drum_amp,0.25,\drum_tone,0.1,\drum_amp2,0.05,\mix,0.9,\snd_amp,0.01,\snd2_amp,0.5,\res_short,4);

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// a routine
/// do I add lag to snd_tone?
(
TempoClock.default.tempo_(60/60);
t = Task({
	"start".postln;
	a = Synth(\chill,[\drum_tone,0.01,\drum_amp,0,\drum_amp2,0]);

	8.wait;
	a.set(\drum_amp,0.15);

	24.wait;
	"perc higher pitch".postln;
	a.set(\drum_tone,0.001,\drum_amp2,0.0025);


	////////////////////////////////
	16.wait;
	"perc muted".postln;
	a.set(\drum_amp,0.04,\drum_tone,0.005,\mix,0.13);


	///
	16.wait;

	"perc deep pitch, slow beat".postln;
	// bird sounds is drum_amp2
	a.set(\lower,1,\upper,4,\drum_amp,0.25,\drum_tone,0.1,\drum_amp2,0.05,\mix,0.9,\snd_amp,0.01,\snd2_amp,0.5,\res_short,4);


	8.wait;
	a.set(\snd_amp,0.03);
	8.wait;
	a.set(\snd_amp,0.075);
	4.wait;
	a.set(\snd_amp,0.15);


	//////////////////////////////
	4.wait;
	"perc wider beat, middle pitch".postln;
	a.set(\lower,1,\upper,8,\drum_amp,0.15,\drum_tone,0.01,\drum_amp2,0.01,\mix,0.09,\snd_amp,0.25,\snd2_amp,1,\res_short,0.5);

	8.wait;
	"perc tigher beat and faster, higher pitched".postln;
	a.set(\lower,4,\upper,8,\drum_amp,0.08,\drum_tone,0.001,\drum_amp2,0.0025,\snd_amp,6);

	//////////////////////////////
	1.wait;
	a.set(\snd_amp,0.6);


	/////
	15.wait;
	"wobbly chord".postln;
	a.set(\snd_tone,0.35,\drum_amp,0.04,\drum_tone,0.005,\drum_amp2,0,\snd2_amp,0,\snd_amp,1);

	8.wait;
	"sustain chord".postln;
	a.set(\snd_tone,5,\lagu,0,\lagd,0);


	///

	12.wait;
	"return chord, longer beat, modify chord tone".postln;
	a.set(\snd_tone,1,\snd_mod,3,\lower,1,\upper,4,\drum_amp,0.15,\drum_tone,0.01,\lagu,0.4,\lagd,0.1,\drum_amp2,0.005);

	4.wait;
	a.set(\snd_mod,3,\lower,3,\upper,4);

	28.wait;o
	"back to start".postln;
	a.set(\lower,1,\upper,8,\drum_amp,0.15,\drum_tone,0.01,\lagu,0.9,\snd2_amp,1);

	16.wait;
	"release".postln;
	a.set(\drum_amp2,0);
	a.release(18);


	// fade out

});
)

t.play;

