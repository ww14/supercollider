// this is no mbira: vibrations of a bank of resonators that are
// triggered by some bouncing things that bounce one on each resonator

// mouse y controls friction
// mouse x controls gravity
(
    {
    var sc, g, d, z, lfo, rate;
    g = MouseX.kr(0.01, 100, 1);
    d = MouseY.kr(0.00001, 0.2);
	sc = [55,220,440,523,659,1318]; //[451, 495.5, 595, 676, 734.5];//azande harp tuning by B. Guinahui
    lfo = LFNoise1.kr(1, 0.005, 1);
    rate = LFNoise1.kr(1, LFNoise1.kr(10, 1, 0),1);
    rate = rate * sc.size.reciprocal;
    z = sc.collect { |u,i|
        var f, in;
        in = Decay.ar(
			Mix(Impulse.ar(rate, [1.0, LFNoise0.kr(rate/12)].rand, 0.1)),
			0.001);
		in = Ringz.ar(in,
			Array.fill(5, { |i| (i+1) + rand2(0,0.2) })
			        * Decay.ar(in*2,0.02,rand(0.25,0.75), lfo)
			        * u,
                    Array.exprand(5, 0.2, 1).sort
                    );
        in = Mix(in);
		in = Compander.ar(in);

		f = TBall.ar(in, g, d, 0.001);

		in + Mix(Formlet.ar(f, u * Array.fill(4, { |i| (i+1) + rand2(0,0.2) *[1,3]}), 0.1))
    };
    Splay.ar(z) * 0.8
    }.play;
)


[451, 495.5, 595, 676, 734.5].collect

/////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

TempoClock.default.tempo_(60/60);

(
SynthDef(\tball, {
		//arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var sc, z, lfo, rate, snd;


	sc = \sc.kr([110,220,440,523,659,1318]); //[451, 495.5, 595, 676, 734.5];//azande harp tuning by B. Guinahui
    lfo = LFNoise1.kr(1, 0.005, 1);
	rate = LFNoise1.kr([1,10], LFNoise0.kr(10, \speed.kr(1), 0),1);
    rate = rate * sc.size.reciprocal;
    z = sc.collect { |u,i|
        var f, in;
        in = -10.dbamp * Decay.ar(
			Mix(Impulse.ar(rate, [1.0, LFNoise0.kr(rate/12)].rand, 0.1)),
			0.001);
		in = Ringz.ar(in,
			Array.fill(6, { |i| (i+1) + rand2(0,0.2) })/2
			        * Decay.ar(in,0.02,rand(0.5,1), lfo)
			        * u,
                    Array.exprand(6, 0.2, 1)
		);
	   in = TwoTube.ar(in,-0.9,0.99,100,100,2);
       in = Mix(in);
	   in = Compander.ar(in);
		in = IIRFilter.ar(in,3000,1,0.5);

		f = TBall.ar(in * 10, \gravity.kr(0.01), \damp.kr(0.00001), 0.001);

		in + Mix(Formlet.ar(f, u * Array.fill(4, { |i| (i+1) + rand2(0,0.2) *[1,3]})/2, 0.1))
	    };
    snd = Splay.ar(z) * 0.8;
	Out.ar(0, snd * \amp.kr(1).lag3(1));
	}).add;
)

a = Synth(\tball);

(
t = Task({
    var a;
    a = Synth(\tball);

    24.wait;//29.wait;

	a.set(\gravity,1,\damp,0.00001,\amp,0.4);

	16.wait;

	a.set(\speed,2,\amp,0.6,\damp,0.01);

	16.wait;

	a.set(\speed,0.5,\damp,0.00001,\amp,0.4);

	16.wait;

	a.set(\gravity,50,\damp,0.2,\amp,0.4,\speed,1);

	16.wait;

	a.set(\speed,500,\damp,0.75,\gravity,100,\amp,0.2);

	16.wait;

	a.set(\sc,[451, 495.5, 595, 676, 734.5]);

	12.wait;

	a.set(\damp,0.25,\amp,0.15);

	6.wait;

	a.set(\sc,[55,220,440,523,659,1318]);

	12.wait;

	a.set(\speed,2000);

	24.wait;

	a.set(\gravity,0.01, \damp, 0.00001, \amp,1, \speed,1);

	6.wait;

	a.set(\amp,0.8);

	6.wait;

	a.set(\amp,0.7);

	4.wait;
	a.set(\amp,0.5);
	4.wait;
	a.set(\amp,0.3);
	3.wait;
	a.set(\amp,0.1);
	2.wait;
	a.set(\amp,0.05);
	4.wait;
	a.set(\amp,0.01);
	4.wait;
	a.set(\amp,0);
   });
)

t.play;

Ndef

////////////////////////////////////////////////////////////
// I commonly want to use a Pdef in a routine and it doesn't work. I often forget why
(
t = Task({
	Pdef(\a,Pbind(\instrument,\tball));
	Pdef(\a).fadeTime = 1;
	Pdef(\a).play;

    24.wait;//29.wait;

	Pdef(\a).set(\gravity,1,\damp,0.00001,\amp,0.5);

	16.wait;

	Pdef(\a).set(\speed,10,\amp,0.6,\damp,0.01);

	16.wait;

	Pdef(\a).set(\speed,0.5,\damp,0.00001);

	16.wait;

	Pdef(\a).set(\gravity,50,\damp,0.1,\amp,0.4,\speed,1);

	16.wait;

	Pdef(\a).set(\speed,500,\damp,0.75,\gravity,100);

	16.wait;

	Pdef(\a).set(\sc,[451, 495.5, 595, 676, 734.5]);

	12.wait;

	Pdef(\a).set(\damp,0.25);

	6.wait;

	Pdef(\a).set(\sc,[55,220,440,523,659,1318]);

	12.wait;

	Pdef(\a).set(\speed,2000);

	24.wait;

	Pdef(\a).set(\gravity,0.01, \damp, 0.00001, \amp,1, \speed,1);

	6.wait;
	Pdef(\a).fadeTime = 10;
	Pdef(\a).set(\amp,0);

   });
)

t.play;


///////////////////////////////////////////////////
a.set(\gravity,1,\damp,0.00001,\amp,0.9);
a.set(\speed,20,\amp,0.7,\damp,0.05);
a.set(\speed,0.5,\damp,0.00001);
a.set(\gravity,50,\damp,0.1,\amp,0.4,\speed,1);
a.set(\speed,500,\damp,0.75,\gravity,100);
a.set(\sc,[451, 495.5, 595, 676, 734.5]);
a.set(\damp,0.25);
a.set(\sc,[55,220,440,523,659,1318]);
a.set(\speed,2000);
a.set(\gravity,0.01, \damp, 0.00001, \amp,1, \speed,1);


a.set(\amp,0.8);
a.set(\amp,0.7);
a.set(\amp,0.5);
a.set(\amp,0.3);
a.set(\amp,0.1);
a.set(\amp,0.05);
a.set(\amp,0.01);
a.set(\amp,0);