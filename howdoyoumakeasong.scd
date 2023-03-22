//https://scsynth.org/t/how-do-you-make-a-song/4110/5


/////////////////////////////////////////////////
///////////////////////functions/////////////////
/////////////////////////////////////////////////
(
// create a new event type called hasEnv
// which checks every parameter whose key ends in Env or env:
// - convert non-env values to envs (e.g 0 becomes Env([0,0],[dur]))
// - stretch envelope to last for the event's sustain (converted from beats to seconds)
~utils = ();
~utils.hasEnv = {
    // calc this event's duration in seconds
    var durSeconds = ~dur * ~legato / thisThread.clock.tempo;
	//var durSeconds = ~sustain.value / thisThread.clock.tempo;
    // find all parameters ending in env or Env
    var envKeys = currentEnvironment.keys.select{|k|"[eE]nv$".matchRegexp(k.asString)};
    envKeys.do{|param|
        var value = currentEnvironment[param];
        if (value.isArray.not) { value = [value] };
        value = value.collect {|v|
            // pass rests along...
            if (v.isRest) { v } {
                // convert non-env values to a continuous, fixed value env
                if (v.isKindOf(Env).not) { v = Env([v, v], [1]) }
            };
            // stretch env's duration
            v.duration = durSeconds;
        };
        currentEnvironment[param] = value;
    };
};

Event.addParentType(\hasEnv,(
    finish: ~utils[\hasEnv]
));

// assist data-sharing in pbindfx creation
// pbindfx is wrapped in a private environment (Penvir)
// arguments are just pdef names
~pbindFx = {|srcName ... fxNames|
    // add private environment, shared between source and fxs
    Penvir(Event.new(parent:currentEnvironment),
        PbindFx(
            // source: record latest event in ~src
            *[Pdef(srcName).collect(~src=_)]
            // add all fx: they can access source event saved in ~src
            ++ fxNames.collect(Pdef(_))
        )
    )
};

// recorder
~rec = (
    new: {|self, maxChannels=16, path|
        self.stopAll;
        self.maxChannels = maxChannels;
        self.bus = Bus.audio(s, maxChannels);
        self.monitor = Monitor().play(self.bus.index, maxChannels, 0, 2 );
        self.recorder = Recorder(s);
        self.recorder.record(path, self.bus, maxChannels);

    },

    pdef: {|self,pdefName,dur|
        self.pat(Pdef(pdefName), dur);
    },
    pat: {|self,pat,dur|
        if(dur.notNil){ pat = Pfindur(dur, pat) };
        pat <> (out: self.getChannel)
    },
    getChannel: {|self, numChannels=2|
      if((self.nextFreeChannel + numChannels) > self.maxChannels){
            Error("[Rec] no more free channels! Increase maxChannels when calling ~rec.new").throw;
        }{
            var ch = self.bus.subBus(self.nextFreeChannel).index;
            self.nextFreeChannel = self.nextFreeChannel + numChannels;
            ch;
        }
    },
    stopAll: {|self|
        self.recorder !? {
            self.recorder.stopRecording;
        };
        [self.bus, self.monitor].do{|it|
            it !? {it.free};
        };
        self.bus = nil;
        self.monitor = nil;
        self.nextFreeChannel = 0;
    }

);

// pattern transitions:

/* transD: Penv based, parameters are updated discretely for every successive event
- define transitions as Pdefs
e.g. Pdef(\a2b, Pbind(\amp, Penv([0.1,1],1,'exp'), ...))
- trans duration is defined in each Penv, and total trans duration is provided as arg
- durTrans doesn't affect individual Penv's dur

~transD.(\a,3,\a2b, 1) // \a for 3 seconds, then \a2b for 1 second
*/
~transD = {|patA, durA, patTrans, durTrans|
    Pspawner{|sp|
        var trans = PatternProxy();
        trans.source = Pbind();
        sp.par(trans<>Pdef(patA));
        durA.wait;
        trans.source = Pdef(patTrans);
        durTrans.wait;
        sp.suspendAll();
    }
};

/* transD example
Pdef(\a, Pbind(\note,Pseq((0..10)), \amp, 0.1));
Pdef(\b, Pbind(\note,Pseq((0..10).reverse), \amp, 0.5));
Pdef(\trans_a2b, Pbind(\amp, Pn(Penv([0.1,0.5],5))));

~transD.(\a,3,\trans_a2b,5,\b,3).play
*/

/* transC:
continuous transition, pars are set using a custom synth that writes to busses
- trans is defined as a dictionary of envelopes
e.g (amp: Env([0.1,0.5],1), ...)
- all envelopes are stretched to last transDur
- event-specific parameters like \legato are converted to Penvs and not written to busses

// \a for 3 seconds, then trans for 5 second
~transC.(\a,3,(
amp: Env([0.1,0.5],1)
),5)
*/

~transC = {|patA, durA, transDef, transDur|
    Pspawner{|sp|
        var trans = PatternProxy();
        trans.source = Pbind();
        sp.par(trans<>Pdef(patA));
        durA.wait;
        trans.source = Pbind(*~mapTrans.(transDef,transDur).asKeyValuePairs);
        transDur.wait;
        sp.suspendAll();
    }
};

// used by transC
~mapTrans = {|parEnvs, transDur= 1|
    var penvs = parEnvs.select{|v|v.class===Penv}.collect{|penv|
        penv.times = penv.times*transDur
    };
    var busses = parEnvs
    .select{|v,k| penvs.keys.includes(k).not}.collect{Bus.control(s,1)};

    {
        busses.collect{|bus, parName|
            Out.kr(bus, EnvGen.kr(parEnvs[parName],timeScale:transDur));
        };
        Line.kr(0,1,transDur,doneAction:2);
        Silent.ar;
    }.play.onFree{
        busses do: _.free
    };

    busses.collect(_.asMap) ++ penvs
};

/* transC example
Pdef(\a, Pbind(\note,Pseq((0..10)), \amp, 0.1, \pan, -1));
Pdef(\b, Pbind(\note,Pseq((0..10)), \amp, 0.5, \pan, 1));

// \a for 3 seconds, then trans for 5 second, then \b for 3 seconds
Pspawner{|sp|
sp.seq(~transC.(\a,3,(
amp: Env([0.1,0.5],1),
pan: Env([-1,1])
),5));
sp.seq(Pfindur(3,Pdef(\b)))
}.play
*/
)


/////////////////////////////////////////////////
///////////////////////SynthDefs/////////////////
/////////////////////////////////////////////////

(
u = Signal.sineFill(512, [1]);
b = Buffer.loadCollection(s, u, 1);

t = TempoClock.new(60/60).permanent_(true);
)

(
SynthDef(\sinOsc, {
	arg out=0, amp=0.1, sndBuf=0, trigRate=1, shapeAmount=0.2,
	rate=1, freq=20, overlap=2, panMax=0.5, minGrainDur=0.001, syncRatio=2, time=1;

	var gainEnv = \gainEnv.kr(Env.newClear(8).asArray);

	var sig, pos, trig, pan, grainDur;
	var k = 2 * shapeAmount / (1 - shapeAmount);

	// amp envelope
	gainEnv = EnvGen.kr(gainEnv, doneAction:2);

	// Granulation
	trig = Impulse.ar(trigRate);
	grainDur = max(trigRate.reciprocal * overlap, minGrainDur);
	pan = Demand.ar(trig, 0, Dseq([-1, 1], inf) * panMax);

	pos = Phasor.ar(trig, freq * BufFrames.ir(sndBuf) * SampleRate.ir.reciprocal, 0, BufFrames.ir(sndBuf));

    sig = GrainBuf.ar(
			numChannels: 2,
			trigger: trig,
			dur: grainDur,
			sndbuf: sndBuf,
			rate: pos,
			pos: 0,
			interp: 4,
			pan: pan
	);

	// waveshaper
	sig = ((1 + k) * sig / (1 + (k * sig.abs)));

	sig = sig * amp * gainEnv;
	sig = Limiter.ar(sig, 0.95);
	OffsetOut.ar(out, sig);
}).add;
)

(
SynthDef.new(\combL, {
  arg in=0, out=0, mix=(-0.5), decay=1, amp=1, delHz=0.55, delStereoRatio=0.9, delMin=0.001, delMax=0.4;
  var sig, comb;
  sig = In.ar(in, 2);
    delHz = delHz * [1,delStereoRatio];
  comb = CombL.ar(
    sig,
    delMax,
    LFPar.kr(delHz,[0,pi/2]).exprange(delMin,delMax),
    decay,
  );
  sig = XFade2.ar(sig, comb, mix) * amp;
  Out.ar(out, sig);
}).add;
)

/////////////////////////////////////////////////
///////////////////////Patterns/////////////////
/////////////////////////////////////////////////


(
Pdef(\sinOsc1,
	Pbind(
		\type, \hasEnv,
		\instrument, \sinOsc,

		\sndBuf, b,

		//waveshaper
		\shapeAmount, 0.3,

		\overlap, 15,
		\trigRate, 5,
		\panMax, 0.80,

		\midinote, Pseq([
			[31,43],
		],inf),

		\dur, 28,

		\legato, 0.80,

		\atk, 0.01,
		\sus, (1 - Pkey(\atk)) * Pexprand(0.55,0.85,inf),

		\gainEnv, Pfunc{|e|
			var rel = (1 - e.atk - e.sus);
			var c1 = exprand(2,6);
			var c2 = exprand(-2,-6);
			Env([0,1,1,0],[e.atk, e.sus, rel],[c1,0,c2])
		},

		\amp, 0.10,

		\out, 0,
		\finish, ~utils[\hasEnv],
		\cleanupDelay, Pkey(\dur) * Pkey(\legato),
		\fxOrder, [1]
	)
);
)

(
Pdef(\sinOsc2,
	Pbind(
		\type, \hasEnv,
		\instrument, \sinOsc,

		\sndBuf, b,

		//waveshaper
		\shapeAmount, 0.3,

		\overlap, 1,
		\trigRate, 5,
		\panMax, 0.90,

		\midinote, Pseq([
			[57,64,70,76,77],
			[53,58,64,72,76,81],
			[55,62,64,69,74],
			[57,60,64,65,70],
		],inf),

		\dur, 8,

		\atk, 0.01,
		\sus, (1 - Pkey(\atk)) * Pexprand(0.55,0.85,inf),

		\gainEnv, Pfunc{|e|
			var rel = (1 - e.atk - e.sus);
			var c1 = exprand(2,6);
			var c2 = exprand(-2,-6);
			Env([0,1,1,0],[e.atk, e.sus, rel],[c1,0,c2])
		},

		\amp, 0.03,

		\out, 0,
		\finish, ~utils[\hasEnv],
		\cleanupDelay, Pkey(\dur) * Pkey(\legato),
		\fxOrder, [1]
	)
);
)

(
Pdef(\comb_fx,
	Pbind(
		\fx, \combL,
		\mix, 1,
		\amp, 1,
		\delStereoRatio, 0.9,
		\delHz, Pfunc{ thisThread.clock.tempo.reciprocal/2 },
		\delMin, Pwhite(0.25,0.50,inf),
		\delMax, Pwhite(0.25,1,inf),
		\decay, 2,
		\cleanupDelay, Pkey(\decay)
	),
);
)

Pdef(\sinOsc_fx, ~pbindFx.(\sinOsc2,\comb_fx));

Pdef(\sinOsc1).play;
Pdef(\sinOsc2).play;
Pdef(\sinOsc_fx).play;

(
Pdef(\sinOsc_par, Pspawner {|sp|
    sp.par(Pdef(\sinOsc1));
    sp.par(Pdef(\sinOsc2), 2);
});
)

Pdef(\sinOsc_par).play;

////////////////////////////////////////////////////
///////////////////Make a Piece/////////////////////
///////////////////////////////////////////////////

(
Pspawner({|sp|

	sp.par( Pfindur(28, Pdef(\sinOsc1)));

	sp.wait(8);

	sp.par( Pfindur(4, Pdef(\sinOsc2)));

	sp.par( ~transC.(
		\sinOsc2, 4, (
			overlap: Env([1,3],1,\exp),
			trigRate: Env([5,15],1,\exp),
			panMax: Env([0.90,0.10],1,\lin),
	), 8));

	sp.wait(16);

	sp.seq( Pfindur(16, Pdef(\sinOsc_fx)));

}).play(t, quant:1);
)


////////////////////////////////////////////////////
///////////////////Multi Channel Recording/////////
///////////////////////////////////////////////////


(
Pspawner({|sp|
	~rec.new(14, Platform.recordingsDir+/+"piece1_4-%.aiff".format(Date.localtime.stamp));

	sp.par(~rec.pdef(\sinOsc1,28));

	sp.wait(8);

	sp.par(~rec.pdef(\sinOsc2,4));

	sp.par(~rec.pat(~transC.(
		\sinOsc2, 4, (
			overlap: Env([1,3],1,\exp),
			trigRate: Env([5,15],1,\exp),
			panMax: Env([0.90,0.10],1,\lin),
	), 8)));

	sp.wait(16);

	sp.seq(~rec.pdef(\sinOsc_fx,16));

	3.wait;
    sp.suspendAll();
    10.wait; // wait a bit for eventual tails
    ~rec.stopAll;

}).play(t, quant:1);
)