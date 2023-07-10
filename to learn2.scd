// edit: forgot loading the buffer
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
var amp = 0;

a = {
	var sig = PlayBuf.ar(1, b, loop: 1);
	var amp = Amplitude.ar(sig, 0.01, 0.25);
	SendReply.ar(Impulse.ar(25), '/amp', amp);
	(sig * 0.1).dup
}.play;

OSCdef(\amp, { |msg|
	amp = msg[3];
	defer { v.refresh };
}, '/amp', s.addr);

p = Pbind(
	\theta, Pseries(0, 0.1, inf),
	\red, sin(Pkey(\theta)) * 0.5 + 0.5,
	\green, sin(Pkey(\theta) + 1) * 0.5 + 0.5,
	\blue, sin(Pkey(\theta) + 2) * 0.5 + 0.5
).asStream;

v = UserView(nil, Rect(800, 200, 500, 400)).front
.drawFunc_({ |view|
	var b = view.bounds.moveTo(0, 0);
	var c = b.center;

	var colorEvent = p.next(Event.new);
	var color = Color(colorEvent[\red], colorEvent[\green], colorEvent[\blue]);

	var size = amp * b.width * 0.45;

	Pen
	.color_(color)
	.fillOval(Rect.aboutPoint(c, size, size*sin(size)))
	.draw(4);
});

v.onClose = { OSCdef(\amp).free; a.release };
)