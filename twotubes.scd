//prewrite

Server.killAll;
("Setup/Setup.scd").loadRelative // load this file


//our prewrite, two chord clusters and a twotube variant.
(
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
						\amp,0.4,
						\maxRq,i.linlin(0,16,0,0.3),
						\minBpfHz,0.25,
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
						\amp,0.4,
						\maxRq,i.linlin(0,16,0.2,0.3),
						\minBpfHz,0.25,
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

)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// our pdefs first


(

a = (
//Synth(\reverb_ef);
Pdef.removeAll;
Pbindef(\shuffle,
	\instrument, \twotube,
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
		\out,~bus[\reverb],
);


Pbindef(\drum,
	\instrument, \SOSkick,
		\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/12,//Pseg([200,500,200],10,\lin,inf),
		\freq,30,
		\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
		\mod_index,15,
		\pan,0.2,
		\amp,(0.4 - (1 / Pkey(\mod_freq))),
		\out,~bus[\reverb],
);

Pbindef(\cowbell,
		\instrument, \cowbell_m,
		\dur, Psubdivide(
			Pseq([1!24,2!12,1,1,9,1].flat,inf),
			Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/3 //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
		),
		\tension,5*Prand([1e-3,1e-2,1e-1],inf), //pitch
		\timeScale,0.3,  //prevent clipping
		\amp,Plprand(2,3,inf),
		\out,~bus[\reverb],
);


Pbindef(\egg,
	\instrument, \twotube,
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
);

Pbindef(\pluck,
	\instrument, \twotube,
		\dur,Pn(Pshuf([1,1,2,2,2,4]/6,3),inf),
		\k, Pseg([-0.1,-0.9,-0.1],150,\exp,inf),
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*4,inf),
		\amp,0.4,
		\maxRq,Pseg([0.01,0.2,0.01],50,\wel,inf),
		\minBpfHz,0.8,//0.65,
		\maxBpfHz,0.9,//0.75,
		\delay1, Pn(Pn(Pxrand([23,35,47,50,52,59,61,63,64],1),12)),//Pseg([50,45,50],150,\exp,inf).round(1),
		\delay2,Pseg([1,10,1],150,\exp,inf).round(1),
		\out,~bus[\reverb],
);

Pbindef(\close,
		\instrument, \cowbell_m,
		\dur, Psubdivide(
		Pseq((1..30),1),
		Pseq([1],inf)//Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
		),
		\tension,5*Prand([1e-3,1e-2,1e-1],inf), //pitch
		\loss,Pseg([0.999,0.9999],30,\lin,1),
		\timeScale,Pseg([0.3,1],30,\exp,7),  //prevent clipping
		\amp,~fade.(6, 0, 25,8),
		\out,~bus[\reverb],
);
);
)


///testing

Pbindef(\close).play;

Synth(\cowbell_m,[\dur,1/4,\tension,8*1e-4, \timeScale,20, \amp,6,\out,0,])


(Pbind(
		\instrument, \cowbell_m,
		\dur, Psubdivide(
		Pseq((1..30),1),
		Pseq([1],inf)//Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
		),
		\tension,5*Prand([1e-3,1e-2,1e-1],inf), //pitch
	\loss,Pseg([0.999,0.9999],30,\lin,1),
	\timeScale,Pseg([0.3,1],30,\exp,7),  //prevent clipping
		\amp,Plprand(2,3,inf),
	\amp,~fade.(6, 0, 25,8),
		\out,~bus[\reverb],
).play;)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//As a spawn routine


(
//the piece is in 12/4
StageLimiter.activate;
t = TempoClock.default.tempo_(60/60);

l = Task{{
	~cluster2.value;
	rrand(0,2).wait;
	~cluster1.value;
	rrand(1,10).wait;
}.loop
}.start;

a;

Pspawner({|sp|

	sp.par( Pfindur(90, Pbindef(\egg,\amp,~fade.(0.4, 0.0, 90,-5)))); //

	sp.wait(10);

	sp.par( Pfindur(60, Pbindef(\shuffle, \amp,~fade.(0.0, 0.0025, 8,4)))); //

	sp.wait(10);

	sp.par(Pfindur(210,Pbindef(\pluck)));

	sp.wait(10);

	sp.par( Pfindur(60, Pbindef(\drum)));

	sp.wait(50);

	sp.par(Pfindur(90,Pbindef(\cowbell)));

	sp.wait(50);

	sp.par(Pfindur(70,Pbindef(\drum)),10);
	sp.par( Pfindur(60, Pbindef(\shuffle)),20);

	sp.wait(70);

	sp.par(Pfindur(25,Pbindef(\cowbell)));

	sp.wait(20);

	//add fadetime for the egg
	sp.par( Pfindur(15, Pbindef(\egg,\amp,~fade.(0.0, 0.4, 15,2))));

	sp.wait(10);

	l.pause;

	//this doesn't work as intended, porting over the ~fade function from huawei is

	sp.par(Pfindur(30,Pbindef(\close)));
	//sp.seq(Pfindur(3,Pdef(\nil)))

	sp.wait(25);

	l.resume;

	sp.wait(1);

	l.pause;

}).play(t, quant:1);
)





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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




