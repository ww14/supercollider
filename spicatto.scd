("Setup/Setup.scd").loadRelative // load this file

(
~spica = PathName(thisProcess.nowExecutingPath).parentPath++"setup/cellospica/";
b = Dictionary.new;
b.add(\foldernames -> PathName("C:/Users/William Willoughby/Documents/SuperCollider/composition/setup/cellospica/").entries);
	for (0, b[\foldernames].size-1,
		{arg i; b.add(b[\foldernames][i].folderName -> b[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
)

(
SynthDef(\kraftySnr, { |amp = 1, freq = 2000, rq = 3, decay = 0.3, pan, out|
	var sig, env, sub;
	sig = PinkNoise.ar(amp);
	env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
	sig = BPF.ar(sig, freq, rq, env);
	//sub = Saw.ar([freq/2, freq/4]/4);
	//sig = sub*sig;
	sig = RLPF.ar([sig, sig/2], freq*4 * (LFNoise2.ar(0.1).range(1,10)/pi).lagud([0.2, 0.5]).lagud , 1);
	sig = Compander.ar(sig, SinOsc.ar(rq), 0.5,0.0005,1.5,0.001,0.5); //control:
	sig = LPF.ar(sig, 4000).fold2;
	sig = LPF.ar(sig, 4000);
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, Pan2.ar(sig, pan))
}).add;
)

Pbind(\instrument,\fm1, \freq, Pxrand([45,46,44],inf).midicps,\dur,1/2,\atk,0.5,\rel,1,\amp,0.1,\pan,Pwhite(-0.2,0.2)).play;


j = Pbind(\instrument,\brush_m, \dur, Psubdivide(
		Pseq([1!8,2!4,1,1,9,1].flat,inf),
		Pn(Pshuf([Rest(1),1,Rest(1),1],2),inf)
	),\atk,0.5,\rel,1,\amp,0.1,\pan,-0.2).play;

Pbind(\instrument,\kraftySnr, \freq, Pseg([40,50,40],30).midicps,
		\dur,Pseg([1/2,1],30),
	\atk,0.5,
	\rel,1,
	\amp,0.1,
	\pan,Pwhite(-0.2,0.2),
	\decay,Pseg([0.3,5],30),).play;

//test
1000.do({b["spica"][56.0.linrand.round(0)].play;});

15.round(1).do({b["spica"][75.0.rand.round(0)].play;});
1.do({b["viol"][19.0.linrand.round(0)].play;});
b["viol"][1].play;


// function routine
(
r = Routine.new({
	var i = 0, n = 0;

	/*e = Pbind(\instrument,\harpsichord_pluck, \freq, 50 * Pxrand([45,46,44],inf).midicps,\dur,1/2,\atk,0.5,\rel,1,\amp,0.1,\pan,Pwhite(-0.2,0.2)).play;*/
	j = Pbind(\instrument,\brush_m, \dur, Psubdivide(
		Pseq([1!8,2!4,1,1,9,1].flat,inf),
		Pn(Pshuf([Rest(1),1,Rest(1),1],2),inf)
	),\atk,0.5,\rel,1,\amp,0.5,\pan,-0.2,\out,~bus[\reverb]).play;

	8.wait;

	15.round(1).do({b["spica"][75.0.rand.round(0)].play;});

	2.wait;

	15.do({
		30.0.rand.do({b["spica"][56.0.linrand.round(0)].play;});
		1.0.rand.wait;
	});


	10.do({
		100.0.rand.do({b["spica"][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
	});


	20.do({
		n = n+1;
		thisThread.randSeed = n;
		i = Array.fill(10, { 50.linrand}).postln;
		i.do({arg p; p.do({b["spica"][56.0.rand.round(0)].play;})});
		3.0.rand.wait;
	});

/*	10.do({
		100.0.rand.do({b["spica"][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
	});*/

	1.wait;

	1.do({
		1000.do({b["spica"][56.0.linrand.round(0)].play;});
		16.wait;
	});


	15.do({
		30.0.rand.do({b["spica"][56.0.rand.round(0)].play;});
		1.0.rand.wait;});

	4.wait;

	15.do({
		100.0.rand.do({b["spica"][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
});


	15.do({
		200.0.rand.do({b["spica"][56.0.linrand.round(0)].play;});
		3.0.rand.wait;
});
	1.wait;

	f = Pbind(\instrument,\kick_m, \freq, Pseg([40,50,40],30).midicps,
		\dur,Pseg([1/2,1],30),
	//\atk,0.5,
	//\rel,1,
	\amp,0.1,
	\pan,0.2,
	\decay,Pseg([0.3,5],30),
	\out,~bus[\reverb]).play;


	30.wait;

	j.stop;

	2000.do({b["spica"][56.0.linrand.round(0)].play;});

}).play;
)
