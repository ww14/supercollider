Server.killAll
("Setup/Setup.scd").loadRelative // load this file



(
k = Prewrite(1, // start with 1
        (    1: [0.25,2,0.25,2],
            0.25: [3,3,2]/4,
		3/4: [0.25,1,0.125,0.125],
		0.5: [1,1,1,1,1,1]/8
        ), 64);
);


(
l = Prewrite(0.25,
    (
        0.25: #[0.25,0.25,0.50,0.25,0.25,0.5],
        0.5: #[0.5,0.25,0.25,0.50,0.25,0.25,1],
        0.125: #[0.375,0.125],
        //0.375: #[0.375,0.375,1],
        1: #[0.75,0.25,0.125,0.125,0.125,0.125],
        0.75: #[8]
),64);
);

t= TempoClock.default.tempo = 100/60;

(
//Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbindef(\two_bass,
	\instrument, \twotube2,
	\dur,k,//Pseq([9,Pn(Pshuf([1,1,1,4,6,3,3,3,3,9]/12,3),inf)],1),
	\k, -0.7 + Pseg([-0.1,0.1,-0.1],30,\step,inf),
	\preamp,Prand([1,2],inf)*50,
	\amp,0.1,
	\minRq,0.8,
	\maxRq,0.91,
	\minBpfHz,1,
	\maxBpfHz,1.1, //31
	\minCf,100,
	\maxCf,2000,
	\pan,0,
	\delay1,1,
	\delay2,Pwrand([Pn([1],8),Pn([2],8),Pn([0.5],8),Pn([8],4),Pn([0.1],4)],[10,5,1,0.5,0.5].normalizeSum,inf)*Pwrand([[40,45],[45,52],[45,57]],[3,2,1].normalizeSum,inf).midicps, //*[512,256], //perceived pitch lower when this higher
	\out,Pwrand([~bus[\reverb],~bus[\comb]],[0.7,0.3],inf),
);
Pbindef(\two_bass).play(t, quant:1);
)

// two approaches to same effect

// (1)-- call fadeTime
Pbindef(\two_bass).fadeTime = 10;
//switching between the two
Pbindef(\two_bass, \dur, l);
Pbindef(\two_bass, \dur, k*l);
Pbindef(\two_bass, \dur, l);

// (2) or call the fade function
Pbindef(\two_bass, \dur, ~fade.(k, l, 15));
Pbindef(\two_bass, \dur, ~fade.(l,k,20));


(Pbindef(\two_bass, \amp, ~fade.(0.1,0,20));
Pbindef(\two_bass, \delay1, ~fade.(1,500,20));)





/////////////////////////////////////////////////



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
Pbindef(\olschool_clip).play(quant:1);
Pbindef(\olschool_clip, \amp, ~fade.(0.0, 0.8, 15));
)
Pbindef(\olschool_clip, \amp,0.8,\minCf,90,\maxCf,Pwrand([91,900],[0.8,0.2],inf),\delay1,180,\delay2,360,\dur,k/2);
Pbindef(\olschool_clip, \amp, 0);




