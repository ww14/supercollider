(SynthDef(\pluck,{
	var snd, freq, puffDuration, puff;
	freq = \freq.kr(440) +1;
	puffDuration = \puffDuration.kr(0.01);
	puff = BPF.ar(PinkNoise.ar,ExpRand(500,16e3!3),0.6).sum *Env.perc(puffDuration,0.001,curve:-4).ar * -20.dbamp;
	snd = Pluck.ar(RLPF.ar(PinkNoise.ar, ExpRand(1200,8200),0.3),Impulse.ar(0),1/60,1/freq,decaytime:3*(220/freq),coef:0.82);
	snd = RLPF.ar(snd,ExpRand(440,7800),0.3);
	snd = snd +Splay.ar(SinOsc.ar(ExpRand(3320,8e3 ! 6))*Env.perc(0.0,ExpRand(1e-3,3e-2 ! 6)).ar * -2.dbamp);
	snd = LeakDC.ar(snd);
	snd = puff + DelayC.ar(snd,puffDuration, puffDuration);
	8.do {
		snd = BPeakEQ.ar(snd,ExpRand(640,3300),\rq.kr(0.01),10);
			};
	snd = snd * Env.linen(0,1,0.5,curve:-2).ar(Done.freeSelf);
	snd = snd * -1.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;

)

Synth(\pluck)

(
var s;
s = Server.default;

Routine({
	3.do{
		[3,3,4,2,2,4].do {|beats|
			((60-6)+[0,3,12]).do {|note|
				s.bind {Synth(\pluck,[freq:note.midicps])};
			};
			(beats*0.15).wait;
		};
	};
}).play;
)
Pdef.removeAll


(Pbindef(\pluck,
	\instrument,\pluck,
	\freq,(36 + [0,3,12,17] +Pseq(
		[20,20,20,24,15,
		8,8,8,12,15,
		8,[7,8],8,12,15,
		8,[1,8],8,7,12,
		8,[8,13],8,15,21
],inf)).midicps,  // [8,8,8,12,15] [8,7,12]
	\dur, 0.1*Pseq([3,3,4,2,2,4],inf),
	\puffDuration,0.01,
	\rq,Pseg([0,1,2,5,1,7,3,1],[20,10,8,15,7,10,23.6],\step,1),
	\amp,-8.dbamp,
	\out,0
);
)

Pbindef(\pluck).play

(Pbindef(\pluck,
	\instrument,\pluck,
	\freq,(36 + [0,-7,5,12] +Pseq(
		[8,8,8,12,15,
		8,[7,8],8,12,15,
		8,[1,8],8,7,12,
		8,8,12,15,7]
		,inf)).midicps,  // [8,8,8,12,15] [8,7,12]
	\dur, 0.175*Pseq([1,1,2,3,2],inf),  //[1,1,2,3,2] //[1,2,1,2,3], //[ 1, 3, 1, 2, 2 ], //[ 3, 1, 2, 2, 1 ]
	\puffDuration,Pwhite(0.0025,0.015), //10
	\rq,Pwhite(0.001,0.01),
	\amp,-8.dbamp,
	\out,0
);
)

(Pbindef(\pluck,\dur,0.175*Pn(Pshuf([
	Pseq([1,1,2,3,2],1),
	Pseq([1,1,2,3,2],1),
	Pseq([1,2,1,2,3],1),
	Pseq([1,3,1,2,2],1),
	Pseq([3,1,2,2,1],1)
	],Pwrand([4,2,8],[0.5,0.25,0.25],inf))
    ,inf))
)

Pbindef(\pluck,\rq,0.001,\dur,0.7)
Pbindef(\pluck,\puffDuration,Pseg([0.0025,0.015,2],30,\exp,1))

Pbindef(\pluck,\rq,0.21,\dur,0.35)