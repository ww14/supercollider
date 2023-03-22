////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//synthdefs

(
(
SynthDef(\chord, {
		var sig, trig, freq, cycle, env;
		trig = \trig.tr;
	env = EnvGen.ar(Env.perc,doneAction:Done.freeSelf); //EnvGen.ar(Env([0.1,1,1,0],[0.01]++((\dur.kr(0.5)-0.001)*[0.4,0.6])),doneAction:2);//([0,1,1,0],[0.001]++((\dur.kr(1)-0.001)*[0.4,0.6])),doneAction:2);
		//EnvGen.ar(Env([0.1,1,1,0],[0.01]++((\dur.kr(0.5)-0.001)*[0.4,0.6])),doneAction:2);


	    sig = VOSIM.ar(1,\freq.kr(440),\ncycles.kr(50));
	    sig = RLPF.ar(sig,2000);
	   // sig = MembraneHexagon.ar(sig,0.518,0.999999999);
		sig = Mix.ar(sig);

	    // sig = CombC.ar(sig,1,0.1,1.2,1);

		sig = sig * env;

		Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(-6.dbamp)));
	}).add;
);


//sig = GVerb.ar(sig,90,3,0.9,0.1,10,0.7,0.3,0.9); //FreeVerb.ar(sig); ////


SynthDef(\reverb_ef, {
		arg		amp=0.5,in, out, mix=0.085;
		var		sig, verbSig, totalSig, outSig;

		//mix = mix.clip(0,1);

		sig = In.ar(in, 2);

	verbSig = GVerb.ar(sig,80,1,0.9,0.9,50,0.9,0.1,0.5);
	verbSig= RLPF.ar(verbSig,2500);


		//dry/wet mix
		outSig = XFade2.ar(sig, verbSig, mix.linlin(0,1,-1,1));

		outSig = outSig * amp;



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

//DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOSkick -------
// http://www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
// increase mod_freq and mod_index for interesting electronic percussion
	).add;

)

Synth(\chord);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//pdefs


(
Pdef.removeAll;

a = Scale.major;
(
Pdef(\gabor,
	Pbind(
		\instrument, \chord,
		\scale,Pfunc({a},inf),
		\root, Pseq([0!21,7!7,5!7].flatten,inf),
		\octave,Pseq([Pn([4,3],49),Pn([4,5,1],21)],inf),
		\dur,Pseq([1/3!6,1].flatten,inf),
		\degree, Pseq([3,2,0,7,10,7,Pn(Pshuf([-7,0,2,3,7,9,11],3),inf)],1),//Pn(Pshuf([-12,0,3,5,12,14,16,17],3),inf), // midi: Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps,3),inf),
		\ncycles,Pkey(\freq) / Pwrand([1,2,3,4],[4,3,2,1].normalizeSum,inf),
		\out,\reverb_ef,

	)
);
);


(Pdef(\seq,
	Pbind(\instrument, \chord,
		\dur, Pseq([1/6, 1/3, 1/6], inf),
		\root, [-36,-48],
        \degree, Pseq([0, 3, 5, 7, 9, 11, 5, 1,-1], inf),
		\scale,Pfunc({a},inf),
		\pan, Pwhite(-0.3,0.4),
        \amp, -15.dbamp,\out,0)
));

(Pdef(\chord,
	Pbind(\instrument, \chord,
		\dur, Pseq([1,1,1,2,1,2,2], 7),
		\root, [-36,-12,0],
		\degree, Pseq([0, 5, 2, [3,7], [-4,5], [-1,2]], inf), //5,7,8,0
		\scale,Pfunc({a},inf),
	   \ncycles,25,
       \amp, -1.dbamp,
		\out,0)

));



Pdef(\drum,
	Pbind(\instrument, \SOSkick,
		\dur,Psubdivide(
			Pseq([1!24,2!8,4!4].flatten,inf),
			Pseq([1/3, 1, 2,2/3],inf)
		)/2,
		//Pn(Pshuf([1,2,3,1,2,3,6,9,12],3),inf)/12,//Pseg([200,500,200],10,\lin,inf),
		\freq,30,
		\mod_freq, Pwrand([5,10,100,200],[10,2,1,0.5].normalizeSum,inf),
		\mod_index,15,
		\pan,0,
		\amp,(0.2 - (1 / Pkey(\mod_freq))),
		\out,\reverb_ef,
));


)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//testing

TempoClock.default.tempo_(60/60);

(
Synth(\reverb_ef);
//Pdef(\gabor).play;
//Pdef(\drum).play;
Pdef(\chord).play;
)

a = Scale.melodicMinor;
a = Scale.major;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//the piece


(
//the piece is in 9/8
StageLimiter.activate;
t = TempoClock.default.tempo_(60/60);
Synth(\reverb_ef);
//

Pspawner({|sp|
	a = Scale.major;

	sp.par( Pfindur(12, Pdef(\seq)));

	sp.wait(12);

	sp.par( Pfindur(180, Pdef(\seq)));
	sp.par( Pfindur(180, Pdef(\gabor)));

	sp.wait(20);

	sp.par( Pfindur(140, Pdef(\drum)));

	sp.wait(20);
	a = Scale.melodicMinor;
	sp.par( Pfindur(10, Pdef(\chord)));

	sp.wait(40);
	a = Scale.major;
	sp.par( Pfindur(10, Pdef(\chord)));

	sp.wait(60);
	a = Scale.melodicMinor;
	sp.par( Pfindur(10, Pdef(\chord)));

	sp.wait(20);
	a = Scale.major;
	sp.par( Pfindur(9, Pdef(\chord)));


}).play(t, quant:1);
)

