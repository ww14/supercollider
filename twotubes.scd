Server.killAll
("Setup/Setup.scd").loadRelative // load this file


/////////////////////rhythm
(
(
l = Prewrite(0.25,
    (
        0.25: #[0.25,0.25,0.25,0.25,0.5],
        0.5: #[0.125,0.5,0.125,0.125,0.125],
        0.125: #[0.375,0.125],
        //0.375: #[0.375,0.375,1],
        1: #[0.75,0.25],
        0.75: #[8]
),64);
);

(
k = Prewrite(1, // start with 1
        (    1: [0.25,2,0.25,2],
            0.25: [3,3,2]/4,
		3/4: [0.25,1,0.125,0.125],
		0.5: [1,1,1,1,1,1]/8
        ), 4);
);

j = [1, 0.7, 1, 0.25]
)



///////////////////main pbind//////////////////////////////////////////////////////////////

(~d = Pbind(\instrument, \twotubes,
	\dur, 1/Prand([32,64],inf),
	\k, -0.001, // -0.001
	\loss,0.1, //0.1
	\rand,Pwhite(-4,4,inf),
	\out,~bus[\reverb],
	\amp,1,
);)

~d.play;

//////////////////////old/////////////////////////////////////////////////////////
(
~q_d = Pseq([
	Pseq([~d],1),
	Pseq([Pbindf(~d, \dur,k/2,\k,-0.1,\rand,Pwhite(-40,40,24).round(10))],1),
	Pseq([Pbindf(~d, \dur,l/2,\k, 0.5, \rand,Pwhite(0,1000,48).round(100))],2),
	Pseq([Pbindf(~d, \dur,k/2,\k, 1.1)], 1),
	Pseq([Pbindf(~d, \dur,l/2,\k, 0.5,\freq, Pwrand([[55,80],110,220,440],[20,10,2,2].normalizeSum, inf), \rand,Pwhite(0,1000,48).round(100))],2),
	Pseq([Pbindf(~d, \dur,k/2,\k,-0.5,\rand,Pwhite(-10,10000,48).round(10),)], 1),
	Pseq([Pbindf(~d, \dur,l/2,\k,-0.5)], 1),
]);
~r_d = Psetp(\loss, Pseq([0.5,0.999,1.1], 1), ~q_d);
~d_play= ~r_d.play;
	);



x = Synth("twotubes",[\dur,20,\k, 0.9999999,\loss, 0.9999999,\freq,220,\out,~bus[\reverb]]);
x.set(\dur,20,\k, -0.9999999,\loss, 0,\freq,440,\out,~bus[\reverb]);
x.set(\dur,20,\k, -0.9999999,\loss, -1,\freq,2200,\out,~bus[\reverb]);


///////////////////////////////////////////////////////////////////////////////////
////////////////////////composition////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

(
t = TempoClock(60/60,4);
r = Routine.new({
	//var i = 0, n = 0, b=4;

	//~d_play = ~d.play(t, quant:0);

	(~d_a = Pchain(Pbind(
		\amp,0.01,
	)
	,~d);
	~d_a_play = ~d_a.play(t, quant:0);
	);

	3.wait;

	~d_a_play.mute;

	(~d_k = Pchain(Pbind(
	 	\dur, k/2,
	 	\k,Pdefn(\kut,-0.9 ),
	 	\loss, Pdefn(\lost,1.1),
	 	\rand, Pdefn(\rant, Pwhite(-40,40,inf).round(10)),
	 	)
	 	,~d);
		~d_k_play = ~d_k.play(t, quant:0);
	 );

	 24.wait;

	Pdefn(\kut,-0.5);
	 Pdefn(\rant,Pwhite(-10,10000,inf).round(10));
	 Pdefn(\lost,0.99);

	 30.wait;

	Pdefn(\kut,2);
	 Pdefn(\lost,0.3);
	 Pdefn(\rant,Pwhite(-40,40,inf).round(10));


	 20.wait;

	 ~d_a_play.unmute;

	 6.wait;

	 ~d_k_play.mute;

		(~d_l = Pchain(Pbind(
		\dur,Pdefn(\durt, l/2.5),
		\k,Pdefn(\kut,0.5),
		\loss, Pdefn(\lost,0.99),
		\rand, Pdefn(\rant,Pwhite(0,1000,inf).round(100)),
	//\freq,Pdefn(\fret,360),
	)
	,~d);
	~d_l_play = ~d_l.play(t, quant:0);

	);

	12.wait;

	Pdefn(\kut, 2);
	Pdefn(\rant,Pwhite(-40,40,inf).round(10));

	12.wait;

	Pdefn(\kut, -0.5);
	Pdefn(\rant,Pwhite(0,1000,inf).round(100));

	12.wait;

	~d_l_play.mute;
	~d_a_play.mute;

	(~d_l_f = Pchain(Pbind(
		\dur,Pdefn(\durt, l*l),
		\k,Pdefn(\kut,0.5),
		\loss, Pdefn(\lost,0.99),
		\rand, Pdefn(\rant,Pwhite(0,1000,inf).round(100)),
	\freq,Pdefn(\fret,Pwrand([220,440,880,[1760,3000]],[20,10,2,1].normalizeSum, inf)),
	)
	,~d);
	~d_l_f_play = ~d_l_f.play(t, quant:0);

	);

	12.wait;


	Pdefn(\kut,-0.99999);
	Pdefn(\rant,Pwhite(-40,40,inf).round(10));
	Pdefn(\lost,1.1);

	12.wait;

	Pdefn(\kut,0.1);
	Pdefn(\rant,Pwhite(0,1000,inf).round(100));
	Pdefn(\lost,1);

	12.wait;

	Pdefn(\rant,Pwhite(-40,40,inf).round(10));
	Pdefn(\kut,0.99999);
	Pdefn(\lost,0.999);
	Pdefn(\durt,l*Pwrand([1/3,3],[30,1].normalizeSum,inf));

	12.wait;

	~d_a_play.unmute;

	12.wait;

	Pdefn(\durt,l*Pwrand([1/3,20],[200,1].normalizeSum,inf));

	24.wait;

	~d_a_play.mute;

	Pdefn(\kut,0.999);
	Pdefn(\rant,Pwhite(0,1000,inf).round(100));

	24.wait;

	Pdefn(\rant,Pwhite(-40,40,inf).round(10));

	60.wait;

	~d_l_f_play.mute;

	Synth("twotubes",[\dur,20,\k, 0.9999999,\loss, 0.9999999,\freq,220,\out,~bus[\reverb]]);

	5.wait;

	~d_a_play.unmute;

	5.wait;

	Synth("twotubes",[\dur,20,\k, -0.9999999,\loss, 0,\freq,440,\out,~bus[\reverb]]);

	10.wait;

	~d_a_play.mute;
	Synth("twotubes",[\dur,20,\k, -0.9999999,\loss, 1,\freq,110,\out,~bus[\reverb]]);
}).play;
)


