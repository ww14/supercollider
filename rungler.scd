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

numBits4

{ LFCub.ar(Line.kr(100, 800, 0.1)) }.plot(0.1);