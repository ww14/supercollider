("Setup/Setup.scd").loadRelative // load this file

//simple FM lick

(~e = Pbind(\instrument,\fm1, \degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf), \mtranspose, 0, \iScale,45,\dur,Pseq([1],inf),\atk,0.1,\rel,8,\amp,0.1,\pan,Pwhite(-0.7,0.7)))
// a.play;
~play = ~e.play;
~play.pause; //remember why you can't free pbinds? need to call it into a global
~play.play;

t = TempoClock.new(60/60).permanent_(true);

(
~pat_e = Pbind(
	\instrument, \fm1,
    \dur, Pseq([ Pshuf(#[1,1,4,2,2,1,1,]/4, 3) ], inf),
	\midinote, Pxrand((10..50), inf),
	\iScale,Pwrand([0.9,0.09],[0.9,0.1],inf),
	\mRatio, 450,
	\cRatio, Pwrand([1,1000],[0.95,0.05],inf),
	\amp,-40.dbamp
);

~pat_f = Pbind(
	\instrument, \ring1,
    \dur, Pseq([ Pshuf(#[1,1,4,2,2,1,1,]/8, 3) ], inf),
	//\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf),
    \freq,1000*Pseq([ Pshuf(#[60, 61, 62, 63, 64, 65, 66, 67], 3) ].sputter, inf).midicps,
	\amp,-30.dbamp

);

~pat_g = Pbind(
	\instrument, \sinfb,
    \dur, Pseq([ Pshuf(#[1,1,4,2,2,1,1,]/8, 3) ], inf),
	\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf),
);
~player1 = ~pat_e.play(t, quant:1);
~player2 = ~pat_f.play(t, quant:1);
~player3 = ~pat_g.play(t, quant:1);
)

~player1.play(t, quant:1);
~player1.mute;
~player1.unmute;




(
~player1.stop;
~pat_e_1 = Pchain(Pbind(
	\iScale,Pwrand([10,2],[0.1,0.9],inf),
),~pat_e);
~player1 = ~pat_e_1.play(t, quant:1);
)
(
~player2.stop;
~pat_f_1 = Pchain(Pbind(
	\freq,100*Pseq([ Pshuf(#[48,52,57,60], 3) ].sputter, inf).midicps
),~pat_f);
~player2 = ~pat_f_1.play(t, quant:1);
)
(
~player3.pause;
~pat_g_1 = Pchain(Pbind(
	\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,].sputter,inf)// + Prand([-1,1,2],inf)
),~pat_g);
~player3 = ~pat_g_1.play(t, quant:1);
)


(
~player3.pause;
~pat_g_1 = Pchain(Pbind(
	\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,].mirror1,inf)// + Prand([-1,1,2],inf)
),~pat_g);
~player3 = ~pat_g_1.play(t, quant:1);
)

(
(
~twelveBar1 = ChordSymbol.degreeProgression([
    \Dm7, \Em7, \F7, \Gm7, \Am7,\Bb7,\C7,\Dm7
], Scale.major)
);
~player3.pause;
~pat_g_1 = Pchain(Pbind(
	\degree, Pseq(~twelveBar1,inf),
	\dur,1,// + Prand([-1,1,2],inf)
),~pat_g);
~player3 = ~pat_g_1.play(t, quant:1);
)


(

var rhythm = Array.fill(rrand(4,10),{rrand(1,10)}).normalizeSum * rrand(1,4);
l = Prewrite(1,
	(
		//equal to 2 duration units/beats
		1: #[0.25,0.5,0.5,0.25,2],
		0.25: #[1],
		2: rhythm
),15);
(
g = Prewrite(0.25,
	(
		0.25: #[0.25,0.25,0.25,0.5],
		0.5: #[0.25,0.5,0.125,0.125,0.125,0.125],
		0.125: #[0.375,0.125],
		0.375: #[0.375,0.375,1],
		1: #[0.75,0.25],
		0.75: #[16]
),60)
);

~a = Pbind(
	\instrument, \fm1,
    \dur, l,
	\rel,0.4,
	\sus,2,
	\midinote, Pxrand([1,5,[1,3,5],0,],inf),
	\iScale,10,
	\cRatio,200,
);

~b = Pbind(
	\instrument, \fm1,
    \dur, g,
	\rel,0.4,
	\sus,2,
	\midinote, 1,
	\iScale,10,
);

~player1 = ~a.play(t, quant:1);
~player2 = ~b.play(t, quant:1);
)




b.stop;