

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
SynthDef(\rungler, {
	var trig, snd, freqs, perc, a;
	trig = {lfo.()!2}; //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFDNoise3.kr(32.reciprocal).linexp(-1, 1, 48, 72).round(12).poll(1) +  [-12, 0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		LFNoise2.kr(0.1).linlin(-1,1,1.8,3),
		freqs.reciprocal, //LFNoise2.kr(1/15).linexp(-1,1,0.5,0.9)
	);
	snd = -18.dbamp * snd;
	perc = SinGrain.ar(trig,trig * Select.kr(ToggleFF.kr(trig),[1,3,5]),freqs,0.05);
   // perc = DelayC.ar(perc, 0.01, SinOsc.ar(20.reciprocal, [0, pi]).range(0, 0.01));
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0.251);
	snd = snd
	         + perc
	         + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,trig);
	snd = snd ! 2;

	Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\rungler);


