(
Server.killAll;
("Setup/Setup.scd").loadRelative; // load this file
//~fade = { |start, end, time, curve = 0| Pseg(Pseq([start, Pn(end)]), time, curve) };
)

//attempt to communicate

////////////////////////

(SynthDef(\foote,
{
    var trig, in, chain, chain1, chain2, snd2, snd, freqs, gloop, perc, detect_g, detect_p, detect_arp, arp, arp2, env;
	trig = LFNoise1.kr([4.9,2.45],300,300); // LFNoise1.kr([4.9,2.45],300,300)
	in = SinOscFB.ar(trig,trig/1000);
	chain = FFT(LocalBuf(2048), in, 0.85, 1);
		chain1 = PV_RandComb(chain, \wipe.kr(0.68), trig);//Impulse.kr(2)); // 0.68
	    //chain1 = PV_RectComb(chain1, 1, LFTri.kr(0.097,0,0.4,0.5),LFTri.kr(0.24,0,-0.5,0.5));//Impulse.kr(2));
	snd = IFFT(chain1,1).poll;
	//snd2 = IFFT(chain2,1).poll;



	detect_g = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), in), 0.3, 0.3, 0.90, 0.5);
	gloop = Pluck.ar(detect_g,detect_g,0.05,0.05,0.5,0.8);
	gloop = MoogFF.ar(gloop,  SinOsc.kr(LFNoise0.kr(1).linlin(-1,1,0.1, 200)).range(3, 400),3.4);


	detect_arp = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), in), 0.5, 0.5, 0.7, 0.5);
	perc = GVerb.ar(
		CombC.ar(
			Mix.ar(
				VOSIM.ar(detect_arp,
					snd *chain1 * 2000,
					[5,50,500,5000],0.5,0.5)
	)
			,1,0.5,1.2,1.5)
		,15,5,0.2,0.5,50,2);


	detect_p = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), in), 0.3, 0.25, 0.7, 0.5);
	arp = -15.dbamp * RLPF.ar(GVerb.ar(
		SinGrain.ar(Mix.ar(detect_p),0.12,snd.linlin(-1e-2,1e-2,300,900).round(100),0.1)
		,15,3,LFNoise1.kr(1).linexp(-1,1,0.1,0.9)),
	1000,LFNoise1.kr(1).linexp(-1,1,0.1,4));

	//perc = SinGrain.ar(detect_p,0.01,in*200,2);
	/*perc2 = -18.dbamp * Pluck.ar(
		Hasher.ar(Sweep.ar(detect_p)),//,
		detect_p,
		in*200,
		in*200,
		1, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5); */
	arp2 = arp * SinGrain.ar(detect_arp,0.5,in.linlin(2.45,4.9,2000,2500),0.5);


	snd = snd
	      //+ snd2
	      + arp
	      + arp2
	      + perc
	      + gloop;
	snd = LeakDC.ar(snd,0.9);
	snd = LPF.ar(snd,3000) * -10.dbamp;

	env = Env.asr(1, \amp.kr(1), \release.kr(8)).kr(2, \gate.kr(1));
	snd = snd *env;
	snd = snd!2;
	Out.ar(0,snd);
}).add;
)

a= Synth(\foote);


(
TempoClock.default.tempo_(60/60);
t = Task({
	a= Synth(\foote);
	d = Synth("metaldrum",[\ibase,1,\t,1/20,\irange,300,\ringfreq,[33].midicps,\roomsize,50,\amp, -25.dbamp]);

	24.wait;
	a.set(\wipe,0.8);
	d.set(\roomsize, 40);

	24.wait;
	a.set(\wipe,0.5);
	d.set(\roomsize, 30);


	24.wait;
	a.set(\wipe,0.8);
	d.set(\roomsize, 20);

	24.wait;
		a.set(\wipe,0.68);
	d.set(\roomsize, 10);


	24.wait;
	a.set(\gate,0);

	8.wait;
	d.set(\ringfreq, 38.midicps);

	16.wait;
	d.set(\ibase, 10,\roomsize, 1);
});
)

t.play;


a= Synth(\foote);
a.set(\wipe,0.4)

d = Synth("metaldrum",[\ibase,1,\t,1/20,\irange,300,\ringfreq,[33].midicps,\roomsize,50]);
d.set(\ringfreq,38.midicps,\roomsize,10)
d.set(\ibase, 10);

45,42,40,38