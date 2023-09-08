///////////////////////////////////////////////////////////////////////
//set up
Server.killAll;
("Setup/Setup.scd").loadRelative;

///grain synthef
(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain, {
    var pan, env, snd, freqdev, trig;
    // use mouse x to control panning
    //pan = MouseX.kr(-1, 1);
    //freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
	trig = Impulse.ar(LFDNoise3.kr(0.5).linexp(-1, 1, \lower.kr(1), \upper.kr(32)));
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
		\gate.kr(1),
        doneAction: Done.freeSelf);
	snd = GrainFM.ar(2,
		trig,
		\dur.kr(0.1),
		\carfreq.kr(440), // + freqdev,
		\modfreq.kr(220),
		LFNoise1.kr.range(1, 10),
		\pan.kr(0),
		\envbuf.kr(-1));
		snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	snd = snd * env;
		Out.ar(\out.kr(0),snd);
}).add;

)

/////////////////////////////////////////////
//testing

z
b = Synth(\fm_grain, [\envbuf, z,\modfreq,200]);
b.set(\modfreq,385,\dur,4,\amp,-40.dbamp); // A=220, B= 247, C=262 ,C#=275 , D=293, E=330, F#=370, G=196,385, G#=208,415,
b.set(\modfreq,);
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
	b = Synth(\fm_grain, [\envbuf, z,\modfreq,200]);
	b.set(\modfreq,330,\dur,4,\amp,-40.dbamp); // C=262 ,C#=277 , E=330, F#=370, G=196,392, G#=208,415, D=293

	16.wait;
	b.set(\modfreq,262);


	8.wait;
	b.set(\modfreq,196);
	x.set(\lower,8,\upper,16);


	8.wait;
	b.set(\modfreq,277);
	x.set(\lower,1,\upper,32);


	8.wait;
	b.set(\modfreq,196);
	x.set(\lower,1,\upper,3);

	4.wait;
	x.set(\out,~bus[\reverb2]);

	4.wait;
	b.set(\modfreq,330);
	x.set(\lower,1,\upper,32);












	x.set(\lower,20,\upper,24);

	x.set(\lower,128,\upper,1);


	x.set(\lower,1,\upper,1);


	x.set(\out,~bus[\reverb]);


	x.set(\gate, 0);

	108.wait;
	"fadeout and stop".postln;
	Pbindef(\impulse).stop;

	24.wait;
	"removeAll".postln;
	Pbindef(\harmony).stop;
	Pdef.removeAll;

	4.wait;
	//s.stopRecording;
});
)


t.play;