//sleep mix
//load the setup file if you haven't already
("Setup/Setup.scd").loadRelative // load this file

s.scope;
s.plotTree;

( ~basepat =
Pbind(
	\instrument, \pm4,
	\out, ~out,
	\group, ~mainGrp,
	\detunehz, 1,  //make it funky. full detune makes it like a carillon
	\vdepth, 0.003, //make it wobbly, depth of velocity rate

	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,

	// melody
	\scale, Scale.dorian,  //originally dorian
	\degree, Pshuf([-1, 0, 2, 4, 6, 7,13], inf),
	\octave, Pbjorklund(3, 2).linlin(0, 1, 3, Pseq([5,6,7], inf)), //originally 5/8 ; a 3 to 6/7 split makes a great bass to treble contrast

	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),

//////////////////////////////
	// operator 1
	\op1, 1,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.1,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.3, 0.3),

	// operator 2
	\op2, 0.3,
	\op2ratio, 2,
	\op2atk, 0.01,
	\op2dec, 0.1,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.3,
	\op2pan, Pwhite(-0.3, 0.3),

	// operator 3
	\op3, 0,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 4,
	// one-pole coefficient
	\op3coef, 0.5,
	\op3pan, 0,

	// operator 4
	\op4, 0,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.1,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.7,
	\op4pan, 0,

	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, 0.01pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0pi,
	\m1_4, 0pi,

	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,

	\m3_1, 0pi,
	\m3_2, 0pi,
	\m3_3, 0pi, //feedback
	\m3_4, 0.3pi,

	\m4_1, 1pi,
	\m4_2, 0.1pi,
	\m4_3, 1pi,
	\m4_4, 0.5pi, //feedback*/

	\lpf, 2000, //sleepy soundy if low, orig 2000
	\hpf, 80 //high filter makes it sound far away. like an old radio, lower is more resonant, orig 80
);
)

/*
Pdefn(\pm4).play;
Pdefn(\pm4, Pbind(\instrument, \pm4,\vel,Pseq([1, 0.5, 0.8, 0.7], inf))).play;
Pdefn(\lpf, 20);
*/

(
~player2.stop;
~player1 = ~basepat.play;
)

(
t = TempoClock.default.tempo_(60/60);
//overwriting multiple key-value pairs
~pat2 = Pchain(
	Pbind(
		\out, ~bus[\reverb],
		\op2coef, 0.0001,
	),
	~basepat
);
~player2.stop;
~player2 = ~pat2.play(t, quant:1);
~player1.stop;
)

(
t = TempoClock.default.tempo_(60/60);
//overwriting multiple key-value pairs
~pat2 = Pchain(
	Pbind(
		\out, ~bus[\reverb],
		\op4coef, 0.1,
	),
	~basepat
);
~player1.stop;
~player1 = ~pat2.play(t, quant:1);
~player2.stop;
)


/////////////////////////////////////////////////////////////////////////////////////
(Pdef.removeAll;
t = TempoClock.default.tempo_(60/60);
Pbindef(\sleep,
	\instrument, \pm4,
	\out, ~out,
	\group, ~mainGrp,
	\detunehz, 1,  //make it funky. full detune makes it like a carillon
	\vdepth, 0.003, //make it wobbly, depth of velocity rate

	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,

	// melody
	\scale, Scale.dorian,  //originally dorian
	\degree, Pshuf([-1, 0, 2, 4, 6, 7,13], inf),
	\octave, Pbjorklund(3, 2).linlin(0, 1, 3, Pseq([5,6,7], inf)), //originally 5/8 ; a 3 to 6/7 split makes a great bass to treble contrast

	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),

//////////////////////////////
	// operator 1
	\op1, 1,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.1,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Plprand(-0.3,0),

	// operator 2
	\op2, 0.3,
	\op2ratio, 2,
	\op2atk, 0.01,
	\op2dec, 0.1,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.3,
	\op2pan, Phprand(0,0.3),//Pwhite(-0.3, 0.3),

	// operator 3
	\op3, 0,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 4,
	// one-pole coefficient
	\op3coef, 0.5,
	\op3pan, 0.1,

	// operator 4
	\op4, 0,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.1,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.7,
	\op4pan, 0.25,

	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, 0.01pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0pi,
	\m1_4, 0pi,

	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,

	\m3_1, 0pi,
	\m3_2, 0pi,
	\m3_3, 0pi, //feedback
	\m3_4, 0.3pi,

	\m4_1, 1pi,
	\m4_2, 0.1pi,
	\m4_3, 1pi,
	\m4_4, 0.5pi, //feedback*/

	\lpf, 2500, //sleepy soundy if low, orig 2000
	\hpf, 80 //high filter makes it sound far away. like an old radio, lower is more resonant, orig 80
);
)

Pbindef(\sleep).play(t,quant:1);

Pbindef(\sleep,\op4coef, 0); //orig 0.7
Pbindef(\sleep,\op4coef, 2);
Pbindef(\sleep,\op3coef, 0.1);
// some sustained chords
Pbindef(\sleep,\op3, 0.5,\m3_3, 0.25pi); //orig 0 and 0pi
Pbindef(\sleep,\m3_2, pi); //orig 0
Pbindef(\sleep,\op3coef, 0.5);
Pbindef(\sleep,\m2_2, 0.5*pi); //orig 0pi
Pbindef(\sleep,\op3coef, 0.5, \op3,0);
Pbindef(\sleep,\m1_2, pi); //orig 0.2pi
Pbindef(\sleep,\m1_1, 0.2*pi); //orig 0.01pi
Pbindef(\sleep,\op3, 0.5,\m3_3, 0.25pi); //orig 0 and 0pi
// really marks a change
Pbindef(\sleep,\op1ratio, [0.25,2]); // \op1ratio, 1,
Pbindef(\sleep,\legato, 0.25); //\legato, 0.9,
//key change, not super obvious
Pbindef(\sleep,\scale, Scale.minor); //\scle, dorian
Pbindef(\sleep,\legato, 10); //\legato, 0.9,
Pbindef(\sleep,\legato, 1); //\legato, 0.9,
Pbindef(\sleep,\scale, Scale.dorian); //\scle, dorian
Pbindef(\sleep,\op4ratio, 10); // \op4ratio, 5,
Pbindef(\sleep,\op1ratio, 0.75); // \op1ratio, 1,
// new section
Pbindef(\sleep,\op2ratio, [0.5,3],\m2_2, 0.1*pi); // \op2ratio, 2,
Pbindef(\sleep,\op2ratio, 1, \m2_2, 0.1*pi); // \op2ratio, 2,
// some more feedback
Pbindef(\sleep,\op3, 0,\op3coef, 0.5,\op3ratio, 0.1, \m3_1, 0.1*pi); // \op3ratio, 3,

//closing
Pbindef(\sleep,\lpf, 300); // \lpf=2000
Pbindef(\sleep,\hpf, 200); // \hpf=80
Pbindef(\sleep,\detunehz, 3); // 1
Pbindef(\sleep, \vdepth, 0.0001); // 0.003
Pbindef(\sleep,\op1, 0,\op2, 0,\op3, 0,\op4, 0);
Pbindef(\sleep,\amp,Pseg(Pseq([0.3,Pn(0)]),20))


Scale