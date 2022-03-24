
// fm1 playing

e.stop;
(
e = Pbind(\instrument,\fm1, \freq, Pseq([45,36,40,33,38,40].pyramidg,inf).midicps, \iScale,9800,\dur,Prand([1,5]/4,inf),\atk,0.5,\rel,1,\amp,0.1,\pan,Pwhite(-0.2,0.2)).play;
)
c = Pbind(\instrument,\fm1, \freq, Pseq([45,49,51,45,40,42].sputter,inf).midicps, \iScale,9,\dur,Prand([1,1.2]/4,inf),\atk,0.5,\rel,1,\amp,0.1,\pan,Pwhite(-0.7,0.7)).play;
c.pause;

e = Pbind(\instrument,\fm1, \freq, Pseq([[45,36,40],33],inf).midicps, \iScale,0.1,\dur,Pseq([4,5],inf),\atk,1,\rel,8,\amp,0.2,\pan,Pwhite(-0.2,0.2)).play;