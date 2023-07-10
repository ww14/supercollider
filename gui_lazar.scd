https://scsynth.org/t/what-kind-of-synthesis-is-this/4318/3



(

SynthDef(\fm, {
              arg out=0, pan=0, amp=0.25, freq=111, atk=0.001, rel=0.2,
              mInd1=0.5, mInd2=0.5, mInd3=0.5, mInd4=0.5, mInd5=0.5, mInd6=0.5;
               var gainEnv = EnvGen.ar(Env.perc(atk, rel), \gt.kr(1), doneAction:Done.freeSelf);
              var sig, cascade_0, cascade_1;
              cascade_0 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio3.kr(1), pi * 0.5).range(0, mInd3) ) * \amp_3.kr(0.5);
              cascade_0 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio2.kr(1), pi * 0.5).range(0, mInd2) + cascade_0.range(0,mInd2)) * \amp_2.kr(0.5);
              cascade_0 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio1.kr(1), pi * 0.5).range(0, mInd1) + cascade_0.range(0,mInd1)) * \amp_1.kr(0.5);
              cascade_1 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio6.kr(1), pi * 0.5).range(0, mInd6) + LocalIn.ar(1).range(0, mInd6)) * \amp_6.kr(0.5);
              cascade_1 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio5.kr(1), pi * 0.5).range(0, mInd5) + cascade_1.range(0,mInd5)) * \amp_5.kr(0.5);
              cascade_1 = SinOsc.ar(freq, SinOsc.ar(freq * \ratio4.kr(1), pi * 0.5).range(0, mInd4) + cascade_1.range(0,mInd4)) * \amp_4.kr(0.5);


              LocalOut.ar(cascade_1 * \fb.kr(0.9));
              sig = Mix([cascade_0, cascade_1]);
              sig = sig * gainEnv;
              sig = Pan2.ar(sig, pan, amp);
              sig = LeakDC.ar(sig);
              OffsetOut.ar(out, sig)
}).add;
)

//////////////////////////////////////////////////////////////////////////


(
~getRandomSet = {
              arg set;
              var numSteps = rrand(10,30);
              set = set ? ();
              set.putAll((
                             durations: {exprand(0.1,2)}!numSteps,
                             repetitions: {5.rand}!numSteps,
                             notes: {rrand(-24,24)}!numSteps,
        // added motif here
                             motif: {rrand(-12,12)}!5
              ));
};

~viewSet = {
              arg set;
              var window = Window.closeAll.new("Mark Fell Sequencer", Rect.new(300, 300, 1200, 400));
               var texts = (
                             durations: StaticText().string_("durations").font_("Helvetica-Bold", 14),
                             repetitions: StaticText().string_("repetitions").font_("Helvetica-Bold", 14),
                             notes: StaticText().string_("notes").font_("Helvetica-Bold", 14)
              );

              var sliders = (
                             durations: MultiSliderView().background_(Color.rand),
                             repetitions: MultiSliderView().background_(Color.rand),
                             notes: MultiSliderView().background_(Color.rand)
              );

              var buttons = (
                             durations: Button().states_([["scramble durations", Color.black, Color.grey]])
            .action_(~updateDur),
                             repetitions: Button().states_([["scramble repetitions", Color.black, Color.grey]])
            .action_(~updateRep),
                             notes: Button().states_([["scramble notes", Color.black, Color.grey]])
            .action_(~updateNotes)
              );

              var specs = (
                             durations: ControlSpec(0.01,10,\exp),
                             repetitions: ControlSpec(0,10,\lin,1),
                             notes: ControlSpec(0,72,\lin,0.5), //quarter-tones
              );

              var updater = {
                             loop{
                                           sliders.keysValuesDo{
                                                          arg k,sl;
                                                          sl.value = specs[k].unmap(set[k]);
                                           };
                                           0.1.wait;
                           };
              }.fork(AppClock);

               sliders.keysValuesDo{
                             arg k,sl;
                             sl.action = { set[k] = specs[k].map(sl.value).postln };
                             sl.elasticMode_(1);
              };

              window.view.layout_(
                             HLayout(
                                           VLayout(
                                                          texts[\durations],
                                                          sliders[\durations],
                                                          buttons[\durations]
                                           ),
                                           VLayout(
                                                          texts[\repetitions],
                                                          sliders[\repetitions],
                                                          buttons[\repetitions]
                                           ),
                                           VLayout(
                                                          texts[\notes],
                                                          sliders[\notes],
                                                          buttons[\notes]
                                           ),
                             )
              );

              window.onClose = { updater.free };
              window.front.alwaysOnTop_(true);
};

// get random set according to seed number
~makeSeed = {
              arg seed;
              thisThread.randSeed = seed;
              a = ~getRandomSet.();
              ~viewSet.(a);
};

// update durations
~updateDur = {
              a.durations = a.durations.scramble;
};

// update repetitions
~updateRep = {
              a.repetitions = a.repetitions.scramble;
};

// update notes
~updateNotes = {
              a.notes = a.notes.scramble;
};

// update motif
~updateMotif = {
              a.motif = a.motif.scramble;
};
)

(
~seed = 1403411654;

~makeSeed.(~seed);

Pdef(\fm,
              Pn(
                             Pfindur(6,
                                           Pbind(
                                                          \instrument, \fm,

                                                          \durMul, 0.5, //multiply duration
                                                          \dur, Pkey(\durMul) * (Pn(Plazy{ Pdup(Pseq(a.repetitions,1), Pseq(a.durations,1)) },inf)),

                                                          \atk, 0.001,
                                                          \rel, 0.25,
                                                          \midinote, Pseq([[57,60,64,65,70]],inf),
/*
                                                          \octave, Pstutter(3, Pseq([3,4,5], inf)),
                                                          \scale, Scale.minor(\just),
                                                          \degree, Pn(Plazy{ Prout {
                                                                        a.notes.do{
                                                                                      arg note,i;
                                                                                     var repetitions = a.repetitions.wrapAt(i);
                                                                                      repetitions.do {
                                                                                                     arg j;
                                                                                                     (note + .motif.wrapAt(j)).yield};
                                                                        }
                                                          }}, inf,
                                                          ),
*/

                                                          //FM Parameters
                                                          \ratio3, 0,
                                                          \ratio2, 0,
                                                          \ratio1, 0,
                                                          \ratio6, 0.251,
                                                          \ratio5, 0,
                                                          \ratio4, 0,
                                                           \mInd3, 1.462,
                                                          \mInd2, 1.938,
                                                          \mInd1, 2.873,

                                                          \mInd6, 1.065,
                                                          \mInd5, 1.793,
                                                          \mInd4, 3.283,

                                                          \amp3, 0.629,
                                                          \amp2, 0.241,
                                                          \amp1, 0.288,

                                                          \amp6, 0.780,
                                                          \amp5, 0.034,
                                                          \amp4, 0.433,
                                                          \fb, 0.9,
                                                          \amp, 0.05,
                                                          \pan, Pwhite(-0.75,0.75,inf),
                                                          \out, 0,

                                           )
                             ), inf
              )
).play(quant:1);
)



// update seed
~makeSeed.(1403411654);
~makeSeed.(1403251255);
~makeSeed.(1403255);

Pfset(~makeSeed.(1403411654), Pdef(\fm));
Pfset(~makeSeed.(1403251255), Pdef(\fm));
Pfset(~makeSeed.(1403255), Pdef(\fm));