
//https://www.youtube.com/watch?v=0a-drU-_MpA
// https://sccode.org/1-5hZ
// https://sccode.org/1-5i2

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
~xox = {|str| str.collectAs({|l| switch(l.toLower,$x, {1}, $o, {Rest(1)})}, Array)};
)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// kick
(
(SynthDef(\kick, {
	var snd, duration;
	duration = \duration.kr(0.3);
	snd = SinOsc.ar(Env.perc(0,0.1).ar.linexp(0,1,55,1000) * XLine.ar(2,1,0.01)*XLine.ar(1,0.6,0.5));
	snd = snd + (RLPF.ar(Hasher.ar(Sweep.ar),4210,0.3) * Env.perc(0.001,0.01).ar * 5.dbamp);
	snd = snd + (RHPF.ar(Hasher.ar(Sweep.ar),6210,0.3) * Env.perc(0.001,0.03).ar * -9.dbamp);
	snd = snd * (1 + (5 * Env.perc(0,0.01).ar));
	snd = snd.clip2 + (snd.fold2 * -10.dbamp);
	snd = snd + HPF.ar((snd*6.dbamp).tanh, 3000);
	snd = snd * Env.perc(0.01,0.5).ar;
	snd = snd + HPF.ar(LPF.ar(DelayC.ar(snd * -25.dbamp, 0.1, [30e-3, 33.4e-3]), 5000), 100);
	snd = snd * Env.linen(0, duration, 0.01, curve:-4).ar(Done.freeSelf);
	snd = snd * -10.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);


//Synth(\kick);

(SynthDef(\kick2, {
	var snd, duration;
	duration = \duration.kr(0.3);
	snd = SinOsc.ar(Env.perc(0,0.1).ar.linexp(0,1,65,3000) * XLine.ar(2,1,0.01)*XLine.ar(1,0.5,0.5));
	snd = snd * Env.perc(0.001,0.5).ar;
	snd = snd ! 2;
	snd = snd * Env.linen(0, duration, 0.01, curve:-4).ar(Done.freeSelf);
	snd = snd * -2.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);

//Synth(\kick2);

(SynthDef(\kicks, {
	var snd, duration;
	duration = \duration.kr(0.3);
	snd = SinOsc.ar(LFSaw.ar(30).linexp(-1,1,3000, 100));
	snd = snd ! 2;
	snd = snd * Env.linen(0, duration, 0.01, curve:-4).ar(Done.freeSelf);
	snd = snd * -12.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);


//Synth(\kicks);

(SynthDef(\snare, {
	var snd, duration, noise;
	duration = \duration.kr(0.3);
	snd = SinOsc.ar(Env.perc(0,0.01).ar.linexp(0,1,22,500) * [1,2.3,4.6,6.7]);
	snd = snd * Env.perc(0.01, [0.3, 0.05, 0.03, 0.01],curve:-8).ar;
	snd = snd * [0, -5, -2, -10].dbamp;
	snd = snd.sum;
	snd = snd * (1 + (10 * Env.perc(0, 0.01).ar));
	snd = snd.tanh;
	snd = snd + (SinOsc.ar(XLine.ar(3000, 100, 0.01)) * Env.perc(0.001, 0.01).ar);
	noise = (BPF.ar(Hasher.ar(Sweep.ar),[2210, 2830, 2339],[0.5, 0.3, 0.5]) *
		Env.perc([0.01,0.02,0.03],[0.05,0.07,0.1]).ar * [5,3,0].dbamp);
	noise = CombC.ar(noise,0.2, 1/[73, 66, 100],0.1);
	noise = HPF.ar(noise, 300);
	noise = noise.sum * 10.dbamp;
	snd = snd + noise;
	snd = (snd * 10.dbamp).tanh;
	snd = snd * (1 + (0.5 * Env.perc(0,0.05).ar));
	snd = snd + GVerb.ar(snd * -20.dbamp, 30, 1, damping:0.1);
	snd = snd * Env.linen(0, duration, 0.01, curve:-4).ar(Done.freeSelf);
	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);


//Synth(\snare);


(SynthDef(\snare_electro, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;);

//Synth(\snare_electro);

(SynthDef(\clap, {
	var snd, duration, env, noise;
	duration = \duration.kr(0.3);
	snd = LFSaw.ar((BPF.ar(Hasher.ar(Sweep.ar),1500 *[0.9,1,1.2],0.3) * 15.dbamp));
	snd = snd * Env([0,5,0.5,0],[0.001,0.01,0.15],curve:-4).delay([0.01,0,0.013]).ar;
	noise = (BPF.ar(Hasher.ar(Sweep.ar),[2210, 2830, 2339],[0.5, 0.3, 0.5]) *
		Env.perc([0.01,0.02,0.03],[0.05,0.07,0.1]).ar * [5,3,0].dbamp);
	noise = CombC.ar(noise,0.2, 1/[73, 66, 100],0.1);
	noise = HPF.ar(noise, 300);
	noise = noise.sum * 10.dbamp;
	snd = snd + noise;
	snd = snd +noise;
	snd = snd.clip2;
	env = Env.linen(0, duration, 0.01, curve:0).ar(Done.freeSelf);
	snd = snd * env;
	snd = Splay.ar(snd, 0.3);
	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);


(
//metal
SynthDef(\honk,{
	var snd, duration, noise, env, sineFreq, auto;
	duration = \duration.kr(0.3);
	snd = (SinOsc.ar(2 * [0.7, 3.3, 5.44, 7.33, 12.33] * XLine.ar(1.5, 1, 0.001)));
	snd = snd * Env.perc(0.001, [0.1, 0.05, 0.03, 0.003, 0.04, 0.01]).ar;
	snd = snd.sum;
	snd = snd * (1 + SinOsc.ar(50));
	snd = snd * (1 + SinOsc.ar(\pitch.kr(300)));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar),3320,0.3) * Env.perc(0.001,0.02).ar);
	snd = snd + PitchShift.ar(snd, 0.03, 0.5);
	snd = snd + PitchShift.ar(snd, 0.03, 1.1);
	snd = snd * (1 + Env.perc(0,0.02).ar);
	snd = snd.tanh * -5.dbamp;
	snd = snd * (1 + Env.perc(0,0.02).ar);
	snd = snd + GVerb.ar(snd * -20.dbamp, 30, 1);
	env = Env.linen(0,duration,0.001, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	//snd = snd + CombC.ar(snd,mul:0.5);
	snd = snd * -6.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);

//Synth(\honk);


(
//metal
SynthDef(\wooden,{
	var snd, duration, noise, env, sineFreq, auto;
	duration = \duration.kr(0.3);
	snd = (SinOsc.ar(20 * [0.7, 3.3, 5.44, 7.33, 12.33] * XLine.ar(1.5, 1, 0.001)));
	snd = snd * Env.perc(0.001, [0.1, 0.05, 0.03, 0.003, 0.04, 0.01]).ar;
	snd = snd.sum;
	snd = snd * (1 + SinOsc.ar(1000));
	snd = snd * (1 + SinOsc.ar(\pitch.kr(300)));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar),3320,0.3) * Env.perc(0.001,0.02).ar);
	snd = snd + PitchShift.ar(snd, 0.03, 1.5);
	snd = snd * (1 + Env.perc(0,0.02).ar);
	snd = snd.tanh * -15.dbamp;
	snd = snd * (1 + Env.perc(0,0.02).ar);
	snd = snd + GVerb.ar(snd * -20.dbamp, 30, 1);
	env = Env.linen(0,duration,0.001, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	//snd = snd + CombC.ar(snd,mul:0.5);
	snd = snd * -6.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);


//Synth(\wooden, [\pitch,600]);

(
SynthDef(\additive, {
    var snd, duration, n, env;
	duration = \duration.kr(0.30);
	n = (0..15).normalize.pow(0.5);
	snd = SinOsc.ar(n.linexp(0,1,100,8000));
	snd = snd *SinOsc.ar(n*15, 0.5);
	snd = snd * -3.dbamp;
	//snd = snd *SinOscFB.ar(n*20,snd.tanh, 0.5);
	snd = snd.sum;
	snd = BPF.ar(snd, XLine.ar(\bpfStart.kr(30),\bpfEnd.kr(3000), duration), 0.3) * 5.dbamp;
	snd = snd * Line.ar(0,1,0.1).pow(7);
	snd = snd + PitchShift.ar(snd, 0.03, 0.5);
	snd = snd + PitchShift.ar(snd, 0.03, 1.101);
	snd = snd + PitchShift.ar(snd, 0.03, 2.01,mul:0.1);
	snd = Splay.ar(snd,0.9);
	env = Env.linen(0.001,duration,0.01, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	snd = snd * -6.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);

Synth(\additive);


(SynthDef(\additive2, {
    var snd, duration, n, env;
	duration = \duration.kr(0.30);
	n = (0..30).normalize.pow(Rand(0.5,0.9));
	snd = SinOsc.ar(n.linexp(0,1,300,8000));
	snd = snd * -20.dbamp;
	snd = snd.sum;
	snd = (BPF.ar(snd, Latch.ar([800, 1200, 4230] * XLine.ar(1, [0.5,3.3, 0.5], duration), Impulse.ar(XLine.ar(20,30, duration))), 0.05) * [0, -5, -10].dbamp) * 12.dbamp;
	snd = Splay.ar(snd,0.3) * 9.dbamp;
	snd = snd * Line.ar(0,1,0.1).pow(2);
	env = Env.linen(0,duration,0.001, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);

//Synth(\additive2);

(SynthDef(\dialup, {
    var snd, duration, env;
	duration = \duration.kr(0.30);
	snd = SinOsc.ar(TIRand.ar(0,\high.kr(5), Impulse.ar(100!3)).linexp(0,5,200,16050));
	//snd = snd.sum * -10.dbamp;
	snd = Splay.ar(snd,0.3);
	snd = LPF.ar(snd, XLine.ar(8000, 100, duration));
	snd = snd + (RHPF.ar(Hasher.ar(Sweep.ar),1520,0.3) * Env.linen(0, 0.02, 0).ar * (1 + Env.perc(0, 0.01).ar) * -2.dbamp);
	env = Env.linen(0,duration,0.001, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	snd = snd * -20.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);


//Synth(\dialup);

(SynthDef(\drill, {
    var snd, duration, env, freq;
	duration = \duration.kr(1);
	freq = Env([0, 500, 0], [1, 2].normalizeSum * duration, [4,-4]).ar;
	snd = Impulse.ar(freq * [1,2.3, 3.4, 6.7, 8.8], Rand(0, 1!5));
	snd = snd * TRand.ar(0.5, 1, snd);
	snd = snd * [0, -5, -10, -3, -1].dbamp;
	snd = RHPF.ar(snd, [230, 340, 720, 310, 320], 0.3);
	snd = RLPF.ar(snd, 2* [2230, 3340, 5720, 4310, 1320], 0.3);
	snd = snd.sum ;
	snd = snd * (freq/200).pow(0.1);
	snd = CombC.ar(snd, 0.2, 1/50, 0.1);
	snd = CombC.ar(snd, 0.2, 1/93, 0.01);
	snd = CombC.ar(snd, 0.2, 1/27, 0.02);
	snd = snd + PitchShift.ar(snd, 0.03, 1.5);
	snd = snd ! 2;
	snd= snd + DelayC.ar(snd * -10.dbamp, 0.2, [0.13, 0.27]);
	env = Env.linen(0,duration,0.001, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	snd = snd * -10.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);

//Synth(\drill);

(SynthDef(\ping, {
    var snd, duration;
	duration = \duration.kr(0.30);
	snd = SinOsc.ar(1000);
	snd = snd * Env.perc(0.01, 5.0, curve:-8).ar(Done.freeSelf);
	snd = snd * (1+ 3 * Env.perc( 0.01, 1.0).ar);
	snd = snd * LFNoise2.ar(16!4);
	snd = snd.tanh;
	snd = LPF.ar(snd, 3000);
	//snd = snd.sum * -10.dbamp;
	snd = Splay.ar(snd,0.3);
	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0),snd);
}).add;);

//Synth(\ping)


(
//drip
SynthDef(\drippy,{
	var snd, duration, noise, env, sineFreq, auto;
	duration = \duration.kr(0.3);
	auto = LFSaw.ar(Env([0,1],[duration],curve:3).ar.linexp(0,1,\freqStart.kr(50),\freqEnd.kr(50))).linlin(-1,1,1,0);
	sineFreq = auto.pow(4).linexp(0,1,10,16e3);
	snd = (SinOsc.ar(sineFreq * [3,1,2,4]) * [0,-5,-2,-10].dbamp).sum;
	//snd = (snd * [3,1,2,4]*[0,-5,-2,-10].dbamp).sum;
	snd = BPF.ar([snd],(0..10).normalize.linexp(0,1,100,8000) * XLine.ar(\resStart.kr(1),\resEnd.kr(1),duration),0.1).sum * 6.dbamp;
	snd = snd*auto;
	snd = snd * 3.dbamp;
	//snd = (snd*10.dbamp*(1+Env.perc(0,0.1).ar)) ;
	snd = Splay.ar(snd,0.3);
	snd = snd + (GVerb.ar(snd.sum, 60, 1, damping:0.7) * -30.dbamp);
	env = Env.linen(0,duration,0.01, curve:-4).ar(Done.freeSelf);
	snd = snd * env;
	//snd = snd + CombC.ar(snd,mul:0.5);
	snd = snd * -10.dbamp * \amp.kr(-6.dbamp);
	Out.ar(\out.kr(0),snd);
}).add;
);

//Synth(\drippy, [\duration,4, \resStart,1.9,\resEnd,1]);
//Synth(\drippy, [\duration,4,\freqStart,3,\freqEnd,50,\resStart,0.5,\resEnd,1.5]);
)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
// sequencing

~tick8 = (1/2) * (60/150);
//~tick4 = ~tick4 * 2 ; //0.08823;


~kick = "xooooooxxooooox";
~snare = "ooooxoooooooxoo";
~closed_hh = "xoxoxoxxxoooxox";
~open_hh = "ooooooooooxoooo";
~hi_bell = "xoxooxoooxooxoo";
~additive = "ooooxooxooxooxo";
~dial = "ooooxooxoxooxxo";

~bars = 8;

)



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// define patterns

(
	// section 1
	Pdef(\ikeda, Ppar([
		Pbind(\instrument, \kick,     \dur, Pseq(~tick8 * ~xox.(~kick), ~bars)),
		Pbind(\instrument, \snare_electro, \dur, Pseq(~tick8 * ~xox.(~snare), ~bars)),
	Pbind(\instrument, \wooden, \dur, Pseq(~tick8 * ~xox.(~closed_hh), ~bars), \pitch, Pwrand([330,660,440],[0.4,0.3,0.3],inf)),
	Pbind(\instrument, \honk, \dur, Pseq(~tick8 * ~xox.(~hi_bell), ~bars-1)),
	Pbind(\instrument, \additive,   \dur, Pseq(~tick8 * ~xox.(~additive), ~bars),\duration, 0.15 + Plprand(0,0.9) ,\bpfStart,Prand([Pexprand(100,800,1),Pexprand(2000,3000,1)],inf),\bpfEnd,Prand([Pexprand(2e3,8e3,1),Pexprand(800,100,1)],inf)),
		Pbind(\instrument, \kick2,  \dur, Pseq(~tick8 * ~xox.(~open_hh), ~bars-2)),
	]));
	//section 2
	Pdef(\ikeda2, Ppar([
		Pbind(\instrument, \kick,     \dur, Pseq(~tick8 * ~xox.(~open_hh), ~bars)),
		Pbind(\instrument, \snare_electro, \dur, Pseq(~tick8 * ~xox.(~hi_bell), ~bars)),
		Pbind(\instrument, \wooden, \dur, Pseq(~tick8 * ~xox.(~dial), ~bars), \pitch, Pwrand([330,660,440],[0.4,0.3,0.3],inf)),
		Pbind(\instrument, \drippy,
		\dur, Pseq([~tick8*4],~bars*5),
			\duration,Pkey(\dur)*Pwhite(1.0,1.5),
			\freqStart,Pseg([20,20,10,5,50],4,-3,inf),
			\freqEnd,Pseg([10,10,100,1,5],4,-1,inf),
			\resStart,Pseg([1.5,1.5,0.5,0.9,1.3],4,-3,inf),
			\resEnd,Pseg([0.5,0.5,1.5,1.3,0.9],4,-1,inf),
			\amp, -15.dbamp),
		Pbind(\instrument, \honk, \dur, Pseq(~tick8 * ~xox.(~closed_hh), ~bars)),
		Pbind(\instrument, \additive,   \dur, Pseq(~tick8 * ~xox.(~additive), ~bars/2),\bpfStart,Prand([Pexprand(30,200,1),Pexprand(2000,3000,1)],inf),\bpfEnd,Prand([Pexprand(2e3,8e3,1),Pexprand(200,50,1)],inf)),
		Pbind(\instrument, \kick2,  \dur, Pseq(~tick8 * ~xox.(~kick), ~bars)),
		//Pbind(\instrument, \drill,   \dur, Pseq(~tick16 * ~xox.(~open_hh), inf)),
		// Pbind(\instrument, \burst,     \dur, Pseq(~p7, inf)),
	]))
)

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// set a routine
(
t = TempoClock.default.tempo_(60/60);
Pseq([
	Pdef(\ikeda),
	Pdef(\ikeda2),
	Pdef(\ikeda)
]).play(t)
)
