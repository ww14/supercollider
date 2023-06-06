Server.killAll;
("Setup/Setup.scd").loadRelative

(
SynthDef(\impulsetrain2,{arg
	t_go=1, // trigger
	dur = 1, // total duration in seconds (also frequency)
	cur = 0, // curvature or 'shape'. 0 = pulses at regular intervals
	num = 8, // number of impulses per duration
	preamp = 1,
	out=0,
	pan=0 ,
	amp=1,
	k=0;
	var env, train,sig, mod, car;
	env = EnvGen.ar(Env(#[0, 0, 1], [0, dur], cur), t_go);
	train = Changed.ar(ceil(env * num)) * preamp;
  // train = train * (1 - env); // optional decreasing amplitude
  // train = train * env; // optional - increasing amplitude
	//sig = SinOscFB.ar(freq, 0.5,preamp).softclip;
	sig = TwoTube.ar(train,k,1,250,25,);
	sig = sig * amp;
	sig = LPF.ar(sig, 4000);
	//sig = HPF.ar(sig, 15);
	//sig = sig * train;
	sig = Pan2.ar(sig);//.linlin(0,sig,outMin:-1,outMax:1)); //.wrap(-1,1));
	Out.ar(out, sig);
}
).add;)



~a = Synth("metaldrum",[\ibase,0.9,\roomsize,10,\damping,0.05,\inputbw,0.1]);

//////////////////////////////////////////////////////////////


t=0;
t = TempoClock.default.tempo = 120 / 60;


//non-enveloped synth
(
~a = Pbind(\instrument,\metaldrum,
	\dur,inf,
	\ibase,0.9,
	\roomsize,10,
	\damping,0.05,
	\inputbw,0.1,
	\amp,-25.dbamp,
).play(t,quant:0);


~d = Pbind(\instrument, \impulsetrain2,
	\dur,5,
	\k,Pseg([-0.9,0.9,-0.9],100,\lin,inf),
	\num, Pseq([Pn([50],10),Pn([25],10),Pn([12],10),Pn([5],5)],inf), // -0.001
	\cur,Pseq([5,-5,],inf),
	//\out,~bus[\reverb],
	\amp,-6.dbamp,
).play(t,quant:8);

)

~a.stop;
~d.stop;



(
SynthDef(\impulsetrain,{arg
	t_go=1, // trigger
	dur = 1, // total duration in seconds (also frequency)
	cur = 0, // curvature or 'shape'. 0 = pulses at regular intervals
	num = 8, // number of impulses per duration
	preamp = 1,
	out=0,
	pan=0 ,
	amp=1,
	k=0,
	freq=400;
	var env, train,sig, mod, car;
	env = EnvGen.ar(Env(#[0, 0, 1], [0, dur], cur), t_go);
	train = Changed.ar(ceil(env * num)) * preamp;
  // train = train * (1 - env); // optional decreasing amplitude
  // train = train * env; // optional - increasing amplitude
	sig = SinOscFB.ar(freq, 0.5,preamp).softclip;
	sig = TwoTube.ar(train,k,1,25,25,);
	sig = sig * amp;
	sig = LPF.ar(sig, 4000);
	//sig = HPF.ar(sig, 15);
	//sig = sig * train;
	sig = Pan2.ar(sig, sig);//.linlin(0,sig,outMin:-1,outMax:1)); //.wrap(-1,1));
	Out.ar(out, sig);
}
).add;)

Synth(\impulsetrain)