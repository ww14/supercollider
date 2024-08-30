s.options.memSize = 1048576;

s.reboot;  // this is important!


(SynthDef(\oneshot,
{
	var trig, snd, freqs, perc, percVerb, env,duration;
	//trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
		freqs = (\midi.kr(32) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	perc = SinGrain.ar(Impulse.kr(10),0.51,freqs,4);


	perc = perc + (RLPF.ar(Hasher.ar(Sweep.ar),4210,0.3) * Env.perc(0.001,0.01).ar * 5.dbamp);
	perc = perc + (RHPF.ar(Hasher.ar(Sweep.ar),6210,0.3) * Env.xyc({ [1.0.rand, 10.0.rand, -4.rand2] } ! 16, \exp).ar * -20.dbamp);
	perc = perc * (1 + (5 * Env.perc(0,0.01).ar));
	perc = perc.clip2 + (perc.fold2 * -10.dbamp);
	perc = perc + HPF.ar((perc*6.dbamp).tanh, 3000);
	perc = perc * Env.perc(0.01,0.5).ar;
	perc = perc + HPF.ar(LPF.ar(DelayC.ar(perc * -25.dbamp, 0.1, [30e-3, 33.4e-3]), 5000), 100);

	duration = \duration.kr(4);

	percVerb = NHHall.ar(perc!2,duration,0.3);

	perc = XFade2.ar(perc * 0.05, percVerb, \mix.kr(0.009).linlin(0,1,-1,1));
	      //   + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.9);
	snd = perc ;
	env = Env.linen(0,duration, duration, curve:-2).ar(Done.freeSelf);
		snd = snd * env * \amp.kr(1);

	snd = snd ! 2;
	Out.ar(\out.kr(0),snd);
}).add;
)


(SynthDef(\oneshot2,
{
	var trig, snd, freqs, perc, sndVerb, env,duration, chorus;
	//trig = Impulse.ar(LFDNoise3.kr(1).linexp(-1, 1, 1, 48)); //LFDNoise makes the higher freq steps less discrete/quantized
		freqs = (\midi.kr(32) +  [0, 2, 4, 5, 7, 9, 10, 14]).midicps; //
	chorus = SinGrain.ar(Impulse.kr(10)* (SinOsc.ar([0.1,1,2,3,4]) * [-5,0,-5,-2,-10].dbamp),0.51,freqs,4);
	chorus =  RHPF.ar(chorus,SinOsc.kr([0.001,0.01,0.1,0.5,1], 5, 220, 440), 0.05);
	//chorus = RHPF.ar(chorus,440,(0.1+SinOsc.ar(0.1, mul:0.01)));

	perc = (RLPF.ar(Hasher.ar(Sweep.ar),4210,0.3) * Env.perc(0.001,0.015).ar * 5.dbamp);
	perc = perc + (RHPF.ar(Hasher.ar(Sweep.ar),6210,0.3) * Env.perc(0.001,0.03).ar * -9.dbamp);
	perc = 0.1 * perc * (1 + (5 * Env.perc(0,0.01).ar));

	duration = \duration.kr(4);

	snd = chorus + perc;
	snd = snd.clip2 + (perc.fold2 * -20.dbamp);
	snd = snd + HPF.ar((snd*6.dbamp).tanh, 3000);
	snd = snd * Env.perc(0.01,0.5).ar;
	snd = snd + HPF.ar(LPF.ar(DelayC.ar(snd * -25.dbamp, 0.1, [30e-3, 33.4e-3]), 5000), 100);

	sndVerb = NHHall.ar(snd!2,duration,0.3);

	snd = XFade2.ar(perc * 0.05, sndVerb, \mix.kr(0.009).linlin(0,1,-1,1));
	      //   + DelayC.ar(snd, 0.01, SinOsc.ar(0.5, [0, pi]).range(0, 0.001));
	//snd = CombN.ar(snd,0.9);
	env = Env.linen(0,duration, duration, curve:-2).ar(Done.freeSelf);
		snd = snd * env * \amp.kr(1);

	snd = snd ! 2;
	Out.ar(\out.kr(0),snd);
}).add;
)

/////////////////////////////
//testing
a = Synth(\oneshot2, [\duration,200,\midi,58,\amp, -20.dbamp]);

Synth(\oneshot, [\duration,200,\midi,58]);
Synth(\oneshot2, [\duration,200,\midi,58]);

Synth(\oneshot, [\duration,2,\midi,58,\mix,0.025]);
Synth(\oneshot2, [\duration,0.15,\midi,51,\mix,0.05]);


Pbind(\instrument,\oneshot2,\dur,Pbjorklund2(3,8,inf)/6,\duration,Plprand(0.15,0.26),\midi,Pwrand([51,54,48,58],[8,2,1,1].normalizeSum,inf)).play;
Pbind(\instrument,\oneshot,\dur,Pbjorklund2(3,8,inf)/2,\duration,Plprand(0.15,0.26),\midi,Pwrand([51,54,48,58],[8,2,1,1].normalizeSum,inf),\amp,-10.dbamp).play;
a = Pbind(\instrument,\oneshot,\dur,1/6,\duration,Plprand(0.015,0.1),\midi,135,\amp,-30.dbamp).play
a.stop

51+24

(
Pbindef(\oneshot2,\instrument,\oneshot2,\dur,Pbjorklund2(3,8,inf)/6,\duration,Plprand(0.15,0.2),\midi,Pwrand([51,58], [8,2,1].normalizeSum,inf),\amp,-5.dbamp).play;

)

Pbindef(\intro,\instrument,\oneshot,
		\dur,1/9,
		\duration,Plprand(0.015,0.1),
		\midi,-36+[75,82,87,96],
		\amp,-25.dbamp).play;


/////////////////////////////
//patterns

(
c = TempoClock.default.tempo_(65/60);
t = Task({
//s.record;

	Pbindef(\intro,\instrument,\oneshot,
		\dur,1/6*Pbjorklund2(7,8,inf),
		\duration,Plprand(0.015,0.1),
		\midi,-36+[75,82,87,96],
		\amp,-25.dbamp).play;

	16.wait;

	Pbindef(\intro,\duration,0.015);

	3.wait;
	Pbindef(\intro).stop;
	0.5.wait;
	b = Synth(\oneshot, [\duration,200,\midi,58]);

	24.wait;
	Pbindef(\oneshot,\instrument,\oneshot,\dur,Pbjorklund2(3,8,inf),\duration,Plprand(0.15,0.26),\midi,51,\amp,-12.dbamp).play;

	8.wait;
	Pbindef(\oneshot2,\instrument,\oneshot2,\dur,Pbjorklund2(3,8,inf)/6,\duration,Plprand(0.15,0.26),\midi,Pwrand([51,58], [8,2].normalizeSum,inf),\amp,-5.dbamp).play;
	Pbindef(\oneshot,\dur,Pbjorklund2(3,8,inf)/2,\midi,Pwrand([51,58],[8,2].normalizeSum,inf));

	"first and second rotation".postln;

	14.wait;

	7.wait;

	7.wait;
	Pbindef(\oneshot2).stop;
	Pbindef(\oneshot).stop;
	10.wait;
	//s.stopRecording;
   });
)


// play it
t.play(c);




