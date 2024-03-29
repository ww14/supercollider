Server.killAll;
("setup/Setup.scd").loadRelative // load this file

(
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
	snd = TGrains.ar(8, clk, b, \rate.kr(1), pos, dur, pan, 0.1).sum;
	snd = Splay.ar(snd);
	snd = NHHall.ar(snd,60,0.95);

	snd= snd*env*\amp.kr(1);
	Out.ar(\out.kr(0),snd);
}).add;)
)

///////////////////////////////testing

a = Synth(\test,[\rate,31.midiratio,\dur,2,\cRel,0])
a.set(\trate,300)
a.set(\rate,0.02);
a.set(\pos,0.1)

(
Pbindef(\test_mel, \instrument,\test,
	\rate,Pseq([0!24,[0,-12]!24].flatten,inf)+Pseq(
	   (1+ [31,31,31,32,28,31,
		 31,35,32,32,28,31,
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
	\trate, 600,//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,0.dbamp
);
)





/////////patterns

(Pdef.removeAll;

Pbindef(\kick,
	\instrument,\kick,
	\glissf,Phprand(0.9,3),
	\midinote,32,
	\dur,Psubdivide(Pseq([1!8,4,1!8,4,1!14,3].flatten,inf),Pseq([1,Rest(6.5),0.5],inf)),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\pan,0,
	\amp,-12.dbamp,
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
	\amp,-6.dbamp,
	\out,0
);
)

Synth(\kick);

t = TempoClock.default.tempo = (60/60);
//t.schedAbs(t.nextTimeOnGrid(32, -0.001));
Pbindef(\kick).play(t);
Pbindef(\snr).play(t);
Pbindef(\waveTable).play(t);
Pbindef(\test_mel).play(t);

(
StageLimiter.activate;
t = TempoClock.default.tempo_(60/60);

Pspawner({|sp|
	//s.record;
	sp.wait(1);

	t = TempoClock.default.tempo_(60/60);
	sp.par( Pfindur(300, Pbindef(\waveTable)));

	sp.wait(64);

	sp.par( Pfindur(48*4, Pbindef(\kick)));
	sp.par( Pfindur(48*5,Pbindef(\snr)));


	//sp.wait(48*2);
	//sounds bad
	//sp.par( Pfindur(48*2.5, Pdef(\hihat)));


	//sp.wait(48*2);

	//sp.par( Pfindur(60, Pdef(\bell_close)));


	//.wait(80);
	//s.stopRecording;

}).play(t,quant:1);
)




(
Pbind(\instrument,\test,
	\rate,0.midiratio+Pseq(
		 [8,4,8,11].midiratio,inf),
	\dur, Pseq([0.25,0.25,0.5,0.25],inf),
	\cRel,0,
	\trate, 600,//Pstep([100,10],[32,32],inf),//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-6.dbamp
).play;
)

(Pbindef(\test_mel,\instrument,\test,
	\rate,[2,1]* Pseq([
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
\dur, 1/16 * Pseq([2,1,1,2,1,2,2,2,1,2, //1
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
	\cRel,-2,
);
)

[0,1]  [32,37,44]
