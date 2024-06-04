

(
var lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(1.reciprocal).linexp(-1, 1, 1, 50)); //Dust.ar(1);
	//LFNoise2.ar(TExpRand.ar(0.5, 10, trigger))
	Select.ar(ToggleFF.ar(trigger), [
		LFNoise2.ar(TExpRand.ar(0.5, 10, trigger)),
		TRand.ar(-1, 1, trigger),
	]);
};
SynthDef(\fell, {
	var trig, snd, freqs, perc, a, chord, env;
	trig = {lfo.()!2}; //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFDNoise3.kr(32.reciprocal).linexp(-1, 1, 60, 72).round(12).poll(0.5) +  [-12, 0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		LFNoise2.kr(0.1).linlin(-1,1,[0.1,0.8],[3,1]),
		LFNoise2.kr(1).linlin(-1,1,-0.2,0.4), //LFNoise2.kr(1/15).linexp(-1,1,0.5,0.9)
	);
	snd = -12.dbamp * Splay.ar(snd!2);
	perc = SinGrain.ar(trig,LFDNoise3.kr(1).linexp(-1, 1, 0.001,0.05),freqs * LFDNoise3.kr(10).linexp(-1, 1, 0.1, [2,10]),0.05);
	perc = -2.dbamp * Splay.ar(perc,0.3);
	chord = SinGrain.ar(trig,5,freqs*[0.5,1,1.002,2],0.005);
   // perc = DelayC.ar(perc, 0.01, SinOsc.ar(20.reciprocal, [0, pi]).range(0, 0.01));
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0.251);
	snd = BBandPass.ar(snd,1200,1);
	snd =  snd
	        + perc + chord
	        + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,trig);
	//snd = snd ! 2;
	snd = Splay.ar(snd,0.9);
	snd = NHHall.ar(snd,0.61,0.25);
	env = Env.asr(1, \amp.kr(1), \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd * env;


	Out.ar(\out.kr(0), snd);
}).add;
)

a = Synth(\fell);
a.release;



