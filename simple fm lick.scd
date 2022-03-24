("Setup/Setup.scd").loadRelative // load this file

//simple FM lick

(~e = Pbind(\instrument,\fm1, \degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf), \mtranspose, 0, \iScale,45,\dur,Pseq([1],inf),\atk,0.1,\rel,8,\amp,0.1,\pan,Pwhite(-0.7,0.7)))
// a.play;
~e_play.pause; //remember why you can't free pbinds?
~e_play = ~e.play;


(e = Pbind(\instrument,\fm1, \degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf), \octave, 5, \iScale,Pwrand([55,1000],[0.98,0.02],inf),\cRatio,Pwrand([10,100],[0.95,0.05],inf),\dur,Pseq([1],inf),\atk,0.1,\rel,8,\amp,0.1,\pan,Pwhite(-0.4,0.4));) //pyramid is good for a opening to a theme sound
e.pause;
e.play;

(
~one54 = ChordSymbol.degreeProgression([
    \Cdom7, \Fdom7, \Cdom7, \Cdom7,
    \Fdom7, \Fdom7, \Cdom7, \Cdom7,
    \Gdom7, \Fdom7, \Cdom7, \Cdom7
], Scale.major)
)

(
~twelveBar = ChordSymbol.degreeProgression([
    \Cdom7, \Fdom7, \Cdom7, \Cdom7,
    \Fdom7, \Fdom7, \Cdom7, \Cdom7,
    \Gdom7, \Fdom7, \Cdom7, \Cdom7
], Scale.major)
)

(f = Pbind(\instrument,\ring1, \degree, Pseq(~twelveBar1,inf), \mRatio,1,\iScale,10,\octave,4,\dur,Pseq([1,2,3]/4,inf),\atk,0.1,\rel,2,\amp,0.1,\pan,Pwhite(-0.1,0.1)))

(
~twelveBar1 = ChordSymbol.degreeProgression([
    \Dm7, \Em7, \F7, \Gm7, \Am7,\Bb7,\C7,\Dm7
], Scale.major)
)


e.play;
e.stop;
f.play;

(
e = Pbind(
	\instrument, \fm1,
	\type,\phrase,
    \dur, Pseq([ Pshuf(#[1,1,4,2,2,1,1,]/4, 3) ], inf),
	\midinote, Pxrand((10..50), inf),
	\iScale,Pwrand([0.9,0.09],[0.9,0.1],inf),
	\mRatio, 450,
	\cRatio, Pwrand([1,1000],[0.95,0.05],inf),
	\amp,0.008,
	\pan,-0.5,
).play;

e.mute;

f = Pbind(
	\instrument, \ring1,
    \dur, Pseq([ Pshuf(#[1,1,4,2,2,1,1,]/8, 3) ], inf),
	\a, 1,
	\d, 0.3,
	\pan,0.5,
	//\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf),
	\freq,[1000,1200]*Pseq([ Pshuf(#[60, 61, 62, 63, 64, 65, 66, 67], 3) ].sputter, inf).midicps,

).play;

~b = [1,5,4,[7,8],0,5,4,5,6,3,2,1,];

g = Pbind(
	\instrument, \sinfb,
    \dur, Pseq([ Pshuf(#[1,1,4,2,2,1,1,]/8, 3) ], inf),
	/*\degree, Pavaroh(
            Pseq([1,5,4,7,8,0,5,4,5,6,3,2,1], inf),
            #[0, 2, 3, 6, 7, 9],
            #[0, 1, 3, 7, 8, 11]
        ),*/
	\degree, Pseq(~b,inf),
	\pan,Pwhite(-0.3,0.3,inf),
	\octave,Pwrand([5,3,6],[25,2,1].normalizeSum,inf),
	\out,~bus[\reverb],
).play;
)
e.mute;
e.unmute;
f.mute;
f.unmute;
a.mute;
b.mute;
a.unmute;
b.unmute;


(
a = Pbind(
	\instrument, \fm1,
    \dur, Pseq([1,1,1,1,1,1,2]/4, inf),
	\rel,0.4,
	\sus,2,
	\midinote, Pseq([1,2,3,4,],inf),
	\iScale,50,
	\cRatio,200,
).play;

b = Pbind(
	\instrument, \fm1,
    \dur, 1/Pseq([1,1,2,1,1,1,1,], inf),
	\rel,0.4,
	\sus,2,
	\midinote, Pseq([1,2,3,4,],inf),
	\iScale,20,
	//\mRatio,Pwhite(0,100,inf).round(10),
).play;
)