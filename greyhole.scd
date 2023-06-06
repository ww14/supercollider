//grey hole
//from markfell.scd


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
		RLPF.ar(
			CombN.ar(
				Mix.ar( -7.dbamp *  //a.linexp(0,10,-50,-10).dbamp
					SinOscFB.ar(
						[33,220,261,329,392,523,659,784,1046,1318,1568], // Cmaj; Amin [55,220,261,329,440,523,659,880,1046,1318,1760] // [33,261,329,392,523,659,784,1046,1318,1568]
						Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 0, 1, 0]], Impulse.ar(c, 0, 0.1)),  //fb of osc
						Klang.ar(`[ [8, 10, 12], [0.0, 0.1, 0.3], [pi, 0, pi]],Impulse.ar(d,0,0.9,1))    //amp of osc
				))
				,1,XLine.kr(0.0007,0.1,375),0.6),  // XLine.kr(0.0007,0.1,375)
			3000,5.1) //closer to 5 makes the initial high tone harsher
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