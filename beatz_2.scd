s.boot;

Server.killAll;
("Setup/Setup.scd").loadRelative


/*
(
// Basic drum kit

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

/*SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
var env, snd1, snd2, sum;
env = Env.perc(att, rel, amp).kr(doneAction: 2);
snd1 = HPF.ar(
in: WhiteNoise.ar,
freq: ffreq,
mul: env
);
snd2 = SinOsc.ar(freq: sinfreq, mul: env);
sum = snd1 + snd2;
Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
var env, snd, ramp;
env = Env.perc(att, rel, amp).kr(doneAction: 2);
ramp = XLine.kr(
start: sinfreq,
end: sinfreq * glissf,
dur: rel
);
snd = SinOsc.ar(freq: ramp, mul: env);
snd = Pan2.ar(snd, pan);
Out.ar(out, snd);
}).add;*/

// Basic saw synth for chords and bass
SynthDef("sawSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, fb=0,cfhzmin=0.1, cfhzmax=0.3,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, pan=0;
	var env, snd;
	env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
	snd = SinOscFB.ar(freq * [0.99, 1, 1.001, 1.008],fb);
	//snd = TwoTube.ar(snd);
	snd = BPF.ar(
		snd,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)
		).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
	);
	//snd = LPF.ar(snd, 4000);
	//snd = SinOscFB.ar(snd,fb);
	snd = LeakDC.ar(snd);
	snd = Splay.ar(snd);
	snd = snd * env;
	Out.ar(0, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\kik, { |basefreq = 32, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 1,
	decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
	var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
	sig = SinOscFB.ar(fcurve, 0.5, preamp).softclip * env * amp;
	sig = LPF.ar(sig, 4000);
	sig = HPF.ar(sig, 15);
	sig = LeakDC.ar(sig);
	Out.ar(out, sig ! 2)
}).add;

//I fucked up the snare by adding the saw, RLPF, compander, LPF and Balance args.
SynthDef(\kraftySnr, { |amp = 1, freq = 2000, rq = 3, decay = 0.3, pan, out|
	var sig, env, sub;
	sig = PinkNoise.ar(amp);
	env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
	sig = BPF.ar(sig, freq, rq, env);
	//sub = Saw.ar([freq/2, freq/4]/4);
	//sig = sub*sig;
	sig = RLPF.ar([sig, sig/2], freq*4 * (LFNoise2.ar(0.1).range(1,10)/pi).lagud([0.2, 0.5]).lagud , 1);
	sig = Compander.ar(sig, SinOsc.ar(rq), 0.5,0.0005,1.5,0.001,0.5); //control:
	sig = LPF.ar(sig, 4000).fold2;
	sig = LPF.ar(sig, 4000);
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, Pan2.ar(sig, pan))
}).add;

)*/



// Example 1 - hihat only
(
Pbind(
	\instrument, "hihat",
	\dur, Pbjorklund2(Pwrand([2,3,6],[0.5,0.25,0.25],inf), 8)/4,/*Pseq([
		1/8,         1/8,          1/8,                  1/8, // beat 1
		1/8,         1/8,          1/16, 1/16,      1/8, // beat 2
		1/8,         1/8,          1/16, 1/16,      1/8, // beat 2
		1/8,         1/8,          1/16, 1/16,      1/32, 1/32, 1/32, 1/32, 1/8 // beat 2
	], inf),*/
	\att, 0.01,
	\rel, 0.05,
	\ffreq, 11000,
	\pan, 0,
	\amp, 0.3,
	\tempo, 90/60,
	\out,~bus[\comb],//~bus[\chorus]
).play;
)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// A groove
(
t = TempoClock.default.tempo = 55 / 60;

// hihat
Pbindef(\hihat,
	\instrument, Pwrand([\hihat,\bpfsaw],[20,1].normalizeSum,inf),
	\dur, Pseq([Rest(1/4), 1/4, Pwrand([
		Pseq([Rest(1/4), 1/4],1),
		Pseq([Rest(1/4), 1/16,1/16,1/16,1/16],1)],[5,1].normalizeSum,1)
	], inf),
	\att, 0.01,
	\rel, 0.1,
	\midinote,Prand([36, 32, 32, 37], inf)/2,
	\ffreq, 11000,
	\pan, -0.3,
	\amp, 0.3,
	\out,~bus[\reverb],
);

// flat kik
Pbindef(\flatkik,
	\instrument, \kick,//Pseq([\kick1, \kick2, \kick3, \kick1, \kik], inf),
	\dur,Pseq([1/2, Pwrand([
		1/2,
		Pseq([1/8,1/8,1/4],1)],[10,1].normalizeSum,1)
	], inf),
	\basefreq,23.midicps*Pwrand([1,0.75,1.5],[0.8,0.15,0.05],inf),
	\rel, 0.12,
	\ratio,Pwrand([20,3],[0.05,0.95],inf),
	\amp, 0.5,
	\out,0,
);

// snare
Pbindef(\snare,
	\instrument, \kraftySnr,
	\dur, Pseq([Rest(1/2), 1/2], inf),
	\att, 0.01,
	\rel, 0.1,
	\rq,10,
	//\sinfreq, 180,
	//\ffreq, 2000,
	\amp, 0.05,
	\pan,0.2,
	\out,0,
);

// 3-bar rushup?
Pbindef(\rush,
	\instrument, Pseq([\kick1, \kraftySnr, \kick1, \kick1, \kraftySnr], inf),
	\dur, PdurStutter(Pseq(#[1,1,1,1,1, 2,1,2,2,2, 2,1,1,4,1],inf),Pseq(#[0.5, 1, 2, 0.25,0.25],inf)),
	\att, 0.01,
	\rel, 0.1,
	\rq,7,
	//\sinfreq, 180,
	//\ffreq, 2000,
	\amp, 0.2,
	\pan,-0.2,
	\out,0,
);


// pads
Pbindef(\pads,
	\instrument,\sinfb,
	\midinote, //Pseq(~b2+12,inf), //~b1 from simple pads
	Pseq([
		Pn(
			Pxrand([
				[23,35,54,63,64],
				[45,52,54,59,61,64],
				[28,40,47,56,59,63],
				[42,52,57,61,63],
		],1)
			,64),
		Pn(
			Pseq([
				[23,35,54,63,64],
				[45,52,54,59,61,64],
				Prand([
					[28,40,47,56,59,63],
					[42,52,57,61,63]], 1)
		],1)
			,16)
	],
	inf),
	\dur, Prand([1, 3, 4, 4.5], inf),
	\atk, 0.1,
	\fb,Pseg([1/100,0.75,1/100],100,\lin,inf),
	\rel, Pkey(\dur) + 1,
	\pan,0.3,
	//hifreq, 5000,
	\amp, 0.7 * Pseg([0.3,0.37,0.3],100,\lin,inf),
	\out,~bus[\reverb],
);

//pads 2
Pbindef(\pads2,
	\instrument,\organ_donor,
	\midinote, Pseq([
		Pn(
			Pxrand([
				Pseq([23,35,54,63,64],inf),
				Pseq([45,52,54,59,61,64],inf),
				Pseq([28,40,47,56,59,63],inf),
				Pseq([42,52,57,61,63],inf),
		],1)
			,64),
		Pn(
			Pseq([
				Pseq([23,35,54,63,64],inf),
				Pseq([45,52,54,59,61,64],inf),
				Prand([
					Pseq([28,40,47,56,59,63],inf),
					Pseq([42,52,57,61,63],inf)], 1)
		],1)
			,16)
	],
	inf) ,
	\dur, Prand([1, 3, 4, 4.5], inf)/Pseg([20,30,20],100,\lin,inf),
	\atk, 0.05,
	//\fb,0.1,//Pseg([1/100,0.75,1/100],100,\lin,inf),
	\rel, Pkey(\dur) + 0.05,
	\pan,-0.2,
	\cutoff,1000,
	//\hifreq, 400,
	\amp, 0.1 * Pseg([0.3,0.37,0.3],100,\lin,inf),
	\out,~bus[\reverb],
) <> Pbindef<>(\pads);


// counterpoint
Pbindef(\counterpoint,
	\instrument, \twotubes,
	\midinote, Pxrand([61, 63, 63, 64],inf),
	\dur, Pseq([
		Pn(Pseq([1/4, 1/4, 1/2, Rest(3.75), 1/4], 1),8),
		Pn(Pseq([1/2, 1/4, 1/4, Rest(3.75), 1/4],8),1)
	],inf),
	\ctranspose, [0, 12,-12],
	\rel, 0.2,
	\amp, 0.1,
	\k, Pseq([Pn(0,32),Pn(0.09,32)],inf), // -0.001
	\loss,Pseg([-1,1.1,-1],100,\lin,inf), //0.1
	\out,Pwrand([0,~bus[\comb]],[0.9,0.1],inf),
	\rand,Pwhite(-10,10,inf),
);
)



(
Pbindef(\hihat).play(t,quant:1);
Pbindef(\flatkik).play(t,quant:1);
Pbindef(\snare).play(t,quant:1);
Pbindef(\rush).play(t,quant:1);
Pbindef(\pads).play(t,quant:1);
Pbindef(\counterpoint).play(t,quant:5);
)

Pbindef(\pads2).play(t,quant:1);

(
Pbindef(\hihat).stop;
Pbindef(\flatkik).stop;
Pbindef(\snare).stop;
Pbindef(\rush).stop;
Pbindef(\pads).stop;
Pbindef(\pads2).stop;
Pbindef(\counterpoint).stop;
)




Pbindef(\counterpoint,\dur,PdurStutter(Pseq([1,1,1,1,1, 2,1,2,2,2, 2,1,1,1,4],inf),Pseq([1/4, 1/4, 1/2, Rest(3.75), 1/4],inf)));

Pbindef(\flatkik,\ratio,Pwrand([20,3],[0.05,0.95],inf));

Pbindef(\pads2,\rel, Pkey(\dur) + 0.2,\ctranspose, [0, 12,-12],\mtranspose, [0, 12,-7],\amp,0.05);

Pbindef(\pads2,\dur,Pbjorklund2(Pwrand([2,3,5],[0.6,0.2,0.2],inf), 8)/30);




