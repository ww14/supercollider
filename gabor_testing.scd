(
SynthDef(\gabor, {

              var trig = Dust.kr(15,0.5); //Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, 1, 10000));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); ////;

              var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig, doneAction: 2);
              var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig, doneAction: 2);
              var gainEnv = EnvGen.kr(Env([0,1,0], [\atk.kr(0.01), \rel.kr(0.3)], \lin), trig, doneAction: 2);

              var numPartials = 100;
              var n = (1..numPartials);
              var freqs = \freq.kr(150) * (n + (n * n * 0.05));
              var cutoff, amps, sig;

              cutoff = fltEnv * \fltRange.kr(8000);

              amps = (
                             (freqs.log2 - cutoff.log2).squared
                             * \slope.kr(-8)
              ).dbamp;

              sig = SinOsc.ar(freqs * freqEnv.midiratio, 0, amps).sum * -25.dbamp;

              sig = sig * gainEnv;

              sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.25));
              Out.ar(\out.kr(0), sig);
}).add;
)

(
Pdef(\gabor,
              Pbind(
                             \instrument, \gabor,

                             \atk, 0.01,
                             \rel, 0.8,

                             // Bandpass Filter sweep
                             \slope, -5,
                             \fltRange, 8000,

                             \fAtk, 0.3,
                             \fRel, 0.08,
                             //\trig, 10,//Pseq([20,100,15,1],inf),
                             //\trig_dur, Pseq([1,0.5,0.25,1],inf),

                             \freq,Pseq([[256,512,8]!8,[128,512,4]!4].flatten,inf),

                             \amp, 0.70,
                             \pan, 0,
                             \out, 0,
              )
);
)

Pdef(\gabor).play;

Pdef(\gabor).stop;


(
SynthDef(\bass, {
              var snd, auto, freq, trig;
              freq = \freq.kr(40);
              trig = ToggleFF.ar(Dust.ar(8));
              auto = trig.lagud(0.1, 0.3);
              snd = Saw.ar(freq);
              snd = Splay.ar(snd);
              snd = (snd * 3).fold2;
              snd = RLPF.ar(snd, freq * 10, 0.1);
              snd = (snd * 5).fold2;
              snd = RLPF.ar(snd, freq * 8 * TRand.ar(1, 4, trig), 0.5);
              snd = (snd * 5).fold2;
              snd = MoogFF.ar(snd, auto.linexp(0, 1, 100, 8000), 0);
              snd = snd + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
              snd = (snd * -30.dbamp).tanh;
              Out.ar(\out.kr(0), snd);
}).play;
)

(Pdef(\gabor_bass,
              Pbind(\instrument, \bass,
                             \freq,Pseq([40!16,80!2,40!4,120!2].flatten,inf)
)
);
)

Pdef(\gabor_bass).stop;

(
SynthDef(\phase, {
              arg out=0, pan=0, amp=0.25, freq=110,
              mRatio=1.5, cRatio=1, widthMod=0.5;

              var sig, saw, sine;
              var width = SinOsc.ar(widthMod!2).range(\widthMin.kr(0.15), \widthMax.kr(0.50).clip(0.001,0.999));

              saw = LFSaw.ar(mRatio * freq, 1).linlin(-1,1, width.neg, 1-width);
              saw = saw.bilin(0, width.neg, 1-width, 0, -0.5, 1);
              sine = (Select.ar(saw>0, [0.5+saw, saw]) * 2pi).sin;

              sig = SinOsc.ar(
                             cRatio * freq * [1.001, 1],
                             phase: sine * MouseY.kr(0, 7)
              );

              sig = Pan2.ar(sig, pan, amp);
              Out.ar(out, sig);
}).add;
)

(instrument: \phase, midinote: [57,60,64,65,70]).play;



(
(1..50).do({|partials|
              SynthDef(\additive ++ partials, {

                             var sig, freqs, gainEnv;

                             gainEnv = EnvGen.ar(Env.adsr(
                                           \atk.kr(0.07),
                                           \dec.kr(0.5),
                                           \sus.kr(1),
                                           \rel.kr(2),
                                           curve: \curve.kr(-4)
                             ), \gate.kr(1), doneAction:2);

                             freqs = Array.fill(partials, {|i|
                                           \freq.kr(20) * (i+1); // even partials
                             });

                             sig = freqs.collect({|freq, i|
                                           var amps = \decay.kr(0.5) / (i+1); // even partials
                                           SinOsc.ar(freq) * amps;
                             });

                             sig = Mix(sig);

                             sig = sig * gainEnv * \amp.kr(0.3) * \vel.kr(1);
                             sig = Splay.ar(sig);
                             Out.ar(\out.kr(0), sig)
              }).add;
});
)

x = Synth(\additive10, [\freq, 220, \decay, 0.5]);

x.set(\gate, 0);