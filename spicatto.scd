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

y.set(\modfreq,45.midicps,\carfreq,57.midicps,\poll_rate,1,\dur,0.025,\lower,6,\upper,8)

//y.set(\freqdev,-3,\maxRq,0.09,\minRq,0.001,\maxBpfHz,2,\maxCf,1000);


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
		x = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,110,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		z = Synth(\fm_grain, [\envbuf, z,\modfreq,220,\carfreq,220,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		w = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
	);


	4.wait;
	15.round(1).do({b[\cellospica][75.0.rand.round(0)].play;});

	2.wait;
	15.do({
		30.0.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		1.0.rand.wait;
	});

	x.set(\modfreq,275);
	x.set(\carfreq,440);


	5.do({
		100.0.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
	});

	w.set(\modfreq,293,\carfreq,440);

	10.do({
		n = n+1;
		thisThread.randSeed = n;
		i = Array.fill(10, { 50.linrand}).postln;
		i.do({arg p; p.do({b[\cellospica][56.0.rand.round(0)].play;})});
		3.0.rand.wait;
	});


	1.wait;
	"first big batch".postln;
	w.set(\modfreq,330);

	1.do({
		1000.do({b[\cellospica][56.0.linrand.round(0)].play;});
		6.wait;
	});

	y.set(\modfreq,262,\carfreq,110);


	7.do({
		30.0.rand.do({b[\cellospica][56.0.rand.round(0)].play;});
		1.0.rand.wait;});

	4.wait;
		"second batch".postln;

	z.set(\carfreq,440,\modfreq,293);

	7.do({
		100.0.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
});

	x.set(\modfreq,220,\carfreq,880);
		"third batch".postln;
	14.do({
		200.0.rand.do({b[\cellospica][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
});
	9.wait;
	w.set(\gate, 0,\rel,4,\amp,-90.dbamp);
	x.set(\gate, 0,\rel,4,\amp,-90.dbamp);
	y.set(\gate, 0,\rel,4,\amp,-90.dbamp);
	z.set(\gate, 0,\rel,4,\amp,-90.dbamp);

	"biggest batch".postln;

	4500.do({b[\cellospica][56.0.linrand.round(0)].play;});

	//2.wait;
	//1.do({b[\cellospica][56].play;});

}).play;
)



	(
		y = Synth(\fm_grain, [\envbuf, -1,\modfreq,110,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		x = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,110,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		z = Synth(\fm_grain, [\envbuf, z,\modfreq,220,\carfreq,220,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
		w = Synth(\fm_grain, [\envbuf, -1,\modfreq,220,\carfreq,440,\dur,4,\amp,-100.dbamp,\freqdev,-1.4]);
	);


	x.set(\modfreq,262);
	x.set(\carfreq,55);