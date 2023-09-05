

{
    var trate, dur, clk, pos, pan, snd, in, chain;
	var list = Wavetable.chebyFill(128, 1.0 / [1, 2,10, 3, 10, 5, 6, 10],zeroOffset: true);
    // list.plot;
    b = LocalBuf.newFrom(list);
	trate = MouseY.kr(60,600,1);
    dur = 60 / trate;
    clk = Impulse.kr(trate);
    pos = MouseX.kr(0,BufDur.kr(b)) + TRand.kr(0, 0.01, clk);
    pan = WhiteNoise.kr(0.6);
    TGrains.ar(4, clk, b, 1, pos, dur, pan, 0.1);
}.scope(4, zoom: 4);

