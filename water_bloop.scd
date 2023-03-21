
//helper function to have fadetimes over pbindefs
//sourece
//  https://scsynth.org/t/fadetime-with-pdef-and-pbindef/1464/4
//   https://scsynth.org/t/pbindef-fade-in-and-fade-out/1553/6

(
Server.killAll;
("Setup/Setup.scd").loadRelative; // load this file
//~fade = { |start, end, time, curve = 0| Pseg(Pseq([start, Pn(end)]), time, curve) };
)



//////////////////////////////////////////////////////////////////////////////////////////////////
////the patterns
//////////////////////////////////////////////////////////////////////////////////////////////////

(b = (
TempoClock.default.tempo = 60/60;

Pdef.removeAll;

//water drops
(
Pbindef(\water_drop,
	\instrument, \twotube2,
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
	\out,~bus[\reverb2],
));


//pure bloop
(
Pbindef(\olschool_full,
	\instrument, \twotube2,
	\dur,1/20,//Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0	,
	\preamp,Pseq([1,2].mirror*1000,inf),
	\amp,0,
	\minRq,0.001,
	\maxRq,0.0015,
	\minBpfHz,1/300,
	\maxBpfHz,1/301, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,7,
	\delay2,Pseg([2,20,2],60,\lin,inf),
	\out,~bus[\reverb],
));

//high-low bloop
(
Pbindef(\olschool_mel,
	\instrument, \twotube2,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/20,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*10000,inf),
	\amp,0,
	\minRq,0.001,
	\maxRq,0.0015,
	\minBpfHz,1/300,
	\maxBpfHz,1/301, //31
	\minCf,1/200,
	\pan,0,
	\delay1,1,
	\delay2,2,
	\out,~bus[\reverb],
));


//detuned meander chords
(
Pbindef(\olschool_clip,
	\instrument, \twotube2,
	\dur,Pn(Pshuf([1,2,Rest(1),1]/9,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*250,inf),
	\amp,0,
	\minRq,0.005,
	\maxRq,0.0055,
	\minBpfHz,1/160,
	\maxBpfHz,1/150, //31
	\minCf,100,
	\maxCf,2000,
	\pan,0,
	\delay1,8,
	\delay2,16,
	\out,~bus[\reverb],
)):

(
Pbindef(\guitar_clip,
	\instrument, \twotube2,
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
	\delay1,Pwrand([10,1,20,40],[10,2,1,1].normalizeSum,inf),
	\delay2,Pwrand([2,10,20,40],[10,1,0.5,0.5].normalizeSum,inf),
	\out,~bus[\reverb2],
));

(
Pbindef(\guitar_mel,
	\instrument, \twotube2,
	\dur,Pn(Pshuf([1,1,1,1,6,3,3,3,3,9]/12,3),inf),
	\k, 0,
	\preamp,Pseq([1,2].mirror*200,inf),
	\amp,0.005,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,1/2000,
	//\minCf,1/2001,
	\pan,0,
	\delay1,Pseq([Pn([10],32),Pn([20],64),Pn([2,1],16),Pn([40],64)].mirror1,inf),
	\delay2,Pseq([Pseq([2,10,20,40],176),Pseq(2*[2,10,20,40],176)],inf),
	\out,Pwrand([~bus[\reverb],~bus[\comb]],[0.9,0.1],inf),
));

Pbindef(\skiffle,
	\instrument, \twotube2,
	\dur,Pn(Pshuf([1,1,1,2,2,2,6,6,6,12],3),inf)/Pseg([200,500,200],50,\lin,inf),
	\k, Pseg([-0.2,0.2,-0.2],30,\step,inf),
	\preamp,Prand([1,2],inf)*250,
	\amp,0.0005,
	\minRq,0.9,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,2, //31
	//\minCf,100,
	//\minCf,1000,
	\pan,0,
	\delay1,4,
	\delay2,Pseq([Pn([1],8),Pn([2],8)],inf)*[400,800], //perceived pitch lower when this higher
	\out,~bus[\reverb2],
);
));



//////////////////////////testing
Pbindef(\olschool_full).play;
Pbindef(\olschool_full,\delay1,7, \delay2,Pseg([2,20,2],60,\lin,inf),\amp,0.4).play;


//////////////////////////////////////////////////////////////////////////////////////////////////
////the routine
//////////////////////////////////////////////////////////////////////////////////////////////////

(
t = TempoClock(60/60,4);
b;
r = Routine.new({

	Pbindef(\water_drop).play(t, quant:1);

	15.wait;

	Pbindef(\olschool_full, \amp, ~fade.(0.0, 0.3, 15,4)).play(t, quant:1);
	Pbindef(\water_drop, \amp, ~fade.(0.8, 0.0, 15));

	30.wait;

	Pbindef(\olschool_mel, \amp, Pseg([0,0.4,0],1,'lin',inf)).play(t, quant:1);

	30.wait;

	Pbindef(\guitar_clip, \amp, ~fade.(0.0, 0.1, 8,4)).play(t, quant:1);
	Pbindef(\olschool_full, \amp, ~fade.(0.3, 0.001, 30, -1));
	Pbindef(\olschool_mel, \amp, ~fade.(0.4,0,5,-1));

	30.wait;

	Pbindef(\guitar_mel, \amp, ~fade.(0.0, 0.05, 8, 4)).play(t, quant:1);
	Pbindef(\skiffle, \amp, ~fade.(0.0, 0.001, 15, 4)).play(t, quant:1);
	Pbindef(\guitar_clip, \amp, ~fade.(0.1, 0.0, 2, -1));

	90.wait;

	Pbindef(\guitar_mel, \amp, ~fade.(0.05, 0.0, 45));
	Pbindef(\skiffle, \amp, ~fade.(0.001, 0.0, 30));
	Pbindef(\olschool_full, \amp, ~fade.(0.001, 5, 30, 4));
	Pbindef(\water_drop, \amp, ~fade.(0.0, 10, 60, 4));

	30.wait;

	Pbindef(\olschool_full, \amp, ~fade.(5, 0, 30),\delay2,2);

	30.wait;

	Pbindef(\water_drop, \amp, ~fade.(10, 0, 20));

	10.wait;

}).play(t);
)

///////////////////////////////////////////////////////////////
