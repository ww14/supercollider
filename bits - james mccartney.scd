
(
s.waitForBoot({
    Ndef(\bits, {
        var t = PulseCount.ar(Impulse.ar(8e3));
        var sig = HPF.ar(
            (
                ((t * 15) & (t >> 5)) |
                ((t * 5) & (t >> 3)) |
                ((t * 2) & (t >> 9)) |
                ((t * 8) & (t >> 11)) |
                (((t*t) & t) | (t >> 3))
                - 3 % 256
            ) / 127-1 * 3
            , 20
        ) * 0.1;
        sig = JPverb.ar(sig, sig, 0.5, sig);
    }).play;

});
)




(
s.waitForBoot({
    Ndef(\bits, {
		arg bits =256, less = 3, divisor = 128, mul =3 ,rt60 = 0.1, stereo = 0.5 ;
        var t = PulseCount.ar(Impulse.ar(8e3));
        var sig = HPF.ar(
            (
                ((t * 15) & (t >> 5)) |
                ((t * 5) & (t >> [3, 4])) |
                ((t * 2) & (t >> 9)) |
                ((t * 8) & (t >> 11)) |
                (((t*t) & t) | (t >> 3))
                - less % bits
            ) / divisor -1 * mul
            , 30
        ) * 0.1;
        sig = JPverb.ar(sig, sig, 0.5, sig);
		sig = Splay.ar(sig);
	    sig = NHHall.ar(sig,rt60,stereo);
    }).gui;

});
)