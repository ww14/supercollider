s.options.memSize = 1048576;

s.reboot;  // this is important!


(SynthDef(\oneshot,
{
	var trig, snd, freqs, perc, percVerb, env,duration;
	//trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
		freqs = (\midi.kr(32) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	perc = SinGrain.ar(Impulse.kr(10),0.51,freqs,4);

	perc = perc + (RLPF.ar(Hasher.ar(Sweep.ar),4210,0.3) * Env.perc(0.001,0.01).ar * 5.dbamp);
	perc = perc + (RHPF.ar(Hasher.ar(Sweep.ar),6210,0.3) * Env.perc(0.001,0.03).ar * -9.dbamp);
	perc = perc * (1 + (5 * Env.perc(0,0.01).ar));
	perc = perc.clip2 + (perc.fold2 * -10.dbamp);
	perc = perc + HPF.ar((perc*6.dbamp).tanh, 3000);
	perc = perc * Env.perc(0.01,0.5).ar;
	perc = perc + HPF.ar(LPF.ar(DelayC.ar(perc * -25.dbamp, 0.1, [30e-3, 33.4e-3]), 5000), 100);

	duration = \duration.kr(4);

	percVerb = NHHall.ar(perc!2,duration,0.3);

	perc = XFade2.ar(perc * 0.05, percVerb, \mix.kr(0.009).linlin(0,1,-1,1));
	      //   + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.9);
	snd = perc ;
	env = Env.linen(0,duration, duration, curve:-2).ar(Done.freeSelf);
	snd = snd * env;

	snd = snd ! 2;
	Out.ar(\out.kr(0),snd);
}).add;
)

Synth(\oneshot, [\duration,200,\midi,58]);

Synth(\oneshot, [\duration,2,\midi,58,\mix,0.025]);
Synth(\oneshot, [\duration,0.15,\midi,51,\mix,0.05]);
