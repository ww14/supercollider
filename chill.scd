// chill
// non-enveloped
(
SynthDef(\chill, {
	var trig, snd, freqs, perc, perc2, percVerb, out, env;
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, \lower.kr(1), \upper.kr(8))); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(4.reciprocal).linexp(-1, 1, 52, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = FMGrain.ar(trig,\snd_tone.kr(0.95),freqs.lag3ud(\lagu.kr(0.015),\lagd.kr(0.1)),\snd_mod.kr(2)*freqs,mul:0.01);
	perc = SinGrain.ar(trig,\drum_tone.kr(0.001).lag3(4),freqs/8,\drum_amp.kr(0.15).lag3(2));
	perc2 = SinGrain.ar(trig,\drum_tone2.kr(0.005).lag3(0.1),freqs/0.1,\drum_amp2.kr(0.005).lag3(2));
	//perc = perc + perc2;
	percVerb = NHHall.ar([perc,perc2],5,0.5);
	perc = XFade2.ar(perc, percVerb, \mix.kr(0.09))
	         + DelayC.ar(percVerb, 1, SinOsc.ar(0.05, [0, pi]).range(0, 1),0.7);
	//snd = CombN.ar(snd,0.9);


	snd = snd + perc ;
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
a = Synth(\chill,[\lower,4,\upper,8,\snd_tone,0.35,\drum_amp,0.04,\drum_tone,0.005]);


// a routine
(
TempoClock.default = 1;
t = Task({
	"start".postln;
	a = Synth(\chill,[\drum_tone,0.01,\drum_amp2,0]);

	32.wait;
	"perc higher pitch".postln;
	a.set(\drum_tone,0.001,\drum_amp2,0.005,\mix,0.2);

	16.wait;
	"perc muted".postln;
	a.set(\drum_amp,0.04,\drum_tone,0.005,\mix,0.09);


	///
	16.wait;
	"perc deep pitch, slow beat".postln;
	a.set(\lower,1,\upper,2,\drum_amp,0.25,\drum_tone,0.1,\mix,0.9);

	12.wait;
	"perc wider beat, middle pitch".postln;
	a.set(\lower,1,\upper,8,\drum_amp,0.15,\drum_tone,0.01,\mix,0.09);

	12.wait;
	"perc tigher beat and faster, higher pitched".postln;
	a.set(\lower,4,\upper,8,\drum_amp,0.1,\drum_tone,0.001);


	/////
	16.wait;
	"wobbly chord".postln;
	a.set(\snd_tone,0.35,\drum_amp,0.04,\drum_tone,0.005,\drum_amp2,0);

	8.wait;
	"sustain chord".postln;
	a.set(\snd_tone,5,\lagu,0,\lagd,0);


	///

	12.wait;
	"return chord, longer beat".postln;
	a.set(\snd_tone,1,\snd_mod,3,\lower,1,\upper,4,\drum_amp,0.15,\drum_tone,0.01,\lagu,0.4,\lagd,0.1,\drum_amp2,0.005);

	32.wait;
	"back to start".postln;
	a.set(\lower,1,\upper,8,\drum_amp,0.15,\drum_tone,0.01,\lagu,0.9);

	16.wait;
	"release".postln;
	a.set(\drum_amp2,0);
	a.release(16);


	// fade out

});
)

t.play;

