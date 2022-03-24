("Setup/Setup.scd").loadRelative // load this file

(
r = Routine.new({
	var i = 0, n = 0;

	~e = Pbind(\instrument,\sinfb, \freq, Pseq([45,40,43,40,45,40],inf).midicps, \iScale,0.1,\dur,Pseq([1],inf)/12,\atk,0.5,\rel,1,\amp,0.2,\pan,Pwhite(-0.7,0.7));

	~play_e = ~e.play(t, quant:1);

	1.wait;
	//~e.mute;

	~f = Pbind(\instrument,\bpfsaw, \freq, Pseq([[57,60,64],69,[57,52]],inf).midicps,\dur,Pseq([4,5],inf),\atk,1,\rel,8,\amp,0.09,\pan,Pwhite(-0.2,0.2));

	~play_f = ~f.play(t, quant:1);

	13.wait;

	(
		~play_e.pause;
		~e_2 = Pchain(Pbind(
			\dur,Pseq([1],inf)/100

		),~e);
		~play_e = ~e_2.play(t, quant:1);

	);

	~g = Pbind(\instrument,\sinfb, \freq, Pseq([57,60,64,69,57,52],inf).midicps, \iScale,0.1,\dur,Pseq([1],inf)/12,\atk,0.5,\rel,1,\amp,0.05,\pan,Pwhite(-0.7,0.7));

	~play_g = ~g.play(t, quant:1);

	12.wait;

	(
		~play_f.pause;
		~f_2 = Pchain(Pbind(
			\freq,Pseq([[57,60,64],45,[40,45,60]],inf).midicps,
			\cfhzmax,3,

		),~f);
		~play_f = ~f_2.play(t, quant:1);

	);
	~play_g.pause;

	//~f.pause;

	~h = Pbind(\instrument,\fm1, \freq, Pseq([45,36,40,33,38,40],inf).midicps, \iScale,0.1,\dur,Pseq([1,8]/8,inf),\atk,0.5,\rel,1,\amp,0.3,\pan,Pwhite(-0.7,0.7));

	~play_h = ~h.play(t, quant:1);

	20.wait;

	~play_h.stop;
	~play_g .play;

	10.wait;

}).play;
)

~f_2.play;

~e_2.play(t, quant:1);


~pat_e = Pbind(\instrument,\sinfb, \freq, Pseq([45,40,43,40,45,40],inf).midicps, \iScale,0.1,\dur,Pseq([1],inf)/12,\atk,0.5,\rel,1,\amp,0.2,\pan,Pwhite(-0.7,0.7));

~player1 = ~pat_e.play(t, quant:1);



(
~player1.pause;
~pat_e_1 = Pchain(Pbind(
	\freq,Pseq([100,150,200],inf).midicps,
),~pat_e);
~player1 = ~pat_e_1.play(t, quant:1);
)