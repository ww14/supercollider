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
Pbind(\instrument,\test,
	\rate,Pseq([0!24,[0,-12]!24].flatten,inf)+Pseq(
	    [31,31,31,32,28,31,
		 31,35,32,32,28,31,
	     31,31,31,32,28,31,
		 31,28,32,31,32,28,
	].midiratio,inf),
	\dur, Pseq(
		[1,1,1,0.5,0.5,0.5,
		 1,1,1,0.5,0.5,0.5,
		 1,1,1,0.5,0.5,0.5,
  		 1,0.5,0.5,1,1,0.5
	],inf),
	\cRel,5,
	\trate, Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-6.dbamp
).play;



/////////patterns


(Pbindef(\kick,
	\instrument,\kick,
	\glissf,Phprand(0.9,3),
	\midinote,32,
	\dur,Psubdivide(Pseq([1!8,4,1!8,4,1!14,3].flatten,inf),Pseq([1,Rest(6.5),0.5],inf)),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\pan,0,
	\amp,-22.dbamp,
	\out,0
);

Pbindef(\snr,
	\instrument,\kraftySnr,
	\midinote,[68,56,44],
	\rq,Plprand(3,10),
	\decay,Phprand(0.3,1),
	\dur,Pseq([Rest(1),Pseq([2],inf)],inf),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
//Psubdivide(Pseq([1!19,3,1!11,6,1!11,3,1!11,6,1!11,3,1!11,6,1!11,3,1!11,6].flatten,inf),
	\pan,0.25,
	\amp,-20.dbamp,
	\out,~bus[\nhhall]
);

Pbindef(\waveTable,
	\instrument,\test,
	\rate,[-0.75,0,0.5,0.9]+Pseq(
		[20,20,20,24,15,
		8,8,8,12,15,
		8,[7,8],8,12,15,
		8,[1,8],8,7,12,
		8,[8,13],8,15,21
	].midiratio,inf),  // [8,8,8,12,15] [8,7,12]
	\dur, Pseq([8,7,9,5,3],inf),
	\sus, Pwhite(0.01,1.5),
	\cRel,0,
	\trate, 10,//Pstep([10,100],[32,32],inf),
	//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-6.dbamp,
	\out,0
);

t = TempoClock.default.tempo_(60/60);
t.schedAbs(t.nextTimeOnGrid(4, -0.001));
Pbindef(\kick).play(t,quant:33);
Pbindef(\snr).play(t,quant:33);
Pbindef(\waveTable).play(t);






(
Pbind(\instrument,\test,
	\rate,0.midiratio+Pseq(
		 [8,4,8,11].midiratio,inf),
	\dur, Pseq([0.25,0.25,0.5,0.25],inf),
	\cRel,-3,
	\trate, 600,//Pstep([100,10],[32,32],inf),//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-6.dbamp
).play;
)