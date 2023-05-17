// chill
// non-enveloped
(
SynthDef(\chill, {
	var trig, snd, freqs, perc, percVerb, out, env;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, \lower.kr(1), \upper.kr(8))); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(4.reciprocal).linexp(-1, 1, 52, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = SinGrain.ar(trig,\snd_tone.kr(1),freqs,0.01);
	perc = SinGrain.ar(trig,\drum_tone.kr(0.001),freqs/8,\drum_amp.kr(0.15));
	percVerb = NHHall.ar(perc!2,5,0.5);
	perc = XFade2.ar(perc, percVerb, \mix.kr(0.009).linlin(0,1,-1,1))
	         + DelayC.ar(percVerb, 1, SinOsc.ar(0.05, [0, pi]).range(0, 1),0.7);
	//snd = CombN.ar(snd,0.9);
	snd = snd + perc ;
	snd = snd ! 2;
	//snd = Limiter.ar(snd, 0.95);
	env = Env.asr(1, \amp.kr(1), \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd * env;
	snd = Pan2.ar(snd,\pan.kr(0));
	Out.ar(\out.kr(0), snd);
}).add;
)


a = Synth(\chill,[\drum_tone,0.01]);

a.set(\drum_tone,0.001);

a.set(\drum_amp,0.04,\drum_tone,0.005);

a.set(\lower,1,\upper,2,\drum_amp,0.15,\drum_tone,0.1);

a.set(\lower,1,\upper,8,\drum_amp,0.15,\drum_tone,0.01);

a.set(\lower,4,\upper,8,\drum_amp,0.1,\drum_tone,0.001);

a.set(\snd_tone,0.25);

a.set(\snd_tone,5);

a.set(\snd_tone,1);

a.set(\lower,1,\upper,8,\drum_amp,0.15,\drum_tone,0.01);

a.release(16);