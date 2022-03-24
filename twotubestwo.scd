(
s = Server.local.waitForBoot({
	~bus = Bus.audio(s,2);
	SynthDef(\reverb_ef, {
		arg   amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var   sig, verbSig, totalSig, outSig;

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
						\amp,0.5,
						\maxRq,i.linlin(0,16,0,0.3),
						\minBpfHz,0.25,
						\maxBpfHz,i.expexp(1.0,16.0,0.1,16.0),
						\minCf, cfLo,
						\maxCf, cfLo * [10,5,1].wchoose([0.87,0.1,0.03]),
						//\maxCf,1000,
						//\pan,Pkey(\preamp).wrap(-0.4,0.4),
						\delay1,cfLo*i,
						\delay2,cfLo/i,
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
						\amp,1,
						\freq,cfLo *2,
						\maxRq,i.linlin(0,16,0.2,0.3),
						\minBpfHz,0.25,
						\maxBpfHz,i.expexp(1.0,16.0,1,16.0),
						\minCf, cfLo,
						\maxCf, cfLo * [10,5,1].wchoose([0.87,0.1,0.03]),
						//\maxCf,1000,
						//\pan,Pkey(\preamp).wrap(-0.4,0.4),
						\delay1,[25,50,100].wchoose([0.87,0.1,0.03]),
						\delay2,[100,50,25].wchoose([0.87,0.1,0.03]),
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
});
)




//start clusters



(
TempoClock.default.tempo = 60/60;
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
		\pan,0,
		\delay1,1,
		\delay2,Pseq([Pn([1],120),Pn([2],120)],inf)*[1000,2000], //perceived pitch lower when this higher
		\out,~bus,
	).play(quant:1);

	//drum
	Pbind(\instrument, \SOSkick,
		\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/12,//Pseg([200,500,200],10,\lin,inf),
		\amp,1,
		\freq,30,
		\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
		\mod_index,15,
		\pan,0,
		\out,0,
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
		\out,0,
	).play(quant:1);



	//descending pluck
	Pbind(\instrument, \twotube,
		\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
		\k, -0.8,
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*4,inf),
		\amp,0.4,
		\maxRq,Pseg([0.01,0.6,0.01],50,\wel,inf),
		\minBpfHz,0.65,
		\maxBpfHz,0.75,
		//\delay1,Pseg([1,10,1],75,\exp,inf),
		//\delay2,Pseg([1,30,1],150,\exp,inf),
		\delay1,Pseg([50,45,50],50,\exp,inf),
		\delay2,Pseg([1,50,1],50,\exp,inf),
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


//water drops

(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
q = Pbind(\instrument, \twotube2,
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
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube2,
	\dur,1/20,//Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0	,
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
Pbind(\instrument, \twotube2,
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
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube2,
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
	\out,~bus[\reverb2],
).play(quant:1);
)





//bass drum

(
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
~a = Pbind(\instrument, \twotube2,
	\dur,k,//Pseq([9,Pn(Pshuf([1,1,1,4,6,3,3,3,3,9]/12,3),inf)],1),
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
	\delay2,Pwrand([Pn([1],8),Pn([2],8),Pn([4],8),Pn([100],4)],[10,5,2,0.5].normalizeSum,inf)*Pwrand([[180,220],[220,300],[220,440]],[3,2,1].normalizeSum,inf), //*[512,256], //perceived pitch lower when this higher
	\out,~bus[\reverb2],
);
~a.play(quant:1);
)
~a.stop;



//synth lead, rq glitches out near 1.

(
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube2,
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
	\delay1,Pwrand([10,1,20,40],[10,2,1,1].normalizeSum,inf),
	\delay2,Pwrand([2,10,20,40],[10,1,0.5,0.5].normalizeSum,inf),
	\out,~bus[\reverb2],
).play(quant:1);
)





(
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube2,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*200,inf),
	\amp,0.005,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,Pseq([Pn([10],32),Pn([20],64),Pn([2,1],16),Pn([40],64)].mirror1,inf),
	\delay2,Pseq([Pseq([2,10,20,40],176),Pseq(2*[2,10,20,40],176)],inf),
	\out,Pwrand([~bus[\reverb],~bus[\comb]],[0.9,0.1],inf),
).play(quant:1);



//64+64+16+32



//a shuffling

//

//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube2,
	\dur,Pn(Pshuf([1,1,1,2,2,2,6,6,6,12],3),inf)/Pseg([200,500,200],50,\lin,inf),
	\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
	\preamp,Prand([1,2],inf)*250,
	\amp,0.0005,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,100,
	//\minCf,1000,
	\pan,0,
	\delay1,4,
	\delay2,Pseq([Pn([1],8),Pn([2],8)],inf)*[400,800], //perceived pitch lower when this higher
	\out,~bus[\reverb2],
).play(quant:1);
)