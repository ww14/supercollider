// https://scsynth.org/t/how-to-record-sound-produced-using-pbind/7526/4


(	SynthDef(\alarm, { |out=0, freq = 440| // changed
		var sig, filter, env;
		env = Env.perc(0.01, 0.25).kr;
		sig = BrownNoise.ar * env;
		filter = { |source, freq = 440, bwr = 0.001, amp = 1|
			Resonz.ar(source, freq, bwr, amp)
		};
	sig = filter.(sig, freq, \bwr_1.kr(0.001), 9);
	FreeSelf.kr(TDelay.kr(env, \delay.kr(3)));
	sig = filter.(sig, freq, \bwr_2.kr(0.5));
	    sig = Pan2.ar(sig,\pan.kr(0));
	sig = BLowPass4.ar(sig,1200,\rq.kr(1));
	OffsetOut.ar(out, sig*\amp.kr(1))
	}
).add;)
	s.sync;


(
Pbindef(\test,
		\instrument, \alarm,
		\bwr_1,0.002,
		\bwr_2,0.1,//0.25,
		\freq, (50 + Pseq([
		Pseq([2, 5, 10],2),
		Pseq([0, 3, 8], 1),
		Pseq([1, 4, 9] ,1),
		Pseq([2, 5, 10] ,2),
		Pseq([4, 7, 12] ,1),
		Pseq([3, 6, 11],1),
	],inf)).midicps,
	\dur, Pseq([1,2,1],inf),
	\amp, 0.dbamp,
	\pan,Pwhite(-0.1,0.1),
).play;
)

(
TempoClock.default.tempo_(300/60);


(
Pdef(\intro,
Pbind(\instrument, \alarm,
		\bwr_1,0.002,
		\bwr_2,0.2,//0.25,
		\freq, (50 + Pseq([
		Pseq([2, 5, 10],2),
		Pseq([0, 3, 8], 1),
		Pseq([1, 4, 9] ,1),
		Pseq([2, 5, 10] ,2),
		Pseq([4, 7, 12] ,1),
		Pseq([3, 6, 11],1),
	],inf)).midicps,
	\dur, Pseq([1,2,1],inf),
	\amp, 0.dbamp,
	\pan,Pwhite(-0.1,0.1),
))
);


Pdef(\long,
	Pbind(
		\instrument, \alarm,
		\bwr_1,0.001,
		\bwr_2,0.001,
		\freq, (74 + [0,3,8] + Pseq([2,-2,2,4, 2,1,2,4,3, 2,-2,2,4, 2,0,2,4,3, 2,0,2,4,3,2],inf)).midicps,
	\dur, Pseq([12!4, 12!3,6,6, 12!4, 12!3,6,6, 12,12,12,6,6,12].flatten,inf),
	\amp,-10.dbamp,
	\pan,Pwhite(-0.1,0.1),
));

	Pdef(\bell,
	Pbind(
		\instrument, \alarm,
	\bwr_1,0.01,//0.001,
	\bwr_2,3,
	\delay,0.9,
	\freq, (50 + Pseq([
		Pseq([2, 5, 10],4),
		Pseq([0, 3, 8], 2),
		Pseq([1, 4, 9] ,2),
		Pseq([2, 5, 10] ,4),
		Pseq([4, 7, 12] ,2),
		Pseq([3, 6, 11],2),
	],inf)).midicps,
		\dur, Pseq([1,1,1],inf), //0.2!3
	\pan,Pwhite(0.0,0.3),
	\amp, 0.dbamp
));



Pdef(\drum,Pbind(
		\instrument, \alarm,
	\bwr_1,0.1,//0.001,
	\bwr_2,5,
	\freq, 38.midicps,
	\dur,Psubdivide(Pseq([1!6,2!6,4!6].flatten,inf), Pseq([12,12,3],inf)),// Pseq([0.2, 0.2, 0.2],inf), 2.4,2.4,0.6
	\pan,Pwhite(-0.3,0.0),
	\amp,0.dbamp
));

//close
Pdef(\bell_close,
	Pbind(
		\instrument, \alarm,
	\bwr_1,0.01,//0.001,
	\bwr_2,3,
	\delay,0.9,
	\freq, (50 + Pseq([
		Pseq([2, 5, 10],4),
		Pseq([0, 3, 8], 2),
		Pseq([1, 4, 9] ,2),
		Pseq([2, 5, 10].reverse ,4),
		Pseq([4, 7, 12].reverse ,2),
		Pseq([3, 6, 11].reverse ,2),
		[2,5,10]
	],1)).midicps,
	\dur, Pseq([1!48,5].flatten,1),
	\amp,0.dbamp,
	\pan,Pwhite(-0.3,0.3),
));
)

(
//the piece is in 3/8, kinda

StageLimiter.activate;
t = TempoClock.default.tempo_(300/60);


Pspawner({|sp|

	sp.par( Pfindur(48*4, Pdef(\bell)));
	sp.par( Pfindur(48*5, Pdef(\drum)));
	sp.par( Pfindur(48*5+2, Pdef(\long)));

	sp.wait(48*4);

	sp.par( Pfindur(60, Pdef(\bell_close)));

}).play(t, quant:1);
)

Pdef(\long).play