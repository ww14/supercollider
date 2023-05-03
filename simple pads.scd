Server.killAll
("Setup/Setup.scd").loadRelative // load this file


(
~spica = PathName(thisProcess.nowExecutingPath).parentPath++"setup/cellospica/";
b = Dictionary.new;
b.add(\foldernames -> PathName(~spica).entries);
	for (0, b[\foldernames].size-1,
		{arg i; b.add(b[\foldernames][i].folderName -> b[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
)

(
/////////////////////groan
(
~a = Pbind(\instrument,\vplay,\buf,b["spica"][4],\rate,Pseq([1,1.01]/[10,9.9,9.8,9.7,9.6,9.5,9.4,9.3,9.2,9.1].mirror,inf),\dur,Pseq([1/4],inf),\amp,-6.dbamp,\rel,3.5,\sus,0,\atk,0.5,);
);


/////////////////////simple pads in A Maj: I-VI-VII-I ; I-V-vi-IV

( ~b1 = [
				[33,45,48,55,57], //A
				[29,41,45,48,53], //F
		        [33,43,47,50,55], //G
		        [33,45,49,55,57], //A
]);

( ~b2 = [
			[33,45,48,55,57], //A
			[40,44,47,52], //E
			[31,34,38,43,46,50], //g
			[38,42,45,50,57], //D
]);


( ~b = Pbind(\instrument, \fm1,
		\dur, 4,
		\midinote, Pseq([
		Pseq(~b1,2),
		Pseq(~b2,1),
	],1),
		//\mRatio,0.001,
        \index,0.5,
		\iScale, Pwrand([2,4],[8,4].normalizeSum,inf),
		\atk, 1/3 * 8,
		\rel, 2.5,
	    \cAtk,0.001,
        \cRel,-0.001,
	    \lsf,1200,
		\amp, -25.dbamp,
		\out, 0,
		\cRatio,[4,1/20],
		);
);

/////////////////////rhythm
(
l = Prewrite(0.25,
    (
        0.25: #[0.25,0.25,0.25,0.5],
        0.5: #[0.25,0.5,0.125,0.125,0.125,0.125],
        0.125: #[0.375,0.125],
        0.375: #[0.375,0.375,1],
        1: #[0.75,0.25],
        0.75: #[16]
),60);
);

(
k = Prewrite(1, // start with 1
        (    1: [0.25,2],
            0.25: [3,3,2]/4,
		3/4: [0.25,1,0.125,0.125],
        ), 4);
);

/////////////////////drum
(
~d = Pbind(\instrument,\bplay,\buf,b["spica"][4],\rate,Pwhite(800,2000,inf).round(100),\dur,k,\amp,3.dbamp,\out,~out,\pan,0.4);
);

/////////////////////hard drum
~x = Pbind(\instrument,\metaldrum, \amp,-20.dbamp,\dur,Pseq([1],1),\ibase,2,\ringfreq,220,\roomsize, 20, \revtime, 0.5, \damping, 0.1, \inputbw, 0.46);

/////////////////////melody
~f = Pbind(
    \instrument, \sinfb, //fm5
	\degree, Pseq([0,Pbrown(0, Scale.minorPentatonic.size, 5)],1),
    \scale, Scale.minorPentatonic,
	\root, -3,
	\octave, Pwrand(
		[8,7],
        [4,1].normalizeSum,
        85
    ),
	/*\seed, 30,
	\seedDrift, 4,
	\seedDriftCurve, 4,
	\legato, 1.1,
	\freqMin, -10,
	\freqMax, 10,
	\freqRound, 0,
	\matrixCut, 0.1,*/
    \dur, l,
	\legato,0.2,
    \pan, -0.4,
	\sus,0.2,
	\amp, -25.dbamp,
	\out,~bus[\reverb]
);

);

//// testing
~f.play;


///////////////////////////////////////////////////////////////////////////////////////////
//the piece
////////////////////////

(
t = TempoClock(60/60,4);
StageLimiter.deactivate;
r = Routine.new({
	//var i = 0, n = 0, b=4;

	//groan
	~a_play = ~a.play(t, quant:1);

	//~a_play.stop;

	8.wait;

	//drum
	~d_play = ~d.play(t, quant:1);
	//~d_play.stop;

	16.wait;

	//chord progression
	(~b_r = Pchain(Pbind(
	\strum,0.5,
	\dur,2,
	\index,2,
	\atk,0.005,
	\rel,2.5,
	\mRatio,2,
	\cRatio,1,
	\iScale, 1,
	//\amp,-15.dbamp,
	//\lag,0.25, //lag sounds bad
	)
	,~b);
	);

	// set up a tone shift for the chord prog
	(
	~q_r = Ppar(
	[Pseq([~b_r], 1),
	Pseq([
	Pbindf(~b_r,
	\iScale,Pwrand([1,2,3],[5,2,1],inf),
	\rel,2.0,
	\cRatio,
	Pwrand([1,2,3],[5,2,1],inf))], 1)
	]);
	~r_r = Psetp(\index, Pseq([1,3,1/10], inf), ~q_r);
	~b_play_r = ~r_r.play(t, quant:0);
	);
	24.wait;



	//melody
	~f.play(t, quant:0);


	8.wait;

	//change the groan pattern
	(
	~a_play.pause;
	~a_2 = Pchain(Pbind(
		\dur,k,
		),~a);
		~a_play = ~a_2.play(t, quant:0);
	);

	16.wait;


	//launch the melody again
	~f.play(t, quant:1);


	//switch drum pattern, have it in sync with the melody
	(
		~d_play.pause;
		~d_2 = Pchain(Pbind(
			\dur,l,
		),~d);
		~d_play = ~d_2.play(t, quant:0);
	);


	32.wait;

	//~f.play;

	// change the groan pattern
	(
	~a_play.pause;
	~a_2 = Pchain(Pbind(
		\dur,1/4,
		),~a);
		~a_play = ~a_2.play(t, quant:0);
	);

	16.wait;

	// bolder progression, drop vol 25>30
	(~b_r2 = Pchain(Pbind(
	\index,8,
	\cRatio,8,
	\mRatio,20,
	)
	,~b_r);
	~b_play_r2 = ~b_r2.play(t, quant:0);
	);

	// switch drum pattern
	16.wait;

		(
		~d_play.pause;
		~d_2 = Pchain(Pbind(
			\dur,k,
		),~d);
		~d_play = ~d_2.play(t, quant:0);
	);

	8.wait;



	8.wait;

	//play mel
	~f_play = ~f.play(t, quant:0);



	8.wait;

	// make drum resonant/clicky
	(
		~d_play.pause;
		~d_2 = Pchain(Pbind(
			\rate,Pwhite(10,80,inf).round(10),
			\out,~bus[\reverb],
			\amp,5.dbamp,
		),~d);
		~d_play = ~d_2.play(t, quant:0);
	);

	8.wait;

	~f_play.stop;

	// play both chord progressions simultaneously
	~b_play_r2 = ~b_r2.play(t, quant:0);

	24.wait;

	// switch groan, bit louder
	(
	~a_play.pause;
	~a_2 = Pchain(Pbind(
		\dur,k,
		\amp,-1.dbamp,
		),~a);
		~a_play = ~a_2.play(t, quant:0);
	);


	~a_play.pause;

	16.wait;

	~b_play_r.pause;
	~b_play_r2.pause;

	// closing progression
	(~r = Pchain(Pbind(\amp,-15.dbamp),
		~b);
	);


	~r_r = Psetp(\index, Pseq([1,2], inf), ~r);
	~b_play_r = ~r_r.play(t, quant:0);


	//////
	//(
	//~r = Psetp(\index, Pseq([1,2], inf), ~b);
	//~b_play = ~r.play(t, quant:0);
	//);

	//////
		(
	~f_2 = Pchain(Pbind(
				\octave, Pwrand(
		[6,5],
        [4,1].normalizeSum,
        4000
    ),
			\dur,Pseq([l**k],inf),
			\amp, Pgeom(0.11,0.999999,inf),
		),~f);
		~f_play = ~f_2.play(t, quant:0);
	);

	96.wait;

	~b_play_r.stop;
	~f_play.stop;

	16.wait;

	~d_play.stop;
}).play(t);
)

//////////////////////////////////////////////////////////////////////////////////////////
/
/
/
/
/
/
/
/
/
/
/
/
/

///////testing//////////////////////////////////////////////////////////////////////////


(

~b_2 = Pchain(Pbind(
	\strum,0.5,
	\dur,2,
	\index,2,
	\atk,0.005,
	\rel,2.5,
	\mRatio,2,
	\iScale, 1,
	\amp,0.1,
	\lag,0.02,
		),~b);
		~b_play = ~b_2.play;
	);

~b_2.play;

~b_play.mute;
~b_play.unmute;

~b_play.stop;


~b.play;
~f.play;
~b_play.pause;
~q = Ppar([Pseq([~b], 1),Pseq([Pbindf(~b, \atk,0.01,\iScale,100,\rel,1.2)], 1)]);
~r = Psetp(\index, Pseq([1,2], inf), ~q);
~b_play_2 = ~r.play;

~x.play;
~x.stop;

~f_play = ~f.play(t, quant:0);


(
t = TempoClock(60/60,4);
r = Routine.new({
	var i = 0, n = 0, b=4;
	~f_play.stop;

	~f_play = ~f.play(t, quant:1);

	(
	~f_play.pause;
	~f_2 = Pchain(Pbind(
			\rel,1,
			\atk,0.001,
			\degree, Pavaroh(
            Pseq([1, 2, 3, 2, 5, 4, 3, 4, 2, 1], inf),
            #[0, 2, 3, 6, 7, 9],
            #[0, 1, 3, 7, 8, 11]
        ),
			\dur, k,//Pwrand(
				//(1..4) / 8,
				//[1, 2, 5, 10].normalizeSum,
				//inf),
			\octave,4,
			\out,~bus[\reverb]
		),~f);
		~f_play = ~f_2.play;
	);

}).play;
)

~f_play.stop;

(
t = TempoClock(60/60,4);
r = Routine.new({
	var i = 0, n = 0, b=4;
	~f_play.stop;

	~f_play = ~f.play(t, quant:1);

	(
	~f_play.pause;
	~f_2 = Pchain(Pbind(
			//\rel,2,
			//\sus,0.5,
			//\atk,0.05,
				\octave, Pwrand(
		[5,6],
        [4,1].normalizeSum,
        80
    ),

			\dur,l**k.round(0.125), /*Pwrand(
				(1..4) / 16,
				[1, 2, 5, 10].normalizeSum,
				inf),*/
			\out,~bus[\reverb],
			//\fb,2,
		),~f);
		~f_play = ~f_2.play;
	);


}).play;
)

~f_play.stop;


(
t = TempoClock(120/60,4);
r = Routine.new({
	var i = 0, n = 0, b=4;
	~b_play.stop;

	~b_play = ~b.play(t, quant:1);

	(
	~b_play.pause;
	~b_2 = Pchain(Pbind(
		\dur, 4,
		\midinote, Pseq([
		Pseq(~b1,2),
		Pseq(~b2,1),
	],1),
		//\mRatio,0.001,
        \index,0.5,
		\iScale, Pwrand([2,4,8],[8,8,1].normalizeSum,inf),
		\atk, 1/3 * 8,
		\rel, 2.5,
	    \cAtk,0.001,
        \cRel,-0.001,
	    //\lsf,1,
		\amp, 0.15,
		\out, 0,
		\cRatio,[4,1/20],
		),~b);
		~b_2_play = ~b_2.play;
	//Ppar([Pseq([~b], 4), Pseq([Pbindf(~b_2, \ctranspose, 12)], 5)]).play(t);
	);

}).play;
)

~b_2_play.stop;

// Nested Patterns!
c = Pbind(
	\instrument,\fm1,
	\degree, Pwrand(
		[Pseq([[7,2,4],0,1,3,4,6,9,7],1),
		Pseq([[7,2,4],7,9,7,5,8,9,7],1)],
		[0.9,0.1],1),
	\iScale,8.1,
	\dur,Pseq([4,4,1,1,1,1,1,1]/4,inf),
	\atk,0.01,
	\rel,8,
	\amp,0.15,
	\pan,Pwhite(-0.2,0.2),
	\octave,3,
	\root,-3);


q = Ppar([Pseq([~b], 4),Pseq([Pbindf(~b, \iScale, 20,\atk,0.01,\rel,1.2)], 5)]);

Psetp(\amp, Pseq([0.15,0.05], inf), q).play;

Pbind(\degree,
    Prewrite(0, ( 0: #[2, 0],
            1: #[0, 0, 1],
            2: #[1, 0, 1]
        ), 4
    ) + Pn(Env([4, 0, 1, 4, 3, 4], [6.4, 6.4, 6.4, 6.4, 6.4], 'step')),
    \dur, 0.2).play

p = Pbind(
    [\degree, \dur], Pseq([[0, 0.1], [2, 0.1], [3, 0.1], [4, 0.1], [5, 0.8]], 1),
    \amp, 0.05, \octave, 6, \instrument, \cfstring1, \mtranspose, 0);

q = Pbindf(p, \instrument, \default );

// PdurStutter( repetitionPattern, patternOfDurations ) -
Pbindf(Pn(q), \dur, PdurStutter(
    Pseq(#[1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 4, 5, 7, 15], inf),
    Pseq(#[0.5], inf)
    )
).play;

Ppatmod(p, { arg oldPat; [p, q, r].choose }, inf).play
Pbindf(Pn(q, inf), \ctranspose, Pn(Env.linen(3, 0, 0.3, 20), inf) ).play;

Pbind(\note, Pwrap(Pwhite(0, 128), 10, 20).round(2), \dur, 0.05).play;

(
(
SynthDef(\help_sinegrain,
    { arg out=0, freq=440, sustain=0.05, pan=0.5, amp=1;
        var env, sig;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction: Done.freeSelf);
		sig = SinOsc.ar(freq, 0, env);
		sig = Pan2.ar(sig, pan, amp);
        Out.ar(out, sig);
    }).add;
);
a = Pn(
    Pwrap(
		Pgeom([100,200],1.07,96),
        100,
        1000.0
    ),
    inf
);
x = a.asStream;
Routine({
    loop({
		Synth(\help_sinegrain, [\freq, [x.next,x.next*sin(x.next)],\dur,0.3,\out,~bus[\reverb]]);
        0.12.wait;
    })
}).play;
)

x.stop;



//////////////
//it'd be great to figure this out.


(
~chord = [
    \Amaj11, \Fmaj11, \Gmaj11, \Am,
    \A, \E, \Gm, \DM,\C_g
].chordProg(Scale.dorian);
)


(( ~b_test = Pbind(\instrument, \help_sinegrain,
			\dur, 2,
			\degree, Pseq(~chord,inf),
	\mRatio,4.0,
	\octave,3,
			\atk, 1/6 * 8,
		    \rel, 3,
			\amp, 0.15,
			\out, 0,
			\index,2,
		\iScale, Pwrand([2,4,8],[8,8,1].normalizeSum,inf),
		\cAtk,0.001,
        \cRel,-0.001,
		\cRatio,[4,1/20],
		);
).play);

~b_test.play;

\









