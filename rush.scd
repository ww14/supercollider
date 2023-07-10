//https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3

//another nathan sound design rip off


//////////////////////////////////////////
//
(
SynthDef(\rush,{
	var trig, snd, freqs, perc, fund, a, cycle,env;
	trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, \low.kr(15), \high.kr(20))); //LFDNoise makes the higher freq steps less discrete/quantized

	fund = \fund.kr([52,53,57,60]); //VII-I-III-V
	a = fund +  .t[0, 4, 7, 9, 11, 14, -24]; //make it an array of chords (t for table)
	a = a.lag3ud;
	cycle = a.size * 0.5;
	freqs = Select.kr(LFSaw.kr(30.reciprocal,0,cycle,cycle),a.midicps);
	//freqs = (SinOsc.kr(180.reciprocal).linexp(-1, 1, 52, 60).round(2).poll(1) +  [0, 2, 4, 5, 7, 9, 10, 14, 24]).midicps; //


	snd = Pluck.ar(
		Hasher.ar(Sweep.ar(trig)) * -15.dbamp,
		trig,
		freqs.reciprocal,
		freqs.reciprocal,
		2.5, //LFNoise2.kr(1/4).linexp(-1,1,1.5,4),
		SinOsc.kr(60.reciprocal,1.5*pi).linexp(-1,1,1e-3,0.5)
	);
	snd = -25.dbamp * snd;
	perc = SinGrain.ar(
		trig,
		SinOsc.kr(60.reciprocal).linexp(-1,1,0.001,0.01),
		freqs.tanh
	) * -12.dbamp;
    //perc = DelayC.ar(perc, 1, SinOsc.ar(20.reciprocal, [0, pi]).range(0, 1));
	snd = LeakDC.ar(snd).sum;
	snd = MoogFF.ar(snd, LFNoise2.kr(0.75).linexp(-1, 1, 500, 16000), 0);
	snd = snd
	    + perc
	         //+ DelayC.ar(snd, 0.1, SinOsc.ar(0.00005, [0, pi]).range(0, 0.01));
	;
	//snd = CombN.ar(snd,trig);


	snd = snd !2 ; //Pan2.ar(snd,\pan.kr(0),\amp.kr(1));
	//snd = snd * \amp.kr(1);
	env = Env.asr(1, \amp.kr(1), \release.kr(16)).kr(2, \gate.kr(1));
	snd = snd *env;
	//snd = NHHall.ar(snd);
	Out.ar(0,snd);
}).add;
)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////testing////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
a = Synth(\rush);
a.free;
a.set(\fund,1);
a.release(8);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////the piece ////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////
// test
a = Synth(\rush);
a.release(8);




////////////////////////
// the piece
////////////////////////


(
TempoClock.default.tempo_(60/60);
t = Task({
	"start".postln;
	//the low high range starts at 15-20
	a = Synth(\rush);

	60.wait;
	"shorter".postln;
	a.set(\low,3,\high,10);

	30.wait;
	"wider".postln;
	a.set(\low,1,\high,100);

	30.wait;
	"new chords".postln;
	a.set(\low,1,\high,100);
	a.set(\fund,[55,59]);

	30.wait;
	"narrower".postln;
	a.set(\low, 15, \high,40);

	60.wait;
	"orignal width, close".postln;
	a.set(\fund,[52,53,57, 60]);
	a.set(\low, 15, \high,20);

	 //fade out
	a.release(16); //could also use \gate
});
)

t.play;




