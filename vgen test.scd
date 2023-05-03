//https://scintillatorsynth.org/docs/guides/vgens-overview/

(
~v = ScinServer.new.boot;
)

(
~red = ScinthDef.new(\red, {
    VRGBOut.pr(1.0, 0.0, 0.0);
}).add;
)

(
~redScinth = Scinth.new(\red);
)

(
~redScinth.free;
)

(
~w = ScinthDef.new(\wave, { |f=1|
    VBWOut.pr(VSinOsc.pr(freq: f));
}).add;
)

(
~k = Scinth.new(\wave);
)

(
~k.set(\f, 0.2);
)

(
~k.free;
)

(
~spot = ScinthDef.new(\spot, {
    VBWOut.pr(VLength.pr(VNormPos.pr));
}).add;
)

(
~d = Scinth.new(\spot);
)

(
~d.free;
)

(
~rings = ScinthDef.new(\rings, {
    var rad = VLength.pr(VNormPos.pr);  // rad is one-dimensional
    var rgb = rad * VVec3.pr(31, 41, 61); // rgb is 3D
    rgb = 0.5 + (rgb.sin * 0.5); // Can do arithmetic with vectors and scalars
    VVec4.pr(VX.pr(rgb), VY.pr(rgb), VZ.pr(rgb), 1.0);
}).add;
)

(
~rg = Scinth.new(\rings);
)

(
~rg.free;
)

(
~zoom = ScinthDef.new(\zoom, {
    var pos = VNormPos.pr;
    var box = 1.0 - max(VX.pr(pos).abs, VY.pr(pos).abs);
	var rad = VLength.pr(VNormPos.pr);  // rad is one-dimensional
	 var rgb = rad * VVec3.pr(31, 41, 61, 31); // rgb is 3D
	rgb = 0.5 + (rgb.sin * 0.5); // Can do arithmetic with vectors and scalars
    VRGBAOut.pr(VX.pr(rgb), VY.pr(rgb), VZ.pr(rgb), VSaw.pr(phase: box));
    //VRGBAOut.pr(VSaw.pr(phase: box));
}).add;
)

(
~z = Scinth.new(\zoom);
)

(
~zoom.free;
)