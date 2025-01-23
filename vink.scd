// https://scsynth.org/t/jaap-vink-analogue-unstable-ring-modulated-feedback/8613


s.options.memSize = 1048576;

s.reboot;  // this is important!
//////////////////////////////////////////////////////////////////////////////////////////////////

(
SynthDef(\vink,{
var in, trig, snd, ff, rmf, env, freq;

	ff = \ff.kr(1000).lag3;
	rmf = \rmf.kr(600).lag3;


	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, \low.kr(8).lag3, \high.kr(8).lag3)); //LFDNoise makes the higher freq steps less discrete/quantized
	//trig = Dust.ar(0.9);

	snd =  ClipNoise.ar(0.2);



	freq = \freq.kr(440)	;

	snd = Pluck.ar(snd, trig, \maxdelaytime.kr(0.2) , freq.reciprocal , \decaytime.kr(1) , \coef.kr(0.81)).distort; //fundamental
	in = LocalIn.ar(2) + [snd,snd];

	//snd = SinGrain.ar(snd,1000.reciprocal,\freq.kr(440).lag3(4),0.025);

	in  = DFM1.ar(in, SinOsc.kr(SinOsc.kr(\vibrato.kr(0.3)).range(0.2, 3)).range(80, 2000), \res.kr(0.01), \inputgain.kr(0.5) , 0, \noiselevel.kr(0.0003));

	snd = snd  + in;

	snd = GVerb.ar(snd,\roomsize.kr(10),1,0.9,0.5,\spread.kr(15));
	//snd = NHHall.ar(snd,1,0.5);

	snd = Compander.ar(snd,snd,
		thresh: 0.1,
        slopeBelow: 1,
        slopeAbove: 1,
        clampTime:  0.1,
        relaxTime:  0.2);

	//LocalOut.ar(snd);
	//snd;

	snd = LeakDC.ar(snd).tanh;
	snd = MoogFF.ar(snd, LFNoise2.kr(0.75).linexp(-1, 1, 500, 1600), 0);


	snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	//snd = snd * \amp.kr(1);
	env = Env.asr(\atk.kr(1), \amp.kr(1).lag3(6), \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd *env;
	Out.ar(0,snd);
}).add;



SynthDef(\bell_tubular, {
	|freq = 440, t60=9, pitchy=1, amp=0.25, gate=1, pan = 0|
	var sig, exciter;
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = DynKlank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		input:exciter,
		freqscale: freq,decayscale:pitchy);

	sig = GVerb.ar(sig,\roomsize.kr(100),2,0.99,spread:5);
	//snd = NHHall.ar(snd,1,0.5);

	sig = Compander.ar(sig,sig,
		thresh: 0.1,
        slopeBelow: 1,
        slopeAbove: 1,
        clampTime:  0.1,
        relaxTime:  0.2);


	sig = LeakDC.ar(sig).tanh;
	sig = MoogFF.ar(sig, LFNoise2.kr(0.75).linexp(-1, 1, 500, 1600), 0);


	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, Pan2.ar(sig, pan, amp));
//This is the same used for glockenspiel, xylophone, marimba and regular bell, what changes is only the ring time t60
//By nicolaariutti and edited by Zé Craum
//	http://sccode.org/1-5ay#c835
}).add;







)
//////////////////////////////////////////////////////////////////////////////////////////////////

/*
(Pbindef(\vink,
	\instrument,\vink,
	\atk, 0.1,
	\dur,1/4,//Pn(Pshuf(0.25/[3,3,3,6],3),inf),
	\note,Pseq([0,2,4,3,6,5,4,1,0,-1,0],inf), /*Pseq([
		Pseq([2, 5, 10],2),
		Pseq([0, 3, 8], 1),
		Pseq([1, 4, 9] ,1),
		Pseq([2, 5, 10] ,2),
		Pseq([4, 7, 12] ,1),
		Pseq([3, 6, 11],1),
	],inf),*/
	\root,[-5,-1],/*+ Pstep([0,
		           4,
		           2,
		           5,
        		   4, // 1 was 12500
		           -1,
		           0, //.pyramidg.flop,
	],[
			28, //first
			14, //first rotation
			14, //second rotation
			14, //1-1-10
			14, //8-2-1
			28, //8-2-1 rotaion
			14  // 2-4-8
		]//[28, 14, 14,14,14, 14]
	,2),*/
	\amp,0.7,
	\release,Pkey(\dur)*0.65);
)
*/

Pdef.removeAll;
(Pbindef(\vink,
	\instrument,\vink,
	//\root,([50,62]).midicps,
	\midinote,Pseq([[57,50,62],[56,50,61],[59,50,62],[61,50,64],[54,50,62]],inf),//Pseq([50,45,48,43,46,41,44,39,38],inf),
	\decaytime,7,
	\atk,0.01,
	\coef,0.1,
	\amp,0.2,
	\inputgain,1,
	\dur,Pseq([4,2,3,2,3,2,3,2,5],inf),
	\low,8.reciprocal,\high,8.reciprocal,
	\spread,1,
	\roomsize,Pseg(Pseq([1,5,1,1,10],inf),Pseq([30,5,20,10],inf),-1,inf))
);

Pbindef(\vink).play

Pbindef(\vink,\midinote,Pseq([50,54,53,57,56,52,54,49,52],inf),\dur,Pseq([4,2,3,2,3,2,3,2,5],inf))
Pbindef(\vink,\midinote,Pseq([50,57,49,50,52,49,52,50,52],inf),\dur,Pseq([4,2,3,2,3,2,3,2,5],inf)/2)


Pbindef(\vink,\midinote,Pseq([64,62,60,59,60,62,65,62,63],inf),	\dur,Pseq([4,2,3,2,3,2,3,2,5],inf)/2)




a = Synth(\vink);
a.set(\freq,38.midicps);
a.set(\low,1,\high,1,\amp,0.25);
a.set(\decaytime,3.5,\coef,0.4);
a.set(\freq,38.midicps);




a.set(\freq,40.midicps);
//a.free;
//a.release;
a.set(\low,1,\high,1.1);


a = Synth(\vink);
a.set(\freq,[500,600,700].collect());
a.set(\low,1,\high,1,\amp,0.25);
a.set(\decaytime,3.5,\coef,0.4);
a.set(\freq,62.midicps);

a.free

c = Synth(\vink);
c.set(\freq,62.midicps);
c.set(\low,1,\high,8,\amp,0.275);
c.set(\decaytime,0.5,\coef,0.14);
c.set(\noiselevel,0.015,\inputgain,0.5);
//c.set(\freq,38.midicps);
c.free;


b = Synth(\vink);
b.set(\freq,33.midicps);
b.set(\low,90,\high,110,\amp,0.15);
b.set(\decaytime,1.75,\coef,0.05);
b.set(\maxdelaytime,0.15);

b.free;

Pbind(\instrument,\vink).play;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(
TempoClock.default.tempo_(60/60);

(p = {|i=0|
		i.set(\freq,33.midicps);
		2.wait;
		i.set(\freq,30.midicps);
		2.wait;
		i.set(\freq,35.midicps);
		2.wait;
		i.set(\freq,33.midicps);
		2.wait;
		i.set(\freq,30.midicps);
		2.wait;
		i.set(\freq,35.midicps);
		1.wait;
		i.set(\freq,37.midicps);
		1.wait;
		i.set(\freq,38.midicps);
		8.wait;
	};
);

//20
//14

(q = {|i=0|
		i.set(\freq,45.midicps);
		4.wait;
		i.set(\freq,42.midicps);
		2.wait;
		i.set(\freq,43.midicps);
		2.wait;
		i.set(\freq,40.midicps);
		1.9.wait;
		i.set(\freq,37.midicps);
		0.1.wait;
		i.set(\freq,38.midicps);
		4.wait;

	};
);

Pdef.removeAll;
(Pbindef(\vink,
	\instrument,\vink,
	//\root,([50,62]).midicps,
	\midinote,Pseq([[57,50,62],[59,50,62],[57,50,62],[52,50,62],[54,50,62]],inf),//Pseq([50,45,48,43,46,41,44,39,38],inf),
	\decaytime,7,
	\atk,0.01,
	\coef,0.1,
	\amp,0.2,
	\inputgain,1,
	\dur,Pseq([4,2,3,2,1],inf),
	\low,8.reciprocal,\high,8.reciprocal,
	\spread,1,
	\roomsize,Pseg(Pseq([1,5,1,1,10],inf),Pseq([30,5,20,10],inf),-1,inf))
);


t = Task({
	//s.record;
	//start bass
	a = Synth(\vink,[\freq,38.midicps,\low,1,\high,1,\amp,0.26,\decaytime,3.5,\coef,0.4]);

	8.wait;

	Pbindef(\vink).play;

	8.wait;
	c = Synth(\vink);
	c.set(\freq,62.midicps,\low,1,\high,8,\amp,0.2,\decaytime,0.5,\coef,0.14,\noiselevel,0.015);
	8.wait;
	1.do(p.value(a));

	b = Synth(\vink,[\freq,38.midicps,\decaytime,3.5,\coef,0.4,\amp,0.26,\low,1,\high,1]);
	2.wait;
	a.set(\amp,0);
	c.set(\freq,50.midicps,\amp,0.15);
	1.do(q.value(b));
   c.set(\freq,57.midicps);
    b.set(\low,1,\high,1.015);
	1.do(p.value(b));
    c.set(\freq,62.midicps);
    1.do(q.value(b));

	b.set(\amp,0);
	a.set(\amp,0.26);
	2.wait;
    1.do(p.value(a));
	108.wait;

	24.wait;
	"removeAll".postln;

	a.set(\gate,0);
	4.wait;
	c.set(\gate,0);
	Pbindef(\vink).stop;
	16.wait;
	//s.stopRecording;
});
)


t.play;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
(

Pbindef(\tubular, \instrument,\bell_tubular,
			\atk,0.1,
			\dur, Pn(Pshuf(1/[3,3,3,6],3),inf),
	\midinote,  [0,2,4] //this ending triggers a new loop
			    + 110
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 9], 1),
						Pseq(#[0, 4, 9, 7], 1),
						Pseq(#[0, 7, 4, 9], 1),
						Pseq(#[0, 7, 9, 4], 1),
						Pseq(#[0, 9, 7, 4], 1),
						Pseq(#[0, 9, 4, 7], 1)],
					[3,1,1,1,1,1].normalizeSum,1),//Pseq((10..50),inf),//60+ [-12,24] + [0,4,11,14]+ Pseq([0,5,4,8,12],inf) , //
\t60,4,
	\pitchy,0.215,
	\amp,0.051,
	\out, 0,//Pwrand([0,~bus[\reverb]],[0.5,0.5],inf),
		);
)

Pbindef(\tubular).play
(Pbindef(\tubular,
	\dur, Pn(Pshuf(1/[3,3,3,6],3),inf),
	\midinote,  [0,2,4,-4] //this ending triggers a new loop
			    + 105
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 9], 1),
						Pseq(#[0, 4, 9, 7], 1),
						Pseq(#[0, 7, 4, 9], 1),
						Pseq(#[0, 7, 9, 4], 1),
						Pseq(#[0, 9, 7, 4], 1),
						Pseq(#[0, 9, 4, 7], 1)],
					[3,1,1,1,1,1].normalizeSum,1),//Pseq((10..50),inf),//60+ [-12,24] + [0,4,11,14]+ Pseq([0,5,4,8,12],inf) ,
));