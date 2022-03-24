//Boilerplate code for basic live coding functionality
//Run this with Ctrl/Cmd + Enter
(
s.freeAll;
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 64;

//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = (96/60);
p.fadeTime_(2.5);
p.quant_(0);

s.waitForBoot({
	d = Dictionary.new;
	d.add(\foldernames -> PathName(thisProcess.nowExecutingPath.dirname +/+ "/buffers").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	s.sync;
	("SynthDefs.scd").loadRelative;
	//loads snippets from setup folder
	s.sync;
	//("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	s.sync;
	//activate StageLimiter - Part of the BatLib quark
	StageLimiter.activate;
	s.sync;
	s.freeAll;
}).start;
);
