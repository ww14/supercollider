//Creating variations on a base rhythmic pattern
Server.killAll;
("Setup/Setup.scd").loadRelative // load this file

(
~commonFuncs = (
	// save starting time, to recognize the last bar of a 4-bar cycle
	init: {
		if(~startTime.isNil) { ~startTime = thisThread.clock.beats };
	},
	// convert the rhythm arrays into patterns
	pbindPairs: { |keys|
		var pairs = Array(keys.size * 2);
		keys.do({ |key|
			if(key.envirGet.notNil) { pairs.add(key).add(Pseq(key.envirGet, 1)) };
		});
		pairs
	},
	// identify rests in the rhythm array
	// (to know where to stick notes in)
	getRestIndices: { |array|
		var result = Array(array.size);
		array.do({ |item, i|
			if(item == 0) { result.add(i) }
		});
		result
	}
);
)

(
t = TempoClock.default.tempo = 98 / 60;
~kikEnvir = (
	parent: ~commonFuncs,
	// rhythm pattern that is constant in each bar
	baseAmp: #[1, 0, 0, 0, 0, 0, 0.7, 0, 0, 1, 0.25, 0, 0, 0, 0, 0] * 2.5,
	baseDecay: #[0.15, 0, 0, 0, 0, 0, 0.15, 0, 0, 0.15, 0.15, 0, 0, 0, 0, 0],
	addNotes: {
		var beat16pos = (thisThread.clock.beats - ~startTime) % 16,
		available = ~getRestIndices.(~baseAmp);

		~amp = ~baseAmp.copy;
		~decay2 = ~baseDecay.copy;
		// if last bar of 4beat cycle, do busier fills
		if(beat16pos.inclusivelyBetween(12, 16)) {
			available.scramble[..rrand(5, 10)].do({ |index|
				// crescendo
				~amp[index] = index.linexp(0, 15, 0.2, 0.5);
				~decay2[index] = 0.15;
			});
		} {
			available.scramble[..rrand(0, 2)].do({ |index|
				~amp[index] = rrand(0.15, 0.3);
				~decay2[index] = rrand(0.05, 0.1);
			});
		}
	}
);
~snrEnvir = (
	parent: ~commonFuncs,
	baseAmp: #[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0] * 50,
	baseDecay: #[0, 0, 0, 0, 0.7, 0, 0, 0, 0, 0, 0, 0, 0.4, 0, 0, 0.4],
	baseRq: #[1, 1, 1, 1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1],
	addNotes: {
		var beat16pos = (thisThread.clock.beats - ~startTime) % 16,
		available = ~getRestIndices.(~baseAmp),
		choice;
		~amp = ~baseAmp.copy;
		~decay = ~baseDecay.copy;
		~rq = ~baseRq.copy;
		if(beat16pos.inclusivelyBetween(12, 16)) {
			available.scramble[..rrand(3, 7)].do({ |index|
				~amp[index] = index.linexp(0, 15, 0.5, 1.8);
				~decay[index] = rrand(0.2, 0.4);
				~rq[index] = rrand(1, 10);
			});
		} {
			available.scramble[..rrand(1, 3)].do({ |index|
				~amp[index] = rrand(0.15, 0.3);
				~decay[index] = rrand(0.2, 0.4);
				~rq[index] = rrand(1,5);
			});
		}
	}
);
~hhEnvir = (
	parent: ~commonFuncs,
	baseAmp: 15 ! 16,
	baseDelta: 0.5 ! 16,
	addNotes: {
		var beat16pos = (thisThread.clock.beats - ~startTime) % 16,
		available = (0..15),//orig 15
		toAdd;
		// if last bar of 4beat cycle, do busier fills
		~amp = ~baseAmp.copy;
		~dur = ~baseDelta.copy;
		if(beat16pos.inclusivelyBetween(12, 16)) {
			toAdd = available.scramble[..rrand(8, 15)]
		} {
			toAdd = available.scramble[..rrand(0, 7)]
		};
		toAdd.do({ |index|
			~amp[index] = ~doubleTimeAmps;

			~dur[index] = ~doubleTimeDurs;
		});
	},
	doubleTimeAmps: Pseq(#[15, 10], 1),
	doubleTimeDurs: Pn(0.125, 2)
);
~kik = Penvir(~kikEnvir, Pn(Plazy({
	~init.value;
	~addNotes.value;
	Pbindf(
		Pbind(
			\instrument, \kik,
			\preamp, 0.15,
			\basefreq,36,
			\ratio,12,
			\dur, 0.25,
			*(~pbindPairs.value(#[amp, decay2]))
		),
		// default Event checks \freq --
		// if a symbol like \rest or even just \,
		// the event is a rest and no synth will be played
		\freq, Pif(Pkey(\amp) > 0, 1, \rest)
	)
}), inf));
~snr = Penvir(~snrEnvir, Pn(Plazy({
	~init.value;
	~addNotes.value;
	Pbindf(
		Pbind(
			\instrument, \kraftySnr,
			\dur, 0.25,
			*(~pbindPairs.value(#[amp, decay,rq]))
		),
		 \freq, Pif(Pkey(\amp) > 0, [50,250,500,2500], \rest)
	)
}), inf));
~hh = Penvir(~hhEnvir, Pn(Plazy({
	~init.value;
	~addNotes.value;
	Pbindf(
		Pbind(
			\instrument, \kraftySnr,
			\rq, Plprand(3,15),//0.01,
			\amp, 15,
			\decay, 0.009,
			*(~pbindPairs.value(#[amp, dur]))
		),
		\freq, Pif(Pkey(\amp) > 0, [1100,1000], \rest)
	)
}), inf));
)

~kik.play(t,quant: 4);
~snr.play(t,quant: 4);
~hh.play(t,quant: 4);

(
~kikEnvir.put(\baseAmp, 0);
)

///////////////////////////////////////////////////////////////////////////////

// stop just before barline
(
s.prepareForRecord;
t.schedAbs(t.nextTimeOnGrid(4, -0.001), {
	[~kik, ~snr, ~hh].do(_.stop);
});)


// start it
(
s.record;
~kik.play(t,quant: 4);
~snr.play(t,quant: 32);
~hh.play(t,quant: 32);
)



//test
// ~snrEnvir.put(\baseAmp, #[1, 0, 0, 0, 0, 0, 0.5, 0, 1, 0, 0, 0, 0.5, 0, 1, 0] * 50);
// ~snrEnvir.put(\baseDecay,#[0, 0, 0, 0, 0.7, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0, 0.4]);
// ~snrEnvir.put(\baseRq, #[1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]);
//
//
// ~kikEnvir.put(\baseAmp, #[1, 0, 1, 0, 0, 0, 0.7, 1, 0, 1, 0.25, 0, 0, 0, 0, 0.25] * 1.5);
//

// transition 1
~snrEnvir.put(\baseRq, #[1, 1, 1, 1, 1, 1, 1, 1, 8, 1, 1, 1, 1, 1, 1, 1]/15);

// transition 2
(
~snrEnvir.put(\baseRq, #[1, 1, 1, 1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1]/1500);
~hhEnvir.put(\baseAmp,10!16);
~hhEnvir.put(\baseDelta,#[1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]);
)


////1a&2a&3a
(
~snrEnvir.put(\baseDecay, #[0, 0, 0.1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0.3,0]);
~kikEnvir.put(\baseAmp, #[1, 0, 1, 0, 0, 0, 0.7, 1, 0, 1, 0.25, 0, 0, 0, 0, 0.25] * 1.5)
)


////2b, step down
~snrEnvir.put(\baseRq, #[1, 1, 1, 1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1]/15);

//step again
~snrEnvir.put(\baseRq, #[1, 1, 1, 1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1]*2);




///original 1&2
(
~kikEnvir.put(\baseAmp, #[1, 0, 0, 0, 0, 0, 0.7, 0, 0, 1, 0.25, 0, 0, 0, 0, 0] * 1.5);

~snrEnvir.put(\baseAmp, #[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0] * 30);
~snrEnvir.put(\baseDecay, #[0, 0, 0, 0, 0.7, 0, 0, 0, 0, 0, 0, 0, 0.4, 0, 0, 0.4]);
~snrEnvir.put(\baseRq, #[1, 1, 1, 1, 1, 1, 1, 1, 10, 1, 1, 1, 1, 1, 1, 1]);
)

///3 original
(
~hhEnvir.put(\baseAmp,15!16);
~hhEnvir.put(\baseDelta,0.5 ! 16);
~kikEnvir.put(\baseAmp, #[1, 0, 1, 0, 0, 0, 0.7, 1, 0, 1, 0.25, 0, 0, 0, 0, 0.25] * 1.5)

)

~kikEnvir.put(\baseDecay, #[0.15, 0, 0, 0, 0, 0, 0.15, 0, 0, 0.15, 0.15, 0, 0, 0, 0, 0] * 0.5);

// dont run this
~hhEnvir.put(\baseAmp,0!16,\baseDelta,0!16,\addNotes,0);
~kikEnvir.put(\baseAmp,0!16);
~snrEnvir.put(\baseAmp,0!16);


// hack but it ends the envs
~hhEnvir.put(\baseAmp,0);
~kikEnvir.put(\baseAmp,0);
~snrEnvir.put(\baseAmp,0);

s.stopRecording;

// this code no longer works. unsure why
(
// stop just before barline
t.schedAbs(t.nextTimeOnGrid(4, -0.001), {
	[~hh].do(_.stop);
});
)

(
// stop just before barline
t.schedAbs(t.nextTimeOnGrid(4, -0.001), {
	[~kik].do(_.stop);
});
)

(
// stop just before barline
t.schedAbs(t.nextTimeOnGrid(4, -0.001), {
	[~snr].do(_.stop);
});
)


	