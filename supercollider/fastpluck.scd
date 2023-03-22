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



});
)

(
SynthDef(\reverb, {
	arg in, out = 0, gate = 1, roomsize = 100, revtime = 1, damping = 0.6, inputbw = 0.5, spread = 15, drylevel = 1, earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300, amp = 0.5;
	var source = In.ar(in,8);
	var reverb;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);


	reverb = GVerb.ar(source, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize);
	reverb = reverb * amp ;
	XOut.ar(out,env,reverb);
//By Zé Craum

}).add;




SynthDef(\reverb_j, {
	arg in, out = 0, gate = 1, amp=1; // roomsize = 100, revtime = 1, damping = 0.6, inputbw = 0.5, spread = 15, drylevel = 1, earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300, amp = 0.5;
	var source = In.ar(in,8);
	var reverb;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);


	reverb = JPverb.ar(source);//source, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize);
	reverb = reverb * amp ;
	XOut.ar(out,env,reverb);
//By Zé Craum

}).add;


SynthDef(\choruscompresseffect, {|in, out =0 gate= 1|
	var source = In.ar(in,2);
	var chorus;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	chorus= Splay.ar(Array.fill(4,{
		var maxdelaytime= rrand(0.005,0.02);

		DelayC.ar(source[0], maxdelaytime,LFNoise1.kr(Rand(0.1,0.6),0.25*maxdelaytime,0.75*maxdelaytime) )
	}));

	chorus = Compander.ar(4*(source + chorus),source,0.4,1,4,0.01,0.1,1);

	XOut.ar(out,env,chorus);

//From Steal This Sound SC Example
//By Nick Collins
}).add;

)
////////////////////////////////////////////////////////////////////////////////////////////////

(
Pdef.removeAll;
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Synth(\reverb_j, [\in, ~bus, \out, 0]);
//Synth(\choruscompresseffect, [\in, ~bus, \out, 0]);
Pbindef(\shuffle,
	\instrument, \twotube,
	\delay1,25,
		\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/Pkey(\delay1), ///Pn(Prand([256,32,128],1),120), //Pseg([256,32,128],80,\wel,inf),
		\k, Pseg([-0.2,0.2,-0.2],30,\wel,inf),
		\preamp,Plprand(1,2,inf)*50,
		\amp,-30.dbamp,//0.0015,
		\minRq,Pseg([0.1,0.5,0.1],30,\wel,inf),
		\maxRq,0.91,
		\minBpfHz,1,
		\maxBpfHz,Pseg([10,50,10],120,\sin,inf), //31
		\minCf,30,
		\maxCf,3000,
		\pan,0,
	\chord, 50,
		\delay2,Pwrand([
			Pseq([Pn([1],60),Pn([2],60),Pn([1.5],12)],1),
			Pseq([Pn([1],60),Pn([0.5],60),Pn([0.25],12)],1),
			Pseq([Pn([1],60),Pn([1.5],60),Pn([2],12)],1),
			Pseq([Pn([1],60),Pn([0.125],60),Pn([0.5],12)],1)
		],
		[3,2,1,2].normalizeSum,
	inf)*Pkey(\chord), //perceived pitch lower when this higher
		\out,~bus,
).play;
)

Pbindef(\shuffle, \delay1, 10, \chord, Pn(Pshuf([25,75,150],3),inf));

StageLimiter.activate;

Pbindef(\shuffle, \delay1, 10, \chord, 60* Pseq([1,5/4,3/2,5/6,15/8].powerset.flatten,inf), \maxBpfHz,10); //diatonic


Pbindef(\shuffle, \delay1, 50, \chord, 50);

Pbindef(\shuffle, \delay1, 100, \chord, Pn([[10,50]],inf));

Pbindef(\shuffle, \delay1, 25, \chord, Pn([[100,50]],inf));

////////////////////////////////////////////////////////////////////////////////////////
(
Pdef.removeAll;
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
//Synth(\reverb_j, [\in, ~bus, \out, 0]);
Synth(\choruscompresseffect, [\in, ~bus, \out, 0]);
Pbindef(\shuffle,
	\instrument, \twotube,
	\dur,Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/ Pstep([256,32,128],[36,6,12],inf), //,
		\k, Pseg([-0.2,0.2,-0.2],30,\wel,inf),
		\preamp,Prand([1,2],inf)*250,
		\amp,-65.dbamp,//0.0015,
		\minRq,Pseg([0.9,0.5,0.9],30,\wel,inf),
		\maxRq,2.91,
		\minBpfHz,1,
		\maxBpfHz,Pseg([31,500,30],120,\sin,inf), //31
		//\minCf,100,
		//\minCf,1000,
		\pan,-0.2,
	\delay1,70,
		\delay2,Pwrand([
			Pseq([Pn([1],120),Pn([2],120),Pn([1.5],12)],1),
			Pseq([Pn([1],120),Pn([0.5],120),Pn([0.25],12)],1),
			Pseq([Pn([1],120),Pn([1.5],120),Pn([2],12)],1),
			Pseq([Pn([1],120),Pn([0.25],120),Pn([0.5],12)],1)
		],
		[4,2,1,1].normalizeSum,
	inf)*[10,50], //perceived pitch lower when this higher
		\out,0,
).play;
)




Pfset

2*a;