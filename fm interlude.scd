/////////synthdef

Server.killAll;
("setup/Setup.scd").loadRelative // load this file

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
	//car = Friction.ar(car, friction: \friction.kr(5.41322e-2), mass: \mass.kr(4.05501),spring:\spring.kr(0.414));
	car = car * env * amp;
	car = Pan2.ar(car, pan);

	Out.ar(0,car);
}).add;
);




/////////pattern

(
Pbindef(\fm1,
	\instrument,\fm1,
	\midinote,45+Pseg([0,2,0,1,2,4,3],[8,4,4,8,4,4],\step,inf)+Pseq([Rest(1),45,Rest(1),40,Rest(1),41,Rest(1),36,Rest(1),38,Rest(1),44],inf)+[-2,0,3,7,12],
	\dur,0.05*Pseq([Rest(1),2],inf),
	\rel,0.1,
	\atk,0.5,
	\iScale,0.1,
	\cRatio,30,
	\mRatio,20,
	\friction,Pgauss(5.41322e-2,5e-3,inf),
	\mass,Pgauss(3,0.5,inf),
	\spring,Pseg([0.175,8*0.175],2*4*4,6,inf),
	\amp,-5.dbamp,
	\out,~bus[\nhhall]
);
)

Pbindef(\fm1).play(quant:1);

Pbindef(\fm1).stop;
