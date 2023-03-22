//https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3

//another nathan sound design rip off

( x =
{
	var trig, snd, freqs, perc;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(1/32).linexp(-1, 1, 52, 56).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		1.5, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5, //LFNoise2.kr(1/15).linexp(-1,1,0.5,0.9)
	);
	snd = -15.dbamp * snd;
	perc = SinGrain.ar(trig,0.001,freqs/2,2);
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



( x =
{
	var trig, snd, freqs, perc;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(1/32).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	perc = SinGrain.ar(trig,0.001,freqs/4,2);
	snd = perc ;
	      //   + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.9);
	snd = snd ! 2;
	snd;
}.play(fadeTime: 0);
)



//https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3

//dirtier, woozy

( x =
{
	var trig, snd, freqs, perc, chain, detect, detect_snd;
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


	perc = SinGrain.ar(trig,0.001,freqs/2,2);

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
	var trig, snd, freqs, perc;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
	freqs = (LFNoise2.kr(1/32).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	perc = SinGrain.ar(trig,0.001,freqs/4,2);
	snd = perc ;
	      //   + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.9);
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



