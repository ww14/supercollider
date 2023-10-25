("Setup/Setup.scd").loadRelative // load this file


(
Pbindef(\bd,
	\instrument, \bd,
	\dur,1/32* Psubdivide(Pseq([1!8,3,1!8,4,1!14,8].flatten,inf),Pseq([2,Rest(1.5),0.5],inf)),
	\decay, 25,
	\tone, 65,
	\amp, 1,//Pseq([1, 0, 1.5, 1.5, 0,
		//1.5, 0, 1.5,
		//0, 1], inf).trace
);



Pbindef(\claves,
	\instrument, \ring3,
	\dur,1/8,
	\snappy, 0.1,
	\tone, 340,
	\amp, Pseq([1, 0, 1.5, 1.5, 0,
		1.5, 0, 1.5,
		0, 1], inf),
);
)


Pbindef(\claves).play;
Pbindef(\bd).play;