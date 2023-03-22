(
~bus = Bus.audio(s,2);

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


(
y = Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbindef(\perc_high,
	\instrument, \SOSkick,
	\dur,Pn(Pshuf([3,1,1,1],3),inf)/8,//Pseg([200,500,200],10,\lin,inf),
	\freq,30,
	\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
	\mod_index,[1000],
	\pan,-0.2,
	\amp,(0.21 - (1 / Pkey(\mod_freq))),
	\out,~bus,
).play;
)

(Pbindef(\perc_high, \freq,[30,60],\mod_index,[1000,10000],\mod_freq, Pwrand([5,4,3,2,1,1000],[10,2,1,0.5,0.1].normalizeSum,inf),\amp,(0.15 - (1 / Pkey(\mod_freq)).linlin(0,25,0,0.15)),\dur,Psubdivide(
			Pseq([1!24,2!6,1!6,4!6,2!6].flatten,inf),
			Pseq(#[6,1,3,4,2],inf)
)/4,));
