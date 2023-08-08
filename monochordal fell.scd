//https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3

//another nathan sound design rip off

( x =
{
	var trig, snd, freqs, perc, a;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(32.reciprocal).linexp(-1, 1, 52, 56).round(4).poll(1) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		1.5, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5, //LFNoise2.kr(1/15).linexp(-1,1,0.5,0.9)
	);
	snd = -15.dbamp * snd;
	perc = SinGrain.ar(trig,0.001,freqs/2,1);
    //perc = DelayC.ar(perc, 0.01, SinOsc.ar(20.reciprocal, [0, pi]).range(0, 0.01));
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0);
	snd = snd
	         + perc
	         + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,trig);
	snd = snd ! 2;
	snd;
}.play(fadeTime: 0);
)

[52, 54, 56, 58, 60] +  .t[0, 2, 4, 5, 7, 9, 10, 14];



(
x =
{
	var trig, snd, freqs, perc, fund, a, cycle;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 15, 20)); //LFDNoise makes the higher freq steps less discrete/quantized
	fund = [57, 60, 52,53];
	a = fund +  .t[0, 4, 7, 9, 11, 14, -24];
	a.postln;
	cycle = a.size * 0.5;
	freqs = Select.kr(LFSaw.kr(30.reciprocal,0,cycle,cycle),a.midicps);
	//freqs = (SinOsc.kr(180.reciprocal).linexp(-1, 1, 52, 60).round(2).poll(1) +  [0, 2, 4, 5, 7, 9, 10, 14, 24]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		2.5, //LFNoise2.kr(1/4).linexp(-1,1,1.5,4),
		SinOsc.kr(60.reciprocal,1.5*pi).linexp(-1,1,1e-3,0.5)
	);
	snd = -25.dbamp * snd;
	perc = SinGrain.ar(
		trig,
		SinOsc.kr(60.reciprocal).linexp(-1,1,0.001,0.01),
		freqs.tanh
	) * -12.dbamp;
    //perc = DelayC.ar(perc, 1, SinOsc.ar(20.reciprocal, [0, pi]).range(0, 1));
	snd = LeakDC.ar(snd);
	snd = MoogFF.ar(snd, LFNoise2.kr(0.75).linexp(-1, 1, 500, 16000), 0);
	snd = snd
	    + perc
	         //+ DelayC.ar(snd, 0.1, SinOsc.ar(0.00005, [0, pi]).range(0, 0.01));
	;
	//snd = CombN.ar(snd,trig);
	snd = snd ! 2;
	//snd = NHHall.ar(snd);
	snd;
}.play(fadeTime: 0);
)


//////////////////////////////////////////
//
// this is now its own file
(
SynthDef(\rush,{
	var trig, snd, freqs, perc, fund, a, cycle;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, \low.kr(15), \high.kr(20))); //LFDNoise makes the higher freq steps less discrete/quantized
	fund = \fund.kr([57, 60, 52,53]);
	a = fund +  .t[0, 4, 7, 9, 11, 14, -24];
	a.postln;
	cycle = a.size * 0.5;
	freqs = Select.kr(LFSaw.kr(30.reciprocal,0,cycle,cycle),a.poll(0.1).midicps);
	//freqs = (SinOsc.kr(180.reciprocal).linexp(-1, 1, 52, 60).round(2).poll(1) +  [0, 2, 4, 5, 7, 9, 10, 14, 24]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -15.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		2.5, //LFNoise2.kr(1/4).linexp(-1,1,1.5,4),
		SinOsc.kr(60.reciprocal,1.5*pi).linexp(-1,1,1e-3,0.5)
	);
	snd = -25.dbamp * snd;
	perc = SinGrain.ar(
		trig,
		SinOsc.kr(60.reciprocal).linexp(-1,1,0.001,0.01),
		freqs.tanh
	) * -12.dbamp;
    //perc = DelayC.ar(perc, 1, SinOsc.ar(20.reciprocal, [0, pi]).range(0, 1));
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(0.75).linexp(-1, 1, 500, 16000), 0);
	snd = snd
	    + perc
	         //+ DelayC.ar(snd, 0.1, SinOsc.ar(0.00005, [0, pi]).range(0, 0.01));
	;
	//snd = CombN.ar(snd,trig);
	snd = snd !2 ; //Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	snd = snd * \amp.kr(1);
	//snd = NHHall.ar(snd);
	Out.ar(0,snd);
}).add;
)


(
TempoClock.default.tempo_(60/60);
t = Task({
	a = Synth(\rush);

	60.wait;
	a.set(\low,3,\high,10);

	30.wait;
	a.set(\low,1,\high,100);

	30.wait;
	a.set(\fund,[57, 53, 59, 55, 53]);

	30.wait;
	a.set(\low, 15, \high,40);

	60.wait;
	a.set(\fund,[57, 60, 52,53]);
	a.set(\low, 15, \high,20);

	// fade out
	a.set(\amp,0.9);
	2.wait;
	a.set(\amp,0.8);
	2.wait;
	a.set(\amp,0.7);
	2.wait;
	a.set(\amp,0.6);
	2.wait;
	a.set(\amp,0.5);
	2.wait;
	a.set(\amp,0.4);
	2.wait;
	a.set(\amp,0.3);
	2.wait;
	a.set(\amp,0.25);
	2.wait;
	a.set(\amp,0.2);
	2.wait;
	a.set(\amp,0.15);
	2.wait;
	a.set(\amp,0.1);
	2.wait;
	a.set(\amp,0.05);
	2.wait;
	a.set(\amp,0.025);
	2.wait;
	a.free
});
)

t.play;



[57, 53, 59, 47, 45] +1


/////////////////////////////////////////////

/// chugging

(
SynthDef(\rush2,{
	var trig, snd, freqs, perc, env;

	trig = Impulse.ar(LFDNoise3.kr(0.1).linexp(-1, 1, \lower.kr(14), \upper.kr(28))); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (\fund.kr(52).lagud +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	perc = SinGrain.ar(trig,0.006,freqs*[1/4,1,8,1/8],1);
	perc = Pluck.ar(perc,trig,freqs.reciprocal,freqs.reciprocal,0.15,[-0.7,0.8]);
	snd = perc
	     + -6.dbamp*DelayC.ar(perc, 0.01, SinOsc.ar(12.reciprocal, [0, pi]).range(0, 0.01));
	//snd = CombN.ar(snd,0.9);
	env = Env.asr(0.01, \dur.kr(1), \release.kr(0.5)).kr(0, \gate.kr(1));
	snd = snd *env *\amp.kr(1);
	snd = snd ! 2;
	Out.ar(0,snd);
}).add;
)
/*
(
SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
    var env, in;
    env = Linen.kr(gate, 0.05, 1, 0.1, 2);
    in = In.ar(out, 2);
    XOut.ar(out, env, CombL.ar(in * env, maxdtime, dtime, decay, 1, in));
}, [\ir, \ir, 0.1, 0.1, 0]).add;
)

a = Synth(\rush2);

Pdef(\rush2,Pbind(\instrument,\rush2,\dur,inf));

q = Pfx(a, \echo, \dtime, 0.2, \decay, 3);

a.stop;q.play
*/

a = Synth(\rush2);
a.set(\fund,2,\lower,10,\upper,14); //helicopter
a.set(\fund,52,\lower,14,\upper,28);
a.set(\fund,46,\lower,6,\upper,10);
a.set(\fund,6,\lower,400,\upper,450); //airplane engines
a.set(\fund,48);

//testing a pdef
(
Pdef(\intro,
Pbind(\instrument, \rush2,
		\fund, (48 + Pseq([
		Pseq([2, 5, 10],2),
		Pseq([0, 3, 8], 1),
		Pseq([1, 4, 9] ,1),
		Pseq([2, 5, 10] ,2),
		Pseq([4, 7, 12] ,1),
		Pseq([3, 6, 11],1),
	],inf)),
	\dur, Pseq([4,6,2]/8,inf),
	\amp, 4.dbamp,
	\pan,Pwhite(-0.1,0.1),
))
);
Pfx


Pdef(\intro).play


//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3

//dirtier, woozy

( x =
{
	var trig, snd, freqs, perc, chain, detect, detect_snd, percVerb;
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, 1, 32)); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (SinOscFB.ar(
		[33,261,329,392,523,659,784,1046,1318,1568], // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
    	Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 0, 1, 0]], Impulse.ar(SinOsc.kr(0.01,1.5*pi).linlin(-1,1,1000,2000).round(0.1), 0, 0.1)),  //fb of osc
		Klang.ar(`[ [8, 10, 12], [0.0, 0.1, 0.3], [pi, 0, pi]],Impulse.ar(SinOsc.kr(0.01,1.5*pi).linlin(-1,1,1,10).round(1),0,0.9,1))    //amp of osc
	).linexp(-1, 1, 30, 150) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps;
	//	(SinOsc.kr(SinOsc.kr(2e-5)).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		1.5, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5, //LFNoise2.kr(1/15).linexp(-1,1,0.5,0.9)
	);
	snd = -15.dbamp * snd;
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0);

	chain = FFT(LocalBuf(2048), snd, 0.5);
    chain = PV_RandComb(chain, 0.5, Impulse.kr(1));
	chain = IFFT(chain) ;
	//chain = NHHall.ar(chain!2,1);


	perc = SinGrain.ar(trig,0.001,freqs/2,2);
	percVerb = NHHall.ar(perc!2,3,0.1);
	perc = XFade2.ar(perc, percVerb, \mix.kr(0.009).linlin(0,1,-1,1));

//	detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048), freqs), 1.0, 0.0, 0.9);
//	detect_snd = MembraneCircle.ar(PinkNoise.ar(0.4),0.05,0.9,detect,3);

	snd = snd
	         + perc
	         + chain
	//         + detect_snd
	         + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,trig);
	snd = snd ! 2;
	snd = LeakDC.ar(snd);
	snd;
}.play(fadeTime: 0);
)

({MembraneCircle.ar(PinkNoise.ar(10),0.05,0.9,1,3)}).play;

( x =
{
	var trig, snd, freqs, perc, percVerb;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(1/32).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	perc = SinGrain.ar(trig,0.001,freqs/4,2);
	percVerb = NHHall.ar(perc!2,3,0.1);
	perc = XFade2.ar(perc, percVerb, \mix.kr(0.009).linlin(0,1,-1,1));
	      //   + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.9);
	snd = perc ;
	snd = snd ! 2;
	snd;
}.play(fadeTime: 0);
)

//
SinOsc



// perc detects change in freq of source audio; cool!
(
SynthDef(\fftod, { |out|
    var source1, detect, freq;
	freq = (SinOsc.kr(32).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps;
	source1= Pluck.ar(freq,Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)),freq.reciprocal,freq.reciprocal,LFNoise2.kr(1/4).linexp(-1,1,0.1,0.3));
    detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048), source1), 1.0, 0.0, 0.9, 0.5);
    Out.ar(out, Pan2.ar(source1, -1.0) + Pan2.ar(SinOsc.ar(110, 0, Decay.ar(0.1 * detect, 0.1)), 1.0));
}).play(s);
)



