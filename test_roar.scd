//https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3
//https://scsynth.org/t/roar-saturator/8508


Platform.userExtensionDir

b = Buffer.alloc(s, 16384, 1);
c = ({Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, \low.kr(10), \high.kr(20)));})

(
a = {
	var notes = [49, 54, 56, 59, 63, 65, 70, 73, 75];
	var harmonics = [1, 2, 3.5, 2, 4, 7];
	var freqs = notes.midicps *.x harmonics *.x [1, 1.008];
	var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
	var sig = Klank.ar(`[freqs, 1 ! freqs.size, b.duration ! freqs.size], exc) * 0.05;
	RecordBuf.ar(sig, b, loop: 0, doneAction: 2);
	sig.dup
}.play;
)

(
z = {
	var pulse = Dust.ar(LFDNoise3.kr(0.2).exprange(3, 15));
	var trig = c;
	var excEg = Decay2.ar(pulse, 0.001, 0.02);
	var noise = PinkNoise.ar * excEg;
	var ffreq = LFDNoise3.kr(0.2).exprange(200, 10000);
	var frq = LFDNoise3.kr(0.12372).exprange(0.02, 0.4);

	noise = BLowPass4.ar(noise, ffreq , frq);

	(Convolution2.ar(noise, b, framesize: b.numFrames) * 0.1).dup
}.play;
)



{Hasher.ar(Sweep.ar + [0, 43758, 1234])}.play;


("Setup/Setup.scd").loadRelative // load this file

(
SynthDef(\roarTest, {
    var sig, sigDry, sigWet, sigShaped, feed;
    var tone, toneFreq, toneComp, toneAmpLo, toneAmpHi, drive, bias, amount;
    var filterFunc, filterFreq, filterLoHi, filterBP, filterRes, filterBW, filterPre;
    var feedAmt, feedFreq, feedBW, feedDelay, feedGate;

    drive       = \drive.kr(spec:ControlSpec(       0, 48,      default: 14         )).dbamp;
    tone        = \tone.kr(spec:ControlSpec(        -1, 1,      default:-0.4        ));
    toneFreq    = \toneFreq.kr(spec:ControlSpec(    20, 20000,  default: 5520       ));
    toneComp    = \toneComp.kr(spec:ControlSpec(    0, 1,       default: 1          ));
    amount      = \amount.kr(spec:ControlSpec(      0, 1,       default: 0.8        ));
    bias        = \bias.kr(spec:ControlSpec(        -1, 1,      default: 0.0        ));

    filterFreq  = \filterFreq.kr(spec:ControlSpec(  20, 20000,  default: 12800      ));
    filterLoHi  = \filterLoHi.kr(spec:ControlSpec(  -1, 1,      default: -1         ));
    filterBP    = \filterBP.kr(spec:ControlSpec(    0, 1,       default: 0.2        ));
    filterRes   = \filterRes.kr(spec:ControlSpec(   0, 1,       default: 0.3        ));
    filterBW    = \filterBW.kr(spec:ControlSpec(    0, 4,       default: 0.5        ));
    filterPre   = \filterPre.kr(spec:ControlSpec(   0, 1,       default: 1          ));

    feedAmt     = \feedAmt.kr(spec:ControlSpec(     -90, 12,    default: 14         )).dbamp;
    feedFreq    = \feedFreq.kr(spec:ControlSpec(    20, 20000,  default: 80         ));
    feedBW      = \feedBW.kr(spec:ControlSpec(      0, 4,       default: 0.1        ));
    feedDelay   = \feedDelay.kr(spec:ControlSpec(   0, 4,       default: 1/6        )) - ControlDur.ir;
    feedGate    = \feedGate.kr(spec:ControlSpec(    0.02, 0.3,  default: 0.1        ));

    toneAmpLo   = tone.lincurve(-1.0, 1.0, 2.0, 0.0, -0);
    toneAmpHi   = tone.lincurve(-1.0, 1.0, 0.0, 2.0,  0);

    // sig = \in.ar([0, 0]);
    // sig = SAMP("/Users/Shared/_sounds/photek/full/photek1.wav")[0].ar(loop:1);
    sig = PlayBuf.ar(1, \buffer.ir, loop:1);

    // WET TONE
    sigWet = sig
        |> BHiShelf.ar(_,  toneFreq, 1, toneAmpHi.ampdb)
        |> BLowShelf.ar(_, toneFreq, 1, toneAmpLo.ampdb);

    // DRY TONE
    sigDry = sig
        |> BHiShelf.ar(_,  toneFreq, 1, 0)
        |> BLowShelf.ar(_, toneFreq, 1, 0);

    // Dry should be silent if tone = 0, else it should "make up"
    // the attenuation from the shelf filters? Use no-op filters on the dry
    // signal so delay from filter matches wet signal?
    sigDry = (sigDry - sigWet);

    // FEEDBACK
    feed = LocalIn.ar(2);
    feed = feed
        *> feedAmt
        |> BBandPass.ar(_, feedFreq, feedBW)
        |> DelayC.ar(_, 4, feedDelay)
        |> LeakDC.ar(_)
        *> Amplitude.ar(sig, 0.01, feedGate);

    // FILTER
    // filterLoHi blends between a lowpass and highpass
    // filterBP blends between the lo-hi signal and a bandpass
    filterFunc = {
        |sig|
        blend(
            blend(
                BLowPass.ar(sig, filterFreq, filterRes),
                BHiPass.ar(sig, filterFreq, filterRes),
                filterLoHi.linlin(-1, 1, 0, 1)
            ),
            BBandPass.ar(sig, filterFreq, filterBW),
            filterBP
        )
    };

    // SHAPE: PRE-FILTER
    // filterPre blends between filtering befor the shape stage, or after
    sigShaped = sigWet + feed;
    sigShaped = blend(sigShaped, filterFunc.(sigShaped), filterPre);

    // SHAPE
    sigShaped = sigShaped
        *> drive
        +> bias
        // |> tanh(_);
        |> SoftClipAmp8.ar(_, drive);
        // |> SmoothFoldQ.ar(_, -1, 1, 0.8, 0.5);

    // SHAPE: POST-FILTER
    sigShaped = blend(sigShaped, filterFunc.(sigShaped), 1 - filterPre);
    LocalOut.ar(sigShaped);

    sigWet = blend(sigWet, sigShaped, amount);

    sig = sigWet + (toneComp * sigDry);

    Out.ar(\out.kr(0), \amp.kr(1) * sig * [1, 1]);
}).add;
)

Synth(\roarTest);

(
// \roarTest.asSynthDesc.controls.collect({
//     |c|
//     "%%,%".format(
//         $\\,
//         c.name,
//         c.defaultValue
//             .round(0.01)
//             .asString
//             .padLeft(20 - c.name.asString.size.postln)
//     )
// }).join(",\n");

Pdef(\roadTestControls, Pbind(
    \drive,            9.0,
    \tone,            0.2,
    \toneFreq,       820.0,
    \toneComp,         0.07,
    \amount,           0.94,
    \bias,             0.1,
    \filterFreq,    280.0,
    \filterLoHi,      -0.7,
    \filterBP,         0.5,
    \filterRes,        0.7,
    \filterBW,         0.18,
    \filterPre,        0.0,
    \feedAmt,          5.0,
    \feedFreq,       2800.0,
    \feedBW,             2,
    \feedDelay,       1/60,
    \feedGate,         0.06,
    \buffer,           0.0,
));



Pdef(\roadTest, Pmono(
    \roarTest,
    \dur, 1/4,
    \buffer, b[\t][0],
    \amp, 4.dbamp,
) <> Pdef(\roadTestControls)).play
)



(

SynthDef(\roar, {
	var snd, fb, duration, upper, lower;
	duration = \duration.kr(4.0);
	snd = Saw.ar(Env([151,309,407,561,774,821,864,1173,1984,51].cpsmidi, [1, 4, 1, 1, 2, 1,1,4,3,2].normalizeSum * duration, curve: -4).ar.midiratio);
	snd = RLPF.ar(snd, XLine.ar([800, 300], [120, 400], duration) * (LFNoise2.kr(3 ! 2) * 3).midiratio * 0.5, \rq.kr(0.1)).sum;
	snd = snd * Env.linen(0.01, duration, 0.03).ar;

	snd = BHiShelf.ar(snd, 1200 * LFNoise2.kr(8).linexp(-1, 1, 0.5, 2), 0.3, -10);
	snd = BLowShelf.ar(snd, 200 * LFNoise2.kr(8).linexp(-1, 1, 0.5, 2), 0.3, -10);

	fb = LocalIn.ar(1);
	fb = BPF.ar(snd, LFNoise2.kr(3).linexp(-1, 1, 100, 3000), 0.3);
	fb = fb * LFNoise2.kr(8).linlin(-1, 1, -5, 12).dbamp;
	fb = LeakDC.ar(fb);
	snd = snd + fb;
	snd = (snd * 3.dbamp).tanh;
	snd = (snd * 3.dbamp).fold2;
	LocalOut.ar(snd);

	snd = BHiShelf.ar(snd, 5200, 0.3, 5);
	snd = BLowShelf.ar(snd, 200, 0.3, 5);

	snd = snd + GVerb.ar(snd * -20.dbamp, 50, 2);
	snd = Limiter.ar(snd);
	Out.ar(\out.kr(0), snd);
}).add;
)

Pbindef(\roar, \instrument,\roar,\dur,Pbjorklund2(5,8,inf)/3,\duration,Pkey(\dur),\rq,0.15).play;


(

SynthDef(\roar2, {
	var snd, fb, duration;
	duration = \duration.kr(4.0);
	snd = VarSaw.ar(\freq.kr(400).cpsmidi,3,0.03);
	snd = RLPF.ar(snd, XLine.ar([800, 300], [1200, 400], duration) * (LFNoise2.kr(3 ! 2) * 3).midiratio * 0.5, \rq.kr(0.1)).sum;
	snd = snd * Env.linen(0.01, duration, 0.03).ar;

	snd = BHiShelf.ar(snd, 1200 * LFNoise2.kr(8).linexp(-1, 1, 0.5, 2), 0.3, -10);
	snd = BLowShelf.ar(snd, 200 * LFNoise2.kr(8).linexp(-1, 1, 0.5, 2), 0.3, -10);

	fb = LocalIn.ar(1);
	fb = BPF.ar(snd, LFNoise2.kr(3).linexp(-1, 1, 100, 3000), 0.3);
	fb = fb * LFNoise2.kr(8).linlin(-1, 1, -5, 12).dbamp;
	fb = LeakDC.ar(fb);
	snd = snd + fb;
	snd = (snd * 3.dbamp).tanh;
	snd = (snd * 3.dbamp).fold2;
	LocalOut.ar(snd);

	snd = BHiShelf.ar(snd, 5200, 0.3, 5);
	snd = BLowShelf.ar(snd, 200, 0.3, 5);

	snd = snd + GVerb.ar(snd * -20.dbamp, 50, 2);
	snd = Limiter.ar(snd) * \amp.kr(0.5);
	Out.ar(\out.kr(0), snd);
}).add;
)

Pdef.removeAll;
t = TempoClock.default.tempo_(60/60);
Pbindef(\roar, \instrument,\roar,\dur,8,\duration,4).play;
Pbindef(\roar, \instrument,\roar,\midinote,Pseq([48,52,57,60].lace(3),inf));
~chord = [151,30,4,1,4,821,8,11,19,51];
Pbindef(\roar, \duration,4,\dur, 4.5);
Pbindef(\roar, \instrument,\roar2,\dur,Pbjorklund2(5,8,inf),\duration,Pkey(\dur)).play;




Pbindef(\roar, \instrument,\roar,\dur,Pbjorklund2(5,8,inf)/3,\duration,Pkey(\dur),\rq,0.15).play;
Pbindef(\roar2, \instrument,\roar2,\freq,Prand([407,774,864,1984],inf),\dur,3,\duration,Pkey(\dur)*0.95,\amp,0.1).play;


Pbindef(\roar, \rq,25);
Pbindef(\roar, \rq,0.08);