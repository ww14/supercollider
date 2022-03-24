//load the setup file if you haven't already
("Setup/Setup.scd").loadRelative // load this file

// bird buffers
//we're overwriting the traditional buffer lib, main difference is that we use "" instead of \ to declare folders
(
~birds = PathName(thisProcess.nowExecutingPath).parentPath++"setup/birds/";
b = Dictionary.new;
b.add(\foldernames -> PathName("C:/Users/William Willoughby/Documents/SuperCollider/composition/setup/birds/").entries);
	for (0, b[\foldernames].size-1,
		{arg i; b.add(b[\foldernames][i].folderName -> b[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
)

b.values;

// http://sccode.org/1-5dl#c950

//must make events if i want to use that functionality
s.scope;
s.plotTree;

b["Woodpeckers"][4].duration;
b["Troupials"][0].duration- (100000/44100);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Test
t = TempoClock.new(60/60).permanent_(true);

(
~sn = Pbind(\instrument,\bplaym,\buf,b["Crows"][6],\amp,Pwhite(0,0.4),\pan,Pwhite(-1,1),\rate,Pwhite(0.5,2.5).round(0.25),\group, ~mainGrp,\out, ~bus[\reverb]);
~play1 = ~sn.play(t, quant:1);
)
~play1.pause;
~play1.play;

~play1.set(\gate,0)

(
~k = Pbind(\instrument,\bplaym,\buf,b["Hummingbirds"][0],\amp,0.02,\dur,0.5,\pan,Pwhite(-0.7,0.7),\rate,Pwhite(40,90).round(5),);
~k.play(t, quant:1);
)


(
~tr = Pbind(\instrument,\playsus,\buf,b["Woodpeckers"][4],\amp,Pwhite(0,0.2),\pan,Pwhite(-1,1),\rate,Pwhite(0.5,2.5).round(0.25),\group, ~mainGrp,\out, ~bus[\reverb]);
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
	\amp, 0.03,
);
~player = ~pat.play;
)

(
~pat = Pmono(
	\playsus,
	\dur, b["Troupials"][0].duration - (100000/44100),//Pexprand(0.01,1),
	\buf, b["Troupials"][0].bufnum,
	\spos, 10000,//Pwhite(0, b["Troupials"][0].numFrames-1, inf),
	\trig, 0, //try changing to zero to avoid jumping around
	\rel,0,
	//\rate, Pwhite(1,2),
	//\group, ~mainGrp,\out, ~bus[\reverb],
	\amp, 0.03,
);
~player = ~pat.play;
)



~player.stop;



//Play sample til it ends
(
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
x.play(s,[\buf, b["Woodpeckers"][3 ]]);

x.free; b.free;

~play1.stop;


Synth(\bufScratchFoldmono, [\bufnum, b["Troupials"][1],\amp,2]);

(
Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][2],\preAmp, 0.2,\foldMin,0,\foldRange, 10,\localFreq, 0.9,\localOscSize, 5e-2,\globalFreq, 2e-5,\smoothAmount, 1e-4,\amp,1]);
Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\preAmp, 0.2,\foldMin,-0.25,\foldRange, 20,\localFreq, 0.9,\localOscSize, 2e-1,\globalFreq, 2e-5,\smoothAmount, 1e-4,\amp,1]);
)

y = Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\preAmp, 0.2,\foldMin,-10,\foldRange, 1000,\localFreq, 9,\localOscSize, 0.09,\globalFreq, 0.2,\smoothAmount, 0.001,\amp,1]);

y = Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\foldMax,0.2,\foldRange,0.1,\preAmp,1]);
y = Synth(\bufScratchFoldmono, [bufnum: b["Woodpeckers"][4],\foldMin,0.19,\foldMax,0.2,\foldRange,75,\preAmp,30,\smoothAmount, 1e-10,]);



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//the piece itself
//not using formal events as there's only one synth
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






