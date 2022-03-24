
(
//s.freeAll;
/*~cleanUp = {
	Buffer.freeAll;
	/*ServerTree.removeAll;
	ServerQuit.removeAll;
	ServerBoot.removeAll;
	CmdPeriod.removeAll;
	Tdef.removeAll;*/
};

ServerQuit.add(~cleanUp);


~cleanUp.();*/

//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 64;

//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo_(96/60);
p.fadeTime_(2.5);
p.quant_(0);

/*
MidiClient.init;
MIDIIn.connectAll;
*/

s.waitForBoot;({
	// Dictionary, load SynthDefs,load Snippets, Stage Limiter, free all nodes in Server
    // buffer naming convention will be d[\k][0] or maybe d["k"][0];
	d = Dictionary.new;
	d.add(\folders -> PathName(thisProcess.nowExecutingPath.dirname +/+ "/buffers").entries);
	for (0, d[\folders].size-1,
		{arg i; d.add(d[\folders][i].folderName -> d[\folders][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	s.sync;
	("SynthDefs.scd").loadRelative;
	s.sync;
	("Snippets.scd").loadRelative;
	s.sync;
	StageLimiter.activate;
	s.sync;
	s.freeAll;

});
)


