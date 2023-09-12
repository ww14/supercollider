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
	snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1).lag3(1));
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
	y = Synth(\fm_grain, [\envbuf, z,\modfreq,330,\dur,4,\amp,-45.dbamp]);

	16.wait;
	y.set(\modfreq,293,\amp,-44.dbamp);
	(
		Pbindef(\sinfb,
			\instrument, \sinfb,
			\midinote,[57,45,33],
			\dur,4,//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
			\rel,4,
			\fb,0.01,
			\iScale,1,
			\index,10,
			\atk,2,
			\cutoff,10,
			\amp,-38.dbamp
		);
		Pbindef(\sinfb).play;
	);


	12.wait;
	y.set(\modfreq,330,\amp,-43.dbamp);
	x.set(\lower,8,\upper,16);


	16.wait;
	y.set(\modfreq,262,\amp,-42.dbamp);
	x.set(\lower,1,\upper,32);


	16.wait;
	y.set(\modfreq,330,\amp,-41.dbamp);
	x.set(\lower,1,\upper,3);

	8.wait;
	"start reverb".postln;
	y.set(\modfreq,293,\amp,-42.dbamp);
	x.set(\out,~bus[\reverb2]);

	8.wait;
	y.set(\modfreq,330,\amp,-41.dbamp);
	x.set(\lower,1,\upper,32);
	Pbindef(\sinfb,\midinote,[69,57,45]);

	8.wait;
	y.set(\modfreq,262);
	x.set(\lower,20,\upper,24);

	8.wait;
	"low point".postln;
	y.set(\modfreq,275,\amp,-37.dbamp);
	x.set(\lower,128,\upper,1);
	Pbindef(\sinfb,\midinote,[57,45,33,21]);

	24.wait;
	y.set(\modfreq,330,\amp,-40.dbamp);
	x.set(\lower,1,\upper,1);

	16.wait;
	"sustain end".postln;
	y.set(\modfreq,220,\dur,8,\amp,-42.dbamp);
	x.set(\lower,1,\upper,32);
	x.set(\out,~bus[\reverb]);
	Pbindef(\sinfb,\midinote,[81,69,57,45,33,21]);

	24.wait;
	"start releasing".postln;
	x.set(\lower,1,\upper,1);
	4.wait;
	x.set(\gate, 0,\rel,8);
	Pbindef(\sinfb,\midinote,0,\rel,8);
	y.set(\gate,0,\rel,16);


	18.wait;
	//s.stopRecording;
});
)


t.play;