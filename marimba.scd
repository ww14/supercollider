// Fun with Splay:
(
 y = {arg fundamental = 110;
var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9];
 var snd = BPF.ar(
		in: Saw.ar(4, LFPulse.ar(harmonics, width: SinOsc.kr(0.1,pi,0.25,0.5))),
 freq: harmonics * fundamental,
		rq: [0.001], //0.01
 mul: 20);
 Splay.ar(snd);
 }.play;

y.set(\fundamental,8);
)

y.set(\fundamental,150);

LFTri

///////////////////////////////
// the piece
////////////// as a function
(
 d = {arg fundamental = 50;
	  var harmonics = [1,2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics, width:  Klang.ar(`[ [80, 400, 800, 1000, 1200], [0.5,1,1,1,1], nil], 1, 0),mul:0.5);
	snd = Saw.ar(4, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag3ud * harmonics ,
		rq: [0.005,0.015],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: 15 * [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],//harmonics.sqrt,
	);
	snd = Compander.ar(snd,snd,0.3,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,3000+(10*fundamental),30);
	snd = RHPF.ar(snd,100,4);
	//snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd);
	snd = SplayAz.ar(2,snd,0.9,6,3);
	Out.ar(0,snd);
}.play;
 )

d.set(\fundamental,70);





///////////////////////////////
// the piece
////////////// using jitlib
(
 d = { |fundamental = 50|
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics, width:  Klang.ar(`[ [80, 400, 800, 1000, 1200], [0.5,1,1,1,1], nil], 1, 0),mul:0.5);
	snd = Saw.ar(4, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental * harmonics ,
		rq: [0.005,0.015],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: 15 * [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],//harmonics.sqrt,
	);
	//snd = HPF.ar(snd,30);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,2000 + (10*fundamental),5);
	snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd);
	snd = Splay.ar(snd,0.6,3);
	//Out.ar(0,snd);
};
)

Ndef(\sound).play;
Ndef(\sound).fadeTime = 5;
// set the source
Ndef(\sound,d);
Ndef(\sound).lag(\fundamental, 2).set(\fundamental,62);

Ndef(\sound).free(10);
Ndef(\sound).clear;

Ndef(\sound).edit;


d.set(\fundamental,50);



//////////////////////////////////////////

//as a synthdef
(SynthDef(\marimba,{arg fundamental = 50;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics, width:  Klang.ar(`[ [80, 400, 800, 1000, 1200], [0.5,1,1,1,1], nil], 1, 0),mul:0.5);
	snd = Saw.ar(4, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental * harmonics ,
		rq: [0.005,0.015],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: 15 * [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],//harmonics.sqrt,
	);
	//snd = HPF.ar(snd,30);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,2000 + (10*fundamental),5);
	snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd);
	snd = Splay.ar(snd,0.6,3);
	Out.ar(\out.kr(0), snd);
}).add;);

a = Synth(\marimba,[\fundamental,50]);



/// better idea; figure out how to send this sound through a FX synth buffer
// a voice in the pause
(
// freeze magnitudes
{
    var in, chain;
	in = LFPulse.ar([1, 2, 3, 4, 5, 6, 7, 8, 9], width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [1,1,1,1,1], nil], 1, 0));
    in = Mix.ar(BPF.ar(
		in: in,
		freq: 50 * [1, 2, 3, 4, 5, 6, 7, 8, 9] ,
		rq: [0.05,0.0015], //0.01
		mul: 30 * [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],//harmonics.sqrt,
	));
	in = IIRFilter.ar(in,2000,0.1);
	chain = FFT(LocalBuf(2048), in);
    chain = PV_MagFreeze(chain, LFPulse.kr(0.1, 0.75));
    0.5 * IFFT(chain).dup;
}.scope(1);
)


// guitar line (add wrap)
(
 d = {
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      var snd;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [1,1,1,1,1], nil], 1, 0));
	snd = Saw.ar(4, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: \fundamental.kr(50) * harmonics ,
		rq: [0.005,0.015], //0.01
		mul: 3 * [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],//harmonics.sqrt,
	);
	snd = -50.dbamp * IIRFilter.ar(snd, SinOsc.kr(SinOsc.kr(0.1),1.5pi,1550,1800)).wrap(0,500);
	snd = LeakDC.ar(snd);
	snd = Splay.ar(snd,0.7);
	Out.ar(0,snd * \amp.kr(1));
}.play;
 )



d.set(\fundamental, 42.midicps);

d.set(\fundamental, 90.midicps);

d.set(\fundamental, 16.midicps); //max 178

d.release(1);


(
 d = {arg fundamental = 50, mul=2;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics.cpsmidi, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [0.1,1,0.5,0.25,0.25], nil], 1, 0));
	snd = LFTri.ar(10*harmonics, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag2ud * harmonics ,
		rq: [0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: mul * [ 0.3, 0.5, 0.8, 0.6, 0.5, 0.4, 0.3, 0.6, 0.3 ],//harmonics.sqrt,
	);
	snd = HPF.ar(snd,30);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,3000 + (20*fundamental),30);
	//snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd);
	snd = SplayAz.ar(2,snd,0.1,4);
	Out.ar(0,snd);
}.play;
 )

d.set(\fundamental,5,\mul,100);
d.set(\fundamental,10,\mul,5);
d.set(\fundamental,50,\mul,2);
d.set(\fundamental,30,\mul,15);
d.set(\fundamental,50,\mul,15);
d.set(\fundamental,60,\mul,50);
d.set(\fundamental,50,\mul,15);
d.set(\fundamental,40,\mul,50);
d.set(\fundamental,50,\mul,15);
d.set(\fundamental,30,\mul,15);
d.set(\fundamental,20,\mul,50);
d.set(\fundamental,90,\mul,15);
d.set(\fundamental,200,\mul,20);

//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////


(
 d = {arg fundamental = 50, amp=1, release=12, gate=1;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd, klank, env;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	env = Env.asr(1, amp, release).kr(2, gate);
	snd = LFPulse.ar(harmonics.midiratio, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [0.05,1,0.5,0.5,0.1], nil], 1, 0));
	klank =  LFTri.ar(10*harmonics, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag3ud * harmonics ,
		rq: [0.0025,0.0075,0.01],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: 25 * [ 0.1, 0.5, 0.8, 0.6, 0.5, 0.4, 0.3, 0.6, 0.3 ],//harmonics.sqrt,
	);
	snd = HPF.ar(snd,40);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,3000 + (20*fundamental),30);
	snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd) * env;
	snd = SplayAz.ar(4,snd,0.1,4);
	Out.ar(0,snd);
}.play;
 )

//d.set(\fundamental,30.midicps,\mul,100);
//https://ccrma.stanford.edu/~ruviaro/texts/A_Gentle_Introduction_To_SuperCollider.pdf p.94
SystemClock.sched(0, {d.set(\fundamental, [30,35,33,38,42].choose.midicps); rrand(5, 10)});
d.set(\gate,0);