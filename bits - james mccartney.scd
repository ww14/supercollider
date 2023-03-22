
(
s.waitForBoot({
    Ndef(\bits, {
        var t = PulseCount.ar(Impulse.ar(8e3));
        var sig = HPF.ar(
            (
                ((t * 15) & (t >> 5)) |
                ((t * 5) & (t >> [3, 4])) |
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