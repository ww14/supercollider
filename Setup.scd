//Boilerplate code for basic live coding functionality
//http://doc.sccode.org/Reference/StartupFile.html
// https://doc.sccode.org/Reference/AudioDeviceSelection.html
Server.killAll;
(
//increase number of buffers the server has access to for loading samples
//1. server config
s = Server.local;
o = Server.default.options;
// s.options.outDevice_(
// 	//"MME : Headphones (Realtek High Defini"
// 	//"MME : Speakers (Realtek High Definiti"
// 	//"Built-in Output" //default sound ouput
// 	//"Soundflower (2ch)" //in case you want to use some other output device
// 	//"MOTU UltraLite mk3 Hybrid"
// );
//o.numOutputBusChannels_(2);
//o.numInputBusChannels_(2);

//o.device = "ASIO : ASIO4ALL v2";
/*o.inDevice_("ASIO : ASIO4ALL v2");
o.outDevice_("ASIO : ASIO4ALL v2");*/


//o.inDevice_("Windows WASAPI : Microphone (Realtek High Defini");
//o.outDevice_("Windows WASAPI : Headphones ");

s.options.sampleRate_(44100);
s.options.memSize_(2.pow(20)); //extremely generous
s.newBusAllocators;
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

//2. initialize global variables
~out = 0;
~buffers = PathName(thisProcess.nowExecutingPath).parentPath++"buffers/"; //thisProcess refers to itself, metadata

//3. define buffers and busses

~makeBuffers = {
	b = Dictionary.new;
	PathName(~buffers).entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};

~makeBusses = {
	~bus = Dictionary.new;
	~bus.add(\reverb -> Bus.audio(s,2));
	~bus.add(\reverb2 -> Bus.audio(s,2));
	~bus.add(\comb -> Bus.audio(s,2));
	~bus.add(\chorus -> Bus.audio(s,2));
	// ~bus.add(\somenewbus -> Bus.audio(s,2));
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	s.bind({  //group commands as one bundle
		~mainGrp = Group.new;
		~reverbGrp = Group.after(~mainGrp);
		~reverb2Grp = Group.after(~mainGrp);
		~combGrp = Group.after(~reverbGrp);
		~chorusGrp = Group.after(~combGrp);
		~reverbSynth = Synth.new(
			\reverb,
			[
				\amp, 1,
				\predelay, 0.1,
				\revtime, 1.8,
				\lpf, 4500,
				\mix, 0.35,
				\in, ~bus[\reverb], //call in audio from the reverb bus
				\out, ~out,
			],
			~reverbGrp //make the synths target the newly created reverb group
		);
		~reverb2Synth = Synth.new(
			\reverb2,
			[
				\in, ~bus[\reverb2], //call in audio from the reverb bus
				\out, ~out,
			],
			~reverb2Grp //make the synths target the newly created reverb group
		);
		~combSynth = Synth.new(
			\comb,
			[
				\in, ~bus[\comb], //call in audio from the comb bus
				\out, ~out,
			],
			~combGrp //
		);
		//for some reason this bus wont work and messes up othernodes.
/*		~chorusSynth = Synth.new(
			\chorus,
			[
				\in, ~bus[\chorus], //call in audio from the chorus bus
				\out, ~out,
			],
			~chorusGrp
		);*/
	});
};


///////////////////////////////////////////
//event tree went here in orig composition 1 example
///////////////////////////////////////////


//4. register functions with ServerBoot/Quit/Tree
ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);

//5. boot server
s.waitForBoot({  //don't do the following until the server is booted

s.sync;  //wait to do the following until all asynchronous commands (eg boot server or add synthdef) are completed

	//6a. SynthDefs

//load synths
("SynthDefs.scd").loadRelative;
// add a fade function, super useful
	// source: https://scsynth.org/t/pbindef-fade-in-and-fade-out/1553/5
~fade = { |start, end, time, curve = 0| Pseg(Pseq([start, Pn(end)]), time, curve) };
//loads snippets from setup folder
//("Snippets.scd").loadRelative;
//wait, because otherwise it won't work for some reason
3.wait;
StageLimiter.activate;
//activate StageLimiter - Part of the BatLib quark

s.sync;


	//6b. register remaining functions with the server
ServerTree.add(~makeNodes);
//ServerTree.add(~makeEvents);
s.freeAll;  //causes servertree to evaluate the two functions

s.sync;

"Setup done!".postln;
})
)