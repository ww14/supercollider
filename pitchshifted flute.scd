
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

	sig = sig * (1+ SinOsc.ar(2.reciprocal*(1+perc_env)));
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
	Out.ar(\out.kr(0), Pan2.ar(sig * 0.1, \pan.kr(0)));
}).add;
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
	\downshift,-30,
	\upshift,30,
	\out,~bus[\nhhall],
);
)



(
~blow = Pbind(
    \instrument, \help_blowhole,
	\dur,Prand([6,3],inf),
	\pan,Pgauss(0,0.1,inf),
	\breathpressure,90,//Plprand(60,80),//Pseg([5,30,5],30,\wel,inf),
	\reedstiffness,100,
	\octave,2,//Pwrand([5,3,8,1],[4,3,2,1].normalizeSum,inf),
    \degree, Pseg([0,2,0,1,2,4,3],[4,2,2,4,2,2],\step,inf)+Pseq([-5,-4,-9,-7,-1],inf)+[-2,0,3,7,12],
	\mul,10,
	\downshift,-10,
	\upshift,5,
	\out,~bus[\nhhall],
);
)

~blow.play;
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
		Pbindf(~blow,\breathpressure,120,\reedstiffness,50,\downshift,-10,\upshift,10,)
      ])
);

~firstSection = Pfindur(32,
    Ppar([
		~blow

    ])
);



~secondSection = Pfindur(100,
    Ppar([
		Pbindf(~blow,\mul,200,\downshift,Pseg([-1,-60,-1],100),\upshift,Pseg([1,60,1],100))

    ])
);


~outroSection = Pfindur(16,
    Ppar([
		~blow
    ])
);

)

//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////piece//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////



(
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