Server.killAll
("Setup/Setup_proxy.scd").loadRelative // load this file

(
~spica = PathName(thisProcess.nowExecutingPath).parentPath++"setup/cellospica/";
b = Dictionary.new;
b.add(\foldernames -> PathName(~spica).entries);
	for (0, b[\foldernames].size-1,
		{arg i; b.add(b[\foldernames][i].folderName -> b[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
)



x = Synth(\bufScratchFold, [bufnum: b["spica"][1],\amp,1])



//windy shower
(
y = Synth(\bufScratchFold, [bufnum: b["spica"][3]]);
y.set(\preAmp, 0.1);
y.set(\foldRange, 0.001);
y.set(\localFreq, 0.0001);
y.set(\localOscSize, 0.001);
y.set(\globalFreq, 9000);
y.set(\smoothAmount, 1);
)

//a beat
(
x.set(\preAmp, 1.0125,\foldRange, 100,\localFreq, 0.5,\localOscSize, 5,\globalFreq, 0.5,\smoothAmount, 0.3);
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

(SynthDef(\sinfb, {
	arg freq = 440, atk = 0.01, sus = 0, rel = 1, fb = 0, amp = 0.3, out = 0, pan=0;
	var sig, env;
	env = EnvGen.ar(Env.linen(atk,sus,rel),1,1,0,1,2);
	sig = SinOscFB.ar(freq,fb,1);
	sig = sig*env;
	Out.ar(out,Pan2.ar(sig,pan,amp));
}).add;);



(
~chord = [
    \Amaj11, \Fm11, \Gmaj11, \Am,
    \A, \E, \Gm, \DM,\C_g
].chordProg(Scale.dorian);
);

(
~chord1 = [
    \Dm7, \Em7, \FM7, \Am7,
    \AM, \BbM, \CM7, \Dm7sharp9,\DM7add11
].chordProg(Scale.dorian);
);


( ~b = Pbind(\instrument, \sinfb,
			\dur, 1,
	\rel,1,
	\degree, Pseq([Pseq(~chord1,1),Pseq(~chord1,1)],inf),
	\octave,3,
	\sus,0.005,
	\strum,Pwrand([0.01, 0.05, 0.2],[12,2,1].normalizeSum,inf),
	\amp, 0.15,
	\out,~bus[\reverb],
	).play;);

~b.play;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
(
t = TempoClock(60/60,4);
r = Routine.new({

	x = Synth(\bufScratchFold, [\bufnum, b["spica"][1],\amp,2]);

	y = Synth(\bufScratchFold, [bufnum: b["spica"][3],\preAmp, 0.1,\foldRange, 0.001,\localFreq, 0.0001,\localOscSize, 0.001,\globalFreq, 9000,\smoothAmount, 1,\amp,0.2]);

	( ~b = Pbind(\instrument, \sinegrain,
			\dur, 1,
			\degree, Pseq(~chord,1),
	\octave,3,
	\strum,Pwrand([0.01, 0.05, 0.1],[12,2,1].normalizeSum,inf),
	\sus,0.5,
	\amp, 0.1,
	\out,~bus[\reverb],
	););


	~q_r = Pseq(
		[
			Pseq([
				~b,
				~b,
				Pbindf(~b, \degree, Pseq(
					~chord1,2))
			]
			, 2),
			Pseq([
				Pbindf(~b, \sustain, 0.005),
				Pbindf(~b, \sustain, 0.005,\degree,Pseq(~chord1,1))
	], 3)],1);
	~r_r = Psetp(\dur, Pseq([1,Pseq([2],inf)], 1), ~q_r);
	~b_play_r = ~r_r.play;

    36.wait;

	//a beat

	z = Synth(\bufScratchFold, [\bufnum, b["spica"][0],\preAmp, 1.0125,\foldRange, 100,\localFreq, 0.5,\localOscSize, 5,\globalFreq, 0.5,\smoothAmount, 0.3, \amp, 0.1]);

	36.wait;

	//to change tone
	z.set(\localOscSize, 7.5,\localOscSize, 15);

	36.wait;

	//nasty
	x.run(false);
	z.set(\localOscSize, 1/15,\globalFreq, 1,\amp,0.2);

	36.wait;

	//panting ghost
	z.set(\localOscSize, 1/50,\globalFreq, 1,\smoothAmount, 0.08,\amp,4);

	72.wait;

	~b_play_r.pause;
	x.run(true);



}).play;
)


///////////////////////////////////////////////////////////////////////
x.run(false);
x.run(true);
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
