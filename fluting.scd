//fluting on cheap glass

(

Pbind(\instrument,\flute_waveguide,
			\atk,1,
			\dur, 1/8 * Pbjorklund2(Pwrand([2,3,5],[0.6,0.2,0.2],inf), 8),
	\midinote,  Pseq([0,2,4], 2) //this ending triggers a new loop
			    +.x Pseq([48,52,57,60].stutter(3), 2)
				+.x Pwrand(
					[Pseq(#[0, 4, 7, 11], 1),
						Pseq(#[0, 4, 11, 7], 1),
						Pseq(#[0, 7, 4, 11], 1),
						Pseq(#[0, 7, 11, 4], 1),
						Pseq(#[0, 11, 7, 4], 1),
						Pseq(#[0, 11, 4, 7], 1)],
					[3,1,1,1,1,1].normalizeSum,1),//Pseq((10..50),inf),//60+ [-12,24] + [0,4,11,14]+ Pseq([0,5,4,8,12],inf) , //
	\ipress,Pwhite(0.88,0.92,inf),
	\ibreath, 0.1 + Pwrand([0.001,0.01,0.1],[5,3,1].normalizeSum,inf),
	\ifeedbk1, 0.4,
	\ifeedbk2, 0.4,
			\amp,0.1,
			\out, Pwrand([0,~bus[\reverb]],[0.5,0.5],inf),
		).play;
)

Pbindef(\z,
					\instrument, \sinfb,
					\dur,1,

				).play

Pbindef(\z).stop;
Synth(\sinfb);