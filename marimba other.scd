///////////////////////////////
// the piece
////////////// as a function



(
 d = {arg fundamental = 50, amp=1, release=12, gate=1;
	  var harmonics = [1, 2, 3, 4, 5, 6, 7, 8, 9,10];
      var snd, klank, env;
	//var env = EnvGen.ar(Env.linen.circle,doneAction:2);
	env = Env.asr(1, amp, release).kr(2, gate);
	snd = LFPulse.ar(harmonics.midiratio, width:  Klang.ar(`[ [10,400, 800, 1000, 1200], [0.05,1,0.5,0.5,0.1], nil], 1, 0));
	klank =  LFTri.ar(10*harmonics, mul:snd);
	snd = BPF.ar(
		in: snd,
		freq: fundamental.lag3ud(0.025,0.025) * harmonics ,
		rq: [0.0025,0.0075,0.01],//[0.0015,0.0015,0.002,0.005,0.0075,0.01,0.01,0.01,0.015],//, //0.01
		mul: 25 * [ 0.1, 0.5, 0.8, 0.6, 0.5, 0.4, 0.3, 0.6, 0.3 ],//harmonics.sqrt,
	);
	//snd = HPF.ar(snd,40);
	//snd = Compander.ar(snd,snd,0.09,1,0.5,0.01,0.01);
	snd = IIRFilter.ar(snd,3000 + (20*fundamental),30);
	snd = BHiPass4.ar(snd,fundamental,5);
	snd = LeakDC.ar(snd) * env;
	snd = SplayAz.ar(4,snd,0.2,10);
	Out.ar(0,snd);
}.play;
 )

//d.set(\fundamental,30.midicps,\mul,100);
//https://ccrma.stanford.edu/~ruviaro/texts/A_Gentle_Introduction_To_SuperCollider.pdf p.94
SystemClock.sched(0, {d.set(\fundamental, [30,35,33,38,42].choose.midicps); [8,16].choose});
d.set(\gate,0);