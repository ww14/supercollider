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
	snd = \amp_snd.kr(1) * IFFT(chain1,1).poll;
	//snd2 = IFFT(chain2,1).poll;



	detect_g = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), in), 0.3, 0.3, 0.90, 0.5);
	gloop = Pluck.ar(detect_g,detect_g,0.05,0.05,0.5,0.8);
	gloop = MoogFF.ar(gloop,  SinOsc.kr(LFNoise0.kr(1).linlin(-1,1,0.1, 200)).range(3, 400),3.4,0,\amp_gloop.kr(1));


	detect_arp = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), in), 0.5, 0.5, 0.7, 0.5);
	perc = GVerb.ar(
		CombC.ar(
			Mix.ar(
				VOSIM.ar(detect_arp,
					snd *chain1 * 2000,
					[5,50,500,5000],0.5,0.5)
	)
			,1,0.5,1.2,1.5)
		,15,5,0.2,0.5,50,2,mul:\amp_perc.kr(1));


	detect_p = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), in), 0.3, 0.25, 0.7, 0.5);
	arp = \amp_arp.kr(1) * -15.dbamp * RLPF.ar(GVerb.ar(
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
    arp2 = \amp_arp2.kr(1) * arp * SinGrain.ar(detect_arp,0.5,in.linlin(2.45,4.9,2000,2500),0.5) ;


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

d = Synth("metaldrum",[\ibase,1,\t,1/20,\irange,300,\ringfreq,[33].midicps,\roomsize,50,\amp, -25.dbamp])
d.set(\amp,-27.dbamp);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////the piece ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

s.prepareForRecord;

(
TempoClock.default.tempo_(60/60);
t = Task({
	//s.record;
	"start".postln;
	1.wait;
	a= Synth(\foote);
	a.set(\amp_gloop, 0, \amp_perc, 0, \amp_snd, 0);
	d = Synth("metaldrum",[\ibase,1,\t,1/20,\irange,300,\ringfreq,[33].midicps,\roomsize,50,\amp, -28.dbamp]);

	12.wait;
	a.set(\amp_snd, 1, \amp_arp2, 0);

	12.wait;
	a.set(\wipe,0.8);
	a.set(\amp_arp2, 0.5, \amp_perc, 1);
	d.set(\roomsize, 40);

	24.wait;
	a.set(\wipe,0.5);
	a.set(\amp_perc, 0.5, \amp_gloop, 0.75);
	d.set(\roomsize, 30);


	24.wait;
	a.set(\wipe,0.8);
	a.set(\amp_snd, 0.75, \amp_arp2, 0.75, \amp_gloop, 0.5);
	d.set(\roomsize, 20);

	24.wait;
	a.set(\wipe,0.68);
	a.set(\amp_perc, 1, \amp_gloop, 0.5, \amp_arp,0.25);
	d.set(\roomsize, 10);


	24.wait;
	a.set(\amp_snd, 1, \amp_arp, 0, \amp_gloop, 0, \amp_perc, 0.25);
	a.set(\gate,0);

	8.wait;
	d.set(\ringfreq, 38.midicps);

	12.wait;
	d.set(\ibase, 10,\roomsize, 1);

	10.wait;
	//s.stopRecording;
});
)


t.play;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

a= Synth(\foote);
a.set(\wipe,0.4)

d = Synth("metaldrum",[\ibase,1,\t,1/20,\irange,300,\ringfreq,[33].midicps,\roomsize,50]);
d.set(\ringfreq,38.midicps,\roomsize,10)
d.set(\ibase, 10);

45,42,40,38