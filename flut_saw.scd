(SynthDef(\flut,
{
	var in, chain, snd, ff, rmf, range, delayTime = 1.23;
	ff = 256;
	rmf = 20.reciprocal;
	in = StkBlowHole.ar(\freq.kr(32),\reedstiffness.kr(64), \noisegain.kr(32), \tonehole.kr(64), \register.kr(4), \breathpressure.kr(90), \mul.kr(1.0), \add.kr(0.0));

    chain = FFT({LocalBuf(4096, 1)}.dup, in);
	chain = PV_BrickWall(chain, SinOsc.kr([0.1, 0.105]));
	chain = PV_RandComb(chain, 0.75, Impulse.kr(8));
	chain = IFFT(chain);
	//chain = IIRFilter.ar(chain);
	chain = chain.tanh;


	range = LFDNoise1.ar(1).linlin(-1,1,0.1, 0.95);
	snd = DelayN.ar(
		DFM1.ar(in, ff, res: 0.491 + LFNoise1.ar(1).range(0.1.neg, 0.1), noiselevel: 0.005),
		0.74157,//2
		delayTime + range);

	snd = snd * SinOsc.ar(rmf).range(0.4,1.2);
	snd = NHHall.ar(snd!2, SinOsc.ar(rmf).range(0.4,2), 0.5);
	snd = snd + (0.2*chain);
	snd = Compander.ar(snd,snd,
		thresh: 0.2,
        slopeBelow: 1,
        slopeAbove: 0.01,
        clampTime:  0.01,
        relaxTime:  0.02);

	snd = snd.tanh;
	snd = HPF.ar(snd,30);
	snd = LPF.ar(snd,4000);

	Out.ar(0,snd)
}).add;
)

Synth(\flut)