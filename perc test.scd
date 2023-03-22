(
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


	SynthDef(\cowbell, {
		var sig, excitation, tension, loss;
		excitation = EnvGen.ar(Env.perc,levelBias:\levelBias.kr(0),timeScale:\timeScale.kr(0.1),doneAction:Done.freeSelf
		) * PinkNoise.ar(1);
		tension = \tension.kr(0.1);
		loss = \loss.kr(0.999);
		sig =  MembraneCircle.ar(excitation, tension, loss);
		Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
	}).add;

)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(
		\instrument, \cowbell,
		\dur, Psubdivide(
			Pseq([1!12,2!4].flat,inf),
		Pn(Pshuf([1,2,1,1]/4,3),inf)), //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)

		\tension,1e-2*Pseq([3,7,5].stutter,inf), //pitch 1e-3, 1e-2, 1e-3
		\timeScale,0.3,  //prevent clipping
		\amp,Plprand(0.4,1.2,inf),
		\out,~bus,
).play;

/*Pbind(
		\instrument, \twotube,
		\dur, Psubdivide(
			Pseq([1!12,2!4].flat,inf),
		Pn(Pshuf([1,2,1,1]/4,3),inf)), //Pseq([Rest(1),1,1,Rest(2),1,1,Rest(1),1],inf)
        \k, Pseg([-0.1,-0.9,-0.1],150,\exp,inf),
		\preamp,Pseq([1,2,3,4,5,6,7,8,9].mirror*4,inf),
		\amp,0.05,
		\maxRq,Pseg([0.01,0.9,0.01],50,\wel,inf),
		\minBpfHz,0.1,//0.65,
		\maxBpfHz,Pwrand([0.5,1.5],[0.95,0.05],inf),//0.75,
		\amp,Plprand(0.4,1.2,inf),
		\out,~bus,
).play*/
)