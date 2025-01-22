// Define the synth
(
SynthDef(\memJam, {
    arg out=0, freq=200, tension=0.1, loss=0.995,
        dustRate=20, amp=0.5, pan=0;

    var exciter, membrane, env, perc_env, sig;

    // Create dust exciter with random amplitude
    exciter = Dust.ar(dustRate) * LFNoise1.kr(0.5).range(0.3, 1);

    // Membrane simulation
    membrane = MembraneCircle.ar(
        exciter,
        tension * LFNoise2.kr(0.2).range(0.8, 1.2),
        loss
    );

	membrane = membrane * LFPulse.kr(
        freq: LFDNoise3.kr(0.2).range(400, 800),
        width: LFNoise1.kr(20).range(0.1, 0.5),
    );


	perc_env = Env.perc.ar;

	sig = membrane * (1+ SinOsc.ar(\cycle.kr(0.5)*(1+perc_env)));
	sig = BHiShelf.ar(sig,1200,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,1200,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.3,1+(0.75*perc_env));
	sig = sig + PitchShift.ar(sig,0.12,0.5+perc_env);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(30)));
	sig = sig.tanh;


	sig = HPF.ar(sig,30);
	sig = LPF.ar(sig,7000);


    // Envelope for shaping
    env = EnvGen.kr(
        Env.perc(0.01, 0.3, curve:-2),
        exciter,
        levelScale: amp, doneAction:2
    );

    // Final processing
    sig = sig * env;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

// Play pattern
(
Pbind(
    \instrument, \memJam,
    \dur, Pseq([0.25, 0.5, 0.25, 0.25, 0.25], inf),
    \tension, 3 * Prand([0.05, 0.08, 0.1, 0.15], inf),
    \dustRate, 5 * Pseq([10, 20, 30, 15], inf),
    \pan, Pwhite(-0.8, 0.8),
    \amp, 0.4
).play;
)


(
SynthDef(\tubeSynth, {
    arg out=0, freq=200, pulseratelow=10 , pulseratehigh =20, chordratio = 0.05, loss=0.995, k=0.1,
        amp=0.5, pan=0, d1= 250, d2=10, gate=0;

    var source, tube, env, sig, perc_env;

	source = WhiteNoise.ar(0.25) * LFPulse.ar(
        freq: LFDNoise3.kr(0.2).range(pulseratelow, pulseratehigh),
        width: LFNoise1.kr(0.5).range(0.1, 0.5),
    );

    tube = TwoTube.ar(
        input: source,
        k: k * LFDNoise3.kr(0.3).range(0.8, 1.2),
        loss: loss,
        d1length: d1,
        d2length: d2
    );


	perc_env = Env.perc.ar;

	sig = tube * (1 + SinOsc.ar(\cycle.kr(5.reciprocal)*(1 + perc_env)));
	sig = BHiShelf.ar(sig,1200,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,1200,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.3,1+(chordratio*perc_env));
	sig = sig + PitchShift.ar(sig,0.012,0.5+perc_env);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(30)));
	sig = sig.tanh;


	sig = HPF.ar(sig,60);
	sig = LPF.ar(sig,7000);



	env = EnvGen.kr(Env([0,1,1,0],[0.01]++((\dur.kr(1)-0.001))),doneAction:Done.freeSelf);

	tube = sig * env * amp;

    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

(
Pbind(
    \instrument, \tubeSynth,
    \dur, Pseq([0.5, 0.25, 0.75, 0.5], inf),
//Pseq([0.333, 0.25, 0.25, 0.167], inf),//Pseq([0.25, 0.125, 0.125, 0.25], inf),
	\pulseratelow, Pstep([10,1],[36,12],inf),//
	\pulseratehigh, Pstep([20,30],[36,12],inf),//
    \k, Prand([0.1, 0.2, 0.15], inf),
    \loss, Pseq([0.91, 0.995, 0.99], inf),
	\chordratio,0.05,//0.25
	\pan, Pgauss(0, 0.25),
	\d1,Pstep([50,55],12,inf).midicps,//
	\d2, (Pseq([3, 1, 2, 1,2,5,2,4], inf)).midicps,//(Pseq([30, 15, 20, 15,20,5,25,40], inf)).midicps, //Pseq([10, 15, 30, 15], inf),
    \amp, 0.3
).play;
)








// Define the funky SynthDef using MembraneCircle
(SynthDef(\funkyMembrane, {
    |freq = 200, amp = 0.5, decay = 0.8, pan = 0|
    var sound, env;

    // MembraneCircle UGen with modulation for added funkiness
    sound = MembraneCircle.ar(
        freq: freq,
        loss: LFNoise1.kr(0.3).range(0.9995, 0.95),
        tension: 0.9
    ) * amp;

    // Envelope for better control
    env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);

    Out.ar(0, Pan2.ar(sound * env, pan));
}).add;)

// Define a Pbind pattern for a funky groove
(p = Pbind(
    \instrument, \tubeSynth,
    \d1, Pseq([150, 200, 250, 300, 225, 275, 325, 175], inf),
    \amp, Pseq([0.5, 0.4, 0.6, 0.7, 0.3, 0.6, 0.5, 0.4], inf),
    \d2, 20.midicps * Pseq([0.4, 0.6, 0.5, 0.3, 0.7, 0.4, 0.6, 0.5], inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \dur, Pseq([0.25, 0.5, 0.25, 0.75, 0.5, 0.25, 0.25, 0.5], inf)
);)

// Play the pattern
p.play;

