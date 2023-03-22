//prewrite


(
s = Server.local.waitForBoot({
	~bus = Bus.audio(s,2);

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

	SynthDef(\twotube,{arg preamp=0, delay1=100, delay2=50, k=0.0, loss=0.999, dur=0.5, pan=0.0, out=0, amp=1, minCf=30, maxCf=6000, minBpfHz=0.02, maxBpfHz=0.25,minRq=0.005, maxRq=0.04;
		var sig, env, senv;

		//k from -1 to 1

		senv = EnvGen.ar(Env([1,1,0,0],[(delay1+delay2)/SampleRate.ir,0.0,1.0]));
		sig = WhiteNoise.ar(preamp) * senv;


		env = EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2);
		sig = TwoTube.ar(sig,k,loss,delay1,delay2);
		//sig = Compander(sig);

		sig = BPF.ar(
			sig,
			LFNoise1.kr({LFNoise1.kr(0.13).exprange(minBpfHz,maxBpfHz)}!8).exprange(minCf, maxCf),
			LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(minRq, maxRq)
		);

		sig = sig * env *amp;
		sig = Pan2.ar(sig,pan);

		Out.ar(out,sig);
	}).add;

	SynthDef(\cowbell, {
		var sig, excitation, tension, loss;
		excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.3),doneAction:Done.freeSelf
		) * PinkNoise.ar(1);
		tension = \tension.kr(0.1);
		loss = \loss.kr(0.999);
		sig =  MembraneCircle.ar(excitation, tension, loss);
		Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
	}).add;



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

	SynthDef(\brush, {
    var sig, excitation, tension, loss;
	excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.25),doneAction:Done.freeSelf
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


SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, amp = 0.8, beater_noise_level = 0.025;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}

//DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOSkick -------
// http://www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
// increase mod_freq and mod_index for interesting electronic percussion
	).add;


	~cluster1 = {
		var trnsp, bund, a;
		bund = s.makeBundle(false, {});
		//trnsp = rrand(-7,7);
		Array.fill(exprand(4,14).round.postln, {[1,2,3,4,6,8,12,16].wchoose([7,6,5,4,3,3,1].normalizeSum)}).do{
			|i|
			var cfLo;
			cfLo = (([23,35,47,50,52,59,61,63,64,76,78].choose) ).midicps * ((1..8).choose);

			bund = s.makeBundle(false, {
				Synth(
					\twotube,
					[
						\k, i.linlin(0,16,0,0.95), //can't go above 1.
						\preamp,i,
						\amp,0.08,
						\maxRq,i.linlin(0,16,0,0.3),
						\minBpfHz,0.2,
						\maxBpfHz,i.expexp(1.0,16.0,0.1,16.0),
						\minCf, cfLo,
						\maxCf, cfLo * [10,5,1].wchoose([0.87,0.1,0.03]),
						//\maxCf,1000,
						//\pan,Pkey(\preamp).wrap(-0.4,0.4),
						\delay1,cfLo*i,
						\delay2,cfLo/i,
						\pan,-1,
						\out, 0,
					],
				)
			},
			bund
			)
		};

		//schedule on an integer time value
		SystemClock.schedAbs(
			(thisThread.seconds+1.0).round(1.0),
			{
				bund = s.makeBundle(nil, {}, bund);
				nil;
			}
		);
	};
	// same as 1 but with parameter tweaks on synth, plucked string
	~cluster2 = {
		var trnsp, bund, a;
		bund = s.makeBundle(false, {});
		//trnsp = rrand(-7,7);
		Array.fill(exprand(4,14).round.postln, {[1,2,3,4,6,8,12,16].wchoose([7,6,5,4,3,3,1].normalizeSum)}).do{
			|i|
			var cfLo;
			cfLo = (([23,35,47,50,52,59,61,63,64,76,78].choose) ).midicps * ((1..8).choose);

			bund = s.makeBundle(false, {
				Synth(
					\twotube,
					[
						\k, i.linlin(0,16,0,0.8),
						\preamp,i,
						\amp,0.10,
						\maxRq,i.linlin(0,16,0.2,0.3),
						\minBpfHz,0.08,
						\maxBpfHz,i.expexp(1.0,16.0,0.1,16.0),
						\minCf, cfLo,

						\maxCf, cfLo * [10,5,1].wchoose([0.87,0.1,0.03]),
						//\maxCf,1000,
						//\pan,Pkey(\preamp).wrap(-0.4,0.4),
						\delay1,[25,50,100].wchoose([0.87,0.1,0.03]),
						\delay2,[100,50,25].wchoose([0.87,0.1,0.03]),
						\pan,1,
						\out, ~bus,
					],
				)
			},
			bund
			)
		};

		//schedule on an integer time value
		SystemClock.schedAbs(
			(thisThread.seconds+1.0).round(1.0),
			{
				bund = s.makeBundle(nil, {}, bund);
				nil;
			}
		);
	};


	/* transC:
	continuous transition, pars are set using a custom synth that writes to busses
	- trans is defined as a dictionary of envelopes
	e.g (amp: Env([0.1,0.5],1), ...)
	- all envelopes are stretched to last transDur
	- event-specific parameters like \legato are converted to Penvs and not written to busses

	// \a for 3 seconds, then trans for 5 second
	~transC.(\a,3,(
	amp: Env([0.1,0.5],1)
	),5)
	*/

	~transC = {|patA, durA, transDef, transDur|
		Pspawner{|sp|
			var trans = PatternProxy();
			trans.source = Pbind();
			sp.par(trans<>Pdef(patA));
			durA.wait;
			trans.source = Pbind(*~mapTrans.(transDef,transDur).asKeyValuePairs);
			transDur.wait;
			sp.suspendAll();
		}
	};

	// used by transC
	~mapTrans = {|parEnvs, transDur= 1|
		var penvs = parEnvs.select{|v|v.class===Penv}.collect{|penv|
			penv.times = penv.times*transDur
		};
		var busses = parEnvs
		.select{|v,k| penvs.keys.includes(k).not}.collect{Bus.control(s,1)};

		{
			busses.collect{|bus, parName|
				Out.kr(bus, EnvGen.kr(parEnvs[parName],timeScale:transDur));
			};
			Line.kr(0,1,transDur,doneAction:2);
			Silent.ar;
		}.play.onFree{
			busses do: _.free
		};

		busses.collect(_.asMap) ++ penvs
	};

	/* transC example
	Pdef(\a, Pbind(\note,Pseq((0..10)), \amp, 0.1, \pan, -1));
	Pdef(\b, Pbind(\note,Pseq((0..10)), \amp, 0.5, \pan, 1));

	// \a for 3 seconds, then trans for 5 second, then \b for 3 seconds
	Pspawner{|sp|
	sp.seq(~transC.(\a,3,(
	amp: Env([0.1,0.5],1),
	pan: Env([-1,1])
	),5));
	sp.seq(Pfindur(3,Pdef(\b)))
	}.play
	*/

});
)




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//As a spawn routine


// our pdefs first
(
Pdef.removeAll;

Pdef(\egg,
	Pbind(\instrument, \twotube,
		\dur,Pseq([1]/192,inf),
		\k, -0.8,
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*5,inf),
		\amp,-25.dbamp,//0.05,
		\maxRq,0.04, //0.1
		\minBpfHz,30,
		\maxBpfHz,Pseg([31,1000,31],100,\lin,inf), //31
		//\pan,Pkey(\preamp).wrap(-0.4,0.4),
		//\delay1,Pseg([300,200,300],100,\lin,inf),
		//\delay2,Pseg([5,300,5],100,\exp,inf),
		\pan,-0.4,
		\out,0,
));

Pdef(\shuffle,
	Pbind(\instrument, \twotube,
		\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/256,//Pseg([200,500,200],10,\lin,inf),
		\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
		\preamp,Prand([1,2],inf)*250,
		\amp,-670.dbamp,//0.0015,
		\minRq,0.9,
		\maxRq,0.91,
		\minBpfHz,1,
		\maxBpfHz,31, //31
		//\minCf,100,
		//\minCf,1000,
		\pan,-0.2,
		\delay1,1,
		\delay2,Pseq([Pn([1],120),Pn([2],120)],inf)*[1000,2000], //perceived pitch lower when this higher
		\out,~bus,
));

Pdef(\pluck,
	Pbind(\instrument, \twotube,
		\dur, Psubdivide(
			Pseq([1!25,2!10,4!5].flatten,inf),
			Pseq(#[0.5, 1, 2,0.25, 0.25],inf)
		),//Psubdivide(
			//Pseq([1!24,2!6,1,1,9,1].flat,inf),
			//Pn(Pshuf([Rest(1),1,1,Rest(1),1,1,Rest(1),1,1,Rest(1),1,1],3),inf)
		//)/4,//Pn(Pshuf([1,1,2,2,2,4]/6,3),inf),
		\k, Pseg([-0.1,-0.9,-0.1],100,\exp,inf),
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*5,inf),
		\amp,-3.dbamp,//0.7,
		\maxRq,Pseg([0.01,0.2,0.01],50,\wel,inf),
		\minBpfHz,0.1,//0.65, 0.1
		\maxBpfHz,Pwrand([1,9],[0.95,0.05],inf),//0.75,
		\delay1, (Pseq([83!72,95!24,23!24].mirror.flat,inf) +  Pseq( [0,2,4,7,4,2],inf ) + .x[0,2,4]
	).cpsoct,//Pwrand([47,23],[0.9,0.1],inf) + Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], inf), // Pn(Pn(Pwrand([23,35,47,50,52,59,61,63,64],[23,35,47,50,52,59,61,63,64].reciprocal.normalizeSum,1),inf)),//Pseg([50,45,50],150,\exp,inf).round(1),
		\delay2,Pseg([1,10,1],100,\exp,inf).round(1),
		\out,0,
));

Pdef(\drum,
	Pbind(\instrument, \SOSkick,
		\dur,Psubdivide(
			Pseq([1!25,2!10,4!5].flatten,inf),
			Pseq(#[0.5, 1, 2,0.25, 0.25],inf)
		)/2,
		//Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/12,//Pseg([200,500,200],10,\lin,inf),
		\freq,30,
		\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
		\mod_index,15,
		\pan,0.2,
		\amp,0.9 * (0.2 - (1 / Pkey(\mod_freq))),
		\out,~bus,
));

Pdef(\perc,
	Pbind(
		\instrument, Pwrand([\tom,\brush,\cowbell],[0.2,0.7,0.1].normalizeSum,inf), // \brusselator
		\dur, Psubdivide(
			Pseq([2!10,1!10,2!10,1,1,9,1,3].flat,inf),
			Pseq([0.2, 0.5, 1.1, 0.25, 0.15],inf) //
		),
		//\dur, Prand(#[0.2, 0.5, 1.1, 0.25, 0.15], inf),
		\tension,100*Prand([1.5e-3,1e-2,1e-3],inf), //pitch
		\timeScale,0.4,  //prevent clipping
		\amp,Plprand(0.5,1.5,inf).dbamp,  // Plprand(2,3,inf)
		\out,~bus,
));


Pdef(\perc_steady,
	Pbind(
		\instrument, \cowbell,//Pwrand([\tom,\brush,\cowbell],[0.2,0.7,0.1].normalizeSum,inf), // \brusselator
		\dur, 2,
		//\dur, Prand(#[0.2, 0.5, 1.1, 0.25, 0.15], inf),
		\tension,0.005,//10*Prand([1.5e-3,1e-2,1e-3],inf), //pitch
		\timeScale,Plprand(0.5,1.0,inf),  //prevent clipping
		\amp,0.1,  // Plprand(2,3,inf)
		\out,~bus,
));


Pdef(\close,
	Pbind(\instrument,\cowbell,
		\dur,Pseq([10],1),
		\tension,0.5,
		\loss,0.5,
		\timeScale,15,
		\amp,6.dbamp, //  6
		\out,~bus,
));


Pdef(\nil,
	Pbind(
		\amp,0,
));

)

(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);

Pdef(\perc).play;
/*Pdef(\pluck,
	Pbind(\instrument, \twotube,
		\dur, Psubdivide(
			Pseq([1!24,2!8,4!4].flatten,inf),
			Pn(Pshuf([2,1,2,4]/4, 2),inf)
		),//Psubdivide(
			//Pseq([1!24,2!6,1,1,9,1].flat,inf),
			//Pn(Pshuf([Rest(1),1,1,Rest(1),1,1,Rest(1),1,1,Rest(1),1,1],3),inf)
		//)/4,//Pn(Pshuf([1,1,2,2,2,4]/6,3),inf),
		\k, Pseg([-0.1,-0.9,-0.1],150,\exp,inf),
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*5,inf),
		\amp,-3.dbamp,//0.7,
		\maxRq,Pseg([0.01,0.2,0.01],50,\wel,inf),
		\minBpfHz,0.1,//0.65, 0.1
		\maxBpfHz,Pwrand([1,9],[0.95,0.05],inf),//0.75,
		\delay1, [1,2]*(Pseq([83!72,95!24,23!24].mirror.flat,inf) +  Pseq( [0,2,4,7,4,2],inf ) + .x[0,2,4]
	).cpsoct,//Pwrand([47,23],[0.9,0.1],inf) + Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], inf), // Pn(Pn(Pwrand([23,35,47,50,52,59,61,63,64],[23,35,47,50,52,59,61,63,64].reciprocal.normalizeSum,1),inf)),//Pseg([50,45,50],150,\exp,inf).round(1),
		\delay2,Pseg([1,10,1],150,\exp,inf).round(1),
		\out,~bus,
)).play;*/

)
////////////////////////////////////////////////////////////
\


(
//the piece is in 12/4
StageLimiter.deactivate;
StageLimiter.activate;
t = TempoClock.default.tempo_(60/60);
Synth(\reverb_ef, [\in, ~bus, \out, 0]);

l = Task{{
	~cluster2.value;
	rrand(0,2).wait;
	~cluster1.value;
	rrand(1,10).wait;
}.loop
}.start;



Pspawner({|sp|

	sp.par( Pfindur(90, Pdef(\egg)));

	sp.wait(10);

	sp.par( Pfindur(60, Pdef(\shuffle)));

	sp.wait(10);

	sp.par(Pfindur(140,Pdef(\pluck)));

	sp.wait(10);

	sp.par(Pfindur(90,Pdef(\perc_steady)));
	sp.par( Pfindur(30, Pdef(\drum)));

	sp.wait(50);

	//sp.par(Pfindur(10,Pdef(\perc)));

	sp.wait(20);

	sp.par(Pfindur(70,Pdef(\drum)),10);
	sp.par( Pfindur(60, Pdef(\shuffle)),20);

	sp.wait(70);

	sp.par(Pfindur(20,Pdef(\perc)));

	sp.wait(20);

	//add fadetime for the egg
	sp.par( Pfindur(15, Pdef(\egg)));

	sp.wait(10);

	sp.par( Pfindur(9, Pdef(\close)));

	sp.wait(9);

	l.pause;

	//this doesn't work as intended, porting over the ~fade function from huawei is

	sp.seq(~transC.(\close,3,(amp: Env([0.1,0.5],1), pan: Env([-1,1])),5));
	sp.seq(Pfindur(3,Pdef(\nil)))

}).play(t, quant:1);
)


Synth(\cowbell,[\dur,1/4,\tension,8*1e-4, \timeScale,2, \amp,6,\out,0,])


Pbind(
	\instrument, \cowbell,
	\dur, Psubdivide(
		Pseq([1!12,2!12,3!12,4!12,5!12,6!12].flat,inf),
		Pn(1/4,inf) //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
	),
	\tension,8*Prand([1e-3],inf), //pitch
	\timeScale,0.3,  //prevent clipping
	\amp,Plprand(3,6,inf),
	\out,0,
).play;



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
Pdef(\pluck,
	Pbind(\instrument, \twotube,
		\dur, Psubdivide(
			Pseq([1!24,2!8,4!4].flatten,inf),
			Pseq(#[0.5, 1, 2,0.25],inf)
		),//Psubdivide(
			//Pseq([1!24,2!6,1,1,9,1].flat,inf),
			//Pn(Pshuf([Rest(1),1,1,Rest(1),1,1,Rest(1),1,1,Rest(1),1,1],3),inf)
		//)/4,//Pn(Pshuf([1,1,2,2,2,4]/6,3),inf),
		\k, Pseg([-0.1,-0.9,-0.1],150,\exp,inf),
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*4,inf),
		\amp,0.2,
		\maxRq,Pseg([0.01,0.9,0.01],50,\wel,inf),
		\minBpfHz,0.1,//0.65,
		\maxBpfHz,Pwrand([0.5,1.5],[0.95,0.05],inf),//0.75,
		\delay1, (Pseq([83!72,95!24,83!12,71!24].mirror.flat,inf) +  Pseq([
        Pshuf(#[-3,0,2,4], 2)+[0,3,5,7],
        Pseq( [0,2,4,7,4,2] )+[0,4,5]
	], inf)).midiratio,//Pwrand([47,23],[0.9,0.1],inf) + Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], inf), // Pn(Pn(Pwrand([23,35,47,50,52,59,61,63,64],[23,35,47,50,52,59,61,63,64].reciprocal.normalizeSum,1),inf)),//Pseg([50,45,50],150,\exp,inf).round(1),
		\delay2,Pseg([1,10,1],150,\exp,inf).round(1),
		\out,~bus,
));
)
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pdef(\pluck).play;
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//As a task
//start clusters

(
t = Task {
	//instantiate reverb synth
	Synth(\reverb_ef, [\in, ~bus, \out, 0]);

	//drum, shuffle sound
	Pbind(\instrument, \twotube,
		\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/240,//Pseg([200,500,200],10,\lin,inf),
		\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
		\preamp,Prand([1,2],inf)*250,
		\amp,0.0025,
		\minRq,0.9,
		\maxRq,0.91,
		\minBpfHz,1,
		\maxBpfHz,31, //31
		//\minCf,100,
		//\minCf,1000,
		\pan,-0.2,
		\delay1,1,
		\delay2,Pseq([Pn([1],120),Pn([2],120)],inf)*[1000,2000], //perceived pitch lower when this higher
		\out,~bus,
	).play(quant:1);


	//drum
	Pbind(\instrument, \SOSkick,
		\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/12,//Pseg([200,500,200],10,\lin,inf),
		\freq,30,
		\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
		\mod_index,15,
		\pan,0.2,
		\amp,(0.4 - (1 / Pkey(\mod_freq))),
		\out,~bus,
	).play(quant:1);

	Pbind(
		\instrument, \cowbell,
		\dur, Psubdivide(
			Pseq([1!24,2!12,1,1,9,1].flat,inf),
			Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/3 //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
		),
		\tension,5*Prand([1e-3,1e-2,1e-1],inf),
		\amp,Plprand(3,6,inf),
		\out,~bus,
	).play(quant:1);


	//frying egg
	Pbind(\instrument, \twotube,
		\dur,Pseq([1]/200,inf),
		\k, -0.8,
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*5,inf),
		\amp,0.4,
		\maxRq,0.1,
		\minBpfHz,30,
		\maxBpfHz,Pseg([31,1000,31],100,\lin,inf), //31
		//\pan,Pkey(\preamp).wrap(-0.4,0.4),
		//\delay1,Pseg([300,200,300],100,\lin,inf),
		//\delay2,Pseg([5,300,5],100,\exp,inf),
		\pan,-0.4,
		\out,0,
	).play(quant:1);

	//descending pluck
	Pbind(\instrument, \twotube,
		\dur,Pn(Pshuf([1,1,2,2,2,4]/3,3),inf),
		\k, Pseg([-0.1,-0.9,-0.1],150,\exp,inf),
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*4,inf),
		\amp,0.35,
		\maxRq,Pseg([0.01,0.2,0.01],50,\wel,inf),
		\minBpfHz,0.8,//0.65,
		\maxBpfHz,0.9,//0.75,
		\delay1, Pn(Pn(Pxrand([23,35,47,50,52,59,61,63,64],1),12)),//Pseg([50,45,50],150,\exp,inf).round(1),
		\delay2,Pseg([1,10,1],300,\exp,inf).round(1),
		\out,~bus,
	).play(quant:1);

	{
		~cluster2.value;
		rrand(0,2).wait;
		~cluster1.value;

		rrand(1,10).wait;
	}.loop;
}.start;
)

//stop clusters
t.stop;




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Misc


//water drops
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
q = Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0.2,
	\preamp,Pseq([1,2].mirror*10,inf),
	\amp,0.8,
	\maxRq,0.1,
	\minBpfHz,3,
	\maxBpfHz,4, //31
	//\pan,Pkey(\preamp).wrap(-0.4,0.4),
	\delay1,1,
	\delay2,2,
	\out,~bus,
);
q.play(quant:1)
)

//old school
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,1/20,//Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*1000,inf),
	\amp,0.4,
	\minRq,0.001,
	\maxRq,0.0015,
	\minBpfHz,1/300,
	\maxBpfHz,1/301, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,1,
	\delay2,2,
	\out,~bus,
).play(quant:1);
)

//detuned meander
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*250,inf),
	\amp,0.8,
	\minRq,0.005,
	\maxRq,0.0055,
	\minBpfHz,1/160,
	\maxBpfHz,1/150, //31
	\minCf,100,
	\maxCf,2000,
	\pan,0,
	\delay1,8,
	\delay2,16,
	\out,~bus,
).play(quant:1);
)

//mor detuned
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*10000,inf),
	\amp,0.4,
	\minRq,0.001,
	\maxRq,0.0015,
	\minBpfHz,1/300,
	\maxBpfHz,1/301, //31
	\minCf,1/200,
	\pan,0,
	\delay1,1,
	\delay2,2,
	\out,~bus,
).play(quant:1);
)


//bass drum
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
	\preamp,Prand([1,2],inf)*250,
	\amp,0.1,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,100,
	//\minCf,1000,
	\pan,0,
	\delay1,20,
	\delay2,Pseq([Pn([1],8),Pn([2],8)],inf)*[512,256], //perceived pitch lower when this higher
	\out,~bus,
).play(quant:1);
)

//synth lead, rq glitches out near 1.
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*200,inf),
	\amp,0.4,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,Pwrand([10,1,20,40],[10,2,1,1].normalizeSum,inf),
	\delay2,Pwrand([2,10,20,40],[10,1,0.5,0.5].normalizeSum,inf),
	\out,~bus,
).play(quant:1);
)


(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*200,inf),
	\amp,0.1,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,Pseq([Pn([10],32),Pn([20],64),Pn([2,1],16),Pn([40],64)].mirror1,inf),
	\delay2,Pseq([Pseq([2,10,20,40],176),Pseq([2,10,20,40],176)],inf),
	\out,~bus,
).play(quant:1);

//64+64+16+32

//a shuffling
//
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,2,2,2,6,6,6,12],3),inf)/256,//Pseg([200,500,200],10,\lin,inf),
	\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
	\preamp,Prand([1,2],inf)*250,
	\amp,0.0035,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,100,
	//\minCf,1000,
	\pan,0,
	\delay1,4,
	\delay2,Pseq([Pn([1],8),Pn([2],8)],inf)*[400,800], //perceived pitch lower when this higher
	\out,~bus,
).play(quant:1);
)