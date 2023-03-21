s.boot;

Server.killAll;
("Setup/Setup.scd").loadRelative




// Example 1 - hihat only
(
Pbind(
	\instrument, "hihat",
	\dur, Pbjorklund2(Pwrand([2,3,6],[0.5,0.25,0.25],inf), 8)/4,/*Pseq([
		1/8,         1/8,          1/8,                  1/8, // beat 1
		1/8,         1/8,          1/16, 1/16,      1/8, // beat 2
		1/8,         1/8,          1/16, 1/16,      1/8, // beat 2
		1/8,         1/8,          1/16, 1/16,      1/32, 1/32, 1/32, 1/32, 1/8 // beat 2
	], inf),*/
	\att, 0.01,
	\rel, 0.05,
	\ffreq, 11000,
	\pan, 0,
	\amp, 0.3,
	\tempo, 90/60,
	\out,~bus[\comb],//~bus[\chorus]
).play;
)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// A groove
(p= (
Pdef.removeAll;
t = TempoClock.default.tempo = 55 / 60;

// hihat
Pbindef(\hihat,
	\instrument, Pwrand([\hihat,\bpfsaw],[20,1].normalizeSum,inf),
	\dur, Pseq([Rest(1/4), 1/4, Pwrand([
		Pseq([Rest(1/4), 1/4],1),
		Pseq([Rest(1/4), 1/16,1/16,1/16,1/16],1)],[5,1].normalizeSum,1)
	], inf),
	\att, 0.01,
	\rel, 0.1,
	\midinote,Prand([36, 32, 32, 37], inf)/2,
	\ffreq, 11000,
	\pan, -0.3,
	\amp, 0.3,
	\out,~bus[\reverb],
);

// flat kik
Pbindef(\flatkik,
	\instrument, \kick,//Pseq([\kick1, \kick2, \kick3, \kick1, \kik], inf),
	\dur,Pseq([1/2, Pwrand([
		1/2,
		Pseq([1/8,1/8,1/4],1)],[10,1].normalizeSum,1)
	], inf),
	\basefreq,23.midicps*Pwrand([1,0.75,1.5],[0.8,0.15,0.05],inf),
	\rel, 0.12,
	\ratio,Pwrand([20,3],[0.05,0.95],inf),
	\amp, 0.5,
	\out,0,
);

// snare
Pbindef(\snare,
	\instrument, \kraftySnr,
	\dur, Pseq([Rest(1/2), 1/2], inf),
	\att, 0.01,
	\rel, 0.1,
	\rq,10,
	//\sinfreq, 180,
	//\ffreq, 2000,
	\amp, 0.05,
	\pan,0.2,
	\out,0,
);

// 3-bar rushup?
Pbindef(\rush,
	\instrument, Pseq([\kick1, \kraftySnr, \kick1, \kick1, \kraftySnr], inf),
	\dur, Psubdivide(
		Pseq(#[1,1,1,1,1, 2,1,2,2,2, 2,1,1,4,1],inf),
		Pseq(#[0.5, 1, 2, 0.25,0.25],inf)),
	\att, 0.01,
	\rel, 0.1,
	\rq,7,
	//\sinfreq, 180,
	//\ffreq, 2000,
	\amp, 0.2,
	\pan,-0.2,
	\out,0,
);


// pads
Pbindef(\pads,
	\instrument,\sinfb,
	\midinote, //Pseq(~b2+12,inf), //~b1 from simple pads
	Pseq([
		Pn(
			Pxrand([
				[23,35,54,63,64],
				[45,52,54,59,61,64],
				[28,40,47,56,59,63],
				[42,52,57,61,63],
		],1)
			,64),
		Pn(
			Pseq([
				[23,35,54,63,64],
				[45,52,54,59,61,64],
				Prand([
					[28,40,47,56,59,63],
					[42,52,57,61,63]], 1)
		],1)
			,16)
	],
	inf),
	\dur, Prand([1, 3, 4, 4.5], inf),
	\atk, 0.1,
	\fb,Pseg([1/100,0.75,1/100],100,\lin,inf),
	\rel, Pkey(\dur) + 1,
	\pan,0.3,
	//hifreq, 5000,
	\amp, 0.7 * Pseg([0.3,0.37,0.3],100,\lin,inf),
	\out,~bus[\reverb],
);

//pads 2
Pbindef(\pads2,
	\instrument,\organ_donor,
	\midinote, Pseq([
		Pn(
			Pxrand([
				Pseq([23,35,54,63,64],inf),
				Pseq([45,52,54,59,61,64],inf),
				Pseq([28,40,47,56,59,63],inf),
				Pseq([42,52,57,61,63],inf),
		],1)
			,64),
		Pn(
			Pseq([
				Pseq([23,35,54,63,64],inf),
				Pseq([45,52,54,59,61,64],inf),
				Prand([
					Pseq([28,40,47,56,59,63],inf),
					Pseq([42,52,57,61,63],inf)], 1)
		],1)
			,16)
	],
	inf) ,
	\dur, Prand([1, 3, 4, 4.5], inf)/Pseg([20,30,20],100,\lin,inf),
	\atk, 0.05,
	//\fb,0.1,//Pseg([1/100,0.75,1/100],100,\lin,inf),
	\rel, Pkey(\dur) + 0.05,
	\pan,-0.2,
	\cutoff,1000,
	//\hifreq, 400,
	\amp, 0.1 * Pseg([0.3,0.37,0.3],100,\lin,inf),
	\out,~bus[\reverb],
) <> Pbindef<>(\pads);


// counterpoint
Pbindef(\counterpoint,
	\instrument, \twotube2,
	\midinote, Pxrand([61, 63, 63, 64],inf),
	\dur, Pseq([
		Pn(Pseq([1/4, 1/4, 1/2, Rest(3.75), 1/4], 1),8),
		Pn(Pseq([1/2, 1/4, 1/4, Rest(3.75), 1/4],8),1)
	],inf),
	\ctranspose, [0, 12,-12],
	\rel, 0.2,
	\amp, 0.1,
	\k, Pseq([Pn(0,32),Pn(0.09,32)],inf), // -0.001
	\loss,Pseg([-1,1.1,-1],100,\lin,inf), //0.1
	\out,Pwrand([0,~bus[\comb]],[0.9,0.1],inf),
	\rand,Pwhite(-10,10,inf),
);

Pbindef(\mel,
    \instrument, \piano_MDA,
	\degree, Pseq([
		Pn(
			Pxrand([
				[23,35,54,63,64],
				[45,52,54,59,61,64],
				[28,40,47,56,59,63],
				[42,52,57,61,63],
		],1)
			,64),
		Pn(
			Pseq([
				Pseq([23,35,54,63,64],1),
				Pseq([45,52,54,59,61,64],1),
				Prand([
					Pseq([28,40,47,56,59,63],1),
					Pseq([42,52,57,61,63],inf)], 1)
		],1)
			,16)
	],
	inf),
	//Pxrand([23,35,54,63,64,45,52,54,59,61,64,28,40,47,56,59,63,42,52,57,61,63],inf),
	\dur, Pbjorklund2(Pseq([8, 6, 8, 5, 8, 3, 8, 1], inf), 8)/4 ,//Prand([1, 3, 4, 4.5], inf)/Pseg([1,10,1],100,\lin,inf),
	/*Psubdivide(
		Pn(Pshuf([1!4,2!4,3!2,16!1].flat,2),inf),
		Prand(#[1, 3, 4, 4.5], inf)),*/
    \pan, Pwhite(-0.2,0.2),
	\sus,Pgauss(0.0,0.4,inf),
	\stretch,0.5,
	\amp, 0.8,
	\out,Pwrand([0,~bus[\comb]],[0.5,0.5],inf),
);

));

Pbindef(\mel).play.play(t,quant:1);




(
Pbindef(\hihat).play(t,quant:1);
Pbindef(\flatkik).play(t,quant:1);
Pbindef(\snare).play(t,quant:1);
Pbindef(\rush).play(t,quant:1);
Pbindef(\pads).play(t,quant:1);
Pbindef(\counterpoint).play(t,quant:5);
)

Pbindef(\pads2).play(t,quant:1);

(
Pbindef(\hihat).stop;
Pbindef(\flatkik).stop;
Pbindef(\snare).stop;
Pbindef(\rush).stop;
Pbindef(\pads).stop;
Pbindef(\pads2).stop;
Pbindef(\counterpoint).stop;
)

Pbindef(\pads2).stop;

///////////////////////////////////////////////////////////////////////////////////////////////////


Pbindef(\counterpoint,\dur,PdurStutter(Pseq([1,1,1,1,1, 2,1,2,2,2, 2,1,1,1,4],inf),Pseq([1/4, 1/4, 1/2, Rest(3.75), 1/4],inf)));

Pbindef(\flatkik,\ratio,Pwrand([20,3],[0.05,0.95],inf));

Pbindef(\pads2,\rel, Pkey(\dur) + 0.2,\ctranspose, [0, 12,-12],\mtranspose, [0, 12,-7],\amp,0.05);

Pbindef(\pads2,\dur,Pbjorklund2(Pwrand([2,3,5],[0.6,0.2,0.2],inf), 8)/30);


////////////////////////////////////////////////////////////////////////////////////////////////////////


(
a = nil;
TempoClock.default.tempo = 55/60;
//~n = (Pget(\tonic)+ Pget(\mod) + [-12,24]);
a = Plambda(
	Pseq([
		Pseq([
		///Phrase A
			Pfindur(8,Ppar([
				//pads
				Pbindef(\pads_1,
					\instrument,\sinfb,
					\lag,Pwrand([0,0.005,0.01],[10,2,1].normalizeSum,inf), //sometimes off the beat
					\midinote, Plet(\mod,
						Pseq([
						Pn(
							Prand([
								[23,35,54,63,64],
								[45,52,54,59,61,64],
								[28,40,47,56,59,63],
								[42,52,57,61,63],
							],1)
							,6),
						Pn(
							Pseq([
								[23,35,54,63,64],
								[45,52,54,59,61,64],
								Prand([
									[28,40,47,56,59,63],
									[42,52,57,61,63]], 1)
							],1)
							,2)
					],
						inf)),
					\dur, Prand([1, 3, 4, 4.5], inf),
					\atk, 0.1,
					\fb,Pseg([1/100,0.75,1/100],100,\lin,inf),
					\rel, Pkey(\dur) + 1,
					\pan,0.3,
					//hifreq, 5000,
					\amp, 0.7 * Pseg([0.3,0.37,0.3],100,\lin,inf),
					\out,~bus[\reverb],
				),
				Pbindef(\hihat,
					\instrument, Pwrand([\hihat,\bpfsaw],[20,1].normalizeSum,inf),
					\dur, Pseq([Rest(1/4), 1/4, Pwrand([
						Pseq([Rest(1/4), 1/4],1),
						Pseq([Rest(1/4), 1/16,1/16,1/16,1/16],1)],[5,1].normalizeSum,1)
					], inf),
					\att, 0.01,
					\rel, 0.1,
					\midinote,Prand([36, 32, 32, 37], inf)/2,
					\ffreq, 11000,
					\pan, -0.3,
					\amp, 0.3,
					\out,~bus[\reverb],
				),
				// flat kik
				Pbindef(\flatkik,
					\instrument, \kick,//Pseq([\kick1, \kick2, \kick3, \kick1, \kik], inf),
					\dur,Pseq([1/2, Pwrand([
						1/2,
						Pseq([1/8,1/8,1/4],1)],[10,1].normalizeSum,1)
					], inf),
					\basefreq,23.midicps*Pwrand([1,0.75,1.5],[0.8,0.15,0.05],inf),
					\rel, 0.12,
					\ratio,Pwrand([20,3],[0.05,0.95],inf),
					\amp, 0.5,
					\out,0,
				),
				// snare
				Pbindef(\snare,
					\instrument, \kraftySnr,
					\dur, Pseq([Rest(1/2), 1/2], inf),
					\att, 0.01,
					\rel, 0.1,
					\rq,10,
					//\sinfreq, 180,
					//\ffreq, 2000,
					\amp, 0.05,
					\pan,0.2,
					\out,0,
				),
				// 3-bar rushup?
				Pbindef(\rush,
					\instrument, Pseq([\kick1, \kraftySnr, \kick1, \kick1, \kraftySnr], inf),
					\dur, Psubdivide(
						Pseq(#[1,1,1,1,1, 2,1,2,2,2, 2,1,1,4,1],inf),
						Pseq(#[0.5, 1, 2, 0.25,0.25],inf)),
					\att, 0.01,
					\rel, 0.1,
					\rq,7,
					//\sinfreq, 180,
					//\ffreq, 2000,
					\amp, 0.2,
					\pan,-0.2,
					\out,0,
				),
				Pbindef(\counterpoint,
					\instrument, \twotube2,
					\midinote, Pxrand([61, 63, 63, 64],inf),
					\dur, Pseq([
						Pn(Pseq([1/4, 1/4, 1/2, Rest(3.75), 1/4], 1),8),
						Pn(Pseq([1/2, 1/4, 1/4, Rest(3.75), 1/4],8),1)
					],inf),
					\ctranspose, [0, 12,-12],
					\rel, 0.2,
					\amp, 0.1,
					\k, Pseq([Pn(0,32),Pn(0.09,32)],inf), // -0.001
					\loss,Pseg([-1,1.1,-1],100,\lin,inf), //0.1
					\out,Pwrand([0,~bus[\comb]],[0.9,0.1],inf),
					\rand,Pwhite(-10,10,inf),
				),
			])),
		//phrase B
		Pfindur(54,Ppar([
			//pads
				Pbindef(\pads_1a,
					\ctranspose, 9,
				)<>Pbindef(\pads_1),

			//harmony
			Pbindef(\harp_h,
			\instrument,\harpsichord_pluck,
			\midinote, Pseq([\rest,Pseq([
						(Pget(\mod) + [-12,24])],3)],inf) , //
			\dur, 3/8 * Pseq([14,Pseq([12,12,10],1)],inf),
			\amp,0.2,
			\decaytime, Pwhite(5,10,inf),
					\coef,Pseg([0.1,0.6,0.1,0.6],108,\exp,inf),
					\pan,0.3,`
					\ctranspose, 0,  //9 doesn't work either; it's dissonant with the pads
			\out, Pwrand([0,~bus[\reverb]],[0.7,0.3],inf),
		)<> Pbindef(\pads)
				,
			//tonic
			Pbindef(\harp_t,
					\instrument, \harpsichord_pluck,
					\dur, Pseq([0.00001, Pshuf(#[24,12,12]*3/8, 3) ], inf),
					\midinote, -12 + Pseq([Pget(\mod)],inf),
					\pan,-0.5,
					\ctranspose, 0,
					\amp,0.15,//Pseg([0.005,0.01,0.005],27,\exp,inf)
					\out,~bus[\reverb],
				),
			Pbindef(\counterpoint),
			],2)
		),
		////  Phrase C
		Pfindur(54,
        Ppar([
			Pbindef(\pads_2,
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
				)<>Pbindef(\pads_1),

			Pbindef(\harp_h),

			Pbindef(\harp_left,
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
			Pbindef(\pads_1),
			Pbindef(\pads_3,
						\instrument,\organ_donor,
						\dur, Prand([1, 3, 4, 4.5], inf)/Pseg([20,30,20],100,\lin,inf),
						\atk, 0.05,
						//\fb,0.1,//Pseg([1/100,0.75,1/100],100,\lin,inf),
						\rel, Pkey(\dur) + 0.05,
						\pan,-0.2,
						\cutoff,1000,
						//\hifreq, 400,
						\amp, 0.1 * Pseg([0.3,0.37,0.3],100,\lin,inf),
					)<>Pbindef(\pads_1),
			Pbindef(\harp_t_2,\coef,Pseg([0.1,0.6],54,\exp,inf))<>Pbindef(\harp_t),
			//Pbindef(\s),
			//Pbindef(\r,\instrument,\SOStom,\amp,0.1)
		],1)
		),
	],2),
		Pbind(\instrument,\harpsichord_pluck,
			\dur, 3/8,
			\midinote, Pseq([
				Pseq([48,52,57,60],1)+.x Pseq(#[0, 4, 7, 11],1) + -12,
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