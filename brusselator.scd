// pspawner ref
// https://scsynth.org/t/how-do-you-make-a-song/4110/5

TempoClock.default.tempo_(120/60);

(
SynthDef(\brusselator, {
	|  out=0, pan=0,amp=1, dur=0.5, reset=10,rate=0.1, mu=1.15, gamma=0.5, initx=0.5,inity=1.0, minCf=30, maxCf=1500, minBpfHz=0.02, maxBpfHz=0.25,minRq=0.005, maxRq=0.04 |
	var reset1, rate1, env, sig;
	reset1 = Impulse.kr(reset);
	//reset = LPF.ar(HPF.ar(WhiteNoise.ar, 30), 80) * Env.linen(0.001, 0.01, 0.001).ar;
	rate1 = rate;
	env = EnvGen.ar(Env([0,1,1,0],[0.01]++((dur-0.001)*[0.4,0.6])),doneAction:2);
	sig = Brusselator.ar(reset1,rate1,mu,gamma,initx,inity);
	sig = BPF.ar(
			sig,
			LFNoise1.kr({LFNoise1.kr(0.13).exprange(minBpfHz,maxBpfHz)}!8).exprange(minCf, maxCf),
			LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(minRq, maxRq)
		);
	sig = LPF.ar(HPF.ar(sig,30),1500);

	sig = sig * amp * env;
	sig = Limiter.ar(sig, 0.95);
	sig = Pan2.ar(sig,pan);
	OffsetOut.ar(out, sig);
}).add;


//doesn't work great
SynthDef(\brussel_perc, {
	|  out=0, pan=0,amp=1, dur=0.5, reset=10,rate=0.1, mu=1.15, gamma=0.5, initx=0.5,inity=1.0|
	var reset1, rate1, env, sig;
	reset1 = Impulse.kr(reset);
	//reset = LPF.ar(HPF.ar(WhiteNoise.ar, 30), 80) * Env.linen(0.001, 0.01, 0.001).ar;
	rate1 = rate;
	env = EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2);
	sig = Brusselator.ar(reset1,rate1,mu,gamma,initx,inity);
	sig = LPF.ar(HPF.ar(sig,10),3000);
	sig = sig * amp * env;
	sig = Limiter.ar(sig, 0.95);
	sig = Pan2.ar(sig,pan);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\reverb_ef, {
		arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);

		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		12.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};

		//dry/wet mix
		totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
	}).add;



SynthDef(\kick, {
    var sig, excitation, tension, loss;
	excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.3),doneAction:Done.freeSelf
	   ) * PinkNoise.ar(1);
	tension = \tension.kr(0.012);
	loss = \loss.kr(0.999);
	sig =  MembraneCircle.ar(excitation, tension, loss);
	Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
}).add;



SynthDef(\cowbell, {
    var sig, excitation, tension, loss;
	excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.1),doneAction:Done.freeSelf
	   ) * PinkNoise.ar(1);
	tension = \tension.kr(0.1);
	loss = \loss.kr(0.999);
	sig =  MembraneCircle.ar(excitation, tension, loss);
	Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
}).add;



SynthDef(\brush, {
    var sig, excitation, tension, loss;
	excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.2),doneAction:Done.freeSelf
	   ) * PinkNoise.ar(2);
	tension = \tension.kr(0.005);
	loss = \loss.kr(0.7);
	sig =  MembraneCircle.ar(excitation, tension, loss);
	Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(2)));
}).add;

SynthDef(\tom, {
    var sig, excitation, tension, loss;
	excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(-0.01),timeScale:\timeScale.kr(1),doneAction:Done.freeSelf
	   ) * PinkNoise.ar(0.5);
	tension = \tension.kr(0.05);
	loss = \loss.kr(0.995);
	sig =  MembraneCircle.ar(excitation, tension, loss);
	Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(2)));
}).add;
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//testing
(

Synth(\reverb_ef);
Pdef.removeAll;

// bell tones, very soft
Pdef(\bell,
	Pbind(\instrument,\brusselator,
	\initx,Pseg([0,1,0],100,\lin,inf),
	\inity,Pseg([1,0,1],100,\lin,inf),
	\gamma, 0.25,
	\mu,10,
	\dur, Pseq([2,1,2,4]*2, inf),
	\rate,1e-4,
	\minRq,0.001,
	\maxRq,0.002,
	\minBpfHz,1/300,
	\maxBpfHz,1/310, //31
	\amp,20,
	\out,\reverb_ef
));

//occassional mel
Pdef(\partmel,
	Pbind(\instrument,\brusselator,
	\initx,Pseg([0,1,0],100,\lin,inf),
	\inity,Pseg([1,0,1],100,\lin,inf),
	\reset,Pseg([1,20,1],100,\lin,inf),
	\gamma, 1,
	\mu,Pkey(\gamma)**2 + 0.9,
	\dur, Pseq([2,1,2,4]/2, inf),
	\rate, Prand([23,35,47,50,52,59,61,63,64,76,78].midicps.linlin(100,1000,0,0.1),inf), //rate impacts percieved pitch so long as mu is > gamma**2 +1, linlin puts perceived pitch in nice range
	\amp,2,
	\out,\reverb_ef
));



//first mel
Pdef(\mel_1,
	Pbind(\instrument,\brusselator,
	//\initx,Pseg([0,1,0],100,\lin,inf),
	//\inity,Pseg([1,0,1],100,\lin,inf),
	//\reset,Pseg([1,10,1],100,\lin,inf),
	\reset,Pseg([10,30,10],100,-4,inf),
	\gamma, 1,
	\mu,Pkey(\gamma)**2 + 0.999999,
	\dur, Pseq([2,1,2,4]/2, inf),
	\rate, Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,0,0.5),3),inf),
	\amp,1,
	\out,0
));


//pitched higher mel
Pdef(\mel_2,
	Pbind(\instrument,\brusselator,
	//\initx,Pseg([0,1,0],100,\lin,inf),
	//\inity,Pseg([1,0,1],100,\lin,inf),
	//\reset,Pseg([1,10,1],100,\lin,inf),
	\reset,Pseg([10,30,10],100,-4,inf),
	\gamma, 1,
	\mu,Pkey(\gamma)**2 + 0.999999,
	\dur, Pseq([2,1,2,4]/2, inf),
	\minRq,0.9,
	\maxRq,0.99,
	\rate, Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,0,0.5),3),inf),
	\amp,1.1 - Pkey(\minRq), //higher rq makes it much lounder sounding
	\out,0
));


//pitched down mel
Pdef(\mel_3,
	Pbind(\instrument,\brusselator,
	\reset,Pseg([10,30,10],100,-4,inf),
	\gamma, 1,
	\mu,Pkey(\gamma)**2 + 0.999999,
	\dur, Pn(Pshuf([2,1,2,4]/2, 2),inf),
	\minRq,0.9,
	\maxRq,0.99,
	\minBpfHz,2,
	\maxBpfHz,3,
	\rate, Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,0,0.5),3),inf),
	\amp,1.1 - Pkey(\minRq),
	\out,0
));


//ascend/descend bubbles
Pdef(\close,
	Pbind(\instrument,\brusselator,
	\initx,Pseg([0,1,0],100,\lin,inf),
	\inity,Pseg([1,0,1],100,\lin,inf),
	\gamma, 1,
	\mu,10,
	\dur, Pseq([2,1,2,4]/2, inf),
	\rate,1e-4,
	\amp,4,
	\out,\reverb_ef
));


//kick
Pdef(\kick,
	Pbind(\instrument, \kick,
	\dur,Pseq([1,Rest(2),2,1,Rest(2.5),0.5],inf),
		\amp,0.2,
	\out,\reverb_ef
));

Pdef(\brush,Pbind(
		\instrument, \brush,
	\dur, Psubdivide(
		Pseq([1!27,2!9,1,1,9,1].flat,inf),
		Pn(Pshuf([Rest(1),1,1,Rest(1),1,1,Rest(1),1,1],3),inf) //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
	),
	\tension,5*Prand([1e-3,1e-2,1e-1],inf),
	\amp,Plprand(0.2,2,inf),
	\out,\reverb_ef
));


// reverse brush
Pdef(\brush_2,Pbind(
		\instrument, \tom,
	\dur, Psubdivide(
		Pseq([1!27,2!9,1,1,9,1].flat,inf),
		Pn(Pshuf([Rest(2),1,Rest(2),1,Rest(2),1],3),inf) //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
	),
	\levelBias,0.9,
	\timeScale,0.5,
	\tension,0.5,
	\loss,0.7,
	\amp,Plprand(0.2,2,inf),
	\out,\reverb_ef
));

//Synth(\tom,[\levelBias,-0.9,\timeScale,0.1,\tension,0.5,\loss,0.9]);
)

(
Synth(\reverb_ef);
Pdef(\mel_3).play;
Pdef(\kick).play;
Pdef(\brush).play;
Pdef(\brush_2).play;
)
s.meter;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//composition

//pbindef is recursively(?) overwritten by downstream commands. FIX
(
//the piece is in 9/4
StageLimiter.activate;
t = TempoClock.default.tempo_(120/60);
Synth(\reverb_ef);

s.scope;
s.plotTree;
s.meter;

Pspawner({|sp|

	sp.par( Pfindur(110, Pdef(\bell)));

	sp.wait(40);

	sp.par( Pfindur(60, Pdef(\partmel)));

	sp.wait(60);

	sp.par( Pfindur(60, Pdef(\mel_1)));

	sp.wait(60);

	sp.par( Pfindur(60, Pdef(\mel_2)));
	sp.par(Pfindur(180,Pdef(\kick)),9);
	sp.par(Pfindur(180,Pdef(\brush)),9);
	sp.par(Pfindur(180,Pdef(\brush_2)),18);

	sp.wait(60);

	sp.par( Pfindur(60, Pdef(\mel_3)));

	sp.wait(60);

	sp.par( Pfindur(60, Pdef(\mel_2)));

	sp.wait(60);

	sp.par(Pfindur(45,Pdef(\mel_2)));
	sp.par(Pfindur(70,Pdef(\close)));

}).play(t, quant:1);
)




//////////////////////////////////
//perc testing




Synth(\brush,[\levelBias,1e-10,\timeScale,0.8,\tension,0.0009,\loss,0.99999999]);
Synth(\brush,[\levelBias,0,\timeScale,0.2,\tension,0.005,\loss,0.7]);
Synth(\tom,[\levelBias,-0.9,\timeScale,0.1,\tension,0.5,\loss,0.9]);
Synth(\cowbell);
Synth(\kick,[\tension,0.005,\loss,0.9999999,\timeScale,20,]);

(
Pbind(
		\instrument, Pwrand([\kick,\cowbell, \brush],[4,2,1].normalizeSum, inf),
        \dur, Psubdivide(
		Pseq(#[1,1,1,1,1,2,2,2,2,2,0,1,3,12,0],inf),
		Pseq(#[1, 2, 1, 0.5,0.5]*2,inf)
	)
).play;
)

Env.sine.plot
Env.triangle(dur: 1.0, level: 1.0).plot
Env.adsr(0.2, 0.35, 0.3, 0.05, -1, 0.0).plot
and
Env.adsr(0.2, 0.35, 0.3, 0.05, 1, 0.0).plot


(
Pbind(
		\instrument, \tom,
	\dur, Psubdivide(
		Pseq([1!8,2!4,1,1,9,1].flat,inf),
		Pseq([1/4],inf)
	),
	\tension,Pseq([0.05,0.06,0.04,0.05,0.05,0.06,0.07,0.06],inf),
	\amp,0.4
).play;


Pbind(\instrument, \brusselator,
      \dur, Pseq([Rest(2), 2, Rest(2), 2], inf),
	\amp,2,
    ).play;



Pbind(
		\instrument, \kick,
	\dur,Psubdivide(
		Pseq([1!8,2!4,1,1,27,1].flat,inf),
		Pseq([Rest(1),2,1],inf)
	),
).play;
)


(
var base;

base = nil;

Ppar([
    Pbindf(
        base,
		\instrument, Pwrand([\kick,\cowbell, \brush],[4,2,1].normalizeSum, inf),
        \dur, Psubdivide(
    Pseq(#[1,1,1,1,1,2,2,2,2,2,0,1,3,12,0],inf),
    Pseq(#[1, 2, 1, 0.5,0.5]*2,inf)
)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\brusselator, 16), Pn(\brusselator, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    ),
/*  Pbindf(
        base,
        \instrument, Pseq([Pn(\kick, 8), Pn(\snare, 8)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
	)*/
]).play(TempoClock(2.3 * 4))
)

