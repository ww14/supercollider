// https://scsynth.org/t/another-benjolin-rungler-patch/6599/2
//I just made the number of bits 2048




///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////instrument/////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
var rungler, lfo;

lfo = {
	var trigger;
	trigger = Impulse.ar(LFDNoise3.kr(4.reciprocal).linexp(-1, 1, 0.001, 2)); //Dust.ar(1);
	Select.ar(Stepper.ar(trigger,0,0,2), [
		LFDNoise3.ar(TIRand.ar(1,1,trigger).reciprocal).linlin(-1,1,0.25,0.65),
		Saw.ar(TIRand.ar(1,1,trigger)).range(0.0,1), //TRand.ar(-1, 1, trigger),
		Pulse.ar(TIRand.ar(2,2,trigger).reciprocal,0.95,0.25).range(0.0,1), //LFNoise2.ar(TIRand.ar(0.5, 10, trigger))
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

SynthDef(\rungler_saw_sub, {
	var snd, sndVerb, runglerOut, env;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFPulse.ar(({ lfo.() } ! 2).linexp(0, 1, [10, 1], 4000) * (snd * \pitch.kr([10])).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2) * (runglerOut[\out] * 0.85).range(100, 7000), \sub_gain.kr(0.5));

	snd = Splay.ar(snd, 0.9);

	sndVerb = NHHall.ar([snd,snd],LFPulse.ar(({ lfo.() }!2).linexp(0.001, 1, 0.19, 2.8),0,0.5),0.75);
	snd = XFade2.ar(snd, sndVerb);

	snd = LeakDC.ar(snd);

	snd= BLowShelf.ar(snd,200*ExpRand(0.7,1.0),1,-5+lfo.());
	snd = BHiShelf.ar(snd,3200*ExpRand(0.7,1.0),1,-5+lfo.());
	snd = (snd).tanh;
	snd= BLowShelf.ar(snd,200*ExpRand(0.7,1.0),1,-5+lfo.());
	snd = BHiShelf.ar(snd,3200*ExpRand(0.7,1.0),1,-5+lfo.());


	// env is just for fadeout
	env = Env.adsr(\attack.kr(0.01), \decay.kr(0.3), \sustainLevel.kr(1), \release.kr(1)).kr(Done.freeSelf, \gate.kr(1));
	snd = snd *env;

	snd = LeakDC.ar(snd) * -3.dbamp  * \amp.kr(1);
	Out.ar(\out.kr(0), snd);
}).add;


SynthDef(\rungler_saw, {
	var snd, sndVerb, runglerOut, env;
	snd = LocalIn.ar(2);
	runglerOut = rungler.(snd[0], snd[1]);
	snd = [runglerOut[\out], runglerOut[\outReverse]];
	snd = LFPulse.ar(({ lfo.() } ! 2).linexp(0, 1, [10, 1], 4000) * (snd * \pitch.kr([10])).midiratio);
	LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
	snd = (snd[0] > snd[1]) - 0.5;
	snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 7000) * (runglerOut[\out] * 2).midiratio, \sub_gain.kr(0.5));

	snd = Splay.ar(snd, 0.9);

	sndVerb = NHHall.ar([snd,snd],LFPulse.ar(({ lfo.() }!2).linexp(0.001, 1, 0.19, 2.8),0,0.5),0.75);
	snd = XFade2.ar(snd, sndVerb);

	snd = LeakDC.ar(snd);

	snd= BLowShelf.ar(snd,200*ExpRand(0.7,1.0),1,-5+lfo.());
	snd = BHiShelf.ar(snd,3200*ExpRand(0.7,1.0),1,-5+lfo.());
	snd = (snd).tanh;
	snd= BLowShelf.ar(snd,200*ExpRand(0.7,1.0),1,-5+lfo.());
	snd = BHiShelf.ar(snd,3200*ExpRand(0.7,1.0),1,-5+lfo.());

	// env is just for fadeout
	env = Env.adsr(\attack.kr(0.01), \decay.kr(0.3), \sustainLevel.kr(1), \release.kr(1)).kr(Done.freeSelf, \gate.kr(1));
	snd = snd *env;

	snd = LeakDC.ar(snd) * -3.dbamp * \amp.kr(1).lag3;
	Out.ar(\out.kr(0), snd);
}).add;
)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////testing////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


a = Synth(\rungler_saw_sub);
Synth(\rungler_saw);
//a.release(2);
a.set(\pitch,[10]);
a.set(\sub_gain,1.5);
a.set(\pitch,[70]);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////the piece//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
TempoClock.default.tempo_(60/60);
t = Task({
	"start".postln;
	//the low high range starts at 15-20
	a = Synth(\rungler_saw_sub);

	18.wait;
	"no sub".postln;
	a.release;
	b = Synth(\rungler_saw);

	64.wait;
	"lower noise by raising pitch".postln;
	b.set(\pitch, 20);

	4.wait;
	"raising pitch".postln;
	b.set(\pitch, 40);


	4.wait;
	"highest pitch".postln;
	b.set(\pitch, 70);

	4.wait;
	"start return to lower pitch".postln;
	b.set(\pitch, 30);
	//pre-start sub
	a = Synth(\rungler_saw);
	a.set(\amp,0,\pitch, 30);

	8.wait;
	"return and jam ".postln;
	b.set(\pitch, 70);
	1.wait;
	b.release(0.1);
	a.set(\amp,1,\pitch,10);

	30.wait;
	"start moog gain".postln;
	a.set(\sub_gain,1.0);
	10.wait;
	a.set(\sub_gain,1.5);
	10.wait;
	a.set(\sub_gain,1.75);
	10.wait;
	a.set(\sub_gain,2.0);
	10.wait;
	"peak moog gain".postln;
	a.set(\sub_gain,2.25);
	10.wait;
	a.set(\sub_gain,2.0);
	10.wait;
	a.set(\sub_gain,1.75);
	10.wait;
	a.set(\sub_gain,1.5);
	10.wait;
	a.set(\sub_gain,1.0);
	10.wait;
	a.set(\sub_gain,0.5);
	"lowest moog gain".postln;
	20.wait;
	a.set(\pitch, 70);

	a.release(8);


});
)

t.reset.play;
