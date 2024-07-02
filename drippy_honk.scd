
// synth

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

(
SynthDef(\fftod, { |out|
    var source1, detect, freq, snd, duration, auto, sineFreq;
	freq = (SinOsc.kr(\freq.kr(32)).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps;

	duration = \duration.kr(3);
	auto = LFSaw.ar(Env([0,1],[duration],curve:3).ar.linexp(0,1,\freqStart.kr(50),\freqEnd.kr(50))).linlin(-1,1,1,0);
	sineFreq = auto.pow(4).linexp(0,1,10,16e3);
	snd = (SinOsc.ar(sineFreq * [3,1,2,4]) * [0,-5,-2,-10].dbamp).sum;

	source1= Pluck.ar(snd,Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)),freq.reciprocal,freq.reciprocal,LFNoise2.kr(1/4).linexp(-1,1,0.1,0.3));
    detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048), snd), 1.0, 0.0, 0.9, 0.5);
    Out.ar(out, Pan2.ar(source1, -1.0) + Pan2.ar(SinOsc.ar(110, 0, Decay.ar(0.1 * detect, 0.1)), 1.0));
}).play;
)

(
//honk
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

);



(Pbindef(\honk,
	\instrument,\honk,
	\pitch,Pstep([45,40].midicps,[32,32],inf),  // [8,8,8,12,15] [8,7,12]
	\dur, Psubdivide(Pseq([1!48,2,1!36,4,1!48,3].flatten,inf),Pseq([0.25],inf)),
	//Pseg([60,600,60],[30,60],\lin,2),//Pwrand([60,200],[0.8,0.2],inf),
	\amp,-12.dbamp,
	\out,0
);)

Pbindef(\honk).play

Synth(\drippy, [\duration,4, \resStart,1.9,\resEnd,1]);
Synth(\drippy, [\duration,4,\freqStart,3,\freqEnd,50,\resStart,0.5,\resEnd,1.5]);
Synth(\drippy, [\duration,4,\freqStart,3,\freqEnd,5,\resStart,10.5,\resEnd,0.05]);
Synth(\drippy, [\duration,4,\freqStart,3,\freqEnd,50,\resStart,10.5,\resEnd,0.05]);
Synth(\drippy, [\duration,12,\freqStart,2,\freqEnd,9,\resStart,1.5,\resEnd,1.45]);
Synth(\drippy, [\duration,2,\freqStart,9,\freqEnd,50,\resStart,1.05,\resEnd,1.5]);
Synth(\drippy, [\duration,1,\freqStart,1000,\freqEnd,50,\resStart,3.05,\resEnd,10.5]);
Synth(\drippy, [\duration,1,\freqStart,45.midicps,\freqEnd,20.midicps,\resStart,0.15,\resEnd,1.5]);
Synth(\drippy, [\duration,1,\freqStart,1000,\freqEnd,50,\resStart,10.05,\resEnd,1.5]);
Synth(\drippy, [\duration,1,\freqStart,10,\freqEnd,500,\resStart,29.05,\resEnd,0.5]);
Synth(\drippy, [\duration,1,\freqStart,100,\freqEnd,5,\resStart,29.05,\resEnd,20.5]);
Synth(\drippy, [\duration,1,\freqStart,1000,\freqEnd,500,\resStart,31.05,\resEnd,0.5])
Synth(\drippy, [\duration,2,\freqStart,100,\freqEnd,5000,\resStart,31.05,\resEnd,0.5]);
Synth(\drippy, [\duration,4,\freqStart,1000,\freqEnd,500,\resStart,31.05,\resEnd,0.5]);











////////////////////////////////////////////////////////////////////
