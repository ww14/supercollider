
(
Server.killAll;
("Setup/Setup.scd").loadRelative; // load this file
//~fade = { |start, end, time, curve = 0| Pseg(Pseq([start, Pn(end)]), time, curve) };
)

(
SynthDef(\help_blowhole, {
	var env = EnvGen.ar(Env([0,1,1,0],[0.01]++((\dur.kr(1)-0.001)*[0.4,0.6])),doneAction:2);
	var sig = StkBlowHole.ar(\freq.kr(440),\reedstiffness.kr(64), \noisegain.kr(20), \tonehole.kr(64), \register.kr(11), \breathpressure.kr(64), \mul.kr(5.0), \add.kr(0.0));


	var perc_env = Env.perc.ar;

	sig = sig * (1+ SinOsc.ar(\cycle.kr(2.reciprocal)*(1+perc_env)));
	sig = BHiShelf.ar(sig,1200,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,1200,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.03,1+(0.3*perc_env));
	sig = sig + PitchShift.ar(sig,0.012,0.5+perc_env);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(30)));
	sig = sig.tanh;


	sig = HPF.ar(sig,30);
	sig = LPF.ar(sig,7000);
	Out.ar(\out.kr(0), Pan2.ar(sig * 0.1, \pan.kr(0)));
}).add;

(
SynthDef(\phase, {
	arg out=0, pan=0, amp=0.25, freq=110,
	mRatio=1.5, cRatio=1, widthMod=0.5;

	var sig, saw, sine, env, perc_env;
	var width = SinOsc.ar(widthMod!2).range(\widthMin.kr(0.15), \widthMax.kr(0.50).clip(0.001,0.999));

	env = EnvGen.ar(Env([0,1,1,0],[0.1]++((\dur.kr(1)-0.001)*[0.4,0.6])),doneAction:2);

	saw = LFSaw.ar(mRatio * freq, 1).linlin(-1,1, width.neg, 1-width);
	saw = saw.bilin(0, width.neg, 1-width, 0, -0.5, 1);
	sine = (Select.ar(saw>0, [0.5+saw, saw]) * 2pi).tanh;

	sig = SinOsc.ar(
		cRatio * freq * [1.001, 1],
		phase: sine * width.range(0,5)
	).tanh;

	perc_env = Env.perc.ar;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.1);


	sig = HPF.ar(sig,30);
	sig = LPF.ar(sig,7000);
	sig = sig.tanh;
	//sig = -50.dbamp * IIRFilter.ar(sig, SinOsc.kr(SinOsc.kr(0.1),1.5pi,1550,1800)).wrap(0,500);

	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)
)





(
~blow = Pbind(
    \instrument, \help_blowhole,
	\dur,Prand([6,3],inf),
	\pan,Pgauss(0,0.1,inf),
	\breathpressure,60,//Plprand(60,80),//Pseg([5,30,5],30,\wel,inf),
	\reedstiffness,Phprand(50,90),
	\octave,Pwrand([5,3,8,1],[4,3,2,1].normalizeSum,inf),
    \degree, Pseg([0,2,0,1,2,4,3],[4,2,2,4,2,2],\step,inf)+Pseq([-5,-4,-9,-7,-1],inf)+[-2,0,3,7,12],
	\mul,20,
	\downshift,-23,
	\upshift,23,
	\out,~bus[\nhhall],
	\pan,Pwhite(-0.9,0.9)
);

~chord = Pbind(\instrument,\phase,\dur,12,\freq,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,57,62],[54,50,62]].midicps,inf),\widthMod,3.reciprocal,\mRatio,50,\cRatio,1.005,\pan,-0.25,\amp,-53.dbamp);

~notes = Pbind(\instrument,\phase,\dur,Pseq([9,2],inf),\freq,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,57,62],[54,50,62]].midicps,inf),\widthMod,570.midicps,\mRatio,0.005,\cRatio,8,\amp,-60.dbamp,\pan,0.25);


/*~texture = Pbind(\instrument,\help_blowhole,\dur,Pseq([2], inf),\freq,Pn(Pshuf([57,62,56,61].midicps,1),inf),\widthMod,3.reciprocal,\mRatio,256,\cRatio,1,\mul,1);*/

~texture = Pbind(\instrument,\help_blowhole,\dur,12,\freq,Prand([57,62,56,61].midicps,inf),\breathpressure,32,\reedstiffness,Plprand(10,100),\downshift,-1,\upshift,1,\cycle,Plprand(10,30),\mul,2.25);

)




/*
(
~blow = Pbind(
    \instrument, \help_blowhole,
	\dur,Prand([6,3],inf),
	\pan,Pgauss(0,0.1,inf),
	\breathpressure,90,//Plprand(60,80),//Pseg([5,30,5],30,\wel,inf),
	\reedstiffness,100,
	\octave,Pwrand([2,1,3],[4,2,1].normalizeSum,inf),
    \degree, Pseg([0,2,0,1,2,4,3],[4,2,2,4,2,2],\step,inf)+Pseq([-5,-4,-9,-7,-1],inf)+[-2,0,3,7,12],
	\mul,10,
	\downshift,-10,
	\upshift,5,
	\out,~bus[\nhhall],
);
)
*/
~blow.play;
~chord.play;
~notes.play;
~texture.play;

Pbind(\instrument,\HC, \dur,Pseq([3,3,2],inf), \rel,Pkey(\dur)*1.4,\tone,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,57,62],[54,50,62]],inf),\downshift,-100,\upshift,100,\out,~bus[\reverb2]).play;


Pbind(\instrument,\rhodesChord, \dur,Pseq([2,1,2,2,1],inf)/8, \rel,Pkey(\dur)*0.4,\phaseLen,Pkey(\dur)*0.5,\midinote,Pseq([[57,50,62],[62,64],[56,50,61],[59,50,62],[56,50],[61,50,64],[57,62],[54,50,62]],inf),\iScale,0.75,\index,2,\mRatio,[0.5,1],\cRatio,0.5,\out,~bus[\reverb2]).play;


(
t = TempoClock.default.tempo_(1);
Pbindef(\harmony)
// slow pvc
)

Pbindef(\harmony).play(t);


//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////structure//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////


(
// Sections using Pfindur
~introSection = Pfindur(16,
    Ppar([
		Pbindf(~blow,\breathpressure,120,\reedstiffness,50,\downshift,-10,\upshift,10,\mul,2)
      ])
);

~firstSection = Pfindur(32,
    Ppar([
		~blow,
		Pbindf(~chord,\cRatio, 0.75,\freq,Pseq([[57,50,62],[62,64],[56,50,61]],inf).midicps)

    ])
);

~secondSection = Pfindur(100,
    Ppar([
		Pbindf(~blow,\mul,125,\downshift,Pseg([-1,-60,-1],100),\upshift,Pseg([1,60,1],100),\cycle,Pseg([2,6,2,1,3].reciprocal,100,-1,inf)),
		~chord,
		~texture,
		~notes

    ])
);


~outroSection = Pfindur(24,
    Ppar([
		~blow,
		Pbindf(~notes,\amp,-65.dbamp),
		Pbindf(~chord,\amp,Pseg(Pseq([-53.dbamp, 0]), 8,32)),
		Pbindf(~texture,\mul,Pseg(Pseq([1.25, 0]), 4,32))
    ])
);

)

~outroSection.play

//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////piece//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////



(
StageLimiter.activate;
t = TempoClock(60/60);
// Main routine
r = Routine({
    var sections = [
        (\name: "Intro", \pattern: ~introSection),
        (\name: "start Groove", \pattern: ~firstSection),
		(\name: "evolving Groove", \pattern: ~secondSection),
        (\name: "Outro", \pattern: ~outroSection)
    ];

    sections.do { |section|
        "Playing %...".format(section.name).postln;
        section.pattern.play(t);
        section.pattern.dur.wait;
    };

    "Funky jam finished!".postln;
    //0.exit;
});
)

r.play(t);