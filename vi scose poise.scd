///////////////////////////////////////////////////////////////////////
//set up
Server.killAll;
("Setup/Setup.scd").loadRelative;

///grain synthef
(
var winenv;
// a custom envelope
winenv = Env([0, 0.5,1, 0], [0.25, 0.5,0.5], [8,2,-8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain, {
    var pan, env, snd, freqdev, trig;
    // use mouse x to control panning
    //pan = MouseX.kr(-1, 1);
    //freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, \lower.kr(1), \upper.kr(32)));
    env = EnvGen.kr(
		Env([0, 1, 0], [1, \rel.kr(1)], \welch, 1),
		\gate.kr(1),
        doneAction: Done.freeSelf);
	snd = GrainFM.ar(2,
		trig,
		\dur.kr(0.1),
		\carfreq.kr(440),
		\modfreq.kr(220) + \freqdev.kr(0),
		LFNoise1.kr.range(1, 10),
		\pan.kr(0),
		\envbuf.kr(-1));
	snd = Pan2.ar(snd,\pan.kr(0).lag3(1),\amp.kr(1).lag3(1));
	snd = snd * env;
		Out.ar(\out.kr(0),snd);
}).add;

)



/////////////////////////////////////////////
//testing

z
y = Synth(\fm_grain, [\envbuf, -1,\modfreq,200]);
y.set(\modfreq,330,\dur,4,\amp,-40.dbamp,\carfreq,220); // A=220, B= 247, C=262 ,C#=275 , D=293, E=330, F#=370, G=196,385, G#=208,415,
y.set(\fredev,-1);
y.set(\amp,-40.dbamp);

//a = Synth.after(y,\wah,[\out,0]);
y.set(\envbuf,z);
y.set(\rel,2);
y.free;
y.set(\gate,0)
//dur range 2-6. base is 4

// use built-in env
x = Synth(\fm_grain, [\envbuf, b[\deskBells][8],\carfreq,220,\dur,1.9,\modfreq,440]);
x.set(\lower,8,\upper,16);
x.set(\lower,1,\upper,3);
x.set(\out,~bus[\reverb2]);
x.set(\lower,1,\upper,32);
x.set(\lower,20,\upper,24);
x.set(\lower,128,\upper,1);
x.set(\lower,1,\upper,1);
x.set(\out,~bus[\reverb]);

x.set(\envbuf, -1);
x.set(\gate, 0);




/////////////////////////////////////////////////////////////
// define some patterns

(
//Pdef.removeAll;
Pbindef(\harmony,
	\instrument, \sinfb,
	\midinote,[57,45,33],
	\dur,4,//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\atk,2,
	\rel,4,
	\fb,0.3,
	\pan,0.25,
	\amp,-41.dbamp
);



Pbindef(\background,
	\instrument, \fm1, //fm5
	\degree, Pseq([0,Pbrown(0, Scale.minorPentatonic.size,  Scale.minorPentatonic.size)],1),
	\scale, Scale.minorPentatonic,
	\root, -3,// semitones relative to 60.midicps, so this is A
	\octave, Pwrand(
		[5,4],
		[4,1].normalizeSum,
		inf
	),
	\index,0.1,
	\iScale,1,
	\mRatio,1,
	\cRatio,1,
	\dur,1/32,//Pwrand([8,16],[0.75,0.25],inf),
	//\legato,0.0,
	\atk,0.25,
	\rel,0.1,
	\cAtk,4,
	\cRel,-16,
	\rq,0.2,
	\pan, 0.4,
	//\sus,0.00,
	\amp, -50.dbamp,//-58.dbamp,
	\out,0
);
)

Pbindef(\background).play;
Pbindef(\background,\rel,8,\amp,Pseg(Pseq([-55.dbamp, Pn(0)]), 12));



/////////////////////////////////////////////////////////////////////////////////////
//the routine


(
s.prepareForRecord;
s.scope;
s.plotTree;
s.meter;
)


(
TempoClock.default.tempo_(60/60);
t = Task({
	//s.record;
	"start".postln;
	1.wait;
	x = Synth(\fm_grain, [\envbuf, b[\deskBells][8],\carfreq,220,\dur,1.9,\modfreq,440]);

	24.wait;
	y = Synth(\fm_grain, [\envbuf, z,\modfreq,330,\dur,4,\amp,-45.dbamp,\pan,-0.25]);

	16.wait;
	y.set(\modfreq,293,\amp,-44.dbamp,\pan,-0.2);
	Pbindef(\harmony).play;


	12.wait;
	y.set(\modfreq,330,\amp,-43.dbamp,\pan,-0.15);
	x.set(\lower,8,\upper,16);
	Pbindef(\harmony,\pan,0.2);
	Pbindef(\background).play;


	16.wait;
	y.set(\modfreq,262,\amp,-42.dbamp,\pan,-0.1);
	x.set(\lower,1,\upper,32);
	Pbindef(\harmony,\pan,0.1);

	16.wait;
	y.set(\modfreq,330,\amp,-41.dbamp,\pan,-0.05);
	x.set(\lower,1,\upper,3);
	Pbindef(\harmony,\pan,0.05);

	8.wait;
	"pan about to cross over".postln;
	y.set(\modfreq,293,\amp,-42.dbamp,\pan,0.05);
	Pbindef(\harmony,\pan,-0.05);

	8.wait;
	y.set(\modfreq,330,\amp,-41.dbamp,\pan,0.1);
	x.set(\lower,1,\upper,32);
	Pbindef(\sinfb,\midinote,[69,57,45]);
	Pbindef(\harmony,\pan,-0.1);

	8.wait;
	y.set(\modfreq,262,\pan,0.15);
	x.set(\lower,20,\upper,24);
	Pbindef(\harmony,\pan,-0.15);

	8.wait;
	"low point".postln;
	y.set(\modfreq,275,\amp,-37.dbamp,\pan,0.25);
	x.set(\lower,128,\upper,1);
	Pbindef(\harmony,\midinote,[57,45,33,21]);
	Pbindef(\harmony,\pan,-0.25);

	24.wait;
	"start reverb on perc".postln;
	y.set(\modfreq,330,\amp,-40.dbamp,\pan,-0.25);
	x.set(\out,~bus[\reverb2]);
	x.set(\lower,1,\upper,1);
	Pbindef(\harmony,\pan,0.25);

	16.wait;
	"sustain end".postln;
	y.set(\modfreq,220,\dur,8,\amp,-43.dbamp);
	x.set(\lower,1,\upper,32);
	x.set(\out,~bus[\reverb]);
	Pbindef(\harmony,\midinote,[81,69,57,45,33,21]);


	24.wait;
	"start releasing".postln;
	x.set(\lower,1,\upper,1);
	Pbindef(\background,\rel,1,\amp,Pseg(Pseq([-50.dbamp, Pn(0)]), 12));
	4.wait;
	x.set(\gate, 0,\rel,8);
	Pbindef(\background,\rel,4);
	Pbindef(\harmony,\midinote,0,\rel,8);
	y.set(\gate,0,\rel,16);


	18.wait;
	//s.stopRecording;
});
)


t.play;