
/////////////////////////////////////////////////////////////////////////

(v = (SynthDef(\x,
	{arg rate=1;
	var trig, snd, freqs, perc, chain, detect, detect_snd, env;
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
//		     + AllpassN.ar(chain, 0.05, {Rand(0.001,0.05)}!2, 1.8)
	//         + detect_snd
	         + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,trig);
	snd = snd ! 2;
	snd = LeakDC.ar(snd);

	env = EnvGen.kr(Env.asr(0.01, \amp.kr(1), \release_dur.kr(inf)), \gate.kr(1), doneAction:2);

	snd = snd * env;
	Out.ar(0,snd);
}).add;

//organ pt.2

SynthDef(\y,
{arg rate=1, trigger=32, cycle_rate=0.0625, array;
	var trig, snd, env, freqs, perc, perc2, chord, cycle, harmony, arp, chain, detect, detect_snd, detect_p, detect_c, detect_arp, fade;
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, 1, trigger)); //LFDNoise makes the higher freq steps less discrete/quantized
	array = [
		[33,261,329,392,523,659,784,1046,1318,1568],
		[51,151,309,407,561,774,821,864,1173,1984],
		[55,220,261,329,440,523,659,880,1046,1318,1760],
	];
	chord = rate * array;
	cycle = chord.size * 0.5;
	chord = Select.kr( SinOsc.kr(cycle_rate,0,cycle,cycle),chord);
	freqs = (SinOscFB.ar(
		chord, // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
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
	snd = -12.dbamp * snd;
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0);

	chain = FFT(LocalBuf(2048), snd, 0.5);
	chain = PV_RandComb(chain, 0.5, Impulse.kr(1));
	chain = IFFT(chain) ;


	perc = SinGrain.ar(trig,0.001,freqs/2,2);


	detect_p = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.2, 0.2, LFDNoise1.kr(0.5).linexp(-1, 1, 0.2, 1), 0.01);
	perc2 = -18.dbamp * Pluck.ar(
		Hasher.ar(Sweep.ar(detect_p)),
		detect_p,
		freqs.reciprocal,
		freqs.reciprocal,
		2, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5);

	//detect_c = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.5, 0.9, 0.999999999, 2);
	harmony = 	LeakDC.ar(GVerb.ar(
		CombC.ar(
			Mix.ar( -40.dbamp *
				SinOscFB.ar(
					chord,
					Klang.ar(`[ [100, 200, 400], [0.01, 0.1, 0.3], [pi, 0, pi]]),
					Klang.ar(`[ [8, 10, 12].reciprocal, [0.1, 0.15, 0.15], [pi, 0, pi]])
				)
			)
			,1,0.1,0.2,0.1)
			,50,1,0.5,0.5,15,2)); //SinOscFB.ar(chord, 0.5pi, Decay.ar(0.01 * detect_c, 0.2));

	detect_arp = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.5, 0.9, 0.2, 0.05);
	arp = 	GVerb.ar(
		CombC.ar(
			Mix.ar( -12.dbamp *
				VOSIM.ar(detect_arp,
					chord,
					500)
			)
			,1,0.1,1.2,0.1)
		,70,1,0.5,0.5,15,2); //SinOscFB.ar(chord, 0.5pi, Decay.ar(0.01 * detect_c, 0.2));



	//	detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048), freqs), 1.0, 0.0, 0.9);
	//	detect_snd = MembraneCircle.ar(PinkNoise.ar(0.4),0.05,0.9,detect,3);

	snd = snd
	+ perc
	+ chain
	+ perc2
	+ harmony
	+ arp
	//         + detect_snd
	+ DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.005);
	snd = snd ! 2;

	fade = Line.ar(start: 1, end: 0.25, dur: 200.0);

	snd = LeakDC.ar(snd,0.995,fade);

	env = EnvGen.kr(Env.asr(0.001, \amp.kr(1), \release_dur.kr(inf)), \gate.kr(1), doneAction:2);

	snd = snd * env;

	Out.ar(0,snd);
}).add;

// make this simplified as a stab
SynthDef(\z,
{ arg rate=1;
	var trig, snd, env, freqs, perc, perc2, chord, cycle, harmony, arp, chain, detect, detect_snd, detect_p, detect_c, detect_arp;
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, 1, 32)); //LFDNoise makes the higher freq steps less discrete/quantized
		chord = rate * [
		[33,261,329,392,523,659,784,1046,1318,1568],
		[51,151,309,407,561,774,821,864,1173,1984],
		[55,220,261,329,440,523,659,880,1046,1318,1760],
	];
	cycle = chord.size * 0.5;
	chord = Select.kr( SinOsc.kr(12.reciprocal,0,cycle,cycle),chord);
	freqs = (SinOscFB.ar(
		chord, // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
	).linexp(-1, 1, 30, 150) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps;
	//	(SinOsc.kr(SinOsc.kr(2e-5)).linexp(-1, 1, 48, 64).round(4).poll(1/5) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -10.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		1.5, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5, //LFNoise2.kr(1/15).linexp(-1,1,0.5,0.9)
		0.1

		);
	snd = -12.dbamp * snd;
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0);

		//detect_c = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.5, 0.9, 0.999999999, 2);
	harmony = 	LeakDC.ar(GVerb.ar(
		CombC.ar(
			Mix.ar( -20.dbamp *
				SinOscFB.ar(
					chord,
					Klang.ar(`[ [100, 200, 400], [0.01, 0.1, 0.3], [pi, 0, pi]]),
					Klang.ar(`[ [8, 10, 12].reciprocal, [0.1, 0.15, 0.15], [pi, 0, pi]])
				)
			)
			,1,0.1,0.2,0.1)
			,50,1,0.5,0.5,15,2)); //SinOscFB.ar(chord, 0.5pi, Decay.ar(0.01 * detect_c, 0.2));


	//	detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048), freqs), 1.0, 0.0, 0.9);
	//	detect_snd = MembraneCircle.ar(PinkNoise.ar(0.4),0.05,0.9,detect,3);

	snd = snd
	+ harmony
	//         + detect_snd
	+ DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.005);
	snd = snd ! 2;


	snd = LeakDC.ar(snd);

	env = EnvGen.kr(Env.asr(0.001, \amp.kr(1), \release_dur.kr(inf)), \gate.kr(1), doneAction:2);

	snd = snd * env;
	Out.ar(0,snd);
}).add;


)
);

x = Synth.new(\y);
x.run(false);

(
//x.set(\rate,0.8);
//x.set(\trigger,2);
x.set(\array,[[1,20],[100],[200]]);
)
(
x.set(\cycle_rate,16.reciprocal);
x.set(\tri0gger,32)
)
(
x.set(\rate,0.1);
x.set(\trigger,5);
)
(
x.set(\rate,0.05);
x.set(\trigger,1.01);
)

Synth.new(\z)

x.release(4);
y.free;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

s.prepareForRecord;
(
v;
StageLimiter.deactivate;
t = Task({
    var x, y;
	//s.record;
    x =  Synth.new(\x);
    29.wait;//29.wait;
	x.release(2.0);
	1.5.wait;
	y = Synth(\y);
    48.wait;
	//y.set(\rate,2.0);
	y.set(\trigger,80);
	32.wait;  //32
	y.set(\cycle_rate,8.reciprocal);
    y.set(\trigger,32);
	32.wait; // 48
	y.set(\cycle_rate,16.reciprocal);
	y.set(\trigger,5);
	8.wait;
	y.set(\cycle_rate,4.reciprocal);
	8.wait;
	y.set(\cycle_rate,16.reciprocal);
	y.set(\trigger,1.01);
	32.wait;
	y.release(8);
	y.set(\trigger,80);
	12.wait;
	//s.stopRecording
   });
)

t.play;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
StageLimiter.deactivate;
(
v;
//StageLimiter.activate;
t = Task({
    var x, y;
    x =  Synth.new(\x);
    29.wait;//29.wait;
	x.release(2.0);
	1.5.wait;
	y = Synth(\y);
    195.wait;
	y.release(8)
   });
)

t.play;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
v;
//StageLimiter.activate;
a = Task({
    var x, y, z, stab;
    x =  Synth.new(\x);
    29.wait;
	x.run(false); //this pauses
	y = Synth(\y);
    72.wait;
	y.run(false);
	stab =  Synth.new(\x);
    0.1.wait;
	stab.run(false);
	y.run(true);
    72.wait;
	y.run(false);
	stab =  Synth.new(\x);
    0.1.wait;
	stab.run(false);
	y.run(true);
    20.wait;
	y.run(false);
	z = Synth(\z);
    20.wait;
	z.release(8);
   });
)

a.play;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//as a func
// just perc

(x =
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
};
)

x.play;

//organ pt.2

( y =
{
	var trig, snd, freqs, perc, perc2, chord, cycle, harmony, arp, chain, detect, detect_snd, detect_p, detect_c, detect_arp;
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, 1, 32)); //LFDNoise makes the higher freq steps less discrete/quantized
	chord = [
		[33,261,329,392,523,659,784,1046,1318,1568],
		[51,151,309,407,561,774,821,864,1173,1984],
		[55,220,261,329,440,523,659,880,1046,1318,1760],
	];
	cycle = chord.size * 0.5;
	chord = Select.kr( SinOsc.kr(12.reciprocal,0,cycle,cycle),chord);
	freqs = (SinOscFB.ar(
		chord, // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
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
	snd = -12.dbamp * snd;
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(1).linexp(-1, 1, 500, 16000), 0);

	chain = FFT(LocalBuf(2048), snd, 0.5);
	chain = PV_RandComb(chain, 0.5, Impulse.kr(1));
	chain = IFFT(chain) ;


	perc = SinGrain.ar(trig,0.001,freqs/2,2);


	detect_p = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.2, 0.2, LFDNoise1.kr(0.5).linexp(-1, 1, 0.2, 1), 0.01);
	perc2 = -18.dbamp * Pluck.ar(
		Hasher.ar(Sweep.ar(detect_p)),
		detect_p,
		freqs.reciprocal,
		freqs.reciprocal,
		2, //LFNoise2.kr(1/4).linexp(-1,1,0.3,0.9),
		0.5);

	//detect_c = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.5, 0.9, 0.999999999, 2);
	harmony = 	GVerb.ar(
		CombC.ar(
			Mix.ar( -40.dbamp *
				SinOscFB.ar(
					chord,
					Klang.ar(`[ [100, 200, 400], [0.01, 0.1, 0.3], [pi, 0, pi]]),
					Klang.ar(`[ [8, 10, 12].reciprocal, [0.1, 0.15, 0.15], [pi, 0, pi]])
				)
			)
			,1,0.1,0.2,0.1)
		,50,1,0.5,0.5,15,2); //SinOscFB.ar(chord, 0.5pi, Decay.ar(0.01 * detect_c, 0.2));

	detect_arp = PV_HainsworthFoote.ar(FFT(LocalBuf(2048), chain), 0.5, 0.9, 0.2, 0.05);
	arp = 	GVerb.ar(
		CombC.ar(
			Mix.ar( -12.dbamp *
				VOSIM.ar(detect_arp,
					chord,
					500)
			)
			,1,0.1,1.2,0.1)
		,70,1,0.5,0.5,15,2); //SinOscFB.ar(chord, 0.5pi, Decay.ar(0.01 * detect_c, 0.2));



	//	detect= PV_HainsworthFoote.ar(FFT(LocalBuf(2048), freqs), 1.0, 0.0, 0.9);
	//	detect_snd = MembraneCircle.ar(PinkNoise.ar(0.4),0.05,0.9,detect,3);

	snd = snd
	+ perc
	+ chain
	+ perc2
	+ harmony
	+ arp
	//         + detect_snd
	+ DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.005);
	snd = snd ! 2;
	snd = LeakDC.ar(snd);
	snd * -10.dbamp;
};
)

y.play;


