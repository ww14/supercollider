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
    var pan, env, snd, sndVerb, freqdev, trig;
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
y.set(\out,~bus[\nhhall]);
y.set(\fredev,-1);
y.set(\amp,-40.dbamp);

y = Synth(\fm_grain, [\envbuf,z,\modfreq,330,\dur,4,\amp,-5.dbamp,\pan,-0.25]);

Buffer

//a = Synth.after(y,\wah,[\out,0]);
y.set(\envbuf,z);
y.set(\rel,2);
y.free;
y.set(\gate,0)
//dur range 2-6. base is 4


/////////////////////////////
//the piece




(
TempoClock.default.tempo_(65/60);
t = Task({
	//s.record;
	a;
	"start".postln;

	1.wait;
	x = Synth(\fm_grain, [\envbuf, b[\deskBells][8],\carfreq,220,\dur,1.9,\modfreq,440,\amp,0.dbamp]);

	24.wait;

	x.set(\lower,8,\upper,16);

	12.wait;
	x.set(\lower,1,\upper,3);

	12.wait;
	x.set(\lower,1,\upper,32);

	12.wait;
	x.set(\lower,1,\upper,128,\amp,4.dbamp);

	24.wait;
	x.set(\lower,1,\upper,2);

	4.wait;
	x.set(\gate, 0,\rel,8);

	18.wait;
	//s.stopRecording;
});
)

t.reset.play;
