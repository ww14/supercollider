{ (SinOsc.ar(GbmanN.ar(10,2.1,10.4)*100+250)*0.2)!2 }.play(s);
(
(SynthDef(\gbman,{
	var sig, env, freq_s;
	//var trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, 1, 10000));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); //Dust.kr(15,0.5);//;
	freq_s = \freq_s.kr(200);
	//env = EnvGen.ar(Env.new([0,1,0.1,0.001],[0.00001,\len.kr(1)/10]),doneAction:2);
	sig = GbmanN.ar(\g_freq.kr(10),\x1.kr(1.0),\y1.kr(1.0));
	sig = SinOsc.ar(sig*\rate.kr(100)+freq_s);
	//sig = TBall.ar(sig * 10, \gravity.kr(0.01), \damp.kr(0.00001), 0.001);
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;);



SynthDef(\reverb_ef, {arg in, out;
		var		snd, sndVerb, totalSig, outSig;
		snd = In.ar(in, 2);
	snd = Splay.ar(snd, \splay.kr(0.3));
	sndVerb = NHHall.ar([snd,snd],\rt60.kr(1),\stereo.kr(0.5));
	    snd = XFade2.ar(snd, sndVerb);
		Out.ar(out, snd);
	}).add;

/*(
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
);*/

(SynthDef(\gbman_env,{
	var sig, env, freq_s, perc_env;

	//var trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, 1, 10000));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); //Dust.kr(15,0.5);//;
	freq_s = \freq_s.kr(200);
	env = EnvGen.ar(Env.new([0,1,0.1,0.001],[0.00001,\dur.kr(1)]),doneAction:2);
	sig = GbmanN.ar(\g_freq.kr(10),\x1.kr(1.0),\y1.kr(1.0));
	sig = SinOscFB.ar(sig*\rate.kr(100)+freq_s,[0.11,0.1],0.2);
	sig = TwoTube.ar(sig,0.1,0.9,16,26,0.3);

	perc_env = Env.perc.ar;

	sig = sig * (1+ LFPulse.ar(\cycle.kr(2.reciprocal)*(1+perc_env),0,0.25));
	sig = BHiShelf.ar(sig,3200,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,3200,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.03,1+(perc_env),mul:0.5);
	sig = sig + PitchShift.ar(sig,0.012,1.01+(perc_env),mul:0.5);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(30)));
	sig = BHiShelf.ar(sig,2500,0.3,10);
	sig = sig.tanh;


	sig = HPF.ar(sig,40);
    sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;);

(SynthDef(\gbman_env_ring,{
	var sig, env, freq_s, ring, klang,perc_env;
	//var trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, 1, 10000));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); //Dust.kr(15,0.5);//;
	freq_s = \freq_s.kr(200);
	env = EnvGen.ar(Env.new([0,1,0.1,0.001],[0.00001,\dur.kr(1)]),doneAction:2);
	sig = GbmanN.ar(\g_freq.kr(10),\x1.kr(1.0),\y1.kr(1.0));
	sig = SinOscFB.ar(sig*\rate.kr(100)+freq_s,[0,0.1],0.1);
	ring = Ringz.ar(TBall.ar(sig*5,\gravity.kr(1/100),0.01,0.0005),freq_s*\over_tone.kr(1),2,);
	sig =  ring;

	perc_env = Env.perc.ar;

	sig = sig * (1+ LFPulse.ar(\cycle.kr(2.reciprocal)*(1+perc_env),0,0.5));
	sig = BHiShelf.ar(sig,1200,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,1200,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.03,1+(0.3*perc_env),perc_env.reciprocal,perc_env);
	sig = sig + PitchShift.ar(sig,0.012,0.5+perc_env);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-30)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(30)));
	sig = sig.tanh;


	sig = HPF.ar(sig,30);

	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;);

(SynthDef(\gbman_env_klang,{
	var sig, env, freq_s, ring, klang, perc_env;
	//var trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, 1, 10000));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); //Dust.kr(15,0.5);//;
	freq_s = \freq_s.kr(200);
	env = EnvGen.ar(Env.new([0,1,0.1,0.001],[0.00001,\dur.kr(1)]),doneAction:2);
	sig = GbmanN.ar(\g_freq.kr(10),\x1.kr(1.0),\y1.kr(1.0));
	sig = SinOscFB.ar(sig*\rate.kr(100)+freq_s,[0,0.1],0.1);
	klang = Mix.ar( -10.dbamp *
					SinOscFB.ar(
						sig.reciprocal,
						freq_s,
			            Klang.ar(`[
				\osc.kr([8, 10, 12]),
				[0.1,0.2,0.3],
//				[SinOsc.kr(1/20,0,0.1,0.1),SinOsc.kr(1/20,pi,0.2,0.3),SinOsc.kr(1/30,0.5*pi,0.25,0.2)],
				               [pi, 0, pi]]
			            )
				));
	sig =  klang;


	perc_env = Env.perc.ar;

	sig = sig * (1+ LFPulse.ar(5.reciprocal*(1+perc_env)));
	sig = BHiShelf.ar(sig,2000,0.3,5);
	sig = sig.fold2;
	sig = BHiShelf.ar(sig,2000,0.3,-5);
	sig = sig + PitchShift.ar(sig,0.03,0.1+(0.1*perc_env));
	sig = sig + PitchShift.ar(sig,0.012,0.5+(perc_env),mul:0.5);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\downshift.kr(-10)));
	sig = sig.tanh;
	sig = sig + CombC.ar(sig * -10.dbamp,0.1,1/(60 * (1+perc_env)),0.15);
	sig = FreqShift.ar(sig,perc_env.linlin(0,1,0,\upshift.kr(10)));
	sig = BHiShelf.ar(sig,3200,0.3,-10);
	sig = sig.tanh;

	sig = HPF.ar(sig,30);
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;);


)
///////////////////////////////////////////////////////////////////////////////////////////////////////


Synth(\gbman,[\freq,20,\rate,50,\g_freq,5,\x1,0.9,\y1,2]);

Synth(\gbman,[\freq,[90],\rate,30,\g_freq,15,\x1,3,\y1,33]);

Synth(\gbman,[\freq,[60],\rate,5,\g_freq,300,\x1,1.9,\y1,3]);




Synth(\gbman,[\freq,[140],\rate,40,\g_freq,3,\x1,3,\y1,0.2]);

Synth(\gbman,[\freq,[120],\rate,20,\g_freq,5,\x1,2,\y1,3]);

Synth(\gbman,[\g_freq,6.midicps,\freq,48.midicps,\rate,25,\x1,2,\y1,3]);




///////////////////////////////////////////////////////////////////////////////////////////////////////

(
Pbind(
		\instrument, \gbman_env,
	\dur,Pseq([0.5,0.5,2,0.25,0.5,0.25],inf),
	    \g_freq,10,//Pseq([[150]!12,[75,100]!12].flatten,inf),
	    \x1,1.25,
	    \y1,1.25,
	    \rate, 20,//Pseq([[150]!12,[75,100]!12].flatten,inf),
	\freq_s,Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps,3),inf),//Pseq([[256,512,8]!8,[128,512,4]!4].flatten,inf),//[151,309,407,561,774,821,864,1173,1984,51],//
		\amp, -6.dbamp,
		\pan, 0,
	).play;
)


///////////////////////////////////////////////////////////////////////////////////////////////////////

(
~bus = Bus.audio(s,2);
c = TempoClock.default.tempo_(60/60);
Synth(\reverb_ef,[\in, ~bus, \out, 0]);
Pbind(
		\instrument, \gbman_env,
	\cycle,Pseq([3,2,1,0.5].reciprocal,inf),
	\dur,2,//Pseq([2!36,[0.5,0.5,2,0.25,0.5,0.25]].flatten,inf),
	\over_tone,[3,2,1,1/2],
	\osc,Pseg([[8, 10, 12],[4, 1, 24],[8, 10, 12]],50,\lin,inf),
	\g_freq,10,//Pseq([[150]!12,[75,100]!12].flatten,inf),
	\x1,1.25,
    \y1,1.25,
	\rate, Pseq([[150]!12,[75,100]!12].flatten,inf),
    \freq_s,Pseq([[256,128]!8,[128,512,4]!4].flatten,inf),//Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps,3),inf),//

	//Pseq([[256,512,128]!4,[128,512,4]!4,[128]!4,[512,64]!4].flatten,inf),
    \amp, -20.dbamp,//0.1,
	\pan, 0,
	\out,0,
    ).play;


Pbind(
		\instrument, \gbman_env_ring,
	\dur,6,//Pseq([2!36,[0.5,0.5,2,0.25,0.5,0.25]].flatten,inf),
	\over_tone,[3,2,1,1/2],
	\osc,Pseg([[8, 10, 12],[4, 1, 24],[8, 10, 12]],50,\lin,inf),
	\g_freq,10,//Pseq([[150]!12,[75,100]!12].flatten,inf),
	\x1,1.25,
    \y1,1.25,
	\rate, Pseq([[150]!12,[75,100]!12].flatten,inf),
	\freq_s,Pseq([[256,512,128]!8,[128,512,4]!4].flatten,inf),
	\gravity,Pseg([0.01,0.1,0.01],100,\exp,inf),//1/20,//
    \amp, -28.dbamp,//0.1,
	\pan, 0,
	\out,~bus,
    ).play;

Pbind(
	\instrument, \gbman_env_klang,
	\dur,8,//Pseq([2!36,[0.5,0.5,2,0.25,0.5,0.25]].flatten,inf),
	\osc,Pseg([[8, 10, 12],[4, 1, 24],[8, 10, 12]],50,\lin,inf),
	\x1,1.25,
    \y1,1.25,
	\rate, Pseq([[1]!12,[75,100]!12].flatten,inf),
	\freq_s,Pseq([[1000]!8,[128,512,4]!4].flatten,inf),

    \amp, -30.dbamp,
	\pan, 0,
	\out,Pwrand([0,~bus],[0.75,0.25],inf),
    ).play;
//Synth(\gbman,[\freq_s,[64],\rate,9,\g_freq,256,\x1,1.9,\y1,3,\amp,-40.dbamp]);
)