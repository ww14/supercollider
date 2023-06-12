//Cheap glass

Server.killAll;
("Setup/Setup.scd").loadRelative // load this file


// Play a major-7th arpeggio, transposed to different scale degrees
// Pseq is the transposer; Pseq is the chord
// The chord is like an "inner loop"
// .x is an 'adverb' that connects
//Glass-ian
/////////////////////////////////////////////////////////////////////////////////////


//update to harp pluck and flute play
//fix weird synth in phrase b (?)

a = nil;

(
TempoClock.default.tempo = 102/60;
//~n = (Pget(\tonic)+ Pget(\mod) + [-12,24]);
a = Plambda(
	Pseq([ //play ABA' twice then close
		Pseq([
		///Phrase A
		Pfindur(54,Ppar([
			//arpeggi
		                                                         	Pbindef(\p,
				\instrument, \harpsichord_pluck,
				\atk,0.005,
				\rel,0.7,
					\lag,Pwrand([0,0.005,0.01],[10,2,1].normalizeSum,inf), //sometimes off the beat
				\midinote, Plet(\tonic, Pseq([0,2,4], 2)) //this ending triggers a new loop
			    +.x Plet(\mod,Pseq([48,52,57,60].stutter(3), 2))
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 11], 1),
						Pseq(#[0, 4, 11, 7], 1),
						Pseq(#[0, 7, 4, 11], 1),
						Pseq(#[0, 7, 11, 4], 1),
						Pseq(#[0, 11, 7, 4], 1),
						Pseq(#[0, 11, 4, 7], 1)],
					[3,1,1,1,1,1].normalizeSum,1),
				\dur, 3/8, //total loop is 228 * (3/8) =108 beats
				\amp, Plprand(0.2,0.35),
					\pan,Pseg([0,0.3,-0.3,0],30,\lin,inf),
				\out,~bus[\reverb],
		),
				//harmony
			Pbindef(\q,
			\instrument,\harpsichord_pluck,
			\midinote, Pseq([\rest,Pseq([
						(Pget(\tonic)+ Pget(\mod) + [-12,24] + [0,4,11,14])],3)],inf) , //
			\dur, 3/8 * Pseq([14,Pseq([12,12,10],1)],inf),
					\amp,Plprand(0.15,0.3),
			\decaytime, Pwhite(5,10,inf),
					\coef,Pseg([0.1,0.6,0.1,0.6],108,\exp,inf),
					\pan,0.3,`
			\out, Pwrand([0,~bus[\reverb]],[0.7,0.3],inf),
		)<> Pbindef(\p)
				,
					//tonic
			Pbindef(\r,
					\instrument, \harpsichord_pluck,
					\dur, Pseq([0.00001, Pshuf(#[24,12,12]*3/8, 3) ], inf),
					\midinote, -12 + Pseq([(Pget(\tonic)+ Pget(\mod))],inf),
					\pan,-0.5,
					\amp,Plprand(0.10,0.25),//Pseg([0.005,0.01,0.005],27,\exp,inf)
					\out,~bus[\reverb],
				),
			],2)
		),
		////  Phrase B
		Pfindur(54,
        Ppar([
			Pbindef(\p_1,
				\midinote, Plet(\tonic, Pseq([0,2,4], 2)) //this ending triggers a new loop
			    +.x Plet(\mod,Pseq([48,52,57,60].reverse.stutter(3), 2))
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 11], 1),
						Pseq(#[0, 4, 11, 7], 1),
						Pseq(#[0, 7, 4, 11], 1),
						Pseq(#[0, 7, 11, 4], 1),
						Pseq(#[0, 11, 7, 4], 1),
						Pseq(#[0, 11, 4, 7], 1)],
					[6,1,1,1,1,1].normalizeSum,1)
				)<>Pbindef(\p),

			Pbindef(\q),

			Pbindef(\s,
					\instrument, \harpsichord_pluck,
					\dur, Pseq([Rest(1), 1, Pwrand([
						Pseq([Rest(1), 1/2,1/2],1),
						Pseq([Rest(1), 1/4,1/4,1/4,1/4],1)],[3,1].normalizeSum,1)
					], inf),
					//Pseq([ Pshuf(#[1,1,1,1,2,2,4]*3/8, 3) ], inf),
					//\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf),
					\midinote, 48 + Pseq([Pget(\tonic) + Pget(\mod)],inf), //Pseq([
						//Pshuf(#[48,52,57,60], 3) ].sputter,inf).midicps,
					\amp,0.2,
					\pan,-0.7,
					\out,~bus[\reverb]
				),
			],1)
		),
		//// Phrase A'
		Pfindur(54,
        Ppar([
			Pbindef(\p),
			Pbindef(\q_1,\coef,Pseg([0.1,0.6],54,\exp,inf))<>Pbindef(\q),
			//Pbindef(\s),
			//Pbindef(\r,\instrument,\SOStom,\amp,0.1)
		],1)
		),
	],2),
		Pbind(\instrument,\harpsichord_pluck,
			\dur, 3/8,
			\midinote, Pseq([
				Pseq([48,52,57,60,72],1)+.x Pseq(#[0, 4, 7, 11],1) + -12,
				48 + [0, 4, 7, 11,12,-24]],1),
			\amp,0.25,
			\atk,0.005,
			\rel,0.7,
			\out,~bus[\reverb],
			)],1).trace(\eventScope) // internally, the values are shared via \eventScope
);

//b = Pbindef(a, \legato, 0.1);
a.play
)

// you can tweak midstream, if there's a param in phrase B it'll revert
Pbindef(\q,\fb,Pseg([0.01,10,0.01],200,\exp,inf));

b.play;

(b = Pbindef(\p,
				\instrument, \fm1,
				\index,2,
				\atk,0.005,
				\rel,0.7,
				\mRatio,Pwrand([2,3],[0.9,0.1],inf),
				\iScale,Pwrand([1,2,3],[5,2,1],inf),
				\cRatio,Pwrand([1,2,3],[5,2,1],inf),
				\cAtk,1,
				\cRel,-1,
				\amp, 0.1,
				\lag,Pwrand([0,0.005,0.01],[10,2,1].normalizeSum,inf), //sometimes off the beat
				\out,0,
				\midinote, Plet(\tonic, Pseq([0,2,4], 2)) //this ending triggers a new loop
			    +.x Plet(\mod,Pseq([48,52,57,60].stutter(3), 2))
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 11], 1),
						Pseq(#[0, 4, 11, 7], 1),
						Pseq(#[0, 7, 4, 11], 1),
						Pseq(#[0, 7, 11, 4], 1),
						Pseq(#[0, 11, 7, 4], 1),
						Pseq(#[0, 11, 4, 7], 1)],
					[5,1,1,1,1,1].normalizeSum,1),
				\dur, 3/8, //total loop is 228 * (3/8) =108 beats
))

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////source inspriation for sharing data between pbinds: use plet and pget which works within a Plambda (kind like a proxyspace?)

(
a = Plambda(
    Pseq([
    Pfindur(5,
        Ppar([
            Pbindef(\a,\note, Plet(\x, Prand([1, 5, 1, [10, 14]], inf)), \dur, 8/3, \pan, -1),
            Pbindef(\b,\note, Plet(\y, Pseq([5, 3, 2, 0, [0, 5, 6, 9]], inf)), \dur, 0.5, \pan,1),
            Pbindef(\c,\note, Pseq([Pget(\x), Pget(\y)], inf) + 12, \pan, 0, \dur, 2/3)
        ])
    ),
    Pbindef(\d,\note, Pget(\x, 0, 6) + [0, 5], \dur, Pstutter(inf, Prand([2/3, 1/6])))
    ], inf).trace(\eventScope) // internally, the values are shared via \eventScope
);

b = Pbindf(a, \instrument, \fm1, \legato, 0.1);
b.play
)

Pbindef(\c,\dur,1/5);


