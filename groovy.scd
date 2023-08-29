("Setup/Setup.scd").loadRelative // load this file

~bus = Bus.audio(s,2);

(Pbindef(\perc,
		\instrument,\SOSkick,// Pwrand([\tom,\brush],[0.1,0.9].normalizeSum,inf), // \brusselator
		\dur,0.125,
		\freq, Pwrand([40,45,49,52],[5,3,2,1].normalizeSum,inf).midicps,
		\mod_freq, Pwrand([50,75,100,1000],[10,2,1,0.5].normalizeSum,inf),
		\mod_index,2,
		//\dur, Prand(#[0.2, 0.5, 1.1, 0.25, 0.15], inf),
		//\tension,Prand([0.15,0.01,0.1],inf), //pitch
		//\timeScale,0.2,  //prevent clipping
		\amp,Plprand(0.25,1,inf),  // Plprand(2,3,inf)
		\out,~bus[\reverb],
);
)

t = TempoClock.default.tempo = 65 / 60;
Pbindef(\perc).play;

(
Pbindef(\perc,\dur,Psubdivide(
			Pseq([2!10,1!10,2!10,1,1,9,1,3].flat,inf),
			Pseq([0.25],inf)
)))


(
Pbindef(\perc,\dur,0.125,\mod_index,[2,12])
)

(
Pbindef(\perc,\dur,0.125,\mod_freq,45.midicps,\freq,52.midicps,\mod_index,6)
)