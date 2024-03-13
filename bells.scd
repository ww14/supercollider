// https://scsynth.org/t/how-to-record-sound-produced-using-pbind/7526/4


Server.killAll;
("setup/Setup.scd").loadRelative // load this file

(	SynthDef(\alarm, { |out=0, freq = 440| // changed
		var sig, filter, env;
		env = Env.perc(0.01, 0.25).kr;
	sig = BrownNoise.ar(10) * env;
		filter = { |source, freq = 440, bwr = 0.001, amp = 1|
			Resonz.ar(source, freq, bwr, amp)
		};
	sig = filter.(sig, freq, \bwr_1.kr(0.001), 9);
	FreeSelf.kr(TDelay.kr(env, \delay.kr(3)));
	sig = filter.(sig, freq, \bwr_2.kr(0.5));
	    sig = Pan2.ar(sig,\pan.kr(0));
	sig = LeakDC.ar(sig);
	sig = BLowPass4.ar(sig,1100,\rq.kr(1));
	sig = BBandPass.ar(sig,700,\bw.kr(1));
	OffsetOut.ar(out, sig*\amp.kr(1))
	}
).add;)
	s.sync;


(
TempoClock.default.tempo_(60/60);
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
	\amp, -10.dbamp,
	\pan,Pwhite(-0.1,0.1),
);
)

Pbindef(\test).play;


///////
// write the pdefs
(
TempoClock.default.tempo_(300/60);
Pdef.removeAll;

(
Pdef(\intro,
Pbind(\instrument, \alarm,
		\bwr_1,0.003,
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
		\out,~bus[\nhhall]

))
);


Pdef(\long,
	Pbind(
		\instrument, \alarm,
		\bwr_1,0.001,
		\bwr_2,0.001,
		\freq, (74 + [0,3,8] + Pseq([2,-2,2,4, 2,1,2,4,3, 2,-2,2,4, 2,0,2,4,3, 2,0,2,4,3,2],inf)).midicps,
	\dur, Pseq([12!4, 12!3,6,6, 12!4, 12!3,6,6, 12,12,12,6,6,12].flatten,inf),
	\amp,-14.dbamp,
	\pan,Pwhite(-0.1,0.1),
		\out,~bus[\nhhall]
));

	Pdef(\bell,
	Pbind(
		\instrument, \alarm,
	\bwr_1,0.01,//0.001,
	\bwr_2,3,
	\bw,2,
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
	\pan,Pwhite(0.2,0.35),
	\amp, -12.dbamp,
		\out,~bus[\reverb2]
));



Pdef(\hat,Pbind(
		\instrument, \alarm,
	\bwr_1,0.5,//0.001,0.6
	\bwr_2,4, //15
	\rq, 0.025,//1
	\freq,24.midicps,
	\dur,Psubdivide(Pseq([1!6,2!6,4!6].flatten,inf), Pseq([12,12,3],inf)),// Pseq([0.2, 0.2, 0.2],inf), 2.4,2.4,0.6
	\pan,Pwhite(-0.3,0.0),
	\amp,-20.dbamp,
	\out,~bus[\nhhall]
));

Pdef(\drum,Pbind(
		\instrument, \alarm,
	\bwr_1,0.5,//0.001,0.6
	\bwr_2,4, //15
	\rq, 10,//1
	\freq,24.midicps,
	\dur,Pwrand([3,6],[2,1].normalizeSum,inf),// Pseq([0.2, 0.2, 0.2],inf), 2.4,2.4,0.6
	\pan,Pwhite(0.2,0.4),
	\amp,-18.dbamp, //-4.dbamp // -18.dbamp

	\out,~bus[\nhhall]
));

// old drum
// \bwr_2,5,\freq, 38.midicps,\amp,-10.dbamp

Pdef(\hihat,Pbind(
		\instrument, \alarm,
	\bwr_1,1,//0.001,
	\bwr_2,100.reciprocal,
	\freq, (Pwrand([81,86],[0.2,0.8],inf)).midicps,
	\dur,Psubdivide(Pseq([1!8,2!8].flatten,inf), Pseq([6,3,2,1],inf)),// Pseq([0.2, 0.2, 0.2],inf), 2.4,2.4,0.6
	\pan,Pwhite(-0.5,0.5),
	\amp,-27.dbamp,
	\out,~bus[\reverb],
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
	\amp,-4.dbamp,
	\pan,Pwhite(-0.3,0.3),
		\out,~bus[\reverb2]
));
)


/////////////////////////////////////////////
//testing

(Pbindef(\drum,
		\instrument, \alarm,
	\bwr_1,0.5,//0.001,
	\bwr_2,4,
	\rq,[10,0.025],
	\freq,24.midicps,
	\dur,4,// Pseq([0.2, 0.2, 0.2],inf), 2.4,2.4,0.6
	\pan,Pwhite(-0.3,0.0),
	\amp,-8.dbamp,
	\out,~bus[\reverb],
);)

Pdef(\drum).play;

Pdef(\bell).play

(
TempoClock.default.tempo_(60/60);
Pdef(\intro).play;
)

~reverbSynth.set(\mix,0.2,\predelay,0.1,\revtime,3,\lpf,1000);
Pbindef(\drum).play


//////////////////////////////////////////////////////////////////////////////////////////////

(
s.prepareForRecord;
s.scope;
s.plotTree;
s.meter;
)

//the piece is in 3/8, kinda
(
StageLimiter.activate;
t = TempoClock.default.tempo_(300/60);

Pspawner({|sp|
	//s.record;
	sp.wait(1);

	t = TempoClock.default.tempo_(60/60);
	sp.par( Pfindur(32, Pdef(\intro)));

	sp.wait(32);

	t = TempoClock.default.tempo_(300/60);
	sp.par( Pfindur(48*4, Pdef(\bell)));
	sp.par( Pfindur(48*5, Pdef(\drum)));
	sp.par( Pfindur(48*5, Pdef(\hat)));
	sp.par( Pfindur(48*5+2, Pdef(\long)));

	sp.wait(48*2);
	//sounds bad
	//sp.par( Pfindur(48*2.5, Pdef(\hihat)));


	sp.wait(48*2);

	sp.par( Pfindur(60, Pdef(\bell_close)));


	sp.wait(80);
	//s.stopRecording;

}).play(t,quant:1);
)











//////////////////////////////////////////////////////////////
// misc testing

TempoClock.default.tempo_(120/60);
Pdef.removeAll;
(Pbindef(\hihat,
		\instrument, \alarm,
	\bwr_1,76.reciprocal,//0.001,
	\bwr_2,76.reciprocal,
	\freq, 66.midicps,
	\dur,\dur,Psubdivide(Pseq([1!24,2!6,4!6].flatten,inf), Pseq([2,4,2],inf)),// Pseq([0.2, 0.2, 0.2],inf), 2.4,2.4,0.6
	\pan,Pwhite(-0.5,0.5),
	\amp,-10.dbamp,
	\out,~bus[\comb],
));

Pbindef(\hihat).play
Pbindef(\hihat,\out,~bus[\reverb]);
Pbindef(\hihat,\bwr_1,76);
Pbindef(\hihat,\bwr_2,8);
Pbindef(\hihat,\bwr_2,76);



Pbindef(\hihat,\bwr_2,20);





Pbindef(\hihat,\freq, 66.midicps,)

Pbindef(\hihat,\freq, 67.midicps,\dur,Plprand(2,5,inf))
