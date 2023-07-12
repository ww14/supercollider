(
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

~bus = Bus.audio(s,2);




SynthDef(\buzz, {arg fundamental = 5, mul=100,trigger=32,amp=1, lagu=0.1, lagd=0.1,center=0;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd, chain, detect_p, perc2,trig, env;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics.cpsmidi, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [0.1,1,0.5,0.25,0.25], nil], 1, 0));
	snd = LFTri.ar(10*harmonics, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag3ud(lagu,lagd) * harmonics ,
		rq: [0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: mul * [ 0.3, 0.5, 0.8, 0.6, 0.5, 0.4, 0.3, 0.6, 0.3 ],//harmonics.sqrt,
	);


	snd = Compander.ar(snd,snd,0.2,1,0.1,0.01,0.01);
	snd = IIRFilter.ar(snd,3000,10);
	snd = BHiPass4.ar(snd,fundamental*3,1);
	snd = HPF.ar(HPF.ar(snd,100),80);
	snd = LeakDC.ar(snd);
	//center = Select.kr(LFSaw.kr(0.1,0.0,1,1),[0,1]);
	snd = SplayAz.ar(2,snd,1,4*amp,center:center);

	env = Env.asr(1, amp, \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd * env;

	Out.ar(~bus,snd);
}).add;
);


(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
d = Synth(\buzz).asStream;
)

d.release(3);

d.mute;

/*
//d.play;
d.set(\fundamental,10,\mul,1);
d.set(\fundamental,5,\mul,10);
d.set(\fundamental,10,\mul,1.5);
d.set(\fundamental,5,\mul,10);
d.set(\fundamental,10,\mul,2);
d.set(\fundamental,5,\mul,10);
d.set(\fundamental,10,\mul,2.5);
d.set(\fundamental,5,\mul,10);
d.set(\fundamental,10,\mul,1);


//d.set(\fundamental,10,\mul,5);
d.set(\fundamental,50,\mul,2);
d.set(\fundamental,30,\mul,10);
d.set(\fundamental,50,\mul,5);
d.set(\fundamental,60,\mul,100);
d.set(\fundamental,40,\mul,100);
d.set(\fundamental,20,\mul,50);
d.set(\fundamental,30,\mul,5);
d.set(\fundamental,50,\mul,5);
d.set(\fundamental,50,\mul,2);
d.set(\fundamental,30,\mul,10);
d.set(\fundamental,30,\mul,2);
//d.set(\fundamental,90,\mul,15);
d.set(\fundamental,50,\mul,7);
d.set(\fundamental,50,\mul,2);
d.set(\fundamental,200,\mul,2);
d.set(\fundamental,200,\mul,100);
d.set(\fundamental,200,\mul,10);
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//~176 seconds
(
TempoClock.default.tempo_(60/60);
s.prepareForRecord;
t = Task({
    var d;
	//s.record;
	1.wait;
	Synth(\reverb_ef, [\in, ~bus, \out, 0]);
    d = Synth(\buzz);
	// intro

	d.set(\fundamental,10,\mul,1,\lagu,2,\lagd,3);
	8.wait;
	//d.set(\fundamental,5,\mul,10);
	//2.wait;
	d.set(\fundamental,10,\mul,1.5);
	4.wait;
	//d.set(\fundamental,5,\mul,10);
	//2.wait;
	d.set(\fundamental,10,\mul,2);
	8.wait;
	//d.set(\fundamental,5,\mul,10);
	//2.wait;

	d.set(\fundamental,10,\mul,2.5);
	8.wait;
	d.set(\fundamental,5,\mul,10);
	4.wait;
	d.set(\fundamental,10,\mul,2);
	16.wait;

	//////////////////////////////////////////////
	// first phrase
	//d.set(\fundamental,10,\mul,5);
	d.set(\fundamental,50,\mul,2,\lagu,0.3);
	24.wait;
	d.set(\fundamental,30,\mul,10,\lagd,0.5,\center,0);
	16.wait;
	d.set(\fundamental,50,\mul,5,\center,1,\lagu,0.45);
	16.wait;
	d.set(\fundamental,30,\mul,10);
	16.wait;
	d.set(\fundamental,50,\mul,5,\center,0);
	24.wait;

    ////////////////////////////////////////////
	// higher, new beat
	d.set(\fundamental,60,\mul,100,\lagu,0.3);
	8.wait;
	d.set(\fundamental,40,\mul,100);
	8.wait;
	d.set(\fundamental,20,\mul,50,\center,1);
	24.wait;

	//////////////////////////////////////////
	// first phrase
	d.set(\fundamental,30,\mul,5);
	16.wait;
	d.set(\fundamental,50,\mul,5, \lagu,0.3);
	8.wait;
	d.set(\fundamental,50,\mul,3,\center,0);
	2.wait;
	d.set(\fundamental,30,\mul,10);
	4.wait;
	d.set(\fundamental,30,\mul,5,\center,1);
	8.wait;
	//d.set(\fundamental,90,\mul,15);
	d.set(\fundamental,50,\mul,7);
	8.wait;
	d.set(\fundamental,50,\mul,5);
	36.wait;

	//////////////////////////////////////////
	//outro
	d.set(\fundamental,200,\mul,0.5,\lagu,0.5,\center,0);
	4.wait;
	d.set(\fundamental,200,\mul,100);
	24.wait;
	d.set(\fundamental,200,\mul,20,\center,1);
	4.wait;

	d.release(4);

	10.wait;
	//s.stopRecording;
   });
)

t.play;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
 a = {arg fundamental = 50, mul=20,osc=4, over=4, shift=1;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd, chain, detect_p, perc2,trig, kernel;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	snd = LFPulse.ar(harmonics,add:0.25, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [0.1,1,0.5,0.25,0.25], nil], 1, 0));
	snd = LFSaw.ar(osc, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag2ud * harmonics ,
		rq: [0.015,0.1],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: mul * [ 0.3, 0.5, 0.3, 0.6, 0.5, 0.4, 0.3, 0.6, 0.3 ],//harmonics.sqrt,
	);

	chain = FFT(LocalBuf(2048), snd);
	chain = PV_SpectralEnhance(chain,over,16,1.5); //PV_SpectralEnhance(chain,80,2,0.3);
	chain =  PV_PitchShift(chain, shift);//0.99999999);//1.000001);
	chain = IFFT(chain) ;

	snd = Pluck.ar(
		chain,
		chain);

	//Convolution.ar(chain,snd, 1024, 0.5);

	snd = HPF.ar(snd,30);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,3000 + (20*fundamental),30);
	//snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd);
	snd = SplayAz.ar(2,snd);
	Out.ar(0,snd);
}.play;
 )

a.set(\fundamental,15,\mul,8, \osc,8,\over,2, \shift, 1.15);






/////////////////////////////////////////////////////


(
SynthDef(\reverb_ef, {
		arg		amp=1, lPos=1, mix=0.085, revTime=0.8, preDel=0.5, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);

		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		6.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};

		//dry/wet mix
		totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
	}).add;




Synth(\reverb_ef, [\in, ~bus, \out, 0]);
 a = {arg fundamental = 50, mul=20,osc=4, over=4;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd, chain, detect_p, perc2,trig, kernel;
	//var env = EnvGen.ar(Env.linen,doneAction:2);
	snd = LFPulse.ar(harmonics,add:0.25,width:Pluck.ar(fundamental,Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 600, 1000)),fundamental.reciprocal,fundamental.reciprocal,LFNoise2.kr(4).linexp(-1,1,0.1,0.9)));

	snd= Pluck.ar(snd,
		Impulse.ar(snd),
		(harmonics).reciprocal,
		(fundamental*harmonics).reciprocal,
		LFNoise2.kr(1/4).linexp(-1,1,0.1,0.3));

	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag2ud * harmonics ,
		rq: [0.9,0.1,0.01],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: mul * [ 0.01, 0.5, 0.3, 0.6, 0.5, 0.4, 0.3, 0.6, 0.3 ],//harmonics.sqrt,
	);

	snd = HPF.ar(snd,30);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,3000 + (20*fundamental),30);
	//snd = BHiPass4.ar(snd,fundamental,1);
	snd = LeakDC.ar(snd);
	snd = SplayAz.ar(2,snd);
	Out.ar(0,snd); //*env
}.play;
 )

a.set(\fundamental,35.midicps,\mul,20,\osc,2);

Pbind(\instrument