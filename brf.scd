// Fun with Splay:

s.options.memSize = 1048576; s.options.numWireBufs = 256; s.reboot;  // this is important!

(
SynthDef(\splay,
{arg fundamental = 110;
		var harmonics, snd, in, env, perc, perc_env, duration;
 harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  snd = BPF.ar(
		in: Saw.ar(\pulse.kr(4), LFPulse.ar(harmonics, width: SinOsc.kr(0.1,pi,0.25,0.5))),
 freq: harmonics * fundamental,
		rq: LFNoise2.kr(0.1).linexp(-1, 1, 0.001, 0.01), //0.01
 mul: 3);
	//snd = GVerb.ar(snd,\roomsize.kr(100),1,0.9,0.5,\spread.kr(15));
	snd = snd!2;
	//duration = \dur.kr(30.0);
	//osc = SinOsc.kr(0.1,pi,0.25,0.51);
	perc_env = Env.perc.ar;
	perc = snd.fold2;
	perc = BHiShelf.ar(perc,1200,0.3,-5);
	perc = snd + PitchShift.ar(perc,0.9,1+(0.3*perc_env));
	perc = snd + PitchShift.ar(perc,0.12,0.5+perc_env);
	//perc = FreqShift.ar(perc,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	//perc = perc.tanh;
	perc = snd + CombC.ar(perc * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	//perc = FreqShift.ar(perc,perc_env.linlin(0,1,0,\upshift.kr(300)));
	perc = perc.tanh;
	//perc = perc * Env.linen(0.01,duration,0.1,curve:-4).ar(Done.freeSelf);

	snd = NHHall.ar(snd,0.75,0.95);
	snd = Compander.ar(snd,snd,
		thresh: 0.1,
        slopeBelow: 1,
        slopeAbove: 0.5,
        clampTime:  0.1,
        relaxTime:  0.2);

	//LocalOut.ar(snd);
	//snd;


	snd = (snd) + perc;

	snd = LeakDC.ar(snd).tanh;
	snd = IIRFilter.ar(snd, freq: 600.0, rq:\rq.kr(0.51), mul: 1.0, add: 0.0);
	//snd = MoogFF.ar(snd, LFNoise2.kr(0.1).linexp(-1, 1, 500, 1600), 0);
	//snd = Splay.ar(snd,0.9);
	env = Env.asr(\atk.kr(0.1), \amp.kr(1).lag3(6), \release.kr(1)).kr(2, \gate.kr(1));
	snd = snd *env;
	Out.ar(0,snd);
}).add;
)

y = Synth(\splay)
y.set(\fundamental,2);


y.set(\fundamental,45);


y = Synth(\splay,[\fundamental,450]);
y.set(\pulse,3.95)
y.set(\fundamental,52.midicps);
y.set(\fundamental,45.midicps);


/////////////////////////////////////////////////////////////////////////

(
SynthDef(\splay,
{arg fundamental = 440;
		var harmonics, snd, in, env, perc, perc_env, duration;
 harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  snd = BRF.ar(
			in: Saw.ar(\pulse.kr(4), LFPulse.ar(harmonics, width: 0.1)),//SinOsc.kr(0.1,pi,0.25,0.5))),
 freq: harmonics * fundamental,
		rq: LFNoise2.kr(0.1).linexp(-1, 1, 0.01, 0.1), //0.01
 mul: 0.5);
	//snd = GVerb.ar(snd,\roomsize.kr(100),1,0.9,0.5,\spread.kr(15));
	snd = snd!2;
	//duration = \dur.kr(30.0);
	//osc = SinOsc.kr(0.1,pi,0.25,0.51);
	perc_env = Env.perc.ar;
	perc = snd.fold2;
	perc = BHiShelf.ar(perc,1200,0.3,-5);
	perc = snd + PitchShift.ar(perc,0.9,1+(0.3*perc_env));
	perc = snd + PitchShift.ar(perc,0.02,0.5+perc_env);
	//perc = FreqShift.ar(perc,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	//perc = perc.tanh;
	perc = snd + CombC.ar(perc * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	//perc = FreqShift.ar(perc,perc_env.linlin(0,1,0,\upshift.kr(30)));
	perc = perc.tanh;
	//perc = perc * Env.linen(0.01,duration,0.1,curve:-4).ar(Done.freeSelf);

	snd = NHHall.ar(snd,0.75,0.5);

	snd = (snd) + perc;

	snd = Compander.ar(snd,snd,
		thresh: 0.0125,
        slopeBelow: 1,
        slopeAbove: 0.25,
        clampTime:  0.01,
        relaxTime:  0.2);

	//LocalOut.ar(snd);
	//snd;

	//snd = HPF.ar(snd,40);

	snd = LeakDC.ar(snd).tanh;
	snd = IIRFilter.ar(snd, freq: 600.0, rq:\rq.kr(0.51), mul: 1.0, add: 0.0);
	//snd = MoogFF.ar(snd, LFNoise2.kr(0.1).linexp(-1, 1, 500, 1600), 1);
		//snd = Splay.ar(snd);
	env = Env.asr(\atk.kr(0.05), \amp.kr(1).lag3(6), \release.kr(10)).kr(2, \gate.kr(1));
	snd = snd *env;
	Out.ar(0,snd);
}).add;
)

y.set(\fundamental,8);


y.set(\fundamental,200);


y = Synth(\splay,[\pulse,4]);
y.set(\pulse,3.99);
y.set(\fundamental,50.midicps);
y.set(\fundamental,62.midicps);