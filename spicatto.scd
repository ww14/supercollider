("Setup/Setup.scd").loadRelative // load this file

(
var winenv;
// a custom envelope
winenv =  Env([0, 0.5,1, 0], [0.25, 0.5,0.5], [8,2,-8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain, {
    var pan, env, snd, sndVerb, freqdev, trig;
    // use mouse x to control panning
    //pan = MouseX.kr(-1, 1);
    //freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
	trig = Impulse.ar(LFDNoise3.kr(\poll_rate.kr(0.5)).linexp(-1, 1, \lower.kr(1), \upper.kr(32)));

    env = EnvGen.kr(
		Env([0, 1, 0], [1, \rel.kr(1)], \welch, 1),
		\gate.kr(1),
        doneAction: Done.freeSelf);
	snd = GrainFM.ar(2,
		trig,
		\dur.kr(0.1),
		\carfreq.kr(440),
		\modfreq.kr(220) + LFNoise1.kr.range(0, \freqdev.kr(0)),
		LFNoise1.kr.range(1, 10),
		\pan.kr(0),
		\envbuf.kr(-1),
	);
	snd = Klank.ar(`[[110, 220, 293, 330, 440, 880, 1760], nil, nil], snd);
	snd = HPF.ar(snd, 40);
	snd = LeakDC.ar(snd);
	snd = Pan2.ar(snd,\pan.kr(0).lag3(1),\amp.kr(1).lag3(0.1));
	snd = snd * env;
		Out.ar(\out.kr(0),snd);
}).add;

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

	in  = DFM1.ar(in, SinOsc.kr(SinOsc.kr(0.3).range(0.2, 3)).range(80, 2000), \res.kr(0.01), \inputgain.kr(0.5) , 0, \noiselevel.kr(0.0003));

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
	Out.ar(\out.kr(0),snd);
}).add;

)

//test
1000.do({b[\cellospica][56.0.linrand.round(0)].play;});

15.round(1).do({b[\cellospica][75.0.rand.round(0)].play;});
1.do({b["viol"][19.0.linrand.round(0)].play;});
b["viol"][1].play;



y = Synth(\fm_grain, [\envbuf, z,\modfreq,220,\carfreq,110,\dur,4,\amp,0.dbamp,\freqdev,-1.4,\out,~bus[\nhhall]]);

(
y = Synth(\fm_grain, [\envbuf, -1,\modfreq,110,\carfreq,440,\dur,4,\amp,-60.dbamp,\freqdev,-1.4]);
x = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,110,\dur,4,\amp,-55.dbamp,\freqdev,-1.4]);
z = Synth(\fm_grain, [\envbuf, z,\modfreq,220,\carfreq,220,\dur,4,\amp,-50.dbamp,\freqdev,-1.4]);
w = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,440,\dur,4,\amp,-55.dbamp,\freqdev,-1.4]);
)

x.set(\modfreq,275);
x.set(\carfreq,440);
w.set(\modfreq,293,\carfreq,440);
w.set(\modfreq,330);
y.set(\modfreq,262,\carfreq,110);
z.set(\carfreq,440,\modfreq,293);
x.set(\modfreq,220,\carfreq,880);

w.set(\freqdev,10);

y.set(\modfreq,45.midicps,\carfreq,57.midicps,\poll_rate,1,\dur,0.025,\lower,6,\upper,8)

//y.set(\freqdev,-3,\maxRq,0.09,\minRq,0.001,\maxBpfHz,2,\maxCf,1000);



///////////////////////////////////////////////////////////////////////////////////////////////////////////

// function routine
(
r = Routine.new({
	var i = 0, n = 0;

	/*e = Pbind(\instrument,\harpsichord_pluck, \freq, 50 * Pxrand([45,46,44],inf).midicps,\dur,1/2,\atk,0.5,\rel,1,\amp,0.1,\pan,Pwhite(-0.2,0.2)).play;*/
	/*j = Pbind(\instrument,\kraftySnr, \dur, Psubdivide(
		Pseq([1!8,2!4,1,1,9,1].flat,inf),
		Pn(Pshuf([Rest(1),1,Rest(1),1]/2,2),inf)
	),\atk,0.5,\rel,1,\amp,0.5,\pan,-0.2,\out,~bus[\reverb]).play;
	8.wait;
*/

	(
		y = Synth(\fm_grain, [\envbuf, -1,\modfreq,110,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		x = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,110,\dur,4,\amp,-100.dbamp,\freqdev,-2.4]);
		z = Synth(\fm_grain, [\envbuf, z,\modfreq,220,\carfreq,220,\dur,4,\amp,-100.dbamp,\freqdev,-3.4]);
		w = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-4.4]);
	);


	6.wait;
	15.round(1).do({b[\cellospica][75.0.rand.round(0)].play;});

	2.wait;
	15.do({
		30.0.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		1.0.rand.wait;
	});

	x.set(\modfreq,275);
	x.set(\carfreq,440);
	w.set(\freqdev,10);


	5.do({
		100.0.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
	});

	w.set(\modfreq,293,\carfreq,440);
	y.set(\freqdev,10);

	10.do({
		n = n+1;
		thisThread.randSeed = n;
		i = Array.fill(10, { 50.linrand}).postln;
		i.do({arg p; p.do({b[\cellospica][56.0.rand.round(0)].play;})});
		3.0.rand.wait;
	});


	1.wait;
	"first big batch, start bass line".postln;
	w.set(\modfreq,330);
	z.set(\freqdev,10);

	a = Synth(\vink);
	a.set(\freq,33.midicps);
	a.set(\low,90,\high,110,\amp,0.15);
	a.set(\decaytime,1.75,\coef,0.05);
	a.set(\maxdelaytime,0.15);



	1.do({
		1000.do({b[\cellospica][56.0.linrand.round(0)].play;});
		6.wait;
	});

	y.set(\modfreq,262,\carfreq,110);
	y.set(\freqdev,0);
	x.set(\freqdev,10);


	7.do({
		30.0.rand.do({b[\cellospica][56.0.rand.round(0)].play;});
		1.0.rand.wait;});

	4.wait;
		"second batch".postln;

	z.set(\carfreq,440,\modfreq,293);
	w.set(\freqdev,0);
	a.set(\freq,28.midicps,\amp,0.18);

	1.do({
		1500.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		6.wait;
});  //100.10.rand.do

	x.set(\modfreq,220,\carfreq,880);
	y.set(\freqdev,10);
	a.set(\freq,21.midicps,\amp,0.2);

		"third batch".postln;
	14.do({
		150.10.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
});
	x.set(\freqdev,100);
	w.set(\freqdev,50);
	y.set(\freqdev,50);
	z.set(\freqdev,50);

	9.wait;
	w.set(\gate, 0,\rel,4,\amp,-90.dbamp);
	x.set(\gate, 0,\rel,4,\amp,-90.dbamp);
	y.set(\gate, 0,\rel,4,\amp,-90.dbamp);
	z.set(\gate, 0,\rel,4,\amp,-90.dbamp);


	"biggest batch".postln;

	5500.do({b[\cellospica][56.0.linrand.round(0)].play;});
	a.free;

	//2.wait;.
	//1.do({b[\cellospica][56].play;});

}).play;
)


/////////////////////////////////////////////////////////////////////////////////////////////////////
	(
		y = Synth(\fm_grain, [\envbuf, -1,\modfreq,110,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		x = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,110,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		z = Synth(\fm_grain, [\envbuf, z,\modfreq,220,\carfreq,220,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		w = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
	);


	x.set(\modfreq,262);
	x.set(\carfreq,55);