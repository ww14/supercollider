("/setup/Setup_jaxa.scd").loadRelative;

~sine = {SinOscFB.ar(120*[0.994,1.03],0.45)*0.7};
~sine.play(fadeTime:3);
~sine.stop(5);

p.fadeTime_(3);

p.clock.tempo;
p.fadeTime;
p.quant;


// why doesn't this work?
b.keys;


//how can i pull up snippets?
//.......


//not sure what the brackets accomplish..
~sine = {SinOsc.ar(120*[0.994,1.03]).tanh*0.07};
~sine.play;
~mix[10] = {~sine};



(
SynthDef(\help_sinegrain,
    { arg out=0, freq=440, sustain=0.05, pan=0.5, amp=1;
        var env, sig;
        env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction: Done.freeSelf);
		sig = SinOsc.ar(freq, 0, env);
		sig = Pan2.ar(sig, pan, amp);
        Out.ar(out, sig);
    }).add;
)


/////let's table the chord issue
// maybe use .flat arg at end
(
~chord = [
    \Amaj11, \Fmaj11, \Gmaj11, \Am,
    \A, \E, \Gm, \DM,\C_g
].chordProg(Scale.dorian);
)




( ~b_test[0] = Pbind(\instrument, \help_sinegrain,
			\dur, 2,
	\degree, Pseq([0,4,3,7],inf),
	\mRatio,4.0,
	\octave,3,
	\strum,Pwrand([0.01, 0.05, 0.2],[12,2,1].normalizeSum,inf),
			\atk, 1/6 * 8,
		    \rel, 3,
			\amp, 0.15,
			\out, 0,
			\index,2,
		\iScale, Pwrand([2,4,8],[8,8,1].normalizeSum,inf),
		\cAtk,0.001,
        \cRel,-0.001,
		\cRatio,[4,1/20],
		);
);

~b_test.play;


//reverb bus, if you hit cmd-. then it won't work
(
~mix.ar;
(~verb = {
	XFade2.ar(
		LPF.ar(
			GVerb.ar(~mix.ar(1),80,8),
			8500
		),
		~mix, \pan.kr(0,0.5),\level.kr(0.15)
	)
};);
~verb.play;
)


~mix[1] = {~b_test} // [n] represents slot n



//can run general effect thru node proxy roles
//there are predinfed params for proxy roles, like filter.
~note[10] = \filter -> {|in| /*some effect*/};

//once the node exists you can adjust params like \wet
~note.set(\wet10, 0.7); //where 10 in wet10 represnts the [10] node

// to undo an effect
~note[10] = nil; //useful to turn off an effect, and to keep multiple patterns in sync when fadeTime>0
