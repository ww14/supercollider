(SynthDef(\guitar,{
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      var snd, env, perc_env;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [1,1,1,1,1], nil], 1, 0));
	snd = Saw.ar(4, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: \fundamental.kr(50) * harmonics ,
		rq: [0.005,0.015], //0.01
		mul: 3 * [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],//harmonics.sqrt,
	);
	snd = -50.dbamp * IIRFilter.ar(snd, SinOsc.kr(SinOsc.kr(0.1),1.5pi,1550,1800)).wrap(0,500);
	snd = LeakDC.ar(snd);

	perc_env = Env.perc.ar;

	snd = snd * (1+ SinOsc.ar(\cycle.kr(50)*(1+perc_env)));
	snd = BHiShelf.ar(snd,1200,0.3,5);
	snd = snd.fold2;
	snd = BHiShelf.ar(snd,1200,0.3,-5);
	//snd = snd + PitchShift.ar(snd,0.03,1+(perc_env));
	//snd = snd + PitchShift.ar(snd,0.012,1.01+perc_env);
	snd = FreqShift.ar(snd,perc_env.linlin(0,1,0,\downshift.kr(-10)));
	snd = snd.tanh;
	snd = snd + CombC.ar(snd * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	snd = FreqShift.ar(snd,perc_env.linlin(0,1,0,\upshift.kr(10)));
	snd = snd.tanh;

	snd = Splay.ar(snd,0.7);

	env =  EnvGen.kr(Env.linen(\atk.kr(0.1),\dur.kr(1), 0.5, curve:0),doneAction:2);//ar(Done.freeSelf);
	snd = snd * env;

	Out.ar(0,snd * \amp.kr(1));
}).add;
);

Synth(\guitar,[\dur,20,\cycle,100.reciprocal,\fundamental,125]);

(
Pbindef(\oneshot2,\instrument,\guitar,
	\dur,Pseq([2,1,0.5,2,0.5,1],inf),
	\fundamental,Pseq([50,42,50,42,50,42,59],inf),
	\atk,Plprand(0.01,0.3),
	\amp,-5.dbamp).play;
)