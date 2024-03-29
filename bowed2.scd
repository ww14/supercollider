(
~bus = Bus.audio(s,2);

SynthDef(\help_dwgbowed, { |out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.25,c3=31,pan=0|
	var numcps =  rrand(2, 20);
    var vib = Gendy1.kr(1,1,1,1,0.1, 4,mul:0.003,add:1);
    var son = DWGBowed.ar(freq*vib, amp,force, gate,pos,0.1,c1,c3);
    son = DWGSoundBoard.ar(son);
    son = BPF.ar(son,118,1)+son;
    son = BPF.ar(son,430,1)+son;
    son = BPF.ar(son,490,1)+son;
    son = LPF.ar(son,6000);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;



SynthDef(\help_blowhole, {
	var env = EnvGen.ar(Env([0,1,1,0],[0.01]++((\dur.kr(1)-0.001)*[0.4,0.6])),doneAction:2);
	var sig = StkBlowHole.ar(\freq.kr(440),\reedstiffness.kr(64), \noisegain.kr(20), \tonehole.kr(64), \register.kr(11), \breathpressure.kr(64), \mul.kr(5.0), \add.kr(0.0));
	Out.ar(\out.kr(0), Pan2.ar(sig * 0.1, \pan.kr(0)));
}).add;




SynthDef(\help_dwgpluckedstiff, { |out=0, freq=440, amp=0.5, gate=1, c1=1,c3=20, pan=0, rel=1, fB = 80|
    var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
    var inp = amp * LFClipNoise.ar(2000) * EnvGen.ar(env,gate);
    var son = DWGPluckedStiff.ar(freq, amp, gate,0.1,c1,c3,inp,rel,fB);
    DetectSilence.ar(son, 0.001, doneAction:2);
    Out.ar(out, Pan2.ar(son * 0.1, pan));
}).add;



//Define piano synthdef and soundboard

SynthDef(\help_oteypianostring, { |out=0, freq=440,gate=1, amp=0.5,rho=1, e=1|
    var son = OteyPianoStrings.ar(freq, amp, rho:rho, e:e)*EnvGen.ar(Env.asr(0,1,0.1),gate,doneAction:2);
	//son = OteySoundBoard.ar(In.ar([20,21],2));
	Out.ar(out, Pan2.ar(son * 1,\pan.kr(0)));
}).add;

SynthDef(\piano_soundboard,{
	arg gain=2;
    var audio = In.ar([20, 21], 2), reverb;
    audio = OteySoundBoard.ar(audio);
	audio = LeakDC.ar(audio,0.99);//;
	reverb = MoogFF.ar(audio,1500,gain);
	audio = Mix.ar(audio + reverb);
    Out.ar(0,audio);
}).add;

SynthDef(\reverb_ef, {
		arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);

		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		12.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};

		//dry/wet mix
		totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
	}).add;


SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, amp = 0.8, beater_noise_level = 0.025;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}
).add;
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Use bowed.
(
Pbind(
    \instrument, \help_dwgbowed,
    \dur , 0.25,
	\degree, Pseq([1,5,[7,3],5,2,6,5,3,2,1,8,4,6,5,3,8,7,4,3,2], inf),
    \amp , Pseq([0.9,0.7,0.5],inf),
).play;
)

//Used stiff bowed
(
Pbind(
    \instrument, \help_dwgpluckedstiff,
	//\scale,a,
    \delta , Pseq([1,0.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1]*0.25,inf),
    \dur , 0.25,
    \degree, Pseq([1,8,8,15,8,8,8,-6,Prand([9,10,11],1),1,7,8]-8, inf),
    \amp , Pwhite(0.2,0.8),
	\c1	, Pkey(\degree)/5,
	\c3 , Pseq([Pseq([1400],24),Pseq([300],24)],inf),
    \pan , Pwhite(-0.1,0.1),
	\fB, Pseq([0,80,400],inf),
).play;

Pbind(\instrument, \help_dwgpluckedstiff, \dur, Pseq([0.25, 1, 0.25], inf), \root, -24,
	\degree, Pseq([0, 3, 5, 7, 9, 11, 5, 1], inf), \pan, Pwhite(-1,1),
    \amp, 0.2).play;
)


//////////////////////////////////////////////
//test piano

a = [1,3,5]; // dorian

a.scramble.dupEach;
(a).pyramid;

TempoClock.default.tempo_(1);

(
Synth.tail(1,\piano_soundboard);
Pbind(
	\instrument, \help_oteypianostring,
	\amp, -25.dbamp,
    \delta, 1,
	\rho, Pseg([1.2,0.1,1.2],60,\wel,inf).trace, //Pwrand([Pn(10,3),Pn(0.1,3),Pn(1,3)],[1,1,1].normalizeSum,inf).trace,
	\dur, 3 + Pwhite(-0.01,0.01,inf),
	\gain, Pseg([2,3,2],60,\wel,inf),
	\degree, Pseq([
		Pseq(a,4),
		Pseq(a-5,2),
		Pseq(a-3,1),
		Pseq(a-1,1),
		Pseq(a,4),
		Pseq(a+2,2),
		Pseq(a+4,1),
		Pseq(a+1,1),
		Pseq(a.pyramid,2),
		Pseq((a-5).pyramid,1),
		Pseq(a-3,1),
		Pseq(a-1,1),
		Pseq(a.pyramid,2),
		Pseq((a+2).pyramid,1),
		Pseq(a+4,1),
		Pseq(a+1,1),
	], inf),
    \out, 20,
).play;
)

//test new pattern

(
Synth.tail(1,\piano_soundboard);
Pbind(
    \instrument, \help_oteypianostring,
    \delta, 1,
    \dur, 3,
	\degree, Pseq(a.pyramid, inf),
    \out, 20,
).play;
)


(
var    patternChoices = (
    up: { Pbind(\degree, Pseries(rrand(-4, 5), 1, rrand(4, 10)), \dur, 0.125) },
    down: { Pbind(\degree, Pseries(rrand(4, 11), -1, rrand(4, 10)), \dur, 0.125 * 4/3) },
	alt: {Pbind(\degree,Pseq([1,3,5],1),\dur,0.25)}
);

p = Pspawn(Pbind(
	\instrument, \help_oteypianostring,
    \pattern, Prand([\up, \down,\alt], inf),
    \delta, Pwhite(1, 5, inf) * 0.125,
    \method, \seq
), (dict: patternChoices)).play;
)

p.stop;


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

(
Pdef.removeAll;

~a = [1,3,5]; // dorian
//StkBlowHole.ar();
(
x = Synth.tail(1,\piano_soundboard);
	//instantiate reverb synth
y = Synth(\reverb_ef, [\in, ~bus, \out, 0]);

// 96 beat loop in 3/8

Pbindef(\piano,
	\instrument, \help_oteypianostring,
    //\delta, 1,
	\rho, 0.3,//Pseg([0.4,0.1,0.4],60,\wel,inf).trace, //Pwrand([Pn(10,3),Pn(0.1,3),Pn(1,3)],[1,1,1].normalizeSum,inf).trace,
	\dur, 1/8, //+ Pwhite(-0.01,0.01,inf),
	//\gain, 1,//Pseg([2,3,2],60,\wel,inf),
	\degree, Pseq([
		Pseq([Pfuncn({~a})].flatten,4),
		Pseq([Pfuncn({~a})].flatten-5,2),
		Pseq([Pfuncn({~a})].flatten-3,1),
		Pseq([Pfuncn({~a})].flatten-1,1),
		Pseq([Pfuncn({~a})].flatten,4),
		Pseq([Pfuncn({~a})].flatten+2,2),
		Pseq([Pfuncn({~a})].flatten+4,1),
		Pseq([Pfuncn({~a})].flatten+1,1),
		Pseq([Pfuncn({~a})].flatten.pyramid,4),
		Pseq([Pfuncn({~a})].flatten.pyramid-5,2),
		Pseq([Pfuncn({~a})].flatten-3,1),
		Pseq([Pfuncn({~a})].flatten-1,1),
		Pseq([Pfuncn({~a})].flatten.pyramid,4),
		Pseq([Pfuncn({~a})].flatten.pyramid+2,2),
		Pseq([Pfuncn({~a})].flatten+4,1),
		Pseq([Pfuncn({~a})].flatten+1,1),
	], inf),

	\amp,0.07,
	\pan,Pwhite(-0.5,-0.25,inf),
    \out, 20,
).play;
);

Pbindef(\duet,
    \instrument, \help_blowhole,
	\dur,1/8,
	\octave,4,
    \degree, Pseq([
		Pseq([Pfuncn({~a})].flatten,4),
		Pseq([Pfuncn({~a})].flatten-5,2),
		Pseq([Pfuncn({~a})].flatten-3,1),
		Pseq([Pfuncn({~a})].flatten-1,1),
		Pseq([Pfuncn({~a})].flatten,4),
		Pseq([Pfuncn({~a})].flatten+2,2),
		Pseq([Pfuncn({~a})].flatten+4,1),
		Pseq([Pfuncn({~a})].flatten+1,1),
		Pseq([Pfuncn({~a})].flatten.pyramid,4),
		Pseq([Pfuncn({~a})].flatten.pyramid-5,2),
		Pseq([Pfuncn({~a})].flatten-3,1),
		Pseq([Pfuncn({~a})].flatten-1,1),
		Pseq([Pfuncn({~a})].flatten.pyramid,4),
		Pseq([Pfuncn({~a})].flatten.pyramid+2,2),
		Pseq([Pfuncn({~a})].flatten+4,1),
		Pseq([Pfuncn({~a})].flatten+1,1),
	], inf),
	\pan,Pwhite(0.1,0.5,inf),
	\mul,4,
	\reedstiffness,Pwrand([64,48],[0.9,0.1],inf),
	\out,Pwrand([0,~bus],[0.9,0.1],inf),
).play;


Pbindef(\harmony,
    \instrument, \help_blowhole,
	\dur,3,
	\pan,Pwhite(0,0.15,inf),
	\breathpressure,64,//Pseg([5,30,5],30,\wel,inf),
	\reedstiffness,64,
	\octave,Pwrand([5,[6,5],3,7],[4,3,2,1].normalizeSum,inf),
    \degree, Pseq([Pfuncn({~a})].flatten, inf),
	\mul,10,
	\out,~bus,
).play;

Pbindef(\perc_high,
	\instrument, \SOSkick,
	\dur,Pn(Pshuf([3,1,1,1],3),inf)/8,//Pseg([200,500,200],10,\lin,inf),
	\freq,30,
	\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
	\mod_index,[1000],
	\pan,-0.2,
	\amp,(0.21 - (1 / Pkey(\mod_freq))),
	\out,~bus,
).play;

Pbindef(\perc_low,
	\instrument, \SOSkick,
	\dur,Pn(Pshuf([3,1,1,1],3),inf)/8,//Pseg([200,500,200],10,\lin,inf),
	\freq,30,
	\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
	\mod_index,[1],
	\pan,-0.2,
	\amp,(0.3 - (1 / Pkey(\mod_freq))),
	\out,~bus,
).play;

)

degreeToFreq

x.set(\gain,2);


// jam
~a = [1,7,3];
~a = [1,Rest(1),7,1,5];
~a = [1,7,4,5,6,2,6,8,4];
~a = [1,7,2,-13].pyramidg;
~a = [1,2,3].rotate(1);
~a = [1,3,5];
~a = [1,3,5].rotate(2).pyramidg;
~a = [1,3,5].rotate(2);
Pbindef(\piano, \amp,0.03);
Pbindef(\perc_low, \freq,[128,256],\mod_index,100,\amp,(0.13 - (1 / Pkey(\mod_freq))));

Pbindef(\piano, \rho,Pseg(Pseq([0.3, Pn(0.1)]), 10));
(Pbindef(\perc_low,
	\freq,Pseq([Pfuncn({~a})].flatten.linlin(1,8,110,220),inf), //[80,64,32],
	\mod_index,[100,10],
	\mod_freq, Pwrand([5,10,25,2000],[10,2,1,0.5].normalizeSum,inf),
	\amp,(0.15 - (1 / Pkey(\mod_freq)).linlin(0,25,0,0.15)),
	\dur,Pbjorklund2(Prand([6,10,18],inf),32,inf)/8 //Psubdivide(Pseq([(1..6)].flatten,inf),Pseq(#[6,3],inf))/2
	,));


(Pbindef(\perc_high,\mod_index,[1000,10000],\mod_freq, Pwrand([5,4,3,2,1],[10,2,1,0.5].normalizeSum,inf),\amp,(0.15 - (1 / Pkey(\mod_freq)).linlin(0,25,0,0.15)),\dur,Psubdivide(
			Pseq([1!12,2!12,1!6].flatten,inf),
			Pseq(#[6,1,3,4,2],inf)
)/4,));


Pbindef(\duet,\reedstiffness,Pwrand([64,32],[0.9,0.1],inf));

Pbindef(\perc_low, \freq,30,\mod_index,1,\amp,(0.3 - (1 / Pkey(\mod_freq))));

Pbindef(\piano);
Pbindef(\piano, \amp,Pseg(Pseq([0.1, Pn(0.0)]), 10));
Pbindef(\harmony, \mul,Pseg(Pseq([8.0, Pn(0.0)]), 10));
Pbindef(\duet, \mul,Pseg(Pseq([4.0, Pn(0.0)]), 10));
Pbindef(\perc_high, \amp,Pseg(Pseq([0.21, Pn(0.0)]), 10));
Pbindef(\perc_low, \amp,Pseg(Pseq([0.2, Pn(0.0)]), 10));