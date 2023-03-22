(SynthDef(\tibetan,{
	var sig, auto, freq, env;
	//freq = \freq.kr(400);
	//var trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, 1, 10000));//Dust.ar(\trig.kr(1)); //\trig.tr; ////ToggleFF.ar(Dust.ar(\trig.kr(1)));//Dust.ar(\trig.kr(1)); //Dust.kr(15,0.5);//;
	env = EnvGen.ar(Env.new([0,1,0.1,0.001],[0.00001,\len.kr(1)/10]).circle,doneAction:2);
	sig = SinOscFB.ar(\freq.kr(100),SinOscFB.ar([0,0,0.5,0,0.5,0.5],1),SinOsc.kr([0.005,0,0.05,0])+[0.06,0.05,0.04,0.03,0.02,0.01]) ;
	sig = (sig * 3).fold2;
	sig = RLPF.ar(sig, 2500, 0.1);
	sig = (sig * 5).fold2;

	sig = CombN.ar(Mix.ar(sig),1,XLine.kr(0.01,0.1,200),0.2);
	//sig = MoogFF.ar(sig);
	sig = sig*env * -25.dbamp;
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.25));
	Out.ar(\out.kr(0), sig);
}).add;)

(
Pdef(\tibetan,
	Pbind(
		\instrument, \tibetan,
		\dur,100000,
		\len, 0.5,
		\freq,[151,309,407,561,774,821,864,1173,1984,51],// Pseq([[256,512,8]!8,[128,512,4]!4].flatten,inf),

		\amp, 0.70,
		\pan, 0,
	)
);
)

Pdef(\tibetan).play;

Pdef(\tibetan, \amp,0);

////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////

//v1
(Ndef(\markfell,{
	Pan2.ar(
		EnvGen.ar(Env.new([0,1,0.1,0.001],[0.00001,0.09]).circle,doneAction:2)*
		GVerb.ar(
			CombC.ar(
				Mix.ar(
					SinOscFB.ar([151,309,407,561,774,821,864,1173,1984,51],SinOscFB.ar([0,0,0.5,0,0.5,0.5],1.3),SinOsc.kr([0.005,0,0.05,0])+[0.06,0.05,0.04,0.03,0.02,0.01]))
				,1,XLine.kr(0.01,0.1,200),0.2)
			,100,)
		,0,-6.dbamp)
}).play;)

Ndef(\markfell).fadeTime = 1;


//v2
(Ndef(\markfell,{
	Pan2.ar(
		EnvGen.ar(Env.new([0,1,0.1,0.001],[0.001,0.09]).circle,doneAction:2)*
		GVerb.ar(
			CombC.ar(
				Mix.ar( -30.dbamp *
					SinOscFB.ar(
						[151,309,407,561,774,821,864,1173,1984,51],
						Klang.ar(`[ [8, 10, 12], [0.0, 0.1, 0.3], [pi, 0, pi]]),
						Klang.ar(`[ [8, 10, 12], [0.0, 0.1, 0.3], [pi, 0, pi]])))
				,1
				,XLine.kr(0.01,0.1,200),0.2)
			,40,1,0.1,0.5,100)
		,0,-6.dbamp)
}).play;)


//v3
(Ndef(\markfell,{
	Pan2.ar(
		EnvGen.ar(Env.new([0.001,1,0.1,0.001],[0.0001,0.9]).circle,doneAction:2)*
		CombN.ar(
			Mix.ar(
				SinOscFB.ar(
					[151,309,407,561,774,821,864,1173,1984,51],
					Klank.ar(`[[151,309,407,561], nil, [1,0,1,0]], ToggleFF.ar(Dust.ar(8))),
					Klank.ar(`[[151,309,407,561], nil, nil], ToggleFF.ar(Dust.ar(4)))
			))
			,1,XLine.kr(0.01,0.1,200),0.2)
		,0,-30.dbamp)
}).play;)



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//v_greyhole; the main one; metal
(

~a = 1;
~b = 2;
//c = min(a,b);

//LFPar.kr(0.003,0.1,0.5,0.52).round(0.01)
Ndef(\markfell,{
	var c,d,rel,env;
	c = SinOsc.kr(0.01,1.5*pi).linlin(-1,1,1000,2000).round(0.1);
	d = SinOsc.kr(0.01,1.5*pi).linlin(-1,1,1,10).round(1);
	rel = LFPar.kr(0.004,0,1.09,1.1).round(0.01).poll(); //full cycle takes 250 seconds
	env =	EnvGen.ar(Env.linen(0.01, 0.0, rel,0.9, -2).circle,doneAction:Done.freeSelf); //Env.new([0, 1, 0.9, 0.1, 0.0001], [0.01, 0.1, 0.02, 0.5])  Env.perc(0.01, 1, 1, -5) //Env.pairs({ { 1.0.rand } ! 2 } ! 16, \exp) //Env.asr(0.02, 0.5, 1, -4)
	Pan2.ar( env *
		HPF.ar(
		RLPF.ar(
			CombN.ar(
				Mix.ar( -7.dbamp *  //a.linexp(0,10,-50,-10).dbamp
					SinOscFB.ar(
						[33,220,261,329,392,523,659,784,1046,1318,1568], // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
						Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 0, 1, 0]], Impulse.ar(c, 0, 0.1)),  //fb of osc
						Klang.ar(`[ [8, 10, 12], [0.0, 0.1, 0.3], [pi, 0, pi]],Impulse.ar(d,0,0.9,1))    //amp of osc
				))
				,1,XLine.kr(0.0007,0.1,375),0.6),  // XLine.kr(0.0007,0.1,375)
			3000,5.1), //closer to 5 makes the initial high tone harsher
			40)
			,0,-6.dbamp)
}).play;
//


Ndef(\markfelt,{
	var a,b, rel, env;
	a = SinOsc.kr(0.01,1.6*pi).linlin(-1,1,0.11,2).round(0.1);  // 0.11,2
	b = SinOsc.kr(0.01,1.6*pi).linlin(-1,1,1,10).round(1);
	rel = LFPar.kr(0.004,0,1.09,1.1).round(0.01);
	env = EnvGen.ar(Env.linen(0.01, 0, rel, 0.7, -2).circle,doneAction:Done.freeSelf); //Env.new([0, 1, 0.9, 0.1, 0.0001], [0.01, 0.1, 0.02, 0.5])  Env.perc(0.01, 1, 1, -5) //Env.pairs({ { 1.0.rand } ! 2 } ! 16, \exp) //Env.asr(0.02, 0.5, 1, -4)
	//atk =  TWChoose.kr(Dust.kr(10), [0.01,0.001,0.1], [0.8, 0.1, 0.1].normalizeSum);
	Pan2.ar( env *
			Greyhole.ar(
				Mix.ar( -45.dbamp *  //a.linexp(0,10,-50,-10).dbamp
					SinOscFB.ar(
						[33,261,329,392,523,659,784,1046,1318,1568], // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
						Klank.ar(`[[151,309,407,561], nil, nil], ToggleFF.ar(Dust.ar(a))), //dust range 2-8 sounds good
						Klank.ar(`[[151,309,407,561], nil, nil], ToggleFF.ar(Dust.ar(b))) //dust range 1-6 sounds good
				))
				,1,0.2,1,0.3,0.5,0.1,8)
		,0,-8.dbamp)
}).play;

)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//0.002666
{ SinOsc.ar(10,1.5*pi).lincurve(-1, 1, 0.0007,0.1, XLine.kr(-1, -10, 375)) * 0.1 }.plot(0.1);

Env.linen(0.01, 0.0, 1,1, -5).plot;

XLine.kr(0.0007,0.1,375).mirror;

{ Clip.ar(SinOsc.ar(440, 0, 0.2), -0.07, 0.07) }.scope;

//v4
(Ndef(\markfell,{
	Pan2.ar(
		EnvGen.ar(Env.new([0.001,1,0.1,0.001],[0.0001,0.9]).circle,doneAction:2)*
		CombN.ar(
			Mix.ar( -30.dbamp *
				SinOscFB.ar(
					[151,309,407,561,774,821,864,1173,1984,51],
					Klank.ar(`[[151,309,407,561], nil, [1,0,1,0]], ToggleFF.ar(Dust.ar(6))),
					Klank.ar(`[[151,309,407,561], nil, nil], ToggleFF.ar(Dust.ar(3)))
			))
			,1,SinOsc.ar(0.125,0,0.01,0.1),0.02,0.5)
		,0,-12.dbamp)
}).play;)

[33,261,329,392,523,659,784,1046,1318,1568]
[55,220,261,329,440,523,659,880,1046,1318,1760]

//v5 -- down belltone
(Ndef(\markfell,{
	Pan2.ar(
		GVerb.ar(
			EnvGen.ar(Env.new([0.01,1,0.01,0.001],[0.0005,LFPar.kr(0.003,0.1,0.5,0.53).round(0.01).poll()]).circle,doneAction:2)*
			CombC.ar(
				Mix.ar( -10.dbamp *
					SinOscFB.ar(
						[33,261,329,392,523,659,784,1046,1318,1568],//[151,309,407,561,774,821,864,1173,1984,51],
						Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 0, 1, 0]], Impulse.ar(5, 0, 0.1)),
						Klang.ar(`[ [8, 10, 12], [0.0, 0.1, 0.3], [pi, 0, pi]],Impulse.ar(1,0,0.9,1))
				))
				,1,XLine.kr(0.01,0.4,600),0.2)
			,20,0.5,0.25,0.5,50)//,5,0.9,2)
		,0,-12.dbamp)
}).play;)

{ Saw.ar(500, 0.1) + Dust2.ar(100, 0.9) }.scope(1);

{ SinOsc.ar(300, 0, 0.2).max(0) }.scope(1);

{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).distort * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).softclip * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).clip2(1) * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).fold2(1) * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).wrap2(1) * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).wrap2(1) * 0.2 }.scope(1);


Pdef.removeAll;
