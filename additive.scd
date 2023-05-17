// https://scsynth.org/t/copying-some-stuff-from-web/6133
(
SynthDef(\additive,{
	var snd,freqs,n,numPartials;
	numPartials=64;
	n=(1..numPartials);
	freqs=\fundamental.kr(60)*n*(1+(n*n*0.001)).sqrt;
	snd=SinOsc.ar(freqs);
	snd=snd*(log2(n)*\tilt.kr(-3)).dbamp;
	snd=snd*(1-log2(n*\phase.kr(1)).sin.abs);
	snd=snd.sum!2;
	snd=snd* -20.dbamp;
	Out.ar(0,snd);
}).add;
)

a = Synth(\additive);
a.set(\phase,1.9,\tilt,-3,\fundamental,40.midicps);

/////////////////////////////////////////////////////////////////////////////////

(
~bus = Bus.audio(s,2);

	SynthDef(\reverb_ef, {
		arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);
/*
		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		12.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};
	*/
	verbSig = NHHall.ar(sig,2.5);

		//dry/wet mix
		totalSig = XFade2.ar(sig, verbSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
	}).add;


SynthDef(\additive_env, {
	var snd, env, freqs,n,numPartials;
	numPartials=60;
	n=(1..numPartials);
	freqs=\fundamental.kr(60)*n*(1+(n*n*0.001)).sqrt;
	snd=DPW3Tri.ar(freqs);
	snd=snd*(log2(n)*\tilt.kr(-3)).dbamp;
	snd=snd*(1-log2(n*\phase.kr(1)).sin.abs);
	snd=snd.sum!2;
	snd=snd* -20.dbamp;
	env = EnvGen.kr(Env.perc(0.001, \dur.kr(0.1)), doneAction:2);
	snd = snd*env;
	Out.ar(\out.kr(0), Pan2.ar(snd,\pan.kr(0)));
}).add;
// https://scsynth.org/t/how-to-generate-paradiddles/1243/7
(
SynthDef(\snare, {
	arg out=0, sus=0.1;
	var sig, brus, trig, env;
	sig = WhiteNoise.ar(0.15);
	sig = MembraneCircle.ar(sig);
	env = EnvGen.kr(Env.perc(0.001, sus), doneAction:2);
	sig = sig*env;
	Out.ar(out, Pan2.ar(sig,\pan.kr(0),\amp.kr(0.5)));
}).add;
);
)


//// make routine with pfindur or by simply modifying the pbindefs
(
Pdef.removeAll;
c=TempoClock(185/60);

(
Pbindef(\additive_env,
	\instrument, \additive_env,
	\fundamental,Pstep([16.midicps,16.midicps,45.midicps,33.midicps,45.midicps,33.midicps],[70,70,70,70,30,40],inf),
	\phase,Pseg([0.01,10,0.01],70,\exp,inf),
	\tilt,-3,//Pstep([1,-3,0],70,inf),
	\dur,Pstep([1/8,1/8,6,1/8,6,1/8,6,1/4,1/3,1/2,10],[70,10,5,10,5,10,5,10,2,3,10],inf),//Pseq([Pseq([2,1,2,4]/2, 8),Pseq([2,1,2,4].reverse/4, 8),8,Pseq([1]/8, 32)],inf),
	//.\fundamental,Pwrand([60,67,65,72],[4,2,1,1].normalizeSum,inf)

));


a=Pbind(
	\instrument, \snare,
	\dur, 1/2,
	\sus, 0.01,
);
b=Pbind(
	\instrument, \snare,
	\dur, 1,

	//\sus, Pseq([0.02, 0.01],inf), // single
	//\sus, Pseq([0.02, 0.01, 0.01],inf), // double
	//\sus, Pseq([0.02, 0.01, 0.01, 0.01],inf), // triple
	\sus,Pstep([Pseq([0.02, 0.01],inf),Pseq([0.02, 0.01, 0.01],inf),Pseq([0.02, 0.01, 0.01, 0.01],inf)],[70,70,70],inf),
	\pan,Pwhite(0,1),
	\out,~bus
);
);

(

Pbindef(\additive_env).play(c,quant:1);

Ppar([a, b]).play(c,quant:1);
);

// what's up with the stagelimiter error? it seems to be related to the membranecircle inclusion


(t = Task({
    Synth(\reverb_ef, [\in, ~bus, \out, 0]);
	Pbindef(\additive_env).play(c,quant:1);


	21.wait;

	7.wait;

	18.wait;

	7.wait;
	3.wait;
	//

	28.wait;

   });
)
(
c=TempoClock(185/60);
t.play(c);
)

c
c.beats;