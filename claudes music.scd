(
Server.killAll;
("Setup/Setup.scd").loadRelative; // load this file
//~fade = { |start, end, time, curve = 0| Pseg(Pseq([start, Pn(end)]), time, curve) };
)


(
// Define the tempo and scale
~scale = Scale.mixolydian;

// SynthDefs
(
SynthDef.new(\fm1, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	iScale=5,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=0.2, pan=0,
	lsf=200, ldb=0, out=0;
	var car, mod, env, iEnv, mod2;
	iEnv =EnvGen.kr(
		Env.new(
			[index, index *iScale, index],
			[atk,rel],
			[cAtk,cRel]
		)
	);//envelope on index allows for more control of a single note shape, imitate acoustic
	env = EnvGen.kr(
		Env.perc(atk,rel,curve:[cAtk,cRel]),
		doneAction:2
	);
	// mod2 = SinOsc.ar(freq/10,mul:freq/10 * iEnv); //additive modulation
	mod = SinOsc.ar(freq * mRatio , mul:freq * mRatio * iEnv);
	//filter sound for clipping/distortion
	car = SinOsc.ar(freq * cRatio + mod);
	car = BLowShelf.ar(car, lsf, 0.5, ldb);
	//car = Friction.ar(car, friction: \friction.kr(5.41322e-2), mass: \mass.kr(4.05501),spring:\spring.kr(0.414));
	car = car * env * amp;
	car = Pan2.ar(car, pan);

	Out.ar(out,car);
}).add;
);


(
SynthDef.new(\fm2, {
	arg freq=500,
	mRatio=1 , //controls spacing of harmonics
	cRatio= 1, //controls number of harmonics, noninteger value make a bell sound
	index=1, // note index =modAmp/modHz which is number of audible harmonic/overtone pairs
	cutoff=1000, res=3,width=0.5,
	iScale=5,
	atk=0.1, rel=1, cAtk=4, cRel=(-4),
	amp=0.2, pan=0,
	lsf=200, ldb=0, out=0;
	var car, mod, env, iEnv, mod2;
	iEnv =EnvGen.kr(
		Env.new(
			[index, index *iScale, index],
			[atk,rel],
			[cAtk,cRel]
		)
	);//envelope on index allows for more control of a single note shape, imitate acoustic
	env = EnvGen.kr(
		Env.perc(atk,rel,curve:[cAtk,cRel]),
		doneAction:2
	);
	// mod2 = SinOsc.ar(freq/10,mul:freq/10 * iEnv); //additive modulation
	mod = SinOsc.ar(freq * mRatio , mul:freq * mRatio * iEnv);
	mod = RLPF.ar(Pulse.ar(mod * width, 0.5), mod.tanh, res);
	//filter sound for clipping/distortion
	car = SinOsc.ar(freq * cRatio + mod);
	car = BLowShelf.ar(car, lsf, 0.5, ldb);
	//car = Friction.ar(car, friction: \friction.kr(5.41322e-2), mass: \mass.kr(4.05501),spring:\spring.kr(0.414));
	car = car * env * amp;
	car = Pan2.ar(car, pan);

	Out.ar(out,car);
}).add;
);

SynthDef(\funkBass, {
    |freq=440, amp=0.5, gate=1, cutoff=1000, res=0.3|
    var sig, env;
    sig = RLPF.ar(Saw.ar(freq) + Pulse.ar(freq * 0.5, 0.5), cutoff, res);
    env = EnvGen.kr(Env.adsr(0.01, 0.1, 0.8, 0.1), gate, doneAction: 2);
    Out.ar(0, Pan2.ar(sig * env * amp, 0));
}).add;



SynthDef.new(\rimshot, {
	arg amp=1,out=0, pan=0;
	var fenv, env, sig, punch, tri1, tri2;
	env = EnvGen.kr(Env.new([1, 1, 0], [0.00272, 0.07], -42), doneAction:2);
	tri1 = LFTri.ar(1667 * 1.1, 1) * env;
	tri2 = LFPulse.ar(455 * 1.1, width:0.8) * env;
	punch = WhiteNoise.ar * env * 0.46;
	sig = tri1 + tri2 + punch;
	sig = BPeakEQ.ar(sig, 464, 0.44, 8);
	sig = HPF.ar(sig, 315);
	sig = LPF.ar(sig, 7300);
	sig = Pan2.ar(sig * amp, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\hat, {
	arg decay=0.42, amp=1, pan=0, out=0;
	var sig, sighi,siglow, sum, env, osc1, osc2, osc3, osc4, osc5, osc6;
	env = EnvGen.kr(Env.perc(0.005, decay, 1, -30),doneAction:2);
	osc1 = LFPulse.ar(203.52);
	osc2 = LFPulse.ar(366.31);
	osc3 = LFPulse.ar(301.77);
	osc4 = LFPulse.ar(518.19);
	osc5 = LFPulse.ar(811.16);
	osc6 = LFPulse.ar(538.75);
	sighi = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
    siglow = (osc1 + osc2 + osc3 + osc4 + osc5 + osc6);
    sighi = BPF.ar(sighi, 8900, 1);
    sighi = HPF.ar(sighi, 9000);
    siglow = BBandPass.ar(siglow, 8900, 0.8);
    siglow = BHiPass.ar(siglow, 9000, 0.3);
    sig = BPeakEQ.ar((siglow+sighi), 9700, 0.8, 0.7);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;


SynthDef.new(\sn, {
	arg amp=2, tone=340, tone2=189, snappy=0.3, gate=0, amp2=1, out=0, pan=0;
	var noiseEnv, atkEnv, sig, noise, osc1, osc2, sum;
	noiseEnv = EnvGen.kr(Env.perc(0.001, 4.2, 1, -115), doneAction:2);
	atkEnv = EnvGen.kr(Env.perc(0.001, 0.8,curve:-95), doneAction:0);
	noise = WhiteNoise.ar;
	noise = HPF.ar(noise, 1800);
	noise = LPF.ar(noise, 8850);
	noise = noise * noiseEnv * snappy;
	osc1 = SinOsc.ar(tone2, pi/2) * 0.6;
	osc2 = SinOsc.ar(tone, pi/2) * 0.7;
	sum = (osc1+osc2) * atkEnv * amp2;
	sig = Pan2.ar((noise + sum) * amp * 2.5,pan);
	sig = HPF.ar(sig, 340);
	Out.ar(out, sig);
}).add;


SynthDef.new(\HC, {
	arg amp=1, freq=370,out=0, pan=0;
	var sig, fenv, env, perc_env;
	env = EnvGen.kr(Env.new([0.15, 1, 0], [0, 6], -250),doneAction:2);
	fenv = Env([freq*1.22972, freq*1.08108, freq], [0.1, 0.5], -4).kr;
	sig = SinOsc.ar(fenv, pi/2);

	sig = BPeakEQ.ar(sig, 464, 0.44, 8);
	sig = HPF.ar(sig, 315);
	sig = LPF.ar(sig, 7300);

	perc_env = Env.perc.ar;
	sig = sig + CombC.ar(sig * -10.dbamp,0.2,1/(60 * (1+perc_env)),0.15);

	sig = Pan2.ar(sig * env * amp * 2, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\claves, {
	arg amp=1, out=0;
	var  env, sig,perc_env,osc1, osc2, osc3, osc4, osc5, osc6, osc_array;
	env = EnvGen.kr(Env.new([1, 1, 0], [0, 0.1], -20), doneAction:2);
	osc1 = LFTri.ar(203.52);
	osc2 = LFTri.ar(366.31);
	osc3 = LFTri.ar(301.77);
	osc4 = LFTri.ar(518.19);
	osc5 = LFTri.ar(811.16);
	osc6 = LFTri.ar(538.75);
	osc_array = [osc1, osc2, osc3, osc4, osc5,osc6].fold2;
	sig = SinOsc.ar(2500*osc_array, pi/2) * env;
	perc_env = Env.perc.ar;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = Splay.ar(sig, 0.5,1,SinOsc.ar(1).linlin(-1,1,-0.7,0.7));
	sig = sig * amp;
	Out.ar(out, sig);
}).add;




SynthDef(\rhodesChord, {
    |freq=440, amp=0.3, gate=1, out=0, pan=0|
    var sig, env, perc_env;
    sig = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.01, 1), gate);
    sig = sig + (SinOsc.ar(freq * 2) * EnvGen.ar(Env.perc(0.01, 0.5), gate) * 0.05);

	perc_env = Env.perc.ar;

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

	env = EnvGen.kr(Env.perc(0.001, 4.2, 1, -4), doneAction:2);
	sig = sig*env;

    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

SynthDef.new(\bd, {
	arg decay=30, amp=2, gate=0, tone=56, out=0;
	var fenv, env, trienv, sig, sub, punch, pfenv;
	env = EnvGen.kr(Env.new([0.11, 1, 0], [0, decay], -225),doneAction:2);
	trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230),doneAction:0);
	fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
	pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
	sig = SinOsc.ar(fenv, pi/2) * env;
	sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
	punch = SinOsc.ar(pfenv, pi/2) * env * 2;
	punch = HPF.ar(punch, 350);
	sig = (sig + sub + punch) * 2.5;
	sig = Limiter.ar(sig, 0.5) * amp;
	sig = Pan2.ar(sig, 0);
	Out.ar(out, sig);
}).add;

)

//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////patterns///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

(
// Patterns
~fm1 = Pbind(
	\instrument,\fm1,
	\degree,Pseg([0,2,0,1,2,4,3],[4,2,2,4,2,2],\step,inf)+Pseq([Rest(1),0,Rest(1),-5,Rest(1),-4,Rest(1),-9,Rest(1),-7,Rest(1),-1],inf)+[-2,0,3,7,12],
	\octave,3,
	\scale, ~scale,
	\dur,0.05*Pseq([Rest(1),2],inf),
	\rel,0.1,
	\atk,0.4,
	\iScale,0.25,
	\cRatio,8,
	\mRatio,128,
	\amp,-35.dbamp,
	\pan,Pgauss(0,0.2),
	\out, ~bus[\nhhall]
);

~fm2 = Pbind(
	\instrument,\fm2,
	\degree,Pseg([0,2,0,1,2,4,3],[2,1,1,2,1,1],\step,inf)+Pseq([Rest(1),0,Rest(1),-5,Rest(1),-4,Rest(1),-9,Rest(1),-7,Rest(1),-1],inf)+[-2,0,3,7,12],
	\octave,3,
	\scale, ~scale,
	\dur,0.5* Pseq([Rest(1),2],inf),
	\rel,1.1,
	\atk,Phprand(0.005,0.1),
	\iScale,0.1,
	\cRatio,16,
	\mRatio,128,
	\res,Pgauss(3,0.5),
	\width,1,//Pgauss(3,0.75),
	\amp,-24.dbamp,
	\pan,Pgauss(0,0.3),
	\out, ~bus[\nhhall]
);

~fm_break = Pbind(
	\instrument,\fm1,
	\degree,Pseg([0,2,0,1,2,4,3, 2,0,1,2,4,3],[4,2,2,4,2,2, 4,2,2,4,2,6],\step,inf)+Pseq([Rest(1),0,Rest(1),-5,Rest(1),-4,Rest(1),-9,Rest(1),-7,Rest(1),-1],inf)+[-2,0,3,7,12],
	\octave,3,
	\scale, ~scale,
	\dur,0.025*Pseq([Rest(1),2],inf),
	\rel,0.1,
	\atk,0.2,
	\iScale,0.25,
	\cRatio,32,
	\mRatio,128,
	\pan,Pgauss(0,0.2),
	\amp,-30.dbamp
);



~rhodesPattern = Pbind(
    \instrument, \rhodesChord,

	\dur, Pseq([4, 4, 4, 3, 1,
		4, 4, 4, 1, 3],inf),//Psubdivide(
			//Pseq([1!4,2,1,1,3].flatten,inf),
		//Pseq(#[4],inf)),
	\degree, [0, 2, 4] + Pseq([8,4,1,5,7],inf), //+ Pseq([[0, 2, 4], [3, 5, 7]], inf),
	\octave, 4,//Pwrand([5,4],[0.75,0.25],inf),
    \amp, 0.22,
    \scale, ~scale,
	\pan,-0.3,
	\out, ~bus[\nhhall]
);


~rhodesCounter = Pbind(
    \instrument, \rhodesChord,

	\dur, Pseq([Rest(3), 1,Rest(3), 1,Rest(3), 1,Rest(4)],inf),//Psubdivide(
			//Pseq([1!4,2,1,1,3].flatten,inf),
		//Pseq(#[4],inf)),
	\degree, Pseq([[0, 2, 4], [3, 5, 7]], inf),
	\octave, Pwrand([5,4],[0.75,0.25],inf),
    \amp, 0.075,
    \scale, ~scale,
	\pan,0.3,
	\out, ~bus[\nhhall]
);


~kickPattern = Pbind(
    \instrument, \bd,
    \dur, Pseq([1, 0.75, 0.25, 0.5, 0.5, 1], inf),
	\tone,56,
	\amp, Pgauss(-10.dbamp,0.05,inf),
	//\out, ~bus[\nhhall]
);

~snarePattern = Pbind(
    \instrument, \sn,
    \dur, Pseq([Rest(1), 1], inf),
	\tone,Pgauss(340,40),
	\snappy,Pgauss(0.5,0.1),
    \amp, Pgauss(-25.dbamp,0.05,inf),
	\pan,Pgauss(0.2,0.1),
	\out, 0
);

~clavPattern = Pbind(
    \instrument, \HC,
    \dur, Pseq([Rest(1), 1, Rest(0.5), 0.5, Rest(0.5), 0.5], inf),
    \degree, Pseq([4, 4, 4, 6], inf),
    \octave, 5,
    \amp, -34.dbamp,
    \scale, ~scale,
	\pan,Pwhite(-0.3,0.3),
	\out, 0
);

~hiHatPattern = Pbind(
	\instrument, Pwrand([\hat,\rimshot],[0.9,0.1],inf),
    \dur, Pseq([0.25, 0.5, 0.25, 0.25, 0.25, 0.5], inf),
	\amp, Pseq([0.2, 0.4, 0.2, 0.3, 0.2, 0.4], inf)* Pgauss(-12.dbamp,0.1),
	\pan,Pgauss(0.0,0.2),
	\out, Pwrand([0,~bus[\comb]],[0.5,0.5],inf)
   // \dur, Pseq([0.05, 0.1, 0.05, 0.05, 0.05, 0.1], inf)
);

)



//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////testing//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

(
t = TempoClock(100/60);

~fm1.play(t);
~fm2.play(t);
~clavPattern.play(t);
~rhodesCounter.play(t);
~rhodesPattern.play(t);
~kickPattern.play(t);
~snarePattern.play(t);
~hiHatPattern.play(t);

//~fm_break.play(t);
)


//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////structure//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////


(
// Sections using Pfindur
~introSection = Pfindur(16,
    Ppar([
        Pbindf(~fm1,\amp,Pseg(Pseq([0,-35.dbamp]), 16,-4)),
        Pbindf(~kickPattern,\amp, Pseg(Pseq([0.0, -10.dbamp]), 16,-4)),
        Pbindf(~hiHatPattern,\amp, Pseg(Pseq([0,-12.dbamp]), 16,-4)),
    ])
);

~mainSection = Pfindur(32,
    Ppar([
        ~fm1,
		~fm2,
		~clavPattern,
        ~rhodesPattern,
		~rhodesCounter,
		Pbindf(~kickPattern,\tone,Pgauss(56,5,inf)),
        ~snarePattern,
        ~hiHatPattern
    ])
);

~mainSection_repeat = Pfindur(32,
    Ppar([
        ~fm1,
		Pbindf(~fm2,\dur,0.5 * Prand([Rest(1),1,1],inf)),//Pn(Pshuf([Rest(1),2,1,Rest(1),2],1),inf)),//Pseq([1, 0.75, 0.75, 1, Rest(0.5),Rest(0.5),1,Rest(2),1,1]/2,inf)),
        Pbindf(~clavPattern,\degree, -1 + Pseq([4, 4, 4, 6], inf)),
        ~rhodesPattern,
		~rhodesCounter,
		Pbindf(~kickPattern,\tone,Pgauss(56,10,inf)),
        ~snarePattern,
		Pbindf(~hiHatPattern,\instrument, Pwrand([\rimshot,\hat],[0.9,0.1],inf))
    ])
);

~breakSection = Pfindur(35,
    Ppar([
		~fm_break,
		Pbindf(~clavPattern,\octave,4),
        ~hiHatPattern
	])
);

~outroSection = Pfindur(16,
    Ppar([
		Pbindf(~fm1,\amp,Pseg(Pseq([-35.dbamp, 0]), 16,6)),
		~rhodesCounter,
        Pbindf(~kickPattern,\tone,Pgauss(56,5,inf),\amp, Pseg(Pseq([-10.dbamp, 0]), 16)),
        Pbindf(~snarePattern,\amp, Pseg(Pseq([-25.dbamp, 0]), 16)),
		Pbindf(~hiHatPattern,\amp, Pseg(Pseq([Pgauss(-12.dbamp,0.1), 0]), 16)),
        Pbindf(~clavPattern, \amp, Pseg(Pseq([-34.dbamp, 0]), 16))
    ])
);

)


(
t = TempoClock(100/60);
~mainSection_repeat.play(t);
)

//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////piece//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////



(
t = TempoClock(100/60);
// Main routine
r = Routine({
    var sections = [
        (\name: "Intro", \pattern: ~introSection),
        (\name: "Main Groove", \pattern: ~mainSection),
        (\name: "Main Groove (Repeat)", \pattern: ~mainSection_repeat),
        (\name: "Break", \pattern: ~breakSection),
        (\name: "Final Groove", \pattern: ~mainSection),
		(\name: "Main Groove (Repeat)", \pattern: ~mainSection_repeat),
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

