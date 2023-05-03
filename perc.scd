("Setup/Setup.scd").loadRelative // load this file

(
~spica = PathName(thisProcess.nowExecutingPath).parentPath++"setup/cellospica/";
b = Dictionary.new;
b.add(\foldernames -> PathName(~spica).entries);
	for (0, b[\foldernames].size-1,
		{arg i; b.add(b[\foldernames][i].folderName -> b[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
)



( ~v = Pbind(
	\instrument,\vplay,
	\buf,b["spica"][49],

	\dur,Pseq([1,4,3,2,1].normalizeSum/1,inf),
	\rate,Pseq([1,4,-3,2,7,1,4,5,-3,1].normalize,inf),
	\amp,0.2,
	\out,~bus[\reverb],
);
)

~play_v = ~v.play;


(
~c = Pbind(
	\instrument,\vplay,
	\buf,b["spica"][49],
	\dur,Pseq([4,3,2,3,1].normalizeSum,inf),
	\rate,Pseq([1,7,-3,1].normalize,inf),
	\amp,0.5

);

);

~play_v.pause;


( ~b = Pbind(
	\instrument,\vplay,
	\buf,b["spica"][49],
	\dur,Pseq([1]/8,inf),
	\rate,Pseq([1,4,-3,2,6,1,4,5,-3,1].normalize,inf),
	\amp,0.5
);
)

~play_v = ~v.play;

~play_v.stream = ~c.asStream;
~play_v.stream = ~b.asStream;
~play_v.stream = ~v.asStream;
