///////////////////////////////////////////////////////////////////////
//set up
Server.killAll;
("Setup/Setup.scd").loadRelative;

Synth(\kick,[\pan,0]);

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
	snd = HPF.ar(snd, 40);
	snd = LeakDC.ar(snd);
	snd = Pan2.ar(snd,\pan.kr(0).lag3(1),\amp.kr(1).lag3(0.75));
	snd = snd * env;
		Out.ar(\out.kr(0),snd);
}).add;
)

/*



~bus.add(\nhhall -> Bus.audio(s,2));
~nhhall = Group.after(~combGrp);


~nhhallSynth = Synth.new(
			\nhhall,
			[
				\in, ~bus[\nhhall], //call in audio from the reverb bus
				\out, ~out,
			],
			~nhhall //make the synths target the newly created reverb group
		);


)
*/

(/*
~sndBus.free;
~verbBus.free;
~sndBus = Bus.audio(s,2); // Bus Microfono
~verbBus = Bus.audio(s,2); // Bus Delay
~micGrp = Group.new;            // Gruppo sources
~fxGrp  = Group.after(~micGrp); // Gruppo elaborazioni

s = Synth(\splay_verb, [\inBus,~sndBus, \outBus,~verbBus, \fadeT, 0.5], ~micGrp, \addToTail);
*/

)


/////////////////////////////////////////////
//testing

z
y = Synth(\fm_grain, [\envbuf, -1,\modfreq,220]);
y.set(\modfreq,330,\dur,4,\amp,-40.dbamp,\carfreq,220); // A=220, B= 247, C=262 ,C#=275 , D=293, E=330, F#=370, G=196,385, G#=208,415,
y.set(\out,~bus[\nhhall]);
y.set(\fredev,-1);
y.set(\amp,-40.dbamp);
y.set(\carfreq,1760);
y.set(\modfreq,275,\carfreq,440,\amp,-35.dbamp,\pan,0.25);
y.set(\modfreq,293,\carfreq,440,\amp,-35.dbamp,\pan,0.25);
y.set(\modfreq,220,\carfreq,110,\amp,-35.dbamp,\pan,0.25);
y.set(\modfreq,262,\carfreq,88,\amp,-35.dbamp,\pan,0.25);

y = Synth(\fm_grain, [\envbuf, z,\modfreq,330,\dur,4,\amp,-45.dbamp,\pan,-0.25]);


//a = Synth.after(y,\wah,[\out,0]);
y.set(\envbuf,z);
y.set(\rel,2);
y.free;
y.set(\gate,0)
//dur range 2-6. base is 4

// use built-in env
x = Synth(\fm_grain, [\envbuf, b[\deskBells][8],\carfreq,220,\dur,1.9,\modfreq,440]);
x.set(\lower,8,\upper,16);
x.set(\out,~bus[\nhhall]);
x.set(\lower,1,\upper,3);
x.set(\out,~bus[\reverb2]);
x.set(\lower,1,\upper,32);
x.set(\lower,20,\upper,24);
x.set(\lower,128,\upper,1);
x.set(\lower,1,\upper,1);
x.set(\out,~bus[\reverb]);
x.set(\amp,-0.dbamp);

x.set(\envbuf, -1);
x.set(\gate, 0);




/////////////////////////////////////////////////////////////
// define some patterns

(a = (
//Pdef.removeAll;
Pbindef(\harmony,
	\instrument, \sinfb,
	\midinote,[57,45,33],
	\dur,4,//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\atk,2,
	\rel,4,
	\fb,0.3,
	\pan,0.25,
	\amp,-41.dbamp,
	\out,~bus[\nhhall]
);

Pbindef(\kick,
	\instrument,\kick,
	\midinote,[57,45,33],
	\dur,Psubdivide(Pseq([1!8,4,1!8,4,1!14,3].flatten,inf),Pseq([2,Rest(1.5),0.5],inf)),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
	\pan,0.28,
	\amp,-26.dbamp,
	\out,~bus[\nhhall]
);

Pbindef(\snr,
	\instrument,\kraftySnr,
	\midinote,[69,57,45],
	\dur,Pseq([Rest(1),Pseq([2],inf)],inf),//Pwrand([0.1,0.2],[0.8,0.2],inf), //0.1
//Psubdivide(Pseq([1!19,3,1!11,6,1!11,3,1!11,6,1!11,3,1!11,6,1!11,3,1!11,6].flatten,inf),
	\pan,0.25,
	\amp,-40.dbamp,
	\out,~bus[\nhhall]
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
	\cRel,16,
	\rq,0.2,
	\pan, Phprand(0,0.4),
	//\sus,0.00,
	\amp, -45.dbamp,//-58.dbamp,
	\out,~bus[\reverb]
);
)
)

Pbindef(\kick).play;
Pbindef(\snr).play;
Pbindef(\background).play;
Pbindef(\background,\amp,Pseg(Pseq([0, -45.dbamp,0]), 1));



/////////////////////////////////////////////////////////////////////////////////////
//the routine
Synth(\fm_grain, [\envbuf, b[\deskBells][8],\carfreq,220,\dur,1.9,\modfreq,440]);

(
s.prepareForRecord;
s.scope;
s.plotTree;
s.meter;
)


(
TempoClock.default.tempo_(65/60);
t = Task({
	//s.record;
	a;
	"start".postln;
	~nhhallSynth.set(\splay,0.9,\rt60,2,\stereo,0.5);
	1.wait;
	x = Synth(\fm_grain, [\envbuf, b[\deskBells][8],\carfreq,220,\dur,1.9,\modfreq,440,\amp,-3.dbamp]);

	24.wait;
	y = Synth(\fm_grain, [\envbuf, z,\modfreq,330,\carfreq, 1760, \dur,4,\amp,-50.dbamp,\pan,-0.25, \out,~bus[\nhhall],\rel,0.5]);

	16.wait;
	"start voices".postln;
	y.set(\modfreq,293,\carfreq, 440, \amp,-47.dbamp,\pan,-0.2);
	Pbindef(\harmony).play;
	Pbindef(\kick).play;
	Pbindef(\snr).play;


	12.wait;
	y.set(\modfreq,330,\carfreq, 1760, \amp,-46.dbamp,\pan,-0.15);
	x.set(\lower,8,\upper,16);
	Pbindef(\harmony,\pan,0.2);


	16.wait;
	y.set(\modfreq,262,\carfreq, 88, \amp,-45.dbamp,\pan,-0.1);
	x.set(\lower,1,\upper,32);
	Pbindef(\harmony,\pan,0.1);

	16.wait;
	y.set(\modfreq,330,\carfreq, 440, \amp,-44.dbamp,\pan,-0.05);
	Pbindef(\harmony,\pan,0.05);
	//Pbindef(\background).play;
	//Pbindef(\background,\amp,Pseg(Pseq([0, -50.dbamp,0]), 1));

	12.wait;
	"pan about to cross over".postln;
	y.set(\modfreq,293,\carfreq, 440, \amp,-45.dbamp,\pan,0.05);
	x.set(\lower,1,\upper,3);
	Pbindef(\harmony,\pan,-0.05);


	12.wait;
	y.set(\modfreq,330,\carfreq, 1760, \amp,-44.dbamp,\pan,0.1);
	x.set(\lower,1,\upper,32);
	Pbindef(\sinfb,\midinote,[69,57,45]);
	Pbindef(\harmony,\pan,-0.1);
	//Pbindef(\background,\amp,Pseg(Pseq([0, -50.dbamp,0]), 1));

	12.wait;
	y.set(\modfreq,262,\carfreq, 88, \pan,0.15,\amp,-42.dbamp);
	x.set(\lower,8,\upper,16);
	Pbindef(\harmony,\pan,-0.15);

	12.wait;
	"low point".postln;
	y.set(\modfreq,275,\carfreq,440,\amp,-41.dbamp,\pan,0.25);
	x.set(\lower,1,\upper,128,\amp,2.dbamp);
	Pbindef(\harmony,\midinote,[57,45,33,21]);
	Pbindef(\harmony,\pan,-0.25);
	Pbindef(\background).play;
	Pbindef(\background,\amp,Pseg(Pseq([0, Pn(-40.dbamp)]), 36));
	Pbindef(\kick,\amp,0);
	Pbindef(\snr,\amp,0);

	1.wait;
	y.set(\amp,-38.dbamp);

	23.wait;
	"slow it down".postln;
	y.set(\modfreq,330,\carfreq,1760,\amp,-43.dbamp,\pan,-0.25);
	x.set(\out,\amp,-3.dbamp);
	x.set(\lower,1,\upper,1);
	Pbindef(\harmony,\pan,0.25);

	16.wait;
	"sustain end".postln;
	y.set(\modfreq,220, \carfreq,1760,\dur,8,\amp,-48.dbamp);
	x.set(\lower,1,\upper,32);
	Pbindef(\harmony,\midinote,[81,69,57,45,33,21]);


	16.wait;
	"start releasing".postln;
	x.set(\lower,1,\upper,1);
	y.set(\gate,0,\rel,16);

	4.wait;
	Pbindef(\harmony,\midinote,0,\rel,12);
	x.set(\gate, 0,\rel,8);

	4.wait;
	"short jam".postln;
	Pbindef(\kick,\amp,-24.dbamp);
	Pbindef(\snr,\amp,-35.dbamp);

	32.wait;
	Pbindef(\background,\amp,Pseg(Pseq([-40.dbamp, Pn(0)]), 28));

	20.wait;
	Pbindef(\background,\rel,4);


	8.wait;
	Pbindef(\kick,\amp,0);
	Pbindef(\snr,\amp,0);

	8.wait;
	Pbindef(\background).stop;
	//s.stopRecording;
});
)


t.reset.play;