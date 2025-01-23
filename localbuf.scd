(
{
    var buf1 = LocalBuf.newFrom((0..5).scramble);
    var buf2 = LocalBuf.newFrom((0..5).scramble - 1);
    var buf3 = LocalBuf.newFrom((0..5).scramble + 1);
    var index = DetectIndex.kr([buf1, buf2], SinOsc.kr([0.85, 0.2], 0, 6).trunc).poll;
    var freq = IndexL.kr([buf2, buf3], index).poll * 40 + 40;
    SawDPW.ar(freq,0) * 0.1
}.play;
)


// DegreeToKey
// modal space
// mouse x controls discrete pitch in dorian mode
(
play({
    var mix;

    mix =

    // lead tone
    SinOsc.ar(
        (
            DegreeToKey.kr(
                [0, 2, 3.2, 5, 7, 9, 10].as(LocalBuf),
                MouseX.kr(0, 15),        // mouse indexes into scale
                12,                    // 12 notes per octave
                1,                    // mul = 1
                72                    // offset by 72 notes
            ).poll
            + LFNoise1.kr([3,3], 0.04)    // add some low freq stereo detuning
        ).midicps,                        // convert midi notes to hertz
        0,
        0.1)

    // drone 5ths
    + RLPF.ar(LFSaw.ar([48,55].midicps, 0.15),
        SinOsc.kr(0.1, 0, 10, 72).midicps, 0.1, 0.1);

    // add some 70's euro-space-rock echo
    CombN.ar(mix, 0.31, 0.31, 2, 1, mix)
})
)


(
{
var in, chain, n;
	n = 7;
	in = RHPF.ar(SinOsc.ar(600*BrownNoise.ar(0.05.dup(n))),LFNoise1.kr([0.1,0.0001]).range(60,50).round(2).midicps, 0.01, 0.9);
    chain = FFT({LocalBuf(2048, 1)}.dup(n), in);
    chain = PV_BrickWall(chain, LFNoise2.kr(20.dup(n)));
    Splay.ar(IFFT(chain)) // inverse FFT
}.play;
)

s.belaMaxScopeChannels > 0

(
{
var in, chain, n;
	n = 40;
	//in = SinGrain.ar(Impulse.kr(10), 0.05, BrownNoise.kr(1).range(400, 500).round(10));
	in = PinkNoise.ar([LFPulse.ar(10,0,0.25, 0.7), LFPulse.ar(0.01,0,0.8, 0.5)]);
	in = Mix.ar( -40.dbamp *  //a.linexp(0,10,-50,-10).dbamp
		Klank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], in));
    chain = FFT({LocalBuf(2048, 1)}.dup(n), in);
	chain = PV_BrickWall(chain, LFNoise2.kr(0.1.dup(n),0.8));
	chain = PV_RandComb(chain, 0.35, Impulse.kr(400,0,0.5));
    Splay.ar(IFFT(chain)) // inverse FFT
}.play;
)

SinGrain



(
SynthDef.new(\fm1, {
	var buf1, buf2, buf3, index, freq, snd, perc, perc_2, trig, in, arp, detect_p, chain, chain2, env;
    buf1 = LocalBuf.newFrom((0..5).scramble);
	buf2 = LocalBuf.newFrom((0..5).scramble + 2);
	buf3 = LocalBuf.newFrom((0..5).scramble + 1);
	index = DetectIndex.ar([buf1, buf2], LFPar.kr([\rate1.kr(0.25), \rate2.kr(0.2)], 0, 6).trunc).poll;
	freq = IndexL.ar([buf2, buf3], index).poll * 40 + 40;
	snd = (
		(LFPulse.ar(freq,0,\pulAmp.kr(1))*0.15) +
		(LFSaw.ar(freq*\sawMul.kr(4),0,\sawAmp.kr(1))*0.05) +
		(LFCub.ar(freq *\cubMul.kr(3),0,\cubAmp.kr(1))*0.04) +
		(LFPar.ar(freq.lag(3) *\parMul.kr(8),0,\parAmp.kr(0))*0.04)
	).tanh;
	snd = Splay.ar(snd);

	trig = LFDNoise3.kr([4.9,2.4],300,300); // LFNoise1.kr([4.9,2.45],300,300)
	in = SinOscFB.ar(trig,trig/1000);
	chain = FFT(LocalBuf(2048), in, 0.85, 1);
	// the lead voice
	//chain = PV_RandComb(chain, \wipe.kr(0.68), trig);//Impulse.kr(2)); // 0.68
	chain = PV_PartialSynthP(chain);
	    //chain1 = PV_RectComb(chain1, 1, LFTri.kr(0.097,0,0.4,0.5),LFTri.kr(0.24,0,-0.5,0.5));//Impulse.kr(2));
	chain = IFFT(chain,1)!2;
	//chain = Splay.ar(chain);
	chain = -12.dbamp * MoogFF.ar(chain,  SinOsc.kr(LFDNoise3.kr(1).linlin(-1,1,0.1, 1000)).range(300, 4000),1,0,\amp_gloop.kr(0).lag3);

/*
	perc = Splay.ar(GVerb.ar(Resonz.ar(freq,[1800,2000,2400,2800],0.05,0.05).tanh,25,0.5),0.5).softclip;
	perc_2 = Splay.ar(DelayC.ar(
		Ringz.ar(freq,2*[180,240,440],0.5,0.0001*[1,0.75,0.5]),
		5,
		DPW4Saw.ar(5.reciprocal, [0, pi]).range(0, 5))
	).softclip;
	*/
	snd = DFM1.ar(snd, SinOsc.kr(LFSaw.kr(\vibrato.kr(0.13)).range(0.2, 2)).range(80, 2000), \res.kr(0.01), \inputgain.kr(1) , \pass.kr(0), \noiselevel.kr(0.003));
	snd = LeakDC.ar(snd);
	//snd = NHHall.ar(snd!2,(1..5),0.05);
	//GVerb.ar(snd,\roomsize.kr(10),0.91,0.2,0.5,\spread.kr(10));
	snd = NHHall.ar(snd!2,(1..4),0.05);
	snd = snd + chain;
	env = Env.asr(1, \amp.kr(1), \release.kr(2),-5).kr(2, \gate.kr(1));
	snd = snd * env;
	Out.ar(0,snd);
}).add;
);

40.cpsmidi
a = Synth(\fm1)
a.set(\inputgain,1,\sawMul,2,\parAmp,0.25)
a.set(\inputgain,0.751,\sawMul,4,\parAmp,0.1)
a.set(\amp_gloop,0.8)
a.set(\parAmp,0.1,\parMul,2)
a.set(\cubMul,5)
a.set(\cubMul,4)
a.set(\rate1,1,\rate2,1.2,\vibrato,0.3)
a.set(\rate1,0.25,\rate2,0.2,\vibrato,0.13)
a.set(\rate1,3.1,\rate2,3.2,\vibrato, 0.03)
a.set(\rate1,0.1,\rate2,0.4,\vibrato,0.003)
a.set(\rate1,0.01,\rate2,0.02,\vibrato,0.3)
a.set(\rate1, 10,\rate2,10.5,\vibrato,100)
a.set(\vibrato,10,\pass,0)
a.set(\cubMul,5)
a.set(\cubMul,6)
a.set(\cubMul,8)

a.release