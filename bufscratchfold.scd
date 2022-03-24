//https://pustota.basislager.org/_/sc-help/Help/Tutorials/Smooth_Clipping_and_Folding.html

(
SynthDef(\bufScratchFold, { |bufnum = 0, globalFreq = 0.7, localOscSize = 0.01, foldRange = 0.28,
    localFreq = 0.87, preAmp = 1.4, smoothAmount = 0.36|
    var sig = BufRd.ar(
        1,
        bufnum,
        (
            // define global and local movement
            LFDNoise3.ar(globalFreq).range(0.2, 0.7) +
            SmoothFoldS.ar(
                // adding space by decorrelating the local scratching / oscillation
                LFTri.ar(localFreq * ({ LFDNoise3.ar(0.2).range(0.999, 1.001) } ! 2)) * preAmp,
                foldRange: foldRange,
                smoothAmount: smoothAmount
            ) * localOscSize
        ) * BufFrames.ir(bufnum)
    );
    // as local oscillation can stick with positive or negative values, a dc leaker is recommended
    Out.ar(0, LeakDC.ar(sig) * EnvGate.new)
}).add
)

x = Synth(\bufScratchFold, [bufnum: b["spica"][0]])

x.set(\preAmp, 2)
x.set(\foldRange, 0.0001)
x.set(\localFreq, 50)
x.set(\localOscSize, 0.005)
x.set(\foldRange, 0.2)
x.set(\localFreq, 0.5)