b = Buffer.alloc(s, s.sampleRate, 5);

b = Buffer.alloc(s, s.sampleRate, 5);

(
{
var writeSig, writePos, readPos;
writeSig = SinOsc.ar({ LFDNoise3.kr(1).exprange(10, 100) } ! 5);
writePos = Phasor.ar(0.0, MouseX.kr(0,200), 0.0, BufFrames.kr(b));
BufWr.ar(writeSig, b, writePos);
readPos = Phasor.ar(0.0, MouseY.kr(0,100), 0.0, BufFrames.kr(b));
Splay.ar(BufRd.ar(5, b, readPos));
}.play;
)

b = Buffer.alloc(s, s.sampleRate, 50);

(
{
var writeSig, writePos, readPos;
writeSig = SinOsc.ar({ LFDNoise3.kr(1).exprange(10, 100) } ! 50);
writePos = Phasor.ar(0.0, MouseX.kr(0,200), 0.0, BufFrames.kr(b));
BufWr.ar(writeSig, b, writePos);
readPos = Phasor.ar(0.0, MouseY.kr(0,100), 0.0, BufFrames.kr(b));
Splay.ar(BufRd.ar(50, b, readPos));
}.play;
)

(
SynthDef.new(\aliasingSynth, {
	//Aliasing Synth. Based on a Reaktor Ensemble by Dietrich Pank.
	//https://www.native-instruments.com/es/reaktor-community/reaktor-user-library/entry/show/5241/:
	//Coded by Santi Vilanova (Playmodes) and Eric Sluyter, with the invaluable help of Thor_Madsen


	arg in=0,out=0;
	var b, writeSig, writePos, readPos;
	var aliased,filteredHP,filteredLP,inputLPfm,inputHPfm,finalsig,writef,readf;

	var readratio=\readratio.kr(1!5); //0-5
	var readfine=\readfine.kr(0!5); //-0.5 0.5
	var writeratio=\writeratio.kr(1!5); //0-5
	var writefine=\writefine.kr(0!5); //-0.5 0.5
	var transpose=\transpose.kr([0,0,0,0,0]); //-2 2

	var readlfofreq=\readlfofreq.kr(0.3!5)*12; //normalized input
	var writelfofreq=\writelfofreq.kr(0.13!5)*12;
	var readlfoamp=\readlfoamp.kr(0!5); //normalized input
	var writelfoamp=\writelfoamp.kr(0!5);

	var lppitch=\lppitch.kr(120).midicps; //0-130
	var lpres=\lpres.kr(0.7);
	var hppitch=\hppitch.kr(20).midicps;
	var hpres=\hpres.kr(0.7);
	var lpfm=\lpfm.kr(1000); //0-3000
	var hpfm=\hpfm.kr(0);
	var drive=\dbdrive.kr(10); //0-30db

	b = LocalBuf.new(1024,5);

	//aliasing synth (5 voices)
	writef=SinOsc.kr(writelfofreq,0,writelfoamp)+writeratio+writefine+transpose;
	readf=SinOsc.kr(readlfofreq,0,readlfoamp)+readratio+readfine+transpose;

	///////////////just for testing
	//writef=MouseX.kr(0,5)!5;
	//readf=MouseY.kr(0,5)!5;
	//////////////

	writePos = Phasor.ar(0.0, writef, 0.0, BufFrames.kr(b)); //write position header
	readPos = Phasor.ar(0.0, readf, 0.0, BufFrames.kr(b)); //read position header
	BufWr.ar(readPos, b, writePos); //in the original synth, writeSig=readPos


	aliased = Splay.ar(BufRd.ar(5, b, readPos)); //aliasing synthesis result


	//filter  (stereo)
	inputLPfm=aliased*lpfm; //we use the input also as an FM source
	inputHPfm=aliased*hpfm;

	filteredHP=BHiPass4.ar(aliased,hppitch+inputHPfm,hpres,drive.dbamp).tanh;//LP filter and saturation
	filteredLP=BLowPass4.ar(filteredHP,lppitch+aliased,lpres); //HP filtering in series

	finalsig=LeakDC.ar(filteredLP,0.995,drive.dbamp).tanh; //final saturation and dc correction
	finalsig=Limiter.ar(finalsig*0.1);
	Out.ar(out, finalsig);

}).add;
)

a = Synth(\aliasingSynth);
a.set(\transpose,0!5);

a.set(\readratio,[1,2,0,4.0,5],\writeratio,[1,2,0,4.0,1]);//,\writeratio,0.1,\lpres,0.9);
a.set(\readratio,0.13,\writeratio,0.1,\lpres,0.9);
a.set(\readfine,-0.3,\writefine,0.5,\lpres,0.9);