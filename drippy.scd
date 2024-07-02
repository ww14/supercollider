
//https://www.youtube.com/watch?v=0a-drU-_MpA
// https://sccode.org/1-5hZ
// https://sccode.org/1-5i2



(
~xox = {|str| str.collectAs({|l| switch(l.toLower,$x, {1}, $o, {Rest(1)})}, Array)};
)


(
SynthDef(\acid, { arg out, freq = 1000, gate = 1, pan = 1, cut = 4000, rez = 0.8, amp = 1, sustain = 1, release = 0.5;
    var sig, env;
	env = EnvGen.kr(Env.linen(0.01, sustain, sustain * release), gate, amp, doneAction: Done.freeSelf);

	sig = sig + Pulse.ar(freq*0.501, 0.01, [0,0.5]);
	sig = sig + Pulse.ar(freq*1.99, 0.11, [0.5,0]);
	sig = RLPF.ar(sig, cut, rez);
	sig = Pan2.ar(sig);
	sig = sig * env;

	Out.ar(out, sig);
}).add;
)

(
Pbind(
	\instrument, \acid,
	\dur, Pseq(~xox.("xxooxoxo") * 8/120, inf),
	\scale, Scale.minor,
	\degree, Pseq([0,4,5,3,3], inf),
	\cut, Pwhite(100, 1500),
	\rez, Pwhite(0.1, 0.8),
	\amp, -10.dbamp,
).play;
)

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

(

~coeff = {|freq| exp(-2pi * (freq * SampleDur.ir))};

SynthDef(\click, { |out, amp=0.1|
	var snd;
	snd = Impulse.ar(0);
	snd = OnePole.ar(snd, ~coeff.(Rand(500, 10000)));
	DetectSilence.ar(snd, doneAction: Done.freeSelf);
	snd = snd * amp;
	snd = Pan2.ar(snd, pos: Rand(-1, 1));
	Out.ar(out, snd);
}).add;


SynthDef(\highshort, { |out, amp=0.1|
	var snd;
	snd = Pulse.ar([10000,10000*1.001], 0.5);
	snd = SinOscFB.ar(snd,1);
	snd = snd * EnvGen.ar(Env([0,1,1,0], [0.001, 0.010, 0.010]), doneAction: Done.freeSelf);
	snd = snd * amp;
	Out.ar(0, snd!2);
}).add;

SynthDef(\drippy,{
	var snd, duration, noise, env, sineFreq, auto;
	duration = \duration.kr(0.3);
	env = Env.linen(0,duration,0.01, curve:-4).ar(Done.freeSelf);
	auto = LFSaw.ar(Env([0,1],[duration],curve:3).ar.linexp(0,1,\freqStart.kr(50),\freqEnd.kr(50))).linlin(-1,1,1,0);
	sineFreq = auto.pow(2).linexp(0,1,10,8e3);
	snd = (SinOsc.ar(sineFreq * [3,1,2,4]) * [0,-5,-2,-10].dbamp).sum;
	//snd = (snd * [3,1,2,4]*[0,-5,-2,-10].dbamp).sum;

	snd = BPF.ar([snd],(0..10).normalize.linexp(0,1,100,8000) * XLine.ar(\resStart.kr(1.5),\resEnd.kr(0.5),duration),0.1).sum * 6.dbamp;
	snd = snd*auto;
	snd = snd.fold2 * 5.dbamp;
	//snd = (snd*10.dbamp*(1+Env.perc(0,0.1).ar)) ;
	snd = Splay.ar(snd,0.9);
	snd = snd * env;
	//snd = snd + CombC.ar(snd,mul:0.5);
	snd = snd * -10.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;
)

Synth(\drippy, [\duration,4,\freqStart,20,\freqEnd,10]);

(
// xxxoxxooxxxooxxo
Pbind(
	\instrument, \drippy,
	\dur, 0.125 * Pseq(~xox.("xxooxoxoxxooxoxo"), inf),
	\duration,Pkey(\dur)*Pwhite(1.0,1.1),
	\freqStart,Pseg([200,200,100,50,500],10,-3,inf),
	\freqEnd,Pseg([10,10,100,1,5],10,-1,inf),

	\amp, -10.dbamp,
).play;
)



(
// sequencing

~tick32 = 0.0625; //0.08823;
~tick16 = ~tick32 * 2;


~pa = "xxooxoxoxxooxoxo";
~p1 = "xxxxxxxxxxxxxxxx"; //click
~p2 = "xxxoxxooxxxooxxo"; //highshort
~p3 = "xooooooooooooooooooxoooooooooooo"; //bass
~p4 = "ooooooxooooooooooooooooooooooooo"; //envsine
~p5 = "oooooooooooooooooooooooooxoooooo"; //highlong
~p6 = "xooooooooooooooooooooooooooooooo"
   ++ "xxoooooooooooooooooooooooooooooo"; //midsine

~p7 = Array.newClear(31).fill(Rest(~tick16)).add(~tick16).scramble; //burst

Pdef(\ikeda, Ppar([
	Pbind(\instrument, \click,     \dur, Pseq(~tick32 * ~xox.(~p1), inf)),
	Pbind(\instrument, \highshort, \dur, Pseq(~tick32 * ~xox.(~p2), inf)),
	Pbind(\instrument, \drippy,
		\dur, Pseq(~tick16 * ~xox.(~pa), inf),
		\duration,Pkey(\dur)*Pwhite(1.0,1.5),
		\freqStart,Pseg([200,200,100,50,500],10,-3,inf),
		\freqEnd,Pseg([10,10,100,1,5],10,-1,inf),
		\amp, -10.dbamp,)
	// Pbind(\instrument, \bass,      \dur, Pseq(~tick16 * ~xox.(~p3), inf)),
	// Pbind(\instrument, \envsine,   \dur, Pseq(~tick16 * ~xox.(~p4), inf)),
	// Pbind(\instrument, \highlong,  \dur, Pseq(~tick16 * ~xox.(~p5), inf)),
	// Pbind(\instrument, \midsine,   \dur, Pseq(~tick32 * ~xox.(~p6), inf)),
	// Pbind(\instrument, \burst,     \dur, Pseq(~p7, inf)),
])).play;
)

Pdef(\ikeda).stop;