(
Server.killAll;
("Setup/Setup.scd").loadRelative; // load this file
//~fade = { |start, end, time, curve = 0| Pseg(Pseq([start, Pn(end)]), time, curve) };
)

(SynthDef.new(\bd, {
	arg decay=30, amp=2, gate=0, tone=56, out=0;
	var fenv, env, trienv, sig, sub, punch, pfenv;
	env = EnvGen.kr(Env.new([0.11, 1, 0], [0, decay], -225),doneAction:2);
	trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230),doneAction:0);
	fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
	pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
	sig = SinOsc.ar(fenv, pi/2) * env;
	sig = sig + (\bell.kr(0.04)*MembraneHexagon.ar(sig)*trienv);
	sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
	punch = SinOsc.ar(pfenv, pi/2) * env * 2;
	punch = HPF.ar(punch, 350);
	sig = (sig + sub + punch) * 2.5;
	sig = Limiter.ar(sig, 0.5) * amp;
	sig = Pan2.ar(sig, 0);
	Out.ar(out, sig);
}).add;


SynthDef(\glockenspiel, {
	|freq = 440, t60=6, pitchy=1, amp=0.25, gate=1, pan = 0, out=0|
	var sig, exciter;
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = DynKlank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale: freq);
	sig = (sig * 0.75) + PitchShift.ar(sig,0.1,\shift.kr(4)+(0.3*EnvGen.ar(Env.perc(0.01, 0.5), gate)));
	//sig = sig + (LFSaw.ar(freq) * EnvGen.ar(Env.perc(0.01, 0.5), gate) * 0.5);
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(out, Pan2.ar(sig, pan, amp));
//This is the same used for glockenspiel, xylophone, marimba and regular bell, what changes is only the ring time t60
//By nicolaariutti and edited by Zé Craum
//	http://sccode.org/1-5ay#c835
}).add;

)

Synth(\glockenspiel)

(
~scale = Scale.mixolydian;
~kickPattern = Pbind(
    \instrument, \bd,
    \dur, Pseq([1, 0.75, 0.25, 0.5, 0.5, 1], inf),
	\tone,700,
	//\decay,30,
	\amp, Pgauss(-8.dbamp,0.05,inf),
	//\out, ~bus[\nhhall]
);


~glockPattern = Pbind(
    \instrument, \glockenspiel,
	\dur, Pseq([Rest(1), 1, Rest(0.5), 0.5, Rest(0.5), 0.5], inf),
    \degree, Pseq([4, 4, 4, 6, 4, 4, 4, 7], inf),
    \octave, 4,
	\t60,Pgauss(0.8,0.05),
	\shift,Plprand(2,4),
    \amp, -35.dbamp,
    \scale, ~scale,
	\pan,Pwhite(-0.3,0.3),
	\out, 0,//Pwrand([0,~bus[\comb]],[0.5,0.5],inf)
);


~glockPattern2 = Pbind(
    \instrument, \glockenspiel,
	\dur, Pseq([Rest(1), 2, Rest(0.5), 0.5, ], inf),//Pbjorklund2(7,8),
    \degree, Pseq([4, 4, 4, 6, 4, 4, 4, 7], inf),
	\octave, 4,
	\t60,Pgauss(3,0.5),
	\shift, Plprand(2,4),
    \amp, -35.dbamp,
    \scale, ~scale,
	\pan,Pwhite(-0.3,0.3),
	\out, Pwrand([0,~bus[\nhhall]],[0.9,0.1],inf)
);
)

~glockPattern2.play

(
t = TempoClock(100/60);
Pbindf(~kickPattern,\tone,Pgauss(45,5,inf),\dur,2,\bell,Pgauss(1,1)).play(t);
~glockPattern.play(t)
)

(
t = TempoClock(100/60);
Pbindf(~kickPattern,\tone,Pgauss(56,5,inf),\dur, Pn(Pshuf([1, 0.75, 0.25, 0.5, 0.5, 1],1), inf),\bell,Pgauss(0.75,0.01)).play(t);
~glockPattern2.play(t)
);

(
t = TempoClock(100/60);
Pbind(
    \instrument, \bd,
	\dur, Pn(Pshuf([1, 0.75, 0.25, 0.5, 0.5, 1],1), inf),
	\tone,56,
	\amp, Pgauss(-8.dbamp,0.05,inf),
	//\out, ~bus[\nhhall]
).play(t);)