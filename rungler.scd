// https://scsynth.org/t/another-benjolin-rungler-patch/6599/2
//I just made the number of bits 2048

(
var rungler, lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(4.reciprocal).linexp(-1, 1, 0.001, 2)); //Dust.ar(1);
	Select.ar(ToggleFF.ar(trigger), [
		LFNoise2.ar(TExpRand.ar(0.5, 10, trigger)),
		TRand.ar(-1, 1, trigger),
	]);
};

rungler = { |dataSignal, clockSignal|
	var numBits, numBits1, numBits2, numBits3, numBits4, bits, bit, out, doDAC;
	doDAC = { |bits|
		var result;
		result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
		result = result / 7;
		result = (result * 2) - 1;
		result;
	};
	bit = dataSignal > 0;
	numBits = 4096;

	bits = [];
	numBits.do {
		bit = Latch.ar(bit, clockSignal);
		bits = bits.add(bit);
		bit = Delay1.ar(bit);
	};
	(
		out: doDAC.(bits[numBits - 2045..numBits - 1]),
		outReverse: doDAC.(bits[numBits - 2..numBits - 2045]),
	);
};

SynthDef(\rungler, {
	var snd, sndVerb, runglerOut;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFTri.ar(({ lfo.() } ! 2).linexp(-1, 1, [10, 1], 6000) * (snd * 24).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 6000) * (runglerOut[\out] * 36).midiratio, 0.5);
	snd = Splay.ar(snd, 0.3);

	sndVerb = NHHall.ar([snd,snd],2,0.25);
	snd = XFade2.ar(snd, sndVerb);

	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\rungler);

/////////////////////////////////////////////////////////////////////////////////////////////////


(
var rungler, lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(4.reciprocal).linexp(-1, 1, 0.001, 2)); //Dust.ar(1);
	Select.ar(ToggleFF.ar(trigger), [
		LFNoise2.ar(TIRand.ar(0.5, 10, trigger)),
		TRand.ar(-1, 1, trigger),
	]);
};

rungler = { |dataSignal, clockSignal|
	var numBits, numBits1, numBits2, numBits3, numBits4, bits, bit, out, doDAC;
	doDAC = { |bits|
		var result;
		result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
		result = result / 12;
		result = (result * 2) - 1;
		result;
	};
	bit = dataSignal > 0;
	numBits = 8096;

	bits = [];
	numBits.do {
		bit = Latch.ar(bit, clockSignal);
		bits = bits.add(bit);
		bit = Delay1.ar(bit);
	};
	(
		out: doDAC.(bits[numBits - 4045..numBits - 1]),
		outReverse: doDAC.(bits[numBits - 2..numBits - 4045]),
	);
};

SynthDef(\rungler_env, {
	var snd, sndVerb, runglerOut;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFPulse.ar(({ lfo.() } ! 2).linexp(0, 1, [10, 1], 4000) * (snd * 10).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 4000) * (runglerOut[\out] * 6).midiratio, 1.5);
	snd = Splay.ar(snd, 0.9);

	sndVerb = NHHall.ar([snd,snd],LFPulse.ar(({ lfo.() }!2).linexp(0, 1, 0.15, 0.8)),0.25);
	snd = XFade2.ar(snd, sndVerb);

	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\rungler_env);

0.056.reciprocal

/////////////////////////////////////////////////////////////////////////////////////////////////

(
var rungler, lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(4.reciprocal).linexp(-1, 1, 0.001, 2)); //Dust.ar(1);
	Select.ar(Stepper.ar(trigger,0,0,2), [
		LFDNoise3.ar(TIRand.ar(1,1,trigger).reciprocal).linlin(-1,1,0.25,0.75),
		Saw.ar(TIRand.ar(1,1,trigger)).range(0,1), //TRand.ar(-1, 1, trigger),
		Pulse.ar(TIRand.ar(2,2,trigger).reciprocal,0.95,0.25).range(0,1), //LFNoise2.ar(TIRand.ar(0.5, 10, trigger))
	]);
};

rungler = { |dataSignal, clockSignal|
	var numBits, numBits1, numBits2, numBits3, numBits4, bits, bit, out, doDAC;
	doDAC = { |bits|
		var result;
		result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
		result = result / 12;
		result = (result * 2) - 1;
		result;
	};
	bit = dataSignal > 0;
	numBits = 2096;

	bits = [];
	numBits.do {
		bit = Latch.ar(bit, clockSignal);
		bits = bits.add(bit);
		bit = Delay1.ar(bit);
	};
	(
		out: doDAC.(bits[numBits - 1045..numBits - 1]),
		outReverse: doDAC.(bits[numBits - 2..numBits - 1043]),
	);
};

SynthDef(\rungler_saw, {
	var snd, sndVerb, runglerOut;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFPulse.ar(({ lfo.() } ! 2).linexp(0, 1, [10, 1], 4000) * (snd * \pitch.kr([10])).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, (runglerOut[\out]).range(200, 7000), 1.25);

	snd = Splay.ar(snd, 0.9);

	sndVerb = NHHall.ar([snd,snd],LFPulse.ar(({ lfo.() }!2).linexp(0.001, 1, 0.19, 2.8),0,0.5),0.75);
	snd = XFade2.ar(snd, sndVerb);

	//snd = SmoothClipS.ar(snd,-0.9,0.9,0.2);
	/*
	snd = BHiShelf.ar(snd,4000,1,-3);
	snd= BLowShelf.ar(snd,100,1,-3);
	snd = snd.tanh;
	snd= BLowShelf.ar(snd,100,1,-3);
	snd = BHiShelf.ar(snd,4000,1,-3);
*/
	snd = LeakDC.ar(snd) * -3.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

a = Synth(\rungler_saw);
a.set(\pitch,[10]);
a.set(\pitch,[10]);
a.set(\pitch,[40]);


/////////////////////////////////////////////////////////////////////////////////////////////////

(
var rungler, lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(4.reciprocal).linexp(-1, 1, 0.001, 2)); //Dust.ar(1);
	Select.ar(Stepper.ar(trigger,0,0,2), [
		LFDNoise3.ar(TIRand.ar(1,1,trigger).reciprocal).linlin(-1,1,0.25,0.75),
		Saw.ar(TIRand.ar(1,1,trigger)).range(0,1), //TRand.ar(-1, 1, trigger),
		Pulse.ar(TIRand.ar(2,2,trigger).reciprocal,0.95,0.25).range(0,1), //LFNoise2.ar(TIRand.ar(0.5, 10, trigger))
	]);
};

rungler = { |dataSignal, clockSignal|
	var numBits, numBits1, numBits2, numBits3, numBits4, bits, bit, out, doDAC;
	doDAC = { |bits|
		var result;
		result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
		result = result / 12;
		result = (result * 2) - 1;
		result;
	};
	bit = dataSignal > 0;
	numBits = 2096;

	bits = [];
	numBits.do {
		bit = Latch.ar(bit, clockSignal);
		bits = bits.add(bit);
		bit = Delay1.ar(bit);
	};
	(
		out: doDAC.(bits[numBits - 1045..numBits - 1]),
		outReverse: doDAC.(bits[numBits - 2..numBits - 1043]),
	);
};

SynthDef(\rungler_saw, {
	var snd, sndVerb, runglerOut;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFPulse.ar(({ lfo.() } ! 2).linexp(0, 1, [10, 1], 4000) * (snd * \pitch.kr([10])).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 7000) * (runglerOut[\out] * 2).midiratio, 0.5);

	snd = Splay.ar(snd, 0.9);

	sndVerb = NHHall.ar([snd,snd],LFPulse.ar(({ lfo.() }!2).linexp(0.001, 1, 0.19, 2.8),0,0.5),0.75);
	snd = XFade2.ar(snd, sndVerb);

	//snd = SmoothClipS.ar(snd,-0.9,0.9,0.2);
	/*
	snd = BHiShelf.ar(snd,4000,1,-3);
	snd= BLowShelf.ar(snd,100,1,-3);
	snd = snd.tanh;
	snd= BLowShelf.ar(snd,100,1,-3);
	snd = BHiShelf.ar(snd,4000,1,-3);
*/
	snd = snd * -3.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

a = Synth(\rungler_saw);
a.set(\pitch,[10]);
a.set(\pitch,[10]);
a.set(\pitch,[40]);


/////////////////////////////////////////////////////////////////////////////////////////////////


(
var rungler, lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(4.reciprocal).linexp(-1, 1, 0.001, 2)); //Dust.ar(1);
	Select.ar(Stepper.ar(trigger,0,0,2), [
		LFDNoise3.ar(60.reciprocal).range(0,1),   // 20.reciprocal
		Saw.ar([1,100.reciprocal]).range(0,1), //TRand.ar(-1, 1, trigger),
		Pulse.ar(2.reciprocal).range(0,1) //LFNoise2.ar(TIRand.ar(0.5, 10, trigger)),
	]);
};

rungler = { |dataSignal, clockSignal|
	var numBits, numBits1, numBits2, numBits3, numBits4, bits, bit, out, doDAC;
	doDAC = { |bits|
		var result;
		result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
		result = result / 12;
		result = (result * 2) - 1;
		result;
	};
	bit = dataSignal > 0;
	numBits = 2096;

	bits = [];
	numBits.do {
		bit = Latch.ar(bit, clockSignal);
		bits = bits.add(bit);
		bit = Delay1.ar(bit);
	};
	(
		out: doDAC.(bits[numBits - 1045..numBits - 1]),
		outReverse: doDAC.(bits[numBits - 2..numBits - 1045]),
	);
};

SynthDef(\rungler_saw, {
	var snd, sndVerb, runglerOut;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFPulse.ar(({ lfo.() } ! 2).linexp(0, 1, [10, 1], 4000) * (snd * \pitch.kr([10])).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 4000) * (runglerOut[\out] * 7).midiratio, 0.5);
	snd = Splay.ar(snd, 0.9);

	sndVerb = NHHall.ar([snd,snd],LFPulse.ar(({ lfo.() }!2).linexp(0, 1, 0.19, 1.8)),0.5);
	snd = XFade2.ar(snd, sndVerb);

	snd = snd * -7.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

a = Synth(\rungler_saw);
a.set(\pitch,[10]);
a.set(\pitch,[50]);

