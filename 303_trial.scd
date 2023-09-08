/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
(
SynthDef(\303, {
	var sig = LFPulse.ar(\freq.kr(110, \glide.kr(0.1)), 0, 0.5).unipolar;
	var env = Env.adsr(\atk.kr(0.01), \dur.kr(1), 0.5, \rel.kr(0.01),0.6, -2); //.kr(\doneAction.kr(2), \gate.kr(1));
	var envgen = EnvGen.kr(env, \gate.kr(1), doneAction:2);
	var fEnv = Env.perc(\fAtk.kr(0.8), \fRel.kr(0.1), 1, \lin).kr(0, \trig.tr(1)).exprange(\cutoff.kr(200), \peak.kr(15000));
	sig = Splay.ar(sig);
	sig = NHHall.ar(sig,10,0.05);
	sig = RLPF.ar(sig, fEnv, \rq.kr(0.5));
	sig = sig*envgen;
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(1));
	Out.ar(\out.kr(0), sig!2);
}).add;
);

(
SynthDef.new(\fm1, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	iScale=5,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=0.2, pan=0,
	lsf=200, ldb=0;
	var car, mod, env, iEnv, mod2;
	iEnv =EnvGen.kr(
		Env.new(
			[index, index *iScale, index],
			[atk,rel],
			[cAtk,cRel]
		)
	);//envelope on index allows for more control of a single note shape, imitate acoustic
	env = EnvGen.kr(
		Env.perc(atk,rel,curve:[cAtk,cRel]),
		doneAction:2
	);
	// mod2 = SinOsc.ar(freq/10,mul:freq/10 * iEnv); //additive modulation
	mod = SinOsc.ar(freq * mRatio , mul:freq * mRatio * iEnv);
	//filter sound for clipping/distortion
	car = SinOsc.ar(freq * cRatio + mod);
	car = BLowShelf.ar(car, lsf, 0.5, ldb);
	car = car * env * amp;
	car = Pan2.ar(car, pan);

	Out.ar(0,car);
}).add;
);

)

(
Pbindef(\303,\instrument,\303,
	\midinote,Pseq([30, 37, 41, 40, 33, 48, 29, 31],inf)+[0,12,24],
	\dur,0.2,
	\rel,0.1,
	\rq,0.75,
	\fAtk,0.08,
	\cutoff,50);
)

Pbindef(\303).play;
45,40,41,36,44

(
(
Pbindef(\303,\midinote,Pstep([45,40,41,36,38,44],3,inf)+[0,12,24],
	\dur,2,//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\rel,0.1,
	\rq,0.75,
	\fAtk,0.08,
	\cutoff,50,
	\amp,-15.dbamp
)
);

Pbindef(\fm1,
	\instrument,\fm1,
	\midinote,Pseq([Rest(1),45,Rest(1),40,Rest(1),41,Rest(1),36,Rest(1),38,Rest(1),44],inf)+[-2,0,3,7,12],
	\dur,Pseq([Rest(1),2],inf),
	\rel,3,
	\atk,0.1,
	\iScale,0.1,
	\cRatio,3,
	\mRatio,3,
	\amp,-10.dbamp
);


Pbindef(\fm2,
	\instrument,\fm1,
	\midinote,Pseq([45,45,45,43,40,41,40,45,45,45,43,40,41,48,47],inf) +[0,36,48],
	\dur,Pseq([1],inf),
	\rel,2,
	\atk,0.02,
	\iScale,5,
	\cRatio,0.5,
	\mRatio,1,
	\amp,-10.dbamp
);
)

Pbindef(\fm2).play
Pbindef(\303).play;


Ppar([Pbindef(\303),Pbindef(\fm1)],inf).play;
