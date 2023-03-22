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



(
{
var in, chain, n ;
	n = 4;
	//in = SinGrain.ar(Impulse.kr(10), 0.05, BrownNoise.kr(1).range(400, 500).round(10));
	in = PinkNoise.ar([0.007, 0.0071]);
	in = Mix.ar( -1.dbamp *  //a.linexp(0,10,-50,-10).dbamp
		Klank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], in));
    chain = FFT({LocalBuf(2048, 1)}.dup(n), in);
	chain = PV_BrickWall(chain, LFNoise2.kr(0.2.dup(n)));
    Splay.ar(IFFT(chain)) // inverse FFT
}.play;
)

SinGrain