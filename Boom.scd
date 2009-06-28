//Boom!

//Synth Def
(
SynthDef(\boom,{arg out=0, amp=1, te=0.02, lo=0.9998, ts=0.1, aT=0.01, sn=0, filtFreq=30, mix=0.0, room=0.25, damp=0.5, vol=1;

var excitation, tension, loss, snare, toggle;

excitation = EnvGen.kr(Env.perc(aT), 
	                         MouseButton.kr(-1, 1), 
                             timeScale: ts, doneAction: 0
                            ) * PinkNoise.ar(0.4);
tension = te;
loss = lo;

snare= {arg dec; EnvGen.kr(Env.linen(0.001, 0.2, dec,0.33,-3), //HP Filtered white noise for metal snares on snaredrum preset
	                         MouseButton.kr(-1, 1), 
                             timeScale: ts, doneAction: 0
                            ) * HPF.ar(WhiteNoise.ar(sn*0.05), 2000)};

toggle = ToggleFF.kr(Trig1.kr(KeyState.kr(11,1,0,0), 0.0001));
        
                            
Out.ar(out, toggle*FreeVerb.ar(
							Mix.new([	(Pan2.ar(HPF.ar(MembraneCircle.ar(excitation, tension, loss), filtFreq), 0.0))*amp, //use MembraneHexagon if too CPU intensive
										snare.value(1.5)*amp,
										snare.value(1.5*0.66)*amp
										]),
							mix,
							room,
							damp)
		);
				
}).send(s)
)

a= Synth(\boom, [\out, 0]);     			//Synth


//GUI 
(

var window, isOn, rim, skin,
	ds, dtCS, dlCS, csfunc, ut, utb, ul, ulb, utMin, utMax, ulMin, ulMax, utFunc, ulFunc, 
	snare, kick, timp, user,
	reverbTitle, mixText, roomText, dampText, mixSlid, roomSlid, dampSlid, dryVal, wetVal, roomVal, dampVal, reverbCS;

ds = Array.newClear(4);		//Drum sliders
dtCS= Array.newClear(4);		//Drum tension control spec
dlCS= Array.newClear(4);		//Drum loss control spec
utMin = Array.newClear(4);	//User tension min slider and extras
utMax = Array.newClear(4);	//User tension max slider and extras
ulMin = Array.newClear(4);	//User loss min slider and extras
ulMax = Array.newClear(4);	//User loss max slider and extras

//Window properties
window=SCWindow("Boom", 
Rect(210, 131, 1000, 787),false);
window.view.background = Color.new255(0,0,0,100);
						

csfunc = {arg min=0.9995, max=0.999, warp='exponential', step=0.00001, start=0.00001; [min, max, warp, step,start].asSpec}; //ControlSpec function

//Drum names
user = SCStaticText(window, Rect(485, 0, 250, 40)).string ="User";
user.font = Font("MarkerFelt-Thin", 15);
snare = SCStaticText(window, Rect(195, 275, 250, 40)).string ="Snare";
snare.font = Font("MarkerFelt-Thin", 15);
kick = SCStaticText(window, Rect(770, 275, 250, 40)).string ="Kick";
kick.font = Font("MarkerFelt-Thin", 15);
timp = SCStaticText(window, Rect(475, 557, 250, 40)).string ="Timpani";
timp.font = Font("MarkerFelt-Thin", 15);

//Drum Sliders

	//Snare
ds[0] = SCSlider(window, Rect(233, 277, 250, 39.35)); 
dtCS[0] = csfunc.value(0.035, 0.0005, 'exponential');
dlCS[0] = csfunc.value(0.9998, 0.9992, 'exponential');
ds[0].action_({
				a.set(	\amp, 2,
						\te, dtCS[0].map(ds[0].value), 
						\lo, dlCS[0].map(ds[0].value), 
						\sn, 1,
						\filtFreq, 150,
						"Snare".postln,
						"Tension: ".post, dtCS[0].map(ds[0].value).postln,
						"Loss: ".post, dlCS[0].map(ds[0].value).postln)
				});

	//Kick
ds[1] = SCSlider(window, Rect(519, 275.45, 250, 39.35));
dtCS[1] = csfunc.value(0.008, 0.001, 'exponential');
dlCS[1] = csfunc.value(0.9995, 0.9996, 'linear');
ds[1].action_({
				a.set(	\amp, 1,
						\te, dtCS[1].map(ds[1].value), 
						\lo, dlCS[1].map(ds[1].value), 
						\sn, 0,
						\filtFreq, 30,
						"Kick".postln,
						"Tension: ".post, dtCS[1].map(ds[1].value).postln,
						"Loss: ".post, dlCS[1].map(ds[1].value).postln)
				});

	//User
ds[2] = SCSlider(window, Rect(482,27.545,39.35,250));
dtCS[2] = csfunc.value(0.008, 0.001, 'exponential');
dlCS[2] = csfunc.value(0.9995,0.999, 'exponential');
ds[2].action_({
				a.set(	\amp, 1,
						\te, dtCS[2].map(ds[2].value), \lo, dlCS[2].map(ds[2].value), 
						\sn, 0,
						"User".postln,
						"Tension: ".post, dtCS[2].map(ds[2].value).postln,
						"Loss: ".post, dlCS[2].map(ds[2].value).postln)
				});

	//Timpani			
ds[3] = SCSlider(window, Rect(482, 314.8, 39.35, 250));
dtCS[3] = csfunc.value(0.01, 0.004, 'exponential');
dlCS[3] = csfunc.value(0.99985, 0.99995, 'exponential');
ds[3].action_({
				a.set(	\amp, 1,
						\te, dtCS[3].map(ds[3].value), 
						\lo, dlCS[3].map(ds[3].value), 
						\sn, 0,
						\filtFreq, 30,
						"Timpani".postln,
						"Tension: ".post, dtCS[3].map(ds[3].value).postln,
						"Loss: ".post, dlCS[3].map(ds[3].value).postln)
				});

//Drum skin and rim			
window.drawHook = {
			rim = Rect(232, 27.545, 538, 538);
			Pen.fillColor = Color.new255(0, 0, 0, 125);
			Pen.fillOval(rim);
			skin = Rect(251, 46.433, 500, 500);
			Pen.fillColor = Color.new255(255, 255, 255, 175);
			Pen.fillOval(skin)};

	
//User Controls
u= SCStaticText(window, Rect(100, 500, 150, 40)).string = "User Drum Settings";
u.font = Font("MarkerFelt-Thin", 15);
	
	//Tension
utFunc = csfunc.value(0.001, 0.1, 'exponential', 0.001, 0.001);
ut = SCStaticText(window, Rect(125, 550, 100,20)).string = "Tension";
		//Centre Slider
utMax[0] =  SCSlider(window, Rect(50, 575, 200,30));
utMax[1] = utFunc;
utMax[2] = SCStaticText(window, Rect(275, 580, 100, 20));
utMax[2].string = "0.001";		
utMax[3] = SCStaticText(window, Rect(10, 580, 100, 20)).string = "Centre";
utMax[0].action_({
				utMax[2].string = utMax[1].map(utMax[0].value);
				a.set(	\amp, 1,
						\te, utMax[1].map(utMax[0].value),
						\sn, 0);
				});
				
		//Rim Slider			
utMin[0] =  SCSlider(window, Rect(50, 620, 200, 30));
utMin[1] = utFunc;
utMin[2] = SCStaticText(window, Rect(275, 625, 100, 20));
utMin[2].string = "0.001";	
utMin[3] = SCStaticText(window, Rect(10, 625, 100, 20)).string = "Rim";
utMin[0].action_({
				var mapVal = utMin[1].map(utMin[0].value);
				utMin[2].string = utMin[1].map(utMin[0].value);
				a.set(	\amp, 1,
						\te, utMin[1].map(utMin[0].value),
						\sn, 0);
				});		
		//Assign tension button			
utb= SCButton(window, Rect(325, 600, 100,20))
		.states_([["Assign Values", Color.black, Color.red]])
		.action_({  dtCS[2] = csfunc.value(utMax[1].map(utMax[0].value), 
												utMin[1].map(utMin[0].value), 'exponential');
		          });			


	//Loss
ulFunc = csfunc.value(0.999, 0.999999, 'exponential', 0.00001);
ul = SCStaticText(window, Rect(130, 660, 100,20)).string = "Loss";
		//Centre Slider
ulMax[0] =  SCSlider(window, Rect(50, 685, 200,30));
ulMax[1] = ulFunc;
ulMax[2] = SCStaticText(window, Rect(275, 690, 100, 20));
ulMax[2].string = "0.999";		
ulMax[3] = SCStaticText(window, Rect(10, 690, 100, 20)).string = "Centre";
ulMax[0].action_({
				ulMax[2].string = ulMax[1].map(ulMax[0].value);
				a.set(	\amp, 1,
						\lo, ulMax[1].map(ulMax[0].value),
						\sn, 0);
				});
				
		//Rim Slider			
ulMin[0] =  SCSlider(window, Rect(50, 730, 200, 30));
ulMin[1] = ulFunc;
ulMin[2] = SCStaticText(window, Rect(275, 735, 100, 20));
ulMin[2].string = "0.999";	
ulMin[3] = SCStaticText(window, Rect(10, 735, 100, 20)).string = "Rim";
ulMin[0].action_({
				var mapVal = ulMin[1].map(ulMin[0].value);
				ulMin[2].string = ulMin[1].map(ulMin[0].value);
				a.set(	\amp, 1,
						\lo, ulMin[1].map(ulMin[0].value),
						\sn, 0);
				});		
				
		//Assign loss button				
ulb= SCButton(window, Rect(325, 710, 100,20))
		.states_([["Assign Values", Color.black, Color.red]])
		.action_({  dlCS[2] = csfunc.value(ulMax[1].map(ulMax[0].value), 
												ulMin[1].map(ulMin[0].value), 'exponential');
		          });

//Reverb Controls

reverbTitle = SCStaticText(window, Rect(775, 500, 100,40)).string = "Reverb Settings";
reverbTitle.font = Font("MarkerFelt-Thin", 15);

	//Dry/Wet Ratio Slider
reverbCS = csfunc.value(0,1, 'linear', 0.01);
mixText = SCStaticText(window, Rect(780, 550, 100,20)).string = "Dry/Wet Ratio";
mixSlid = SCSlider(window, Rect(725, 575, 200,30));
dryVal = SCStaticText(window, Rect(935, 580, 100, 20)).string = "100 /";
wetVal = SCStaticText(window, Rect(965, 580, 100, 20)).string = "0";
mixSlid.action_({ a.set( \mix, reverbCS.map(mixSlid.value));
					dryVal.string = 100-(reverbCS.map(mixSlid.value)*100).abs + "/";
					wetVal.string = reverbCS.map(mixSlid.value)*100.abs});

	//Room Size Slider
roomText = SCStaticText(window, Rect(780, 620, 100,20)).string = "Room Size";
roomSlid = SCSlider(window, Rect(725, 645, 200,30)).value_(0.25);
roomVal = SCStaticText(window, Rect(965, 645, 100, 20)).string = "25";
roomSlid.action_({ a.set( \room, reverbCS.map(roomSlid.value));
						roomVal.string = reverbCS.map(roomSlid.value)*100.abs});
						
	//HF Dampening Slider					
dampText = SCStaticText(window, Rect(780, 690, 100,20)).string = "HF Dampening";
dampSlid = SCSlider(window, Rect(725, 715, 200,30)).value_(0.5);
dampVal = SCStaticText(window, Rect(965, 715, 100, 20)).string = "50";
dampSlid.action_({ a.set( \damp, reverbCS.map(roomSlid.value));
						dampVal.string = reverbCS.map(dampSlid.value)*100.abs});
						
//Window bits
window.onClose = { if(isOn=true, {a.free})};
isOn=true;
window.front;
window.view.focus(true);

)
