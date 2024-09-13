/////////synthdef

Server.killAll;
("setup/Setup.scd").loadRelative // load this file

(
SynthDef.new(\fm1, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	iScale=5, width=0.5, res=1,rq=1,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=0.2, pan=0,
	lsf=200, ldb=0, out=0;
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
	mod = RLPF.ar(Pulse.ar(mod * width, 0.5), mod.tanh, res);
	mod = mod + CombC.ar(mod * -10.dbamp,0.1,1/(60 * (1+iEnv)),0.15);
	//filter sound for clipping/distortion
	car = SinOsc.ar(freq * cRatio + mod);
	car = BLowShelf.ar(car, lsf, 0.5, ldb);
	car = BLowPass.ar(car,4000,rq,-1);
	car = car * env * amp;
	car = Pan2.ar(car, pan);

	Out.ar(out,car);
}).add;
);




/////////pattern


(
t = TempoClock(55/60);
Pbindef(\fm1,
	\instrument,\fm1,
	\midinote,45+Pseg([0,2,0,1,2,4,3],[8,4,4,8,4,4],\step,inf)+Pseq([Rest(1),45,Rest(1),40,Rest(1),41,Rest(1),36,Rest(1),38,Rest(1),44],inf)+[-2,0,3,7],
	\dur,Prand([0.05,0.055],inf)*Pseq([Rest(1),2],inf),
	\rel,Pgauss(0.1,0.05),
	\atk,Pgauss(0.005,0.02),  //Pseg(Pseq([Pgauss(-12.dbamp,0.1), 0]), 16)),
	\iScale,Pgauss(0.1,0.01),
	\rq,Pgauss(3,1),
	\cRatio,40,
	\mRatio,15,
	\res,Pgauss(20,4),
	\width,0.15,//0.15,
	\amp,-5.dbamp,
	\out,Pwrand([0,~bus[\nhhall]],[0.95,0.05],inf));
);
)

Pbindef(\fm1).play(t,quant:1);

Pbindef(\fm1).stop;



(
t = TempoClock(55/60);
Pbindef(\fm1,
	\instrument,\fm1,
	\midinote,45+Pseg([0,2,0,1,2,4,3],[8,4,4,8,4,4],\step,inf)+Pseq([Rest(1),45,Rest(1),40,Rest(1),41,Rest(1),36,Rest(1),38,Rest(1),44],inf)+[-2,0,3,7,12],
	\dur,0.1*Pseq([Rest(1),2],inf),
	\rel,Pgauss(0.1,0.05),
	\atk,Pgauss(0.5,0.02),  //Pseg(Pseq([Pgauss(-12.dbamp,0.1), 0]), 16)),
	\iScale,Pgauss(0.3,0.01),
	\rq,Pgauss(5,1),
	\cRatio,Pseg(Pseq([64,2,128]),32,-20),//32
	\mRatio,16,
	\res,1,
	\width,0.1,//0.15,
	\amp,-20.dbamp,
	\out,Pwrand([0,~bus[\nhhall]],[0.1,0.9],inf));


Pbindef(\fm1).play(t,quant:1);
)
