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
		OffsetOut.ar(out, sig)
	}
).add;)
	s.sync;
(
	Pbind(
		\instrument, \alarm,
	\bwr_1,0.001,//0.001,
	\bwr_2,0.5,
	\freq, (83 + Pseq([
		             Pseq([2, 5, 10],4),
		Pseq([0, 3, 8], 2),
		Pseq([1, 4, 9] ,2),
		Pseq([2, 5, 10] ,4),
		Pseq([4, 7, 12] ,2),
		Pseq([3, 6, 11],2),
	],inf)).midicps,
		\dur, Pseq([0.2, 0.2, 0.2],inf),
	\pan,Pwhite(-0.3,0.3),
).play;)

(
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
		\dur, Pseq([0.2, 0.2, 0.2],inf),
	\pan,Pwhite(-0.3,0.3),
).play;



Pbind(
		\instrument, \alarm,
	\bwr_1,0.1,//0.001,
	\bwr_2,5,
	\freq, 38.midicps,
	\dur,Pseq([2.4,2.4,0.6],inf),// Pseq([0.2, 0.2, 0.2],inf),
	\pan,Pwhite(-0.1,0.1),
).play;
)
