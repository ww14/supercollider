(~bus = Bus.audio(s,2);

	SynthDef(\reverb_ef, {
		arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);
/*
		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		12.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};
	*/
	verbSig = NHHall.ar(sig);

		//dry/wet mix
		totalSig = XFade2.ar(sig, verbSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
	}).add;

	SynthDef(\twotube,{arg preamp=0, delay1=100, delay2=50, k=0.0, loss=0.999, dur=0.5, pan=0.0, out=0, amp=1, minCf=30, maxCf=6000, minBpfHz=0.02, maxBpfHz=0.25,minRq=0.005, maxRq=0.04;
		var sig, env, senv;

		//k from -1 to 1

		senv = EnvGen.ar(Env([1,1,0,0],[(delay1+delay2)/SampleRate.ir,0.0,1.0]));
		sig = WhiteNoise.ar(preamp) * senv;


		env = EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2);
		sig = -2.dbamp * TwoTube.ar(sig,k,loss,delay1,delay2);
		//sig = Compander(sig);

		sig = BPF.ar(
			sig,
			LFNoise1.kr({LFNoise1.kr(0.13).exprange(minBpfHz,maxBpfHz)}!8).exprange(minCf, maxCf),
			LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(minRq, maxRq)
		);

	sig = HPF.ar(sig,40);

		sig = sig * env *amp;
		sig = Pan2.ar(sig,pan);

		Out.ar(out,sig);
	}).add;

)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////the piece ////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


(
c = TempoClock.default.tempo_(95/60);
t = Task({
Synth(\reverb_ef, [\in, ~bus, \out, 0]);
Pbindef(\twenty,
	\instrument, \twotube,
	\dur,Pn(Pshuf(1/[3,3,3,6],3),inf),
	\k, -0.7,
	\preamp,30*Pwhite(1,1.05,inf),
	\amp,-6.dbamp,
	\minRq,0.01,
	\maxRq,0.4,
	\minBpfHz,30,
	\maxBpfHz,60,//Pstep([150,70,350],14,inf), //31
	\minCf,100,//Pseg([125,100,125],96,\lin,inf),
	\maxCf,400,//Pseg([400,500,400],96,\lin,inf),
	\pan,0,
	\delay1,Pstep([[3, 9, 18],
		           [4 ,8, 19],
		           [6, 5, 22],
		           [3, 9, 18],
		           [4, 1, 19],
		           [6, 9, 22],
		           [3, 9, 17]],
	             2,inf),
	\delay2,Pstep([[1, 2, 4],
		           [1, 2, 4].rotate(1),
		           [1, 2, 4].rotate(-1),
		           [1,2,10],
        		   [8,2,1].rotate(1), // 1 was 12500
		           [8,2,10000],
		           [2, 4, 8], //.pyramidg.flop,
	],[
			28, //first
			14, //first rotation
			14, //second rotation
			14, //1-1-10
			14, //8-2-1
			28, //8-2-1 rotaion
			14  // 2-4-8
		]//[28, 14, 14,14,14, 14]
	,2), //Pseg([[8, 1, 24],[4, 10, 12],[8, 1, 24]],6,\step,inf),  //
	\out,~bus,
).play(quant:1);

	21.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[6,6,6,3],3),inf));
	7.wait;

	"first and second rotation".postln;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[3,3,3,6],3),inf));
	18.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[6,6,6,3],3),inf));
	7.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[3,3,3,6],3),inf));
	3.wait;

	"1-2-10 and 8-2-1 rotation".postln;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[60,60,60,3],3),inf),\delay2);
	//Pbindef(\twenty,\dur,Pn(Pshuf(1/[60,60,60,3],3),inf));
	21.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[3,3,3,6],3),inf));
	7.wait;


	"8-2-1".postln;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[60,60,60,3],3),inf));
	18.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[6,6,6,3],3),inf));
	7.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[3,3,3,6],3),inf));
	3.wait;

	"2-4-8 and 1-2-4".postln;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[20,30,20,1],3),inf));
	21.wait;
	Pbindef(\twenty,\dur,Pn(Pshuf(1/[3,3,3,6],3),inf));
	14.wait;
	Pbindef(\twenty).stop;
   });
)


// play it
t.play(c);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////testing////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


Pbindef{


Synth(\reverb_ef, [\in, ~bus, \out, 0]);
(
c = TempoClock.default.tempo_(95/60);
Pbindef(\twenty,
	\instrument, \twotube,
	\dur,Pn(Pshuf(1/[3,3,3,6],3),inf),
	\k, -0.7,
	\preamp,100*Pwhite(1,1.05,inf),
	\amp,0.2,
	\minRq,0.01,
	\maxRq,0.4,
	\minBpfHz,30,
	\maxBpfHz,60,//Pstep([150,70,350],14,inf), //31
	\minCf,100,//Pseg([125,100,125],96,\lin,inf),
	\maxCf,400,//Pseg([400,500,400],96,\lin,inf),
	\pan,0,
	\delay1,Pstep([[3, 9, 18],
		           [4 ,8, 19],
		           [6, 5, 22],
		           [3, 9, 18],
		           [4, 1, 19],
		           [6, 9, 22],
		           [3, 9, 17]],
	             2,inf),
	\delay2,[8,2,20], //Pseg([[8, 1, 24],[4, 10, 12],[8, 1, 24]],6,\step,inf),  //
	\out,~bus,
		).play(c);
	)

(
Pbindef(\twenty,
			\delay2,[8,2,10000].rotate(-1), //Pseg([[8, 1, 24],[4, 10, 12],[8, 1, 24]],6,\step,inf),  //
		);
	)