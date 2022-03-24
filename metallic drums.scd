Server.killAll
("Setup/Setup.scd").loadRelative // load this file




// you can only call this as a synth, not pbind. it never releases. there's an embedded sin func

//this has a good pace, bass drum with distortion and saw synth
~a = Synth("metaldrum",[\ibase,1.9,\t,1/10.2,\irange,8.5,\ringfreq,[33,45,48,55,57].midicps,\roomsize,50,\spread,15]);

//big sounds, saw toothy, reverb
~a = Synth("metaldrum",[\ibase,1.9,\t,1,\irange,8.5,\ringfreq,[33,45,48,55,57].midicps,\roomsize,50,\damping,0.001,\earlyreflevel,0.5]);


// nice descent sounds, resolves into standard beat that then separates. phase music
~a = Synth("metaldrum",[\ibase,1.999,\t,1/100,\irange,3,\ringfreq,[33,45,48,55,57].midicps,\roomsize,50]);

// nasal synth with transformations, rolling perc with high nasal synth
~a = Synth("metaldrum",[\ibase,9,\irange,3,\ringfreq,[200],\roomsize,50,\damping,0.04,\inputbw,0.0001]);


// slow drum, oil barrel, it isn't too dynamic
~a = Synth("metaldrum",[\ibase,0.9,\roomsize,10,\damping,0.05,\inputbw,0.1]);
~a.free;

// slow pvc
~a = Synth("metaldrum",[\ibase,0.9,\irange,3,\ringfreq,[200],\roomsize,50,\damping,0.04,\inputbw,0.001]);

// slow pvc? ibase 10000, 100, or [8000/ 2000 freq] works well too
~a = Synth("metaldrum",[\ibase,1000,\irange,1/300,\ringfreq,200,\roomsize,100,\damping,0.1,\revtime, 0.5,\inputbw,0.001]);

// slow pvc? ibase 10000, 100, or [8000/ 2000 freq] works well too
~a = Synth("metaldrum",[\ibase,[100],\irange,1/3000,\ringfreq,30,\roomsize,50,\damping,0.1,\revtime, 0.5,\inputbw,0.001]);

// one shot
~a = Synth("metaldrum",[\ibase,20,\t,0.5,\ringfreq,[3],\roomsize, 5, \revtime, 0.6, \damping, 0.62, \inputbw, 0.48, \drylevel, -6, \earlylevel, -11, \taillevel, -13]);


// slight glitch pipe; doesn't cohere well
~a = Synth("metaldrum",[\ibase,2.1,\ringfreq,[300],\roomsize, 5, \revtime, 0.6, \damping, 0.62, \inputbw, 0.48, \drylevel, -6, \earlylevel, -11, \taillevel, -13]);

~a.free;

// less glitchy pipe
~a = Synth("metaldrum",[\ibase,2,\ringfreq,220,\roomsize, 20, \revtime, 0.5, \damping, 0.1, \inputbw, 0.46]);

// pvc pip with artifacts
~x = Pbind(\instrument,\metaldrum, \ibase,2,\ringfreq,220,\roomsize, 20, \revtime, 0.5, \damping, 0.1, \inputbw, 0.46);
~x.play;