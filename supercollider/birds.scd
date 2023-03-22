//load the setup file if you haven't already
("Setup/Setup.scd").loadRelative // load this file

// bird buffers
//we're overwriting the traditional buffer lib, main difference is that we use "" instead of \ to declare folders
(
~birds = PathName(thisProcess.nowExecutingPath).parentPath++"setup/birds/";
b = Dictionary.new;
b.add(\foldernames -> PathName(~birds).entries);
for (0, b[\foldernames].size-1,
	{arg i; b.add(b[\foldernames][i].folderName -> b[\foldernames][i].entries.collect({
		arg sf;
		Buffer.read(s,sf.fullPath);
	});
)});
)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Patterns and Test

b.values;
b["Woodpeckers"][4].duration;
b["Troupials"][0].duration- (200000/44100);

(a = (
	Pdef.removeAll;

	Pdef(\crow,
		Pbind(\instrument,\bplaym,
			\buf,b["Crows"][6],
			\amp,Pwhite(0,0.4),
			\pan,Pwhite(-1,1),
			\rate,Pwhite(0.5,2.5).round(0.25),
			\out, ~bus[\reverb]));

	Pdef(\peck,
		Ppar([
		Pbind(\instrument,\playsus,
			\buf,b["Woodpeckers"][4],
			\dur,Psubdivide(
				Pseq([1!4,2!8,3,1,1,1,13,1].flat,inf),
					Pseq([2,Rest(1)],inf)
			),
			\amp,Pwhite(0.1,0.4),
			\pan,Pwhite(-0.2,0.2),
			\rate,Pwhite(0.5,2.5).round(0.25),
			\out, ~bus[\reverb]),
		Pbind(\instrument,\playsus,
			\buf,b["Woodpeckers"][4],
			\dur,Psubdivide(
				Pseq([1,3,1,13,1,1,1!4,2!8].flat,inf),
					Pseq([Rest(1),2],inf)
			),
			\amp,Pwhite(0.01,0.1),
				\pan,Pwrand([-0.9,0.9],[0.8,0.2],inf),//Pwhite(-0.2,0.2),
				\rate,Pwrand([5,0],[0.9,0.1],inf) + Pwhite(0.5,2.5).round(0.25),
			\out, ~bus[\comb])
	])
	);


	Pdef(\troupial_loop,Pmono(
		\playsus,
		//\dur, b["Troupials"][0].duration - (100000/44100),//Pexprand(0.01,1),
		\buf, b["Troupials"][0].bufnum,
		\spos, Pgauss(400000, 30000, inf),//Pwhite(0, b["Troupials"][0].numFrames-1, inf),
		\trig, 1, //try changing to zero to avoid jumping around
		\relcrv,-10,
		//\rate, Pwhite(1,2),
		//\group, ~mainGrp,\out, ~bus[\reverb],
		\amp, Pseg(Pseq([0, 0.3],inf),Pseq([5,55],inf), 2), //0.25, fade up for 5 then down from 0.4 to 0 over 55 secs
		\pan,0.5,
	));

	Pdef(\falcon_loop,Pmono(
		\playsus,
		\dur, Pexprand(0.01,1),
		\buf, b["Falcons"][0].bufnum,
		\spos, Pgauss(520000, 30000, inf),
		\trig, 1, //try changing to zero to avoid jumping around
		//\rate, Pwhite(0.95,1.05).round(0.05),
		//\group, ~mainGrp,\out, ~bus[\reverb],
		\pan,0.7,
		\amp, Pseg(Pseq([0, 0.3],inf),Pseq([3,17],inf), 2),
		\out,~bus[\comb])
	);



	Pdef(\vireo_warble,Pmono(
		\playsus,
		\buf, b["Vireos"][0].bufnum,
		\spos, Pwhite(0, b["Vireos"][0].numFrames-1, inf),
		\trig, 0, //try changing to zero to avoid jumping around
		\rate, Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,0.1,2),3),inf),//Pwhite(0.95,1.05).round(0.05),
		//\group, ~mainGrp,\out, ~bus[\reverb],
		\amp, Pseg(Pseq([0, Pn(0.3)]), 4, 2),
		\pan,-0.4,
		\out,~bus[\comb]
	));

	Pdef(\hum_perc,
		Pbind(\instrument,\bplaym,
			\buf,b["Hummingbirds"][0],
			\amp,Pseg(Pseq([0, 0.2],inf),Pseq([5,55],inf), 2),
			\dur,0.5,
			\pan,Pwhite(0.2,0.5),
			\rate,Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,10,30),3),inf),
			\out, ~bus[\comb]));

	Pdef(\hum_perc_down,
		Pbind(\instrument,\playsus,
			\buf,b["Hummingbirds"][0],
			\dur, Pmeanrand(0,1,inf).round(0.1),
			\amp,Phprand(0,1),
			\pan,Pwhite(0.2,0.5),
			\rate,Pwhite(0.5,2.5).round(0.25),
			\out, ~bus[\comb]));

	//this wigs out if i break it across mul lines, w/e
	l = Task{{var buf_rand;buf_rand = ([b["Tits"][0],b["Hummingbirds"][0],b["Troupials"][0],b["Vireos"][0],b["Crows"][0],b["Falcons"][0],b["Woodpeckers"][3]].choose);buf_rand.duration.value;		Synth(\PlayBuf,[\buf, buf_rand,\pan,1.0.sum3rand,\out,[0,~bus[\reverb],~bus[\comb]].wchoose([0.87,0.1,0.03])]);(buf_rand.duration - 1.0 ).wait;}.loop};

))

Pdef(\crow).play;
Pdef(\hum_perc).play;
Pdef(\hum_perc_down).play;
Pdef(\peck).play;
Pdef(\falcon_loop).play;
Pdef(\troupial_loop).play;
Pdef(\vireo_warble).play;

Synth(\playsus,[\buf, b["Tits"][0],\loop,0,\atk,5,\atkcrv,2,\rel,5,\relcrv,-2]);  // 25 y
Synth(\playsus,[\buf, b["Hummingbirds"][0]]); //25 y
Synth(\playsus,[\buf, b["Troupials"][0]]); //30
Synth(\playsus,[\buf, b["Vireos"][0]]); //30
Synth(\playsus,[\buf, b["Crows"][0]]); // 34 y


b["Tits"][0].plot; //25 y
b["Hummingbirds"][0].plot; //25 y
b["Troupials"][0].plot; //20
b["Vireos"][0].plot; //30
b["Crows"][0].plot; //34  y
b["Falcons"][0].plot; // 23
b["Woodpeckers"][3].duration; //24

(
	Pdef(\peckish,
		Pbind(\instrument,\playsus,
			\buf,b["Woodpeckers"][4],
			\dur,Psubdivide(
				Pseq([1,3,1,13,1,1,1!4,2!8].flat,inf),
		Pseq([Rest(1),1],inf)
			),
			\amp,Pwhite(0.1,0.2),
			\pan,Pwhite(-0.2,0.2),
			\rate,2 + Pwhite(0.5,2.5).round(0.25),
			\out, ~bus[\comb])).play;
)

l.play;
l.pause;
m.play;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//the piece itself


(

StageLimiter.activate;
t = TempoClock.default.tempo_(60/60);

a;

Pspawner({|sp|


	sp.par( Pfindur(60, Pdef(\crow)));


	sp.wait(20);

	Synth(\playsus,[\buf, b["Tits"][0],\out,~bus[\reverb],\amp,0.1,\pan,-0.4,\loop,0,\atk,5,\atkcrv,2,\rel,5,\relcrv,-2]);// 25 tit

	sp.wait(20);

	Synth(\playsus,[\buf, b["Hummingbirds"][0],\out,~bus[\reverb],\amp,0.3,\pan,0.4,\loop,0,\atk,5,\atkcrv,2,\rel,5,\relcrv,-2]); //25 hummingbird

	sp.wait(10);

	sp.par( Pfindur(45, Pdef(\peck)));

	sp.wait(15);

	Synth(\playsus,[\buf, b["Crows"][0],\out,~bus[\reverb],\amp,0.3,\pan,-0.4,\loop,0,\atk,5,\atkcrv,2,\rel,5,\relcrv,-2]); //34 crow

	sp.wait(20); //20

	sp.par( Pfindur(60, Pdef(\troupial_loop)));

	sp.wait(10);

	Synth(\playsus,[\buf, b["Vireos"][0],\out,~bus[\reverb],\amp,0.2,\pan,-0.4,\loop,0,\atk,5,\atkcrv,2,\rel,5,\relcrv,-2]); //30 vireo

	sp.wait(20);

	sp.par( Pfindur(20, Pdef(\falcon_loop)));

	sp.wait(20);

	sp.par( Pfindur(80, Pdef(\vireo_warble)));

	sp.wait(10);

	Synth(\playsus,[\buf, ["Troupials"][0],\out,~bus[\reverb],\amp,0.1,\pan,0.4,\loop,0,\atk,5,\atkcrv,2,\rel,5,\relcrv,-2]); //30 troupial

	sp.wait(20);

	//sp.par( Pfindur(40, Pdef(\hum_perc_down)));

	sp.wait(15);

	sp.par( Pfindur(45, Pdef(\peck)));

	sp.wait(15);

	sp.par( Pfindur(20, Pdef(\falcon_loop)));

	sp.wait(10);

	sp.par( Pfindur(60, Pdef(\hum_perc)));

	sp.wait(30);

	sp.par( Pfindur(45, Pdef(\crow)));

}).play(t, quant:1);
)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(
/*s.prepareForRecord;
s.record;*/


t = TempoClock(60/60);
{
	(
		~k = Pbind(\instrument,\bplaym,\buf,b["Hummingbirds"][0],\amp,0.02,\dur,Pwrand([0.5,0.25,0.125],[5,2,1].normalizeSum,inf),\pan,Pwhite(-0.7,0.7),\rate,Pwhite(40,90).round(5),\out,~bus[\comb]);
		~k.play(t, quant:1);
	);
	10.wait;
	(
		~sn = Pbind(\instrument,\bplaym,\buf,b["Crows"][6],\amp,Pwhite(0,0.4),\pan,Pwhite(-1,1),\rate,Pwhite(0.5,2.5).round(0.25),\group, ~mainGrp,\out, ~bus[\reverb]);
		~play1 = ~sn.play(t, quant:1);
	);

	10.wait;
	/*
	x.play(s,[\buf, b["Tits"][0],\amp,0.15]);

	20.wait;

	x.play(s,[\buf, b["Hummingbirds"][0]]);

	20.wait;

	x.play(s,[\buf, b["Troupials"][0]]);

	10.wait;

	x.play(s,[\buf, b["Vireos"][0]]);

	30.wait;

	x.play(s,[\buf, b["Crows"][0]]);

	20.wait;

	x.play(s,[\buf, b["Falcons"][0]]);

	30.wait;

	x.play(s,[\buf, b["Woodpeckers"][3]]);

	10.wait; */
	(
		~sn_1 = Pbind(\amp, 0.01) <> ~sn;
		~play1.pause;
		~play1 = ~sn_1.play(t, quant:1);
		~tr = Pbind(\instrument,\playsus,\buf,b["Woodpeckers"][3],\amp,Pwhite(0,0.2),\pan,Pwhite(-1,1),\rate,Pwhite(0.5,2.5).round(0.25),\group, ~mainGrp,\out, ~bus[\reverb]);
		~play3 = ~tr.play(t, quant:1);

	);


	10.wait;
	//vulture
	10.wait;

	5.wait;

	5.wait;

	10.wait;

	20.wait;

	15.wait;

	5.wait;

	10.wait;

	15.wait;

	5.wait;

	15.wait;

	15.wait;

	10.wait;

	30.wait;

	5.wait;

	10.wait;

	5.wait;

	10.wait;

	10.wait;

	45.wait;
	~chug.stop;
	//s.stopRecording;
	//Pdefn(\cm,Pgeom(150000,0.9,inf)); //back off,
	//Pdefn(\cm,150); //close it down
	// Pdefn(\m,Pseq([45,[45,70,48],49,[45,59,48],59],inf)); //completely different territory
}.fork(t);
)



/*(
~k = Pbind(\instrument,\bplaym,\buf,b["Hummingbirds"][0],\amp,0.2,\dur,0.5,\pan,Pwhite(-0.5,-0.2),\rate,Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,10,30),3),inf),\out, ~bus[\comb]);
~k.play(t, quant:1);
)


(
~k = Pbind(\instrument,\bplaym,\buf,b["Hummingbirds"][0],\amp,0.2,\dur,0.5,\pan,Pwhite(-0.5,-0.2),\rate,Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,0.1,2),3),inf),\out, ~bus[\comb]);
~k.play(t, quant:1);
)


(
~tr = Pbind(\instrument,\playsus,\buf,b["Woodpeckers"][4],\amp,Pwhite(0,0.2),\pan,Pwhite(0.2,0.5),\rate,Pwhite(0.5,2.5).round(0.25),\group, ~mainGrp,\out, ~bus[\reverb]);
~play3 = ~tr.play(t, quant:1);
)


//for an intense background drone
(
~pat = Pmono(
\playsus,
\dur, Pexprand(0.01,1),
\buf, b["Woodpeckers"][4].bufnum,
\spos, Pwhite(0, b["Woodpeckers"][4].numFrames-1, inf),
\trig, 0, //try changing to zero to avoid jumping around
\rate, Pwhite(89.5,90.0).midiratio,
//\group, ~mainGrp,\out, ~bus[\reverb],
\amp, 0.3,
);
~player = ~pat.play;
)


(
~pat = Pmono(
\playsus,
\dur, Pexprand(0.01,1),
\buf, b["Falcons"][0].bufnum,
\spos, Pwhite(0, b["Falcons"][0].numFrames-1, inf),
\trig, 0, //try changing to zero to avoid jumping around
//\rate, Pwhite(0.95,1.05).round(0.05),
//\group, ~mainGrp,\out, ~bus[\reverb],
\amp, 0.3,
\out,~bus[\comb]
);
~player = ~pat.play;
)



(
~pat = Pmono(
\playsus,
//\dur, b["Troupials"][0].duration - (100000/44100),//Pexprand(0.01,1),
\buf, b["Troupials"][0].bufnum,
\spos, 10000,//Pwhite(0, b["Troupials"][0].numFrames-1, inf),
\trig, 0, //try changing to zero to avoid jumping around
\relcrv,-10,
//\rate, Pwhite(1,2),
//\group, ~mainGrp,\out, ~bus[\reverb],
\amp, 0.3,
);
~player = ~pat.play;
)


(
~pat = Pmono(
\playsus,
\buf, b["Vireos"][0].bufnum,
\spos, Pwhite(0, b["Vireos"][0].numFrames-1, inf),
\trig, 0, //try changing to zero to avoid jumping around
\rate, Pn(Pshuf([23,35,47,50,52,59,61,63,64].midicps.linlin(0,1000,0.1,2),3),inf),//Pwhite(0.95,1.05).round(0.05),
//\group, ~mainGrp,\out, ~bus[\reverb],
\amp, 0.3,
\out,~bus[\comb]
);
~player = ~pat.play;
)


~player.stop;*/



//Play sample til it ends
/*(
x = SynthDef("PlayBuf",{
arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.0, sus=1, rel= 0, pos=0;
var sig;
sig = Pan2.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2),pan);
sig = sig * amp;
Out.ar(out,sig)
});
)
x.play(s,[\buf, b["Tits"][0],\amp,0.15]);
x.play(s,[\buf, b["Hummingbirds"][0]]);
x.play(s,[\buf, b["Troupials"][0]]);
x.play(s,[\buf, b["Vireos"][0]]);
x.play(s,[\buf, b["Crows"][0]]);
x.play(s,[\buf, b["Falcons"][0]]);
x.play(s,[\buf, b["Woodpeckers"][3]]);

x.free; b.free;

~play1.stop;*/

//
// Synth(\bufScratchFoldmono, [\bufnum, b["Troupials"][1],\amp,2]);
//
// (
// Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][2],\preAmp, 0.2,\foldMin,0,\foldRange, 10,\localFreq, 0.9,\localOscSize, 5e-2,\globalFreq, 2e-5,\smoothAmount, 1e-4,\amp,1]);
// Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\preAmp, 0.2,\foldMin,-0.25,\foldRange, 20,\localFreq, 0.9,\localOscSize, 2e-1,\globalFreq, 2e-5,\smoothAmount, 1e-4,\amp,1]);
// )
//
// y = Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\preAmp, 0.2,\foldMin,-10,\foldRange, 1000,\localFreq, 9,\localOscSize, 0.09,\globalFreq, 0.2,\smoothAmount, 0.001,\amp,1]);
//
// y = Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\foldMax,0.2,\foldRange,0.1,\preAmp,1]);
// y = Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\foldMin,0.19,\foldMax,0.2,\foldRange,75,\preAmp,30,\smoothAmount, 1e-10,]);



