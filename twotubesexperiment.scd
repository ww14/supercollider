//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Misc


//water drops
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
q = Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0.2,
	\preamp,Pseq([1,2].mirror*10,inf),
	\amp,0.8,
	\maxRq,0.1,
	\minBpfHz,3,
	\maxBpfHz,4, //31
	//\pan,Pkey(\preamp).wrap(-0.4,0.4),
	\delay1,1,
	\delay2,2,
	\out,~bus,
);
q.play(quant:1)
)

//old school
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,1/20,//Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*1000,inf),
	\amp,0.4,
	\minRq,0.001,
	\maxRq,0.0015,
	\minBpfHz,1/300,
	\maxBpfHz,1/301, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,1,
	\delay2,2,
	\out,~bus,
).play(quant:1);
)

//detuned meander
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*250,inf),
	\amp,0.8,
	\minRq,0.005,
	\maxRq,0.0055,
	\minBpfHz,1/160,
	\maxBpfHz,1/150, //31
	\minCf,100,
	\maxCf,2000,
	\pan,0,
	\delay1,8,
	\delay2,16,
	\out,~bus,
).play(quant:1);
)

//mor detuned
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*10000,inf),
	\amp,0.4,
	\minRq,0.001,
	\maxRq,0.0015,
	\minBpfHz,1/300,
	\maxBpfHz,1/301, //31
	\minCf,1/200,
	\pan,0,
	\delay1,1,
	\delay2,2,
	\out,~bus,
).play(quant:1);
)


//bass drum
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
	\preamp,Prand([1,2],inf)*250,
	\amp,0.1,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,100,
	//\minCf,1000,
	\pan,0,
	\delay1,20,
	\delay2,Pseq([Pn([1],8),Pn([2],8)],inf)*[512,256], //perceived pitch lower when this higher
	\out,~bus,
).play(quant:1);
)

//synth lead, rq glitches out near 1.
(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*200,inf),
	\amp,0.4,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,Pwrand([10,1,20,40],[10,2,1,1].normalizeSum,inf),
	\delay2,Pwrand([2,10,20,40],[10,1,0.5,0.5].normalizeSum,inf),
	\out,~bus,
).play(quant:1);
)


(
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*200,inf),
	\amp,0.1,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,Pseq([Pn([10],32),Pn([20],64),Pn([2,1],16),Pn([40],64)].mirror1,inf),
	\delay2,Pseq([Pseq([2,10,20,40],176),Pseq([2,10,20,40],176)],inf),
	\out,~bus,
).play(quant:1);

//64+64+16+32

//a shuffling
//
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbind(\instrument, \twotube,
	\dur,Pn(Pshuf([1,1,1,2,2,2,6,6,6,12],3),inf)/256,//Pseg([200,500,200],10,\lin,inf),
	\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
	\preamp,Prand([1,2],inf)*250,
	\amp,0.0035,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,100,
	//\minCf,1000,
	\pan,0,
	\delay1,4,
	\delay2,Pseq([Pn([1],8),Pn([2],8)],inf)*[400,800], //perceived pitch lower when this higher
	\out,~bus,
).play(quant:1);
)