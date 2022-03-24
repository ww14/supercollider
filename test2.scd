Server.killAll
("Setup/Setup.scd").loadRelative // load this file

Pdef(\a, Pbind(\instrument,\bufScratchFold,\bufnum, b[\cellospica][0],\amp,1));
Pdef(\a).fadeTime = 4;


Pdef(\a).play;
Pdef(\a).stop;



//windy shower
(
y = Synth(\bufScratchFold, [bufnum: d["cellospica"][0]]);
y.set(\preAmp, 0.1);
y.set(\foldRange, 0.001);
y.set(\localFreq, 0.0001);
y.set(\localOscSize, 0.001);
y.set(\globalFreq, 9000);
y.set(\smoothAmount, 1);
)

y.free;

//a beat
(
Pbindef(\a,\preAmp, 1.0125,\foldRange, 100,\localFreq, 0.45,\localOscSize, 5.5,\globalFreq, 0.9,\smoothAmount, 0.3);
)

//to change tone
x.set(\localOscSize, 7.5,\localOscSize, 15);

//nasty
x.set(\localOscSize, 1/15,\globalFreq, 1);

//panting ghost
x.set(\localOscSize, 1/50,\globalFreq, 1,\smoothAmount, 0.08);

//////////////////////////////////
(
SynthDef(\sinegrain,
    { arg out=0, freq=440, sustain=0.05, pan=0.5, amp=1;
        var env, sig;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction: Done.freeSelf);
		sig = SinOsc.ar(freq, 0, env);
		sig = Pan2.ar(sig, pan, amp);
        Out.ar(out, sig);
    }).add;
);



(
~chord = [
    \Amaj11, \Fmaj11, \Gmaj11, \Am,
    \A, \E, \Gm, \DM,\C_g
].chordProg(Scale.dorian);
);

(
~chord1 = [
    \Dm7, \Em7, \FM7, \Am7,
    \AM, \BbM, \CM7, \Dm7sharp9
].chordProg(Scale.dorian);
);


( ~b = Pbind(\instrument, \sinegrain,
			\dur, 2,
			\degree, Pseq(~chord,1),
	\octave,3,
	\strum,Pwrand([0.01, 0.05, 0.2],[12,2,1].normalizeSum,inf),
	\amp, 0.15,
	\out,~bus[\reverb],
	););

~b.play;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
(
t = TempoClock(60/60,4);
r = Routine.new({

	Pdef(\a, Pbind(\instrument,\bufScratchFold,\bufnum, b[\cellospica][0],\amp,1));
	Pdef(\a).fadeTime = 3;


	( ~b = Pbind(\instrument, \sinegrain,
			\dur, 2,
			\degree, Pseq(~chord,1),
	\octave,3,
	\strum,Pwrand([0.01, 0.05, 0.2],[12,2,1].normalizeSum,inf),
	\amp, 0.10,
	\out,~bus[\reverb],
	););


	~q_r = Pseq([Pseq([~b], 4),Pseq([Pbindf(~b, \degree, Pseq(~chord1,1))], 4)],1);
	~r_r = Psetp(\sustain, Pseq([2,0.1,0.005], inf), ~q_r);
	~b_play_r = ~r_r.play;

    44.wait;

	//a beat
	Pbindef(\a,\preAmp, 1.0125,\foldRange, 100,\localFreq, 0.45,\localOscSize, 5.5,\globalFreq, 0.9,\smoothAmount, 0.3);

	36.wait;

	//to change tone
	Pbindef(\a,\localOscSize, 7.5,\localOscSize, 15);

	36.wait;

	//nasty
	Pbindef(\a,\localOscSize, 1/15,\globalFreq, 1,\amp,0.2);

	36.wait;

	//panting ghost
	Pbindef(\a,\localOscSize, 1/50,\globalFreq, 1,\smoothAmount, 0.08);

	36.wait;



}).play;
)




///////////////////////////////////////////////////////////////////////


(
// first collect some things to play with
SynthDef("moto-rev", { arg out=0;
    var x;
    x = RLPF.ar(LFPulse.ar(SinOsc.kr(0.2, 0, 10, 21), [0,0.1], 0.1),
        100, 0.1).clip2(0.4);
    Out.ar(out, x);
}).add;

SynthDef("bubbles", { arg out=0;
    var f, zout;
    f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8,7.23], 0, 3, 80)).midicps;
    zout = CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4); // echoing sine wave
    Out.ar(out, zout);
}).add;


SynthDef("rlpf",{ arg out=0,ffreq=600,rq=0.1;
    ReplaceOut.ar( out, RLPF.ar( In.ar(out), ffreq,rq) )
}).add;


SynthDef("wah", { arg out, rate = 1.5, cfreq = 1400, mfreq = 1200, rq=0.1;
    var zin, zout;

    zin = In.ar(out, 2);
    cfreq = Lag3.kr(cfreq, 0.1);
    mfreq = Lag3.kr(mfreq, 0.1);
    rq   = Ramp.kr(rq, 0.1);
    zout = RLPF.ar(zin, LFNoise1.kr(rate, mfreq, cfreq), rq, 10).distort
                    * 0.15;

    // replace the incoming bus with the effected version
    ReplaceOut.ar( out , zout );

}).add;

SynthDef("modulate",{ arg out = 0, freq = 1, center = 440, plusMinus = 110;
    Out.kr(out, SinOsc.kr(freq, 0, plusMinus, center));
}).add;
)

// execute these one at a time

// y is playing on bus 0
y = Synth("moto-rev",["out",0]);

// z is reading from bus 0 and replacing that; It must be *after* y
z = Synth.after(y,"wah",["out",0]);

// stop the wah-ing
z.run(false);

// resume the wah-ing
t.run(true);

// add a rlpf after that, reading and writing to the same buss
a = Synth.after(z,"rlpf",["out",0]);

// create another rlpf after x
t = Synth.after(a,"rlpf",["out",0]);

a.set("ffreq", 400);

a.set(\ffreq, 100); // Symbols work for control names too

// Now let's modulate x's ffreq arg
// First get a control Bus
b = Bus.control(s, 1);

// now the modulator, *before* x
m = Synth.before(x, "modulate", [\out, b]);

// now map x's ffreq to b
a.map("ffreq", b);

m.set("freq", 4, "plusMinus", 20);

a.free;
z.free;
m.free;

// now place another synth after y, on the same bus
// they both write to the buss, adding their outputs
r = Synth.after(y,"bubbles",["out",0]);

y.free;
r.free;



///////////////////////////////////////////////////////////////////////

(
	~b_test = Pbind(\instrument, \sinegrain,
			\dur, 2,
			\degree, Pseq(~chord,1),
	\octave,3,
	\sustain,2,
	\strum,Pwrand([0.01, 0.05, 0.2],[12,2,1].normalizeSum,inf),
	\amp, 0.15,
	\out,~bus[\reverb],
	);

~b_test.play;

)
