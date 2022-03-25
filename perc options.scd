//////////////////////////////////////////////////////////////////////////////////////////////
//  kick options
// https://sccode.org/1-57g


(
SynthDef(\kick1, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(800, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
    snd = snd + (SinOsc.ar(XLine.ar(172, 50, 0.01)) * Env.perc(0.0001, 0.3, 1, \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick1, [amp: 0.4]);

(
SynthDef(\kick2, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).ar * 0.5);
    snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(167, 52, 0.04)) * Env.perc(0.0005, 0.3).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick2, [amp: 0.4]);

(
SynthDef(\kick3, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
    snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick3, [amp: 0.4]);


(
var base;
//
base = Pbind(\amp, 1);

~p =	Ppar([
    Pbindf(
        base,
        \instrument, Pseq([\kalimba, \SOSsnare, \SOSkick, \xilophone, \SOSsnare], inf),
        \dur, Pseq([4, 3, 3, 2, 4], inf)/4
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\SOShats, 16), Pn(\SOStom, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    ),
	    Pbindf(
        base,
        \instrument, Pseq([Pn(\clap_electro, 16), Pn(\kick_electro, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)/64,
		\amp,0.3
    )
]);
~p.play(TempoClock(106/60));
)
~p.stop;


/*
contributors so far: nathan ho

i use Hasher.ar(Sweep.ar) as a quick way to generate deterministic white noise, so i can get exactly the same kick each time for a precise digital sampler effect. you are free to replace it with WhiteNoise.ar.

the DC.ar(0) does nothing, it's just so i can reorder all the "snd = snd +" lines and/or comment out parts of the synth.

some of the attacks are so fast that Env:kr doesn't correctly handle them. that's why i always use Env:ar, so i don't have to think about ar/kr when i'm messing with sharp envelope attacks. i'm sure many of them could be refactored to kr for CPU, but idc

*/


//////////////////////////////////////////////////////////////////////////////////////////////
// neurofunk, heavy
// https://sccode.org/1-57f

(
SynthDef(\neurosnare, {
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1));
    Out.ar(\out.kr(0), snd);
}).add;
)

Synth(\neurosnare, ["amp": 0.4, "exp":1/1000000]);


//////////////////////////////////////////////////////////////////////////////////////////////
// cheesy drumkick
// https://sccode.org/1-54H

(
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\snare, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\hihat, {
    |out = 0, pan = 0, amp = 0.3|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap, {
    |out = 0, amp = 0.5, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;
)

Synth(\kick2, [amp: 0.4]);



(
var base;

base = Pbind(\amp, 0.1);

Ppar([
    Pbindf(
        base,
		\instrument, Pwrand([\snare,\kick, \hihat],[4,2,1].normalizeSum, inf),
        \dur, Psubdivide(
    Pseq(#[1,1,1,1,1,2,2,2,2,2,0,1,3,12,0],inf),
    Pseq(#[1, 2, 1, 0.5,0.5]*2,inf)
)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\brusselator, 16), Pn(\brusselator, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    ),
/*  Pbindf(
        base,
        \instrument, Pseq([Pn(\kick, 8), Pn(\snare, 8)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
	)*/
]).play(TempoClock(2.3 * 4));
)



(
var base;

base = Pbind(\amp, 0.1);

Ppar([
    Pbindf(
        base,
        \instrument, Prand([\snare,\kick3, \kick, \hihat], inf),
        \dur, Pn(Pshuf([2,1,2,4], 3),inf)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\brusselator, 16), Pn(\brusselator, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    )
]).play(TempoClock(2.3 * 4));
)

PdurStutter


(
var base;

base = Pbind(\amp, 1);

Ppar([
    Pbindf(
        base,
        \instrument, Pseq([\kick, \neurosnare, \snare, \kick, \technokick], inf),
        \dur, Pseq([4, 3, 3, 2, 4], inf)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\hihat, 16), Pn(\snare, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    )
]).play(TempoClock(2.3 * 4));
)


//////////////////////////////////////////////////////////////////////////////////////////////
// gabber perc
// https://sccode.org/1-5aV


(
SynthDef(\gabberkick, {
    var snd, low, hi;
    snd = SinOsc.ar(\freq.kr(54) * XLine.kr(5, 1, 0.07) * XLine.kr(1.05, 1, 0.32));
    snd = snd * Env.perc(0.01, 2.0, curve: -8).ar;
    snd = (snd * 40.dbamp).tanh;
    snd = BHiShelf.ar(snd, 200, 1, -8);
    snd = BPeakEQ.ar(snd, \ffreq.kr(1000) * XLine.kr(1, 0.5, 0.5), 1, 15);
    snd = BPeakEQ.ar(snd, \ffreq.kr(1000) * 1.6 * XLine.kr(1, 0.5, 0.5), 1, 8);
    snd = (snd * 6.dbamp).tanh;
    snd = snd + ((snd.sign - snd) * -20.dbamp);
    low = LPF.ar(LPF.ar(snd, 500), 500);
    hi = HPF.ar(HPF.ar(snd, 500), 500);
    hi = DelayC.ar(hi, 0.2, SinOsc.kr(2, [1.5pi, 0.5pi]).range(0, 0.001));
    hi = hi * -3.dbamp;
    snd = low + hi;
    snd = (snd * 60.dbamp).tanh;
    snd = snd * Env.asr(0, 1, 0.01).kr(Done.freeSelf, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;
)

(
Pbind(*[
    instrument: \gabberkick,
    amp: -20.dbamp,
	legato: Pseg([1,0.5,1],20,\exp,inf),
    dur: Pseq([1, 1, 1, 1, 0.5, 0.5, 1, 0.5, 0.5], inf),
    freq: Pdup(Pseq([4, 5], inf), Pexprand(40, 500, inf)),
    ffreq: Pdup(Pseq([4, 5], inf), Pexprand(200, 3000, inf)),
]).play(TempoClock(120 / 60));
)


//////////////////////////////////////////////////////////////////////////////////////////////
//  techno perc
// https://sccode.org/1-5bV

TempoClock.default.tempo_(140/60);

(
SynthDef(\technokick, {
	| freq=51.913087197493, amp=0.5, rel=0.28571428571429, out=0, click=0.008, spread=0.1, damp=0.6 gate=1 |
	var sig, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -4, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rel/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(rel, rel/2, 1, 0.01, curve: 3),
		gate, doneAction: Done.freeSelf); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: 5,
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq

	verb = BLowPass.ar(verb, 400+freq,2);

	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1);
	Out.ar(out, sig);
}).add;
)

(
~kickIntro = Pbind(*[
	instrument: \technokick,
	damp: 0.95,
	spread: Pseq([0.9,0.8,0.6,0]),
	click: Pwhite(0.006, 0.008, 4),
	dur: 1,
	midinote: Pseq([60,55,52.5,40]);
]);
~kick = Pbind(*[
	instrument: \technokick,
	spread: Pseq([0.9,0.8,0.6,0], inf),
	click: Pwhite(0.006, 0.008, inf),
	dur: 2,
	legato: 2,
	midinote: Pseq([Pseq([32], 4), Pseq([28], 4)],inf),
	amp:10;
]);

~song = Pseq([~kickIntro, ~kick]);
~song.play(quant: 4);
)


































