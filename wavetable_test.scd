Server.killAll;
("setup/Setup.scd").loadRelative // load this file


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////synthdefs

(
SynthDef(\vink,{
var in, trig, snd, ff, rmf, env, freq;

	ff = \ff.kr(1000).lag3;
	rmf = \rmf.kr(600).lag3;


	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, \low.kr(8).lag3, \high.kr(8).lag3)); //LFDNoise makes the higher freq steps less discrete/quantized
	//trig = Dust.ar(0.9);

	snd =  ClipNoise.ar(0.2);



	freq = \freq.kr(440)	;

	snd = Pluck.ar(snd, trig, \maxdelaytime.kr(0.2) , freq.reciprocal , \decaytime.kr(1) , \coef.kr(0.81)).distort; //fundamental
	in = LocalIn.ar(2) + [snd,snd];

	//snd = SinGrain.ar(snd,1000.reciprocal,\freq.kr(440).lag3(4),0.025);

	in  = DFM1.ar(in, SinOsc.kr(SinOsc.kr(\vibrato.kr(0.3)).range(0.2, 3)).range(80, 2000), \res.kr(0.01), \inputgain.kr(0.5) , 0, \noiselevel.kr(0.0003));

	snd = snd  + in;

	snd = GVerb.ar(snd,\roomsize.kr(10),1,0.9,0.5,\spread.kr(15));
	//snd = NHHall.ar(snd,1,0.5);

	snd = Compander.ar(snd,snd,
		thresh: 0.1,
        slopeBelow: 1,
        slopeAbove: 1,
        clampTime:  0.1,
        relaxTime:  0.2);

	//LocalOut.ar(snd);
	//snd;

	snd = LeakDC.ar(snd).tanh;
	snd = MoogFF.ar(snd, LFNoise2.kr(0.75).linexp(-1, 1, 500, 1600), 0);


	snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	//snd = snd * \amp.kr(1);
	env = Env.asr(\atk.kr(1), \amp.kr(1).lag3(6), \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd *env;
	Out.ar(0,snd);
}).add;


(
//metal
SynthDef(\wooden,{
	var snd, duration, noise, env, sineFreq, auto;
	duration = \duration.kr(0.3);
	snd = (SinOsc.ar(20 * [0.7, 3.3, 5.44, 7.33, 12.33] * XLine.ar(1.5, 1, 0.001)));
	snd = snd * Env.perc(0.001, [0.1, 0.05, 0.03, 0.003, 0.04, 0.01]).ar;
	snd = snd.sum;
	snd = snd * (1 + SinOsc.ar(1000));
	snd = snd * (1 + SinOsc.ar(\pitch.kr(300)));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar),3320,0.3) * Env.perc(0.001,0.02).ar);
	snd = snd + PitchShift.ar(snd, 0.03,  \shift.kr(1.1));
	snd = snd * (1 + Env.perc(0,0.02).ar);
	snd = snd.tanh * -15.dbamp;
	snd = snd * (1 + Env.perc(0,0.02).ar);
	snd = snd + GVerb.ar(snd * -20.dbamp, 30, 1);
	env = Env.linen(0,duration,0.001, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	//snd = snd + CombC.ar(snd,mul:0.5);
	snd = snd * -8.dbamp * \amp.kr(1);
	Out.ar(\out.kr(0),snd);
}).add;);

(SynthDef(\test,
{
    var list, trate, dur, clk, pos, pan, snd, in, chain, env;
	env = EnvGen.kr(
			Env.linen(\atk.kr(0.01),\sus.kr(0.1),\dur.kr(1),0.9,\cRel.kr(-3)),
		doneAction:2
	);


	list = Wavetable.chebyFill(256, 1.0 / [1, 2,10, 3, 10, 5, 6, 10],zeroOffset: true);
    // list.plot;
    b = LocalBuf.newFrom(list);
	trate = \trate.kr(500);
    dur = 60 / trate;
    clk = Impulse.kr(trate);
	pos = \pos.kr(0.5)*BufDur.kr(b) + TRand.kr(0, 0.01, clk);
	pan = BrownNoise.kr(0.9);
		snd = TGrains.ar(8, clk, b, \rate.kr(1) + \root.kr(0), pos, dur, pan, 0.1).sum;
	snd = Splay.ar(snd);
	snd = NHHall.ar(snd,60,0.95);

	snd= snd*env*\amp.kr(1);
	Out.ar(\out.kr(0),snd);
}).add;);

);



//Synth(\ping)


// Synth(\ping, [\freq, 1000]);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////testing

(Pbindef(\wooden,
	\instrument,\wooden,
	\pitch,45.midicps,  // [8,8,8,12,15] [8,7,12]
	\shift,Pwhite(0.85,1.2),
	\dur, Pseq([0.5],inf),
	//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-6.dbamp,
	\out,0
);
)

Pbindef(\wooden).play;
Pbindef(\waveTable).play

a = Synth(\test,[\rate,31.midiratio,\dur,2,\cRel,0]);
a.set(\trate,300);
a.set(\rate,0.02);
a.set(\pos,0.1)

(
Pbindef(\test_mel, \instrument,\test,
	\rate,Pseq([1e-3!24,[1e-3,-12]!24].flatten,inf)+Pseq(
	   (1+ [31,31,31,32,28,31,
			31,[35,36],32,32,28,31,
	     31,31,31,32,28,31,
		 31,28,32,31,32,28,
	]).midiratio,inf),
	\dur, 1/4*Pseq(
		[1,1,1,0.5,0.5,0.5,
		 1,1,1,0.5,0.5,0.5,
		 1,1,1,0.5,0.5,0.5,
  		 1,0.5,0.5,1,1,0.5
	],inf),
	\cRel,Pwhite(-4,0),
	\pos,Pwhite(0,1),
	\trate, 150,//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,0.dbamp
);
)


(
Pbindef(\test_mel_2, \instrument,\test,
	\rate,[1e-3,-8]+Pseq(
	   (1+ [31,32,28,31,
			[35,36],32,28,31,
	     32,28,31,
		 28,32,31,32,28,
	]),inf),
	\dur, 1/16*Pseq(
		[3,0.5,0.5,1.5,
		 1,1.5,0.5,3.5,
		 0.5,0.5,1.5,
  		 0.5,0.5,1,1,0.5
	],inf),
	\cRel,Pwhite(-3,0),
	\pos,Pwhite(0,1),
	\trate, 100,//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,0.dbamp
);
)

Pbindef(\test_mel_2).play

[8,7,9,5,3].sum

Synth(\kick);

t = TempoClock.default.tempo = (66/60);
//t.schedAbs(t.nextTimeOnGrid(32, -0.001));
Pbindef(\kick).play(t);
Pbindef(\snr).play(t);
Pbindef(\waveTable).play(t);
(Pbind(
	\instrument, \test,
  \degree, Pclump(Pseq([3, 3, 4, 2, 4, 2, 4], inf), Pseq([1, 3, 5, 7, 9], inf), inf),
	\dur, 1/8,
	\rel,1/8,
	\curve,2,
	\rq,Pwhite(0.1,0.2),
	\amp, -8.dbamp
).play;
)

(Pbind(
	\instrument, \vink,
  \degree, 1+Pclump(Pseq([3, 3, 4, 2, 4, 2, 4], inf), Pseq([1, 3, 5, 3, 2], inf), inf),
	\dur, 1,
	\rel,1/8,
	// \curve,50,
	\rq,0.15,
	\amp, -6.dbamp
).play;
)


8.midiratio

Pbindef(\test_mel).play(t);


(
Pbind(\instrument,\test,
	\rate,0.midiratio+Pseq(
		 [8,4,8,11].midiratio,inf),
	\dur, Pseq([0.25,0.25,0.5,0.25],inf),
	 \cRel,0,
	\trate, 100,//Pstep([100,10],[32,32],inf),//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-6.dbamp
).play;
)


//Modest mouse lounge riff
(Pbindef(\test_mel,\instrument,\test,
	\rate,[1.98,1]* Pseq([
		[32,37,44,47],
		[32,37,44],
		[32,37,44],
		[32,37,44,47],
		[32,37,44],
		[32,37,44,40],
		[32,37,44,41],
		[32,37,44,43],
		[32,37,44,41],
		[32,37,44]
        ].midiratio,inf),
\dur, 1/2 * Pseq([2,1,1,2,1,2,2,2,1,2, //1
	2,1,1,2,1,2,2,2,1,2, //2
	2,1,1,2,1,2,2,2,1,2, //3
	2,1,1,2,1,2,2,2,1,2, //4
	2,1,1,2,1,2,1,1,1,2,2, //5
	2,1,1,2,1,2,2,2,1,2, //6
	2,1,1,2,1,2,1,1,1,2,2, //7
	2,1,1,2,1,2,2,2,1,2, //8
	2,1,1,2,1,2,1,1,1,2,2, //9
	2,1,1,2,1,2,2,2,1,2, //10
	2,1,1,2,1,2,1,1,1,2,2, //11
	2,1,1,2,1,2,2,2,1,2 //12
],inf),
	\cRel,-1,
);
)

Pbindef(\test_mel).play
Pbindef(\test_mel,\root,-13.9-0.2,\amp,5.dbamp);

[0,1]  [32,37,44]

Synth(\kraftySnr)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////patterns

(Pdef.removeAll;

Pbindef(\kick,
	\instrument,\kick,
	\glissf,Phprand(0.9,2.5),
	\midinote,32,
	\dur,Psubdivide(Pseq([1!8,4,1!8,4,1!14,3].flatten,inf),Pseq([1,Rest(6.5),0.5],inf)),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\pan,0,
	\amp,-10.dbamp,
	\out,0
);

Pbindef(\wooden,
	\instrument,\wooden,
	\pitch,45.midicps * Pwrand([1,2,1.5],[4,2,1].normalizeSum,inf),  // [8,8,8,12,15] [8,7,12]
	\dur, Psubdivide(Pseq([1!48,2,1!36,4,1!48,2].flatten,inf),Pseq([0.25],inf)),
	//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-20.dbamp,
	\out,0
);


Pbindef(\honk,
	\instrument,\wooden,
	\pitch,45.midicps ,  // [8,8,8,12,15] [8,7,12]
	\dur, Psubdivide(Pseq([1!48,2,1!36,4,1!48,3].flatten,inf),Pseq([Rest(5.5),0.5,Rest(4)],inf)),
	//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-10.dbamp,
	\out,0
);


Pbindef(\snr,
	\instrument,\kraftySnr,
	\midinote,[68,56,44],
	\rq,Plprand(3,6),
	\decay,Phprand(0.3,1),
	\dur,Pseq([Rest(1),Pseq([2],inf)],inf),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
//Psubdivide(Pseq([1!19,3,1!11,6,1!11,3,1!11,6,1!11,3,1!11,6,1!11,3,1!11,6].flatten,inf),
	\pan,0.25,
	\amp,-18.dbamp,
	\out,~bus[\nhhall]
);


Pbindef(\waveTable,
	\instrument,\test,
	\rate,[0.5,1,1.5,1.9]*Pseq(
		[20,20,20,24,15,
		8,8,8,12,15,
		8,[7,8],8,12,15,
		8,[1,8],8,7,12,
		8,[8,13],8,15,21
	].midiratio,inf),  // [8,8,8,12,15] [8,7,12]
	\dur, Pseq([8,7,9,5,3],inf),
	\sus, Pwhite(0.01,1.5),
	\cRel,0,
	\trate, Pstep([10,100,50,10,50],[64,32,32,32],inf),
	//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-4.dbamp * 1/(Pkey(\trate).log2),
	\out,0
);
)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////routine

(
StageLimiter.activate;
t = TempoClock.default.tempo_(66/60);

Pspawner({|sp|
	//s.record;
	sp.wait(1);

	t = TempoClock.default.tempo_(66/60);
	sp.par( Pfindur(328, Pbindef(\waveTable)));

	sp.wait(32);
	//sp.par( Pfindur(300, Pbindef(\waveTable)));
	sp.par( Pfindur(32*3, Pbindef(\kick)));
	sp.par( Pfindur(32*4,Pbindef(\snr)));
	sp.par( Pfindur(32*3,Pbindef(\wooden)));


	sp.wait(32*2);
	sp.par( Pfindur(32*5,Pbindef(\honk))); // ping sucks

	sp.wait(32*2);
	sp.par( Pfindur(32*3,Pbindef(\kick)));

	sp.wait(32*1);
	sp.par( Pfindur(32*4,Pbindef(\snr)));
	sp.par( Pfindur(32*3 - 8 ,Pbindef(\wooden)));

	sp.wait(32*1);
	sp.par(Pfindur(32*3-8,Pbindef(\kick)));
	//sounds bad
	//sp.par( Pfindur(48*2.5, Pdef(\hihat)));


	//sp.wait(48*2);

	//sp.par( Pfindur(60, Pdef(\bell_close)));


	//.wait(80);
	//s.stopRecording;

}).play(t,quant:1);
)




