Server.killAll;
("Setup/Setup.scd").loadRelative;

(
SynthDef(\impulsetrain,{arg
	t_go=1, // trigger
	dur = 1, // total duration in seconds (also frequency)
	rel=20,
	cur = 0, // curvature or 'shape'. 0 = pulses at regular intervals
	num = 8, // number of impulses per duration
	preamp = 1,
	preamp2 = 1,
	out=0,
	pan=0 ,
	amp=1,
	k=0,
	l=0.999,
	d1=1,
	d2=1,
	freq=300;
	var env, train,sig, sigVerb, chord, envChord;
	env = EnvGen.ar(Env(#[0, 0, 1], [0, dur], cur), t_go);
	train = Changed.ar(ceil(env * num)) * preamp;
  // train = train * (1 - env); // optional decreasing amplitude
  // train = train * env; // optional - increasing amplitude
	sig = TwoTube.ar(train,k,l,d1,d2);
	sigVerb = NHHall.ar([sig,sig],0.1,0.05);
	sig = XFade2.ar(sig, sigVerb);
	//sig = sig * SinOscFB.ar(freq, 0.15,preamp).softclip;
	env = EnvGen.ar(Env(#[0, 1,0], [dur, rel], cur), t_go);
	chord = SinOscFB.ar(freq, [0.05,0.5], preamp2).tanh;
	chord = env * chord;
	sig = sig + chord;
	sig = LPF.ar(sig, 4000);
	sig = HPF.ar(sig, 40);
	//sig = sig * train;
	sig = Pan2.ar(sig,pan,amp);//.linlin(0,sig,outMin:-1,outMax:1)); //.wrap(-1,1));
	Out.ar(out, sig);
}
).add;)


///////////////////////////////////////////////////////////////////////////////////////
//testing

Synth(\impulsetrain)

(

TempoClock.default.tempo = 60 / 60;



Pbindef(\impulse,
	\instrument, \impulsetrain,
	\dur,3,
	\midinote, [69,57,45] + Pseq([0,2,4,0,2,7,0,2,4,0,-5,-1], inf), //this ending triggers a new loop
	\preamp2,Pseg([0.05,0.25,0.05],100,\lin,inf),
	\k,0.951,//Pseg([-0.9,-0.1,-0.9],100,\lin,inf),
	\l,Pseg([0.1,0.95,0.9],100,-4,inf),
	\d1,45.midicps,
	\d2,Pstep([33,26,33],[24,48,24],1).midicps, //Pseq([Pn([33.midicps],5),Pn([26.midicps],5),Pn([35.midicps],3),Pn([32.midicps],2)],inf),
	\num, Pseq([Pn([50],5),Pn([25],5),Pn([12],3),Pn([5],2)],inf), // -0.001
	\cur,Pwhite(5,-5,inf),
	\pan,Pwhite(-0.3,0.3,inf),
	\out,~bus[\reverb2],
	\amp,0.dbamp,
).play;
)


Pbindef(\impulse).stop;
Pbindef(\impulse,\amp,Pseg([0,-100],12,\lin).dbamp);



/////////////////////////////////////////////////////////////////////////////////////
//the patterns

(
	Pbindef(\impulse,
	\instrument, \impulsetrain,
	\dur,3,
	\midinote, [57,45] + Pseq([0,2,4,0,2,7,0,2,4,0,-5,-1], inf), //this ending triggers a new loop
	\preamp2,Pseg([0.05,0.25,0.05],120,\lin,inf),
	\k,0.951,//Pseg([-0.9,-0.1,-0.9],100,\lin,inf),
	\l,Pseg([0.1,0.95,0.9],120,-4,inf),
	\d1,45.midicps,
	\d2,Pstep([33,[26,33],33],[24,48,36],1).midicps, //Pseq([Pn([33.midicps],5),Pn([26.midicps],5),Pn([35.midicps],3),Pn([32.midicps],2)],inf),
	\num, Pseq([Pn([50],5),Pn([25],5),Pn([12],3),Pn([5],2)],inf), // -0.001
	\cur,Pwhite(5,-5,inf),
	\pan,Pwhite(-0.3,0.3,inf),
	\out,~bus[\nhhall],
	\amp,-6.dbamp,
);


Pbindef(\harmony,
	\instrument, \bpfsaw,
	\dur,3,
	\midinote, [57,45] + Pseq([0,2,4,0,2,7,0,2,4,0,-5,-1], inf), //this ending triggers a new loop
	\c1,2,
	\c2,-1,
	\rqmin,0.25,
	\rqmax,1.2,
	\pan,Pwhite(0.01,0.3,inf),
	\out,~bus[\reverb2],
	\amp,Pseg(Pseq([-60,-15,-90].dbamp,inf),Pseq([70,30],inf),Pseq([1,-3],inf),inf),
);

~nhhallSynth.set(\splay,0.5,\rt60,0.5,\stereo,0.5);
)


/////////////////////////////////////////////////////////////////////////////////////
//the routine


(
s.prepareForRecord;
s.scope;
s.plotTree;
s.meter;
)


(
TempoClock.default.tempo_(60/60);
t = Task({
	//s.record;
	"start".postln;
	1.wait;
	Pbindef(\harmony).play;
	Pbindef(\impulse).play;


	108.wait;
	"fadeout and stop".postln;
	Pbindef(\impulse).stop;

	24.wait;
	"removeAll".postln;
	Pbindef(\harmony).stop;
	Pdef.removeAll;

	4.wait;
	//s.stopRecording;
});
)


t.play;