Server.killAll
("Setup/Setup.scd").loadRelative // load this file


// Nested Patterns!
(c = Pbind(
	\instrument,\fm1,
	\degree, Pwrand(
		[Pseq([[7,2,4],0,1,3,4,6,9,7],1),
		Pseq([[7,2,4],7,9,7,5,8,9,7],1),
		Pseq([[7,2,4],7,9,7,5,8,9,7].reverse,1)],
		[0.8,0.1,0.1],1),
	\iScale,8.1,
	\dur,Pseq([4,4,1,1,1,1,1,1]/4,inf),
	\atk,0.01,
	\rel,8,
	\amp,0.15,
	\pan,Pwhite(-0.2,0.2),
	\octave,3,
	\root,-3);
);

q = Ppar([Pseq([c], 4),Pseq([Pbindf(c, \instrument,\bpfsaw,\rel,3,\octave,8)], 5),Pseq([Pbindf(c, \iScale, 20,\rel,1.2)], 5)]);

Psetp(\amp, Pseq([0.15,0.05], inf), q).play;