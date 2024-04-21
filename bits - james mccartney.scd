
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
		arg pulse = 8e3, t1a =15 , t1b = 5, t2a = 5, t2b = 3, t3a = 2, t3b = 9, t4a = 8, t4b = 11, bits =256, less = 3, add = 128, mul =3 ,rt60 = 0.1, stereo = 0.5 ;
        var t = PulseCount.ar(Impulse.ar(pulse));
        var sig = HPF.ar(
            (
                ((t * t1a) & (t >> t1b)) |
                ((t * t2a) & (t >> t2b)) |
                ((t * t3a) & (t >> t3b)) |
                ((t * t4a) & (t >> t4b)) |
                (((t*t) & t) | (t >> 3))
                - less % bits
            ) / add -1 * mul
            , 30
        ) * 0.1;
        //sig = JPverb.ar(sig, 0.1, 0.5, 0.1);
		sig = Splay.ar(sig);
	    sig = NHHall.ar(sig,rt60,stereo);
    }).gui;

});
)

Ndef('bits').set('t1a', 15 , 't1b',5, 't2a', 5, 't2b', 3, 't3a', 3, 't3b', 9, 't4a', 8, 't4b', 5, 'bits', 256, 'less', 3, 'add', 128, 'mul', 3 ,'rt60', 0.1, 'stereo', 0.45);