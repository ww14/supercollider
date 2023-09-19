Server.killAll;
("Setup/Setup.scd").loadRelative;


(
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

SynthDef(\fm_grain_test, {
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
		\modfreq.kr(200),
		LFNoise1.kr.range(1, 10),
		\pan.kr(0),
		\envbuf.kr(-1));
		snd = Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	snd = snd * env;
		Out.ar(\out.kr(0),snd);
}).add;

)



// use built-in env
x = Synth(\fm_grain_test, [\envbuf, b[\deskBells][8],\carfreq,100]);
x.set(\carfreq,220,\dur,1.9,\modfreq,440);
x.set(\lower,8,\upper,16);
x.set(\lower,1,\upper,3);
x.set(\out,~bus[\reverb2]);
x.set(\lower,1,\upper,32);
x.set(\lower,32,\upper,128);
x.set(\lower,128,\upper,1);
x.set(\lower,1,\upper,1);
x.set(\out,~bus[\reverb]);

x.set(\envbuf, -1);

x.set(\gate, 0);



(
Pbindef(\303,
	\instrument, \sinfb,
	\midinote,[57,45,33] + Pseq([0,4,2,0], inf),
	\dur,4,//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\rel,4,
	\fb,0.01,
	\iScale,1,
	\index,10,
	\atk,2,
	\cutoff,10,
	\amp,-30.dbamp
);
);
Pbindef(\303,\midinote,0,\rel,8).play