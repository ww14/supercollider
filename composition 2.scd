//load the setup file if you haven't already
("Setup/Setup.scd").loadRelative // load this file



// http://sccode.org/1-5dl#c950

//must make events if i want to use that functionality
s.scope;
s.plotTree;


/* bpfsaw: an instrument by Eli Fieldsteel as part of his SuperCollider tutorial series
A detuned slow-enveloped saw wave which sounds lush and beautiful, especially with some extended chords
Has a lot of arguments,

atk = attack
sus = sustain
rel = release
ts = timescale of the envelope
c1 = start of envelope curve
c2 = end of envelope curve
freq = frequency
detune = detuning (multiple of frequency), works well with low values, higher ones get quite silly
pan = panning in stereo
cfhzmin = minimum modulation of filter frequency
cfhzmax = maximum modulation of filter frequency
cfmin = minimum filter frequency
cfmax = maximum filter frequency
rqmin = controls filter sweeping. Lower values = greater effects of filtering
rqmax = controls filter sweeping. Lower values = greater effects of filtering
lsf = frequency at which low shelf is activated
ldb = low shelf boost (in dB) - gets really glitchy over around 16 dB, but sounds great so I keep it high
amp = volume
out = channels out
*/

(SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
	cycle = 2.reciprocal, downshift = -30, upshift = 30, reverb_amp=1,
	lsf=200, ldb=0, amp=1, out=0;
	var sig, env, perc_env, reverb;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
	sig = Saw.ar(freq * LFNoise1.ar(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)
		).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
	);


	perc_env = Env.perc.ar;

	reverb = sig * (1+ LFPulse.ar(cycle*(1+perc_env),0,0.1));
	reverb = BHiShelf.ar(reverb,1200,0.3,5);
	reverb = reverb.fold2;
	reverb = BHiShelf.ar(reverb,1200,0.3,-5);
	reverb = reverb + PitchShift.ar(reverb,0.03,1+(0.3*perc_env),perc_env.reciprocal,perc_env);
	reverb = reverb + PitchShift.ar(reverb,0.012,0.5+perc_env);
	reverb = FreqShift.ar(reverb,perc_env.linlin(0,1,0,downshift));
	reverb = reverb.tanh;
	reverb = reverb + CombC.ar(reverb * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	reverb = FreqShift.ar(reverb,perc_env.linlin(0,1,0,upshift));
	reverb = reverb.tanh * reverb_amp;
	reverb = HPF.ar(reverb,30);


	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = XFade2.ar(sig, reverb, pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Test

(~chug = Pbind(
	\instrument, \bpfsaw,
	\dur, Pseq([0.2,0.3],inf),  //2.5 to 6
	\midinote, Pdefn(\m,Pseq([
		60,[60,64,69],[53,65],[65,69,72,76],59],
	inf)),
	//starts out empty for only chug, if you add notes the melody takes over chug
	\detune, Pdefn(\d,Pexprand(0.05,0.2,inf)),  //Pexprand(0.05,0.2,inf), large detune makes it go nuts
	\cfmin, Pdefn(\cn,100),
	\cfmax,Pdefn(\cm,150),
	\rqmin,Pexprand(0.01,0.15,inf),
	\atk,Pwhite(2.0,2.5,inf),
	\rel,Pwhite(1.5,4.0,inf),
	\ldb, 6,   //orig at 6
	\amp,0.4,
	\upshift,Plprand(10,100),
	\downshift,Plprand(-10,-100),
	\out,0,
	\group, ~mainGrp,
	\out, ~out,
).play;
)
~chug.stop;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//the piece itself
//not using formal events as there's only one synth
/*s.prepareForRecord;
s.record;*/

(
t = TempoClock(60/60);
// Main routine
r = Task({

	(~chug = Pbind(
			\instrument, \bpfsaw,
	        \dur, Pseq([0.2,0.3],inf),  //2.5 to 6
			\midinote, 0, //starts out empty for only chug, if you add notes the melody takes over chug
	        \detune, Pexprand(0.05,0.2,inf),  //Pexprand(0.05,0.2,inf), large detune makes it go nuts
			\cfmin, 100,
		    \cfmax,200,
		    \rqmin,0.25,//Pexprand(0.01,0.15,inf),
			\atk,Pwhite(2.0,2.5,inf),
			\rel,Pwhite(1.5,5.0,inf),
	        \ldb, 6,   //orig at 6
		    \upshift,0,//Plprand(10,100),
		    \downshift,0,//Plprand(-10,-100),
			\amp,0.8,
		    \reverb_amp,0,
			\out,0,
			\group, ~mainGrp,
			\out, ~out,
	).play;
	);
	10.wait;
	Pbindf(~chug,
		\midinote,Pseq([0,2,8,0,0,[60,64,69]],inf),
		\rqmin,Pexprand(0.01,0.15,inf),
		\upshift,Plprand(10,100),
		\downshift,Plprand(-10,-100),
		\reverb_amp,0.5
	);
	20.wait;
	Pbindf(~chug,\midinote,Pseq([0,2,65,0,0,[60,64,69]],inf),\reverb_amp,0.75);
	20.wait;
	Pbindf(~chug,\midinote,Pseq([60,[60,64,69],[53,65],[65,69,72,76],59],inf),\reverb_amp,0.75);
	30.wait;
	Pbindf(~chug,\detune, Pwhite(0.05,0.7,inf)); //
	10.wait;
	Pbindf(~chug,\detune,Pexprand(0.05,0.2,inf));
	10.wait;
	Pbindf(~chug,\midinote,Pseq([0,2,65,0,0,[60,64,69]],inf),\reverb_amp,0.75);
	10.wait;
	Pbindf(~chug,\midinote,Pseq([0,2,8,0,0,[60,64,69]],inf),\reverb_amp,0.5); //transition from chug to melodic
	10.wait;
	Pbindf(~chug,\midinote,0,\reverb_amp,0.15);
	// ~a = Pbind(\instrument,\vplay,\buf,b[\k][0],\dur,Pxrand([1,2],inf),\amp,0.2,\rate,0.25,\out,~bus[\reverb]).play;
	10.wait;
	Pbindf(~chug,\cfmax,1500,\reverb_amp,0); //open it up
	10.wait;
	Pbindf(~chug,\cfmin,1400); //constrain
	5.wait;
	Pbindf(~chug,\cfmin,100); //unconstrain
	5.wait;
	// ~a.stop;
	Pbindf(~chug,\midinote,Pseq([0,2,8,0,0,[60,64,69]],inf),\reverb_amp,0.25); //transition from chug to melodic
	10.wait;
	Pbindf(~chug,\midinote,Pseq([0,2,65,0,0,[60,64,69]],inf),\reverb_amp,0.75);
	20.wait;
	Pbindf(~chug,\midinote,Pseq([60,[60,64,69],[53,65],[65,69,72,76],59],inf),\reverb_amp,1);
	15.wait;
	Pbindf(~chug,\cfmin,1400); //constrain
	5.wait;
	Pbindf(~chug,\cfmin,100); //unconstrain
	10.wait;
	Pbindf(~chug,\cfmax,15000); //open it up
	15.wait;
	Pbindf(~chug,\cfmin,14999); //constrain
	5.wait;
	Pbindf(~chug,\cfmin,100); //unconstrain
	15.wait;
	Pbindf(~chug,\cfmax,150000); //glitch light, in a nice way
	15.wait;
	Pbindf(~chug,\cfmin,15000); //constrain, will glitch too
	10.wait;
	Pbindf(~chug,\cfmin,100); //unconstrain
	30.wait;
	Pbindf(~chug,\midinote,Pseq([0,2,65,0,0,[60,64,69]],inf),\reverb_amp,0.5); //transition from chug to melodic
	5.wait;
	Pbindf(~chug,\cfmax,15000); //close it
	10.wait;
	Pbindf(~chug,\midinote,Pseq([0,2,8,0,0,[60,64,69]],inf),\reverb_amp,0.25);
	5.wait;
	Pbindf(~chug,\cfmax,1500); //open it
	10.wait;
	Pbindf(~chug,\midinote,0,\reverb_amp,0); //solo chug
	10.wait;
	Pbindf(~chug,\cfmax,Pgeom(1500,0.8,inf)); //slowly constrain
	45.wait;
	~chug.stop;
	//s.stopRecording;
	//Pdefn(\cm,Pgeom(150000,0.9,inf)); //back off,
	//Pdefn(\cm,150); //close it down
	// Pdefn(\m,Pseq([45,[45,70,48],49,[45,59,48],59],inf)); //completely different territory

});
)

r.play(t);





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Synth(\bplay, [\atk, 0.1, \sus,1, \rel, 7, \buf, b[\cellospica][3], \out, ~bus[\reverb]], target: ~mainGrp);
b[\crotales][3].play; //buffer plays

//Digitally modeled analog filter
Synth(\dfm1, [\freq, 15, \atk, 0.1, \rel, 7, \res,3,\inputgain,1,\type,0.0,\noise,0.09], target: ~mainGrp);



~a = Pbind(\instrument,\vplay,\buf,b[\k][0],\dur,Pxrand([1,2],inf),\amp,0.2,\rate,0.25,\out,~bus[\reverb]).play;
~a = Pbind(\instrument,\vplaym,\rel, 10,\buf,b[\glass][[10,34]],\dur,1,\amp,0.5,\rate,l,\out,~bus[\reverb]).play;

(~a = Pbind(\instrument,\vplay,\rel, 1,\buf,Pseq([
	b[\cellospica][[48,1]],
	b[\cellospica][49,2],
	b[\cellospica][50,3],
	b[\cellospica][51,4],
	b[\cellospica][0,5],
	b[\cellospica][5,6],
	b[\cellospica][6,7],
	b[\cellospica][7,8]
    ], inf)
,\dur,1,\amp,0.5,\rate,1,\out,~bus[\reverb]).play;)


//a fun intro to a perc mix
~a = Pbind(\instrument,\vplay,\rel, 5, \buf,b[\ht][0],\dur,Pxrand([2,2,2,0.25,2],inf),\amp,0.5,\rate,[0.1,10],\out,~bus[\reverb]).play;
~b = Pbind(\instrument,\vplay,\atk,0.2,\rel,2,\buf,b[\oh][0],\dur,Pseq([0.5,1,0.5,0.5],inf),\amp,0.5,\rate,0.1,\out,~out).play;
~c = Pbind(\instrument,\vplay,\rel,2,\buf,b[\q][0],\dur,0.5,\amp,0.5,\rate,0.5,\out,~out).play;
~a = Pbind(\instrument,\vplay,\rel,2,\buf,b[\stab][1],\dur,Pxrand([0.25,0.5,0.125,0.25,0.125]/4,inf),\amp,0.5,\rate,l,\out,~bus[\reverb]).play;
~a = Pbind(\instrument,\vplay,\rel,2,\buf,b[\stab][1],\dur,Pseq([0.5,Pseq([1],inf)]/4,inf),\amp,0.5,\rate,1/l,\out,~bus[\reverb]).play;

~c.stop;
~a = Pbind(\instrument,\vplaym,\rel,10,\buf,b[\shakers][5],\dur,1,\amp,0.5,\rate,0.2,\out,~out).play;
~b = Pbind(\instrument,\vplaym,\rel,2.9,\buf,b[\shakers][13],\dur,1,\amp,0.5,\rate,0.5,\out,~bus[\reverb]).play;


//messy
(
var rhythm = Array.fill(rrand(4,10),{rrand(1,10)}).normalizeSum * rrand(1,4);
l = Prewrite(1,
	(
		//equal to 2 duration units/beats
		1: #[0.25,0.5,0.5,0.25,2],
		0.25: #[1],
		2: rhythm
),15);
(
g = Prewrite(0.25,
	(
		0.25: #[0.25,0.25,0.25,0.5],
		0.5: #[0.25,0.5,0.125,0.125,0.125,0.125],
		0.125: #[0.375,0.125],
		0.375: #[0.375,0.375,1],
		1: #[0.75,0.25],
		0.75: #[16]
),60)
);

~k = Pbind(\instrument,\vplaym,\buf,[b[\deskBells][0],b[\deskBells][7]],\dur,g,\amp,1,\rate,1/g,\out,~bus[\reverb]);
~a = Pbind(\instrument,\vplay,\buf,b[\k][0],\dur,Pxrand([0.125,0.25,0.25],inf),\amp,0.5,\rate,0.25/l,\out,~out);
~a.play;
//~k.play;
)
~a.stop;


//test
(Pbind(
	\instrument, \dfm1,
	        \freq, Pdefn(\m,40),
	        \res, 10,  //
	        \inputgain, 1,
	        \type, Pdefn(\t,Pwhite(0.01,0.1,inf)),  //
			\noise,Pdefn(\n,0.001),
			\atk,Pwhite(0.1,0.2,inf),
			\rel,Pwhite(1,10.0,inf),
	        \dur, Prorate(0.6, 0.5),
	        \amp, 0.25,
	        \group, ~mainGrp,
			\out, ~bus[\reverb],
).play;)
(Pdefn(\m,Pxrand([ //choose among the chords at random
					[23,35,54,63,64],
					[45,52,54,59,61,64],
					[28,40,47,56,59,63],
					[42,52,57,61,63],
],inf).midicps);)

//a complicated pattern, swing notes

(
p = Pbind(
	\instrument, \sinfb,
    \degree, Pseries(4, Pwhite(-2, 2, inf).reject({ |x| x == 0 }), inf).fold(-7, 11),
    \dur, Prorate(0.6, 0.5),   // actually yields 0.3, 0.2, 0.3, 0.2...
	\out, ~bus[\reverb]
);
p.play;)


//panola potential lick
(
~ex = Panola.new(
	"(c2\\vol{0.2} <c4_4 e g5> <e_8 g b-3> <c_16\\vol{1} e g c5>)*4"
	"(c2\\vol{0.3} <c5_4 e5 g5> <e5_8 g5 b5-3> <c5_16\\vol{1} e5 g5 c5>)*4"
	"(c2\\vol[0.2] <c5_4 e g5> <e_8 g b-3> <c_16\\vol{1} e g c5>)*4"
	"(c2\\vol{0.3} <c5_4 e5 g5> <e5_8 g5 b5-3> <c_16\\vol{1} e g c5>)*4"

);
~pat = Pbind(\instrument, \pm4,	\midinote, ~ex.midinotePattern,	\dur, ~ex.durationPattern, \amp, ~ex.volumePattern,	\tempo, ~ex.tempoPattern, \lag, ~ex.lagPattern,	\legato, ~ex.pdurPattern);
~player = ~pat.play;
)


~ex = Panola.new("((c4_16 d)*3 (e f)*3)*2 (g a)*3 c5_4");
Pdefn(\m,~ex.midinotePattern, \dur, ~ex.durationPattern); //since not inf it'll end string, best as oneshots

(
~ex = Panola.new(
	"(c2\\vol{0.2} <c4_4 e g5> <e_8 g b-3> <c_16\\vol{1} e g c5>)*4"
	"(c2\\vol{0.3} <c5_4 e5 g5> <e5_8 g5 b5-3> <c5_16\\vol{1} e5 g5 c5>)*4"
	"(c2\\vol[0.2] <c5_4 e g5> <e_8 g b-3> <c_16\\vol{1} e g c5>)*4"
	"(c2\\vol{0.3} <c5_4 e5 g5> <e5_8 g5 b5-3> <c_16\\vol{1} e g c5>)*4"

);
~pat = Pbind(\instrument, \tpulse,	\midinote, 60,	\dur, ~ex.durationPattern, \amp, ~ex.volumePattern,	\tempo, ~ex.tempoPattern, \lag, ~ex.lagPattern,	\legato, ~ex.pdurPattern);
~player = ~pat.play;
)


Ndef(\verb).play;
Ndef(\verb).filter(1, {arg in;
	var sig = HPF.ar(in, 220);
	FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.5);
}).set(\wet1, 0.4);




(
SynthDef("bubbles", { |out|
    var f, sound;
    f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8, 7.23], 0, 3, 80)).midicps; // glissando function
    sound = CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4); // echoing sine wave
    Out.ar(out, sound);
}).add;

SynthDef("tpulse", { |out = 0, freq = 700, sawFreq = 440.0|
    Out.ar(out, SyncSaw.ar(freq, sawFreq, 0.1))
}).add;

)
x = Synth.new("tpulse");

