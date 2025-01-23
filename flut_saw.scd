(
{
	var in, chain, snd, ff, rmf, range, delayTime = 1.23;
	ff = 256;
	rmf = 20.reciprocal;
	in = StkBlowHole.ar(\freq.kr(32),\reedstiffness.kr(64), \noisegain.kr(32), \tonehole.kr(64), \register.kr(4), \breathpressure.kr(90), \mul.kr(1.0), \add.kr(0.0));

    chain = FFT({LocalBuf(4096, 1)}.dup, in);
	chain = PV_BrickWall(chain, SinOsc.kr([0.1, 0.105]));
	chain = PV_RandComb(chain, 0.5, Impulse.kr(8));
	chain = IFFT(chain);
	chain = IIRFilter.ar(chain, freq: 3500.0, rq:1);


	range = LFDNoise1.ar(1).linlin(-1,1,0.1, 1).poll(1);
	snd = DelayN.ar(
		DFM1.ar(in, ff, res: 0.491 + LFNoise1.ar(1).range(0.1.neg, 0.1), noiselevel: 0.005),
		0.74157,//2
		delayTime + range);

	snd = snd * LFPulse.ar(rmf,width:SinOsc.kr(0.1,0,0.25,0.5),mul:0.3,add:0.5);
	snd = NHHall.ar(snd!2, SinOsc.ar(rmf).range(0.4,2), 0.25);
	snd = IIRFilter.ar(snd, freq: 800.0, rq:\rq.kr(0.5), mul: 1.0, add: 0.0);


	snd = snd + (0.1*chain);
	snd = Compander.ar(snd,snd,
		thresh: 0.1,
        slopeBelow: 1.2,
        slopeAbove: 0.1,
        clampTime:  0.01,
        relaxTime:  0.02);

	snd = snd.tanh;
	snd = HPF.ar(snd,30);
	snd = LPF.ar(snd,4500);

	LocalOut.ar(snd);
	snd;
}.play;
)