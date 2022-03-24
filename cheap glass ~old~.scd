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
	Pseq([
		///Phrase A
		Pfindur(108,
        Ppar([
			Pbindef(\p,
				\instrument, \harpsichord_pluck,
				\atk,0.005,
				\rel,0.7,
				\lag,Pwrand([0,0.0075,0.015],[10,2,1].normalizeSum,inf), //sometimes off the beat
				\midinote, Plet(\tonic, Pseq([0,2,4], 2)) //this ending triggers a new loop
			    +.x Plet(\mod,Pseq([48,52,57,60].stutter(3), 2))
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 11], 1),
						Pseq(#[0, 4, 11, 7], 1),
						Pseq(#[0, 7, 4, 11], 1),
						Pseq(#[0, 7, 11, 4], 1),
						Pseq(#[0, 11, 7, 4], 1),
						Pseq(#[0, 11, 4, 7], 1)],
					[4,1,1,1,1,1].normalizeSum,1),
				\dur, 3/8, //total loop is 228 * (3/8) =108 beats
				\amp, 0.1,
				\out,~bus[\reverb],
		),
			Pbindef(\q,
			\instrument,\harpsichord_pluck,
			\midinote, Pseq([\rest,Pseq([
						(Pget(\tonic)+ Pget(\mod) + [-12,24] + [0,4,11,14])],3)],inf) , //
			\dur, 3/8 * Pseq([14,Pseq([12,12,10],1)],inf),
			\amp,0.3,
			\decaytime, Pwhite(5,10,inf),
			\out, Pwrand([0,~bus[\reverb]],[0.7,0.3],inf),
		)<> Pbindef(\p)
				,
			Pbindef(\s,
					\instrument, \SOShats,
					\dur, Pseq([ Pshuf(#[1,1,1,1,2,2,4]*3/8, 3) ], inf),
					//\degree, Pseq([1,5,4,[7,8],0,5,4,5,6,3,2,1,],inf),
					\freq,100*Pseq([
						Pshuf(#[48,52,57,60], 3) ].sputter,inf).midicps,
					\amp,0.005,
				),
/*			Pbindef(\r,
					\instrument, \sinfb,
					\dur,1,
				) */
			Pbindef(\r,
					\instrument, \sinfb,
					\dur, Pseq([ Pshuf(#[24,12,12]*3/8, 3) ], inf),
					\midinote, Pseq([(Pget(\tonic)+ Pget(\mod))/2],inf),
					\amp,0.1,//Pseg([0.005,0.01,0.005],27,\exp,inf)
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
					[10,1,1,1,1,1].normalizeSum,1)
				)<>Pbindef(\p),
			Pbindef(\q),
			Pbindef(\s_1,\freq,10*Pseq([ Pshuf(#[48,52,57,60], 3) ].sputter,inf).midicps,\amp,0.005,\out,~bus[\reverb],
				)<>Pbindef(\s),
		],1)
		),
		//// Phrase A'
		Pfindur(54,
        Ppar([
			Pbindef(\p),
			Pbindef(\q_1,\coef,Pseg([0.1,0.6],54,\exp,inf))<>Pbindef(\q),
			Pbindef(\s),
			Pbindef(\r,\instrument,\SOStom,\amp,0.1)
		],1)
		),
	],inf).trace(\eventScope) // internally, the values are shared via \eventScope
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

b = Pbindf(a, \instrument, \sine, \legato, 0.1);
b.play
)

Pbindef(\c,\dur,1/5);


