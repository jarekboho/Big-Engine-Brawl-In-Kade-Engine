package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float;
	public var hideLastBG:Bool = false;
	public var tweenDuration:Float = 2;
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	public var swagBacks:Map<String, Dynamic> = [];
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = [];
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []];
	public var slowBacks:Map<Int, Array<FlxSprite>> = [];

	public var positions:Map<String, Map<String, Array<Int>>> = [
		'puffball' => ['gf' => [550, -130], 'bf' => [960, -320 + 350], 'thomas' => [-35, 0]],
		'endlessremix' => ['gf' => [550, -130], 'bf' => [960, -320 + 350], 'thomas' => [-35, 0]],
		'harbor' => ['gf' => [700, 230], 'bf' => [1000, 100 + 350], 'henry' => [-205 + -460, 300 + -210]],
		'sadstory' => ['gf' => [400, 130], 'sadbf' => [3000, 400 + 350], 'sadhenry' => [-1200, -450]],
		'splendid' => ['gf' => [400, 130], 'splendidbf' => [2250, -27 + 350], 'james' => [750, -130]],
		'ugh' => ['gf' => [400, 130], 'splendidbf' => [2250, -27 + 350], 'ughjames' => [750, -130]],
		'indignation' => ['gf' => [400, 130], 'indigbf' => [620, 250 + 350], 'gordon' => [795, -50]],
		'godraysremix' => ['gf' => [400, 130], 'indigbf' => [620, 250 + 350], 'gordondamn' => [795, -50]],
		'loathed' => ['gf' => [550, -130], 'loathed_gordon' => [-800, -700 + 350], 'alfred' => [760, -320]],
		'oldreliable' => ['gf' => [400, -230], 'reliablebf' => [300, -400 + 350], 'edward' => [100 + -460, 100 + -210]],
		'confusion' => ['gf' => [0, 0], 'bf' => [0, 0 + 350], 'fatass' => [-155, -310]]
	];

	public var ob1:FlxSprite;
	public var ob2:FlxSprite;
	public var ob3:FlxSprite;
	public var ob4:FlxSprite;
	public var ob5:FlxSprite;
	public var ob6:FlxSprite;
	public var ob7:FlxSprite;
	public var ob8:FlxSprite;
	public var ob9:FlxSprite;
	public var ob10:FlxSprite;
	public var ob11:FlxSprite;
	public var ob12:FlxSprite;
	public var ob13:FlxSprite;
	public var ob14:FlxSprite;
	public var ob15:FlxSprite;
	public var ob16:FlxSprite;

	public var jamessky:FlxBackdrop;

	public var modifier:Float = 1;

	public var exChar1:Character = null;
	public var exChar2:Character = null;

	public var loathedTrains:String = 'loathed_bgengine_';

	public var achieves:Array<String> = [];

	public var curLoathedState:Int = 0;

	public function new(daStage:String)
	{
		super();
		this.curStage = daStage;
		camZoom = 1.05;
		if (PlayStateChangeables.Optimize)
			return;

		switch (daStage)
		{
				case 'puffball':
					camZoom = 0.7;
					curStage = 'puffball';
					ob1 = new FlxSprite(-701,-488).loadGraphic(Paths.image('bgs/puffball/puffballstage', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(2700);
					ob1.updateHitbox();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);
				case 'endlessremix':
					camZoom = 0.7;
					curStage = 'endlessremix';
					ob1 = new FlxSprite(-701,-488).loadGraphic(Paths.image('bgs/endlessremix/station', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(2700);
					ob1.updateHitbox();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);
				
					ob2 = new FlxSprite(-701,-488).loadGraphic(Paths.image('bgs/endlessremix/nighttime_overlay', 'shared'));
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.setGraphicSize(2700);
					ob2.updateHitbox();
					ob2.alpha = 0.60;
					swagBacks['ob2'] = ob2;
					layInFront[2].push(ob2);
				case 'harbor':
					camZoom = 0.8;
					curStage = 'harbor';
					ob2 = new FlxSprite(-1254,-912).loadGraphic(Paths.image('bgs/harbor/sky', 'shared'));
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.setGraphicSize(3500);
					ob2.updateHitbox();
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);
	
					ob3 = new FlxSprite(-1254,-912).loadGraphic(Paths.image('bgs/harbor/clouds', 'shared'));
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.setGraphicSize(3500);
					ob3.updateHitbox();
					swagBacks['ob3'] = ob3;
					toAdd.push(ob3);
	
					ob1 = new FlxSprite(-1254,-912).loadGraphic(Paths.image('bgs/harbor/back', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(3500);
					ob1.updateHitbox();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);
	
					ob4 = new FlxSprite(1764,138);
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.frames = Paths.getSparrowAtlas('bgs/harbor/wata', 'shared');
					ob4.animation.addByPrefix('idle','wata',24,true);
					ob4.animation.play('idle');
					ob4.setGraphicSize(400);
					ob4.updateHitbox();
					swagBacks['ob4'] = ob4;
					toAdd.push(ob4);
	
					ob5 = new FlxSprite(-1254,-912).loadGraphic(Paths.image('bgs/harbor/night_overlay', 'shared'));
					ob5.antialiasing = FlxG.save.data.antialiasing;
					ob5.setGraphicSize(3500);
					ob5.updateHitbox();
					ob5.alpha = 0.30;
					swagBacks['ob5'] = ob5;
					layInFront[2].push(ob5);
					
					ob6 = new FlxSprite(-1254,-912).loadGraphic(Paths.image('bgs/harbor/fog', 'shared'));
					ob6.antialiasing = FlxG.save.data.antialiasing;
					ob6.setGraphicSize(3500);
					ob6.updateHitbox();
					ob6.alpha = 0.18;
					swagBacks['ob6'] = ob6;
					layInFront[2].push(ob6);
				case 'sadstory':
					camZoom = 0.275;
					curStage = 'sadstory';
					ob1 = new FlxSprite(-2350,-1600).loadGraphic(Paths.image('bgs/sadstory/ground', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(8315);
					ob1.updateHitbox();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);
	
					ob2 = new FlxSprite(-2250,-1650).loadGraphic(Paths.image('bgs/sadstory/insidetunnel', 'shared'));
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.setGraphicSize(8315);
					ob2.updateHitbox();
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);
	
					ob3 = new FlxSprite(-2350,-1545).loadGraphic(Paths.image('bgs/sadstory/brickwall', 'shared'));
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.setGraphicSize(8315);
					ob3.updateHitbox();
					swagBacks['ob3'] = ob3;
					layInFront[1].push(ob3);
	
					ob4 = new FlxSprite(-2350,-1600).loadGraphic(Paths.image('bgs/sadstory/foliage', 'shared'));
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.setGraphicSize(8315);
					ob4.updateHitbox();
					swagBacks['ob4'] = ob4;
					layInFront[1].push(ob4);
	
					ob5 = new FlxSprite(-2350,-1600).loadGraphic(Paths.image('bgs/sadstory/rails', 'shared'));
					ob5.antialiasing = FlxG.save.data.antialiasing;
					ob5.setGraphicSize(8315);
					ob5.updateHitbox();
					swagBacks['ob5'] = ob5;
					layInFront[1].push(ob5);

					ob7 = new FlxSprite(-2250,-1650).loadGraphic(Paths.image('bgs/endlessremix/nighttime_overlay', 'shared'));
					ob7.antialiasing = FlxG.save.data.antialiasing;
					ob7.setGraphicSize(8315);
					ob7.updateHitbox();
					ob7.alpha = 0.00001;
					swagBacks['ob7'] = ob7;
					layInFront[2].push(ob7);

					ob6 = new FlxSprite(-2250,-1650);
					ob6.frames = Paths.getSparrowAtlas('bgs/sadstory/rain', 'shared');
					ob6.antialiasing = FlxG.save.data.antialiasing;
					ob6.animation.addByPrefix('idle','rain idle',24,true);
					ob6.animation.play('idle');
					ob6.setGraphicSize(8315*2);
					ob6.updateHitbox();
					swagBacks['ob6'] = ob6;
					layInFront[2].push(ob6);
					ob6.alpha = 0.00001;
				case 'splendid':
					camZoom = 0.65;
					curStage = 'splendid';
					jamessky = new FlxBackdrop(Paths.image('bgs/splendid/jamesbg_skyloop', 'shared'),X);
					jamessky.y = -500;
					swagBacks['jamessky'] = jamessky;
					toAdd.push(jamessky);
	
					ob2 = new FlxSprite(-323,-349);
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.frames = Paths.getSparrowAtlas('bgs/splendid/jamesbg_hills', 'shared');
					ob2.animation.addByPrefix('jamesbg hills idle','jamesbg hills idle',24,true);
					ob2.animation.play('jamesbg hills idle');
					ob2.setGraphicSize(3280);
					ob2.updateHitbox();
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);
	
					ob3 = new FlxSprite(191,86);
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.frames = Paths.getSparrowAtlas('bgs/splendid/james_chasis', 'shared');
					ob3.animation.addByPrefix('james chasis idle','james chasis idle',34,true);
					ob3.animation.play('james chasis idle');
					ob3.setGraphicSize(2680);
					ob3.updateHitbox();
					swagBacks['ob3'] = ob3;
					toAdd.push(ob3);
	
					ob4 = new FlxSprite(191,86);
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.frames = Paths.getSparrowAtlas('bgs/splendid/james_phase2_chasis', 'shared');
					ob4.animation.addByPrefix('james phase2 chasis idle','james phase2 chasis idle',34,true);
					ob4.animation.play('james phase2 chasis idle');
					ob4.alpha = 0.00001;
					ob4.setGraphicSize(2680);
					ob4.updateHitbox();
					swagBacks['ob4'] = ob4;
					toAdd.push(ob4);

					ob5 = new FlxSprite();
					ob5.frames = Paths.getSparrowAtlas('bgs/splendid/sparks', 'shared');
					ob5.animation.addByPrefix('loop', 'sparks idle', 24, true);
					ob5.animation.play('loop');
					ob5.alpha = 0.00001;
					ob5.screenCenter(X);
					if(FlxG.state == PlayState.instance)
					{
					var playState = cast(FlxG.state, PlayState);
					ob5.cameras = [playState.camHUD];
					}
					ob5.y = FlxG.height - ob5.frameHeight + 20;
					swagBacks['ob5'] = ob5;
					layInFront[2].push(ob5);

					ob6 = new FlxSprite().loadGraphic(Paths.image('bgs/splendid/spark-overlay', 'shared'));
					ob6.alpha = 0.00001;
					ob6.screenCenter(X);
					if(FlxG.state == PlayState.instance)
					{
					var playState = cast(FlxG.state, PlayState);
					ob6.cameras = [playState.camHUD];
					}
					ob6.y = FlxG.height - ob6.frameHeight + 20;
					swagBacks['ob6'] = ob6;
					layInFront[2].push(ob6);
				case 'ugh':
					camZoom = 0.65;
					curStage = 'ugh';
					jamessky = new FlxBackdrop(Paths.image('bgs/splendid/jamesskyugh', 'shared'),X);
					jamessky.scrollFactor.set();
					jamessky.y = -500;
					swagBacks['jamessky'] = jamessky;
					toAdd.push(jamessky);
		
					ob2 = new FlxSprite(-323,-349);
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.frames = Paths.getSparrowAtlas('bgs/splendid/jamesbg_hills', 'shared');
					ob2.animation.addByPrefix('jamesbg hills idle','jamesbg hills idle',24,true);
					ob2.animation.play('jamesbg hills idle');
					ob2.setGraphicSize(3280);
					ob2.updateHitbox();
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);
		
					ob3 = new FlxSprite(191,86);
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.frames = Paths.getSparrowAtlas('bgs/splendid/james_ugh_chasis', 'shared');
					ob3.animation.addByPrefix('james ugh chasis idle','james ugh chasis idle',34,true);
					ob3.animation.play('james ugh chasis idle');
					ob3.setGraphicSize(2680);
					ob3.updateHitbox();
					swagBacks['ob3'] = ob3;
					toAdd.push(ob3);
	
					ob4 = new FlxSprite(-200,-300).loadGraphic(Paths.image('bgs/splendid/ughoverlay', 'shared'));
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.setGraphicSize(5000);
					ob4.updateHitbox();
					ob4.alpha = 0.15;
					swagBacks['ob4'] = ob4;
					layInFront[2].push(ob4);
				case 'indignation':
					camZoom = 0.5;
					curStage = 'indignation';
					if(FlxG.state == PlayState.instance)
					{
					var playState = cast(FlxG.state, PlayState);
					playState.doMiddleScroll = true;
					}

					ob1 = new FlxSprite(-1075,-739).loadGraphic(Paths.image('bgs/indignation/bg', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					
					ob1.setGraphicSize(3865);
					ob1.updateHitbox();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);

					ob5 = new FlxSprite(ob1.x + ob1.width,-739).loadGraphic(Paths.image('bgs/indignation/bg', 'shared'));
					ob5.antialiasing = FlxG.save.data.antialiasing;
					
					ob5.setGraphicSize(3865);
					ob5.updateHitbox();
					swagBacks['ob5'] = ob5;
					toAdd.push(ob5);

					ob6 = new FlxSprite(ob1.x - ob1.width,-739).loadGraphic(Paths.image('bgs/indignation/bg', 'shared'));
					ob6.antialiasing = FlxG.save.data.antialiasing;
					
					ob6.setGraphicSize(3865);
					ob6.updateHitbox();
					swagBacks['ob6'] = ob6;
					toAdd.push(ob6);
					
					ob2 = new FlxSprite(-918,-177);
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.frames = Paths.getSparrowAtlas('bgs/indignation/door_open', 'shared');
					ob2.animation.addByPrefix('indig_shed doorcloseidle','door open closed',24,true);
					ob2.animation.addByPrefix('indig_shed dooropenidle','door open idle',24,true);
					ob2.animation.addByPrefix('indig_shed dooropen','door open open',24,false);
					ob2.animation.play('indig_shed doorcloseidle');
					ob2.setGraphicSize(985);
					ob2.updateHitbox();
					swagBacks['ob2'] = ob2;
					layInFront[1].push(ob2);
	
					ob3 = new FlxSprite(1645,-177);
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.frames = Paths.getSparrowAtlas('bgs/indignation/door_open', 'shared');
					ob3.animation.addByPrefix('indig_shed doorcloseidle','door open closed',24,true);
					ob3.animation.addByPrefix('indig_shed dooropenidle','door open idle',24,true);
					ob3.animation.addByPrefix('indig_shed dooropen','door open open',24,false);
					ob3.animation.play('indig_shed doorcloseidle');
					ob3.setGraphicSize(985);
					ob3.updateHitbox();
					swagBacks['ob3'] = ob3;
					layInFront[1].push(ob3);
	
					ob4 = new FlxSprite(380,-177);
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.frames = Paths.getSparrowAtlas('bgs/indignation/door_gordon', 'shared');
					ob4.animation.addByPrefix('indig_shed dooropenidle','door middle idle',24,true);
					ob4.animation.addByPrefix('indig_shed doorcloseidle','door middle alt idle',24,true);
					ob4.animation.addByPrefix('indig_shed doorclose','door middle close',24,false);
					ob4.animation.addByPrefix('indig_shed dooropen','door middle open',24,false);
					ob4.animation.play('indig_shed dooropenidle');
					ob4.setGraphicSize(985);
					ob4.updateHitbox();
					swagBacks['ob4'] = ob4;
					layInFront[1].push(ob4);

					exChar1 = new Character(-220 + -460, 290 + -210, 'indighenry');
					swagBacks['exChar1'] = exChar1;
					toAdd.push(exChar1);
					exChar1.dance();

					exChar2 = new Character(2400 + -460, 310 + -210, 'indigjames');
					swagBacks['exChar2'] = exChar2;
					toAdd.push(exChar2);
					exChar2.dance();
				case 'godraysremix':
					camZoom = 0.65;
					curStage = 'godraysremix';
					if(FlxG.state == PlayState.instance)
					{
					var playState = cast(FlxG.state, PlayState);
					playState.doMiddleScroll = true;
					}

					ob1 = new FlxSprite(-1075,-739).loadGraphic(Paths.image('bgs/indignation/bg', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
				
					ob1.setGraphicSize(3865);
					ob1.updateHitbox();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);
				
					ob2 = new FlxSprite(-912,-187);
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.frames = Paths.getSparrowAtlas('bgs/indignation/indig_sheddoor', 'shared');
					ob2.animation.addByPrefix('indig_shed doorcloseidle','indig_shed doorcloseidle',24,true);
					ob2.animation.play('indig_shed doorcloseidle');
					ob2.setGraphicSize(975);
					ob2.updateHitbox();
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);
	
					ob3 = new FlxSprite(1656,-187);
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.frames = Paths.getSparrowAtlas('bgs/indignation/indig_sheddoor', 'shared');
					ob3.animation.addByPrefix('indig_shed doorcloseidle','indig_shed doorcloseidle',24,true);
					ob3.animation.play('indig_shed doorcloseidle');
					ob3.setGraphicSize(975);
					ob3.updateHitbox();
					swagBacks['ob3'] = ob3;
					toAdd.push(ob3);
	
					ob4 = new FlxSprite(378,-187);
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.frames = Paths.getSparrowAtlas('bgs/indignation/indig_sheddoor', 'shared');
					ob4.animation.addByPrefix('indig_shed dooropenidle','indig_shed dooropenidle',24,true);
					ob4.animation.play('indig_shed dooropenidle');
					ob4.setGraphicSize(975);
					ob4.updateHitbox();
					swagBacks['ob4'] = ob4;
					layInFront[1].push(ob4);
	
					ob5 = new FlxSprite(-1075,-739).loadGraphic(Paths.image('bgs/indignation/night_overlay', 'shared'));
					ob5.antialiasing = FlxG.save.data.antialiasing;
					ob5.setGraphicSize(3865);
					ob5.updateHitbox();
					ob5.alpha = 0.60;
					swagBacks['ob5'] = ob5;
					layInFront[2].push(ob5);
				case 'loathed':
					camZoom = 1.05;
					curStage = 'loathed';
					ob16 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					if(FlxG.state == PlayState.instance)
					{
					var playState = cast(FlxG.state, PlayState);
					ob16.cameras = [playState.camHUD];
					}

					ob1 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase1/sky', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(Std.int(2160));
					ob1.updateHitbox();
					ob1.x = -539; ob1.y = -685;
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);

					ob2 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase1/clouds', 'shared'));
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.setGraphicSize(Std.int(2160));
					ob2.updateHitbox();
					ob2.scrollFactor.set(0.5, 0.5);
					ob2.x = -539; ob2.y = -685;
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);

					ob3 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase1/stage', 'shared'));
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.setGraphicSize(Std.int(2160));
					ob3.updateHitbox();
					ob3.x = -539; ob3.y = -685;
					swagBacks['ob3'] = ob3;
					toAdd.push(ob3);

					ob10 = new FlxSprite();
					for (i in 1...15)
					{
						ob10.loadGraphic(Paths.image('backgrounds/loathed/trains/${loathedTrains}${i}', 'shared'));
					}
					ob10.setPosition(1622,50 - ob10.height/2);
					ob10.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['ob10'] = ob10;
					toAdd.push(ob10);

					ob4 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase1/brickwall', 'shared'));
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.setGraphicSize(Std.int(2160));
					ob4.updateHitbox();
					ob4.x = -539; ob4.y = -485;
					swagBacks['ob4'] = ob4;
					layInFront[2].push(ob4);

					ob5 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase2/sky', 'shared'));
					ob5.antialiasing = FlxG.save.data.antialiasing;
					ob5.setGraphicSize(Std.int(2160));
					ob5.updateHitbox();
					ob5.x = -539; ob5.y = -685;
					ob5.alpha = 0.00001;
					swagBacks['ob5'] = ob5;
					toAdd.push(ob5);

					ob6 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase2/clouds2', 'shared'));
					ob6.antialiasing = FlxG.save.data.antialiasing;
					ob6.setGraphicSize(Std.int(2160));
					ob6.updateHitbox();
					
					ob6.scrollFactor.set(0.5, 0.5);
					ob6.x = -539; ob6.y = -685;
					ob6.alpha = 0.00001;
					swagBacks['ob6'] = ob6;
					toAdd.push(ob6);

					ob7 = new FlxSprite().loadGraphic(Paths.image('backgrounds/loathed/phase2/stage2', 'shared'));
					ob7.antialiasing = FlxG.save.data.antialiasing;
					ob7.setGraphicSize(Std.int(2160));
					ob7.updateHitbox();
					ob7.x = -539; ob7.y = -685;
					ob7.alpha = 0.00001;
					swagBacks['ob7'] = ob7;
					toAdd.push(ob7);

					ob8 = new FlxSprite(-2250,-1650).loadGraphic(Paths.image('bgs/endlessremix/nighttime_overlay', 'shared'));
					ob8.antialiasing = FlxG.save.data.antialiasing;
					ob8.setGraphicSize(8315);
					ob8.updateHitbox();
					ob8.alpha = 0.40;
					swagBacks['ob8'] = ob8;
					layInFront[2].push(ob8);

					ob9 = new FlxSprite(-2250,-1650);
					ob9.frames = Paths.getSparrowAtlas('bgs/sadstory/rain', 'shared');
					ob9.antialiasing = FlxG.save.data.antialiasing;
					ob9.animation.addByPrefix('idle','rain idle',24,true);
					ob9.animation.play('idle');
					ob9.setGraphicSize(4320);
					ob9.updateHitbox();
					swagBacks['ob9'] = ob9;
					layInFront[2].push(ob9);
				case 'oldreliable':
					camZoom = 2;
					curStage = 'oldreliable';
					ob1 = new FlxSprite().loadGraphic(Paths.image('backgrounds/reliable/insideshed', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(Std.int(1425));
					ob1.updateHitbox();
					ob1.x = -539; ob1.y = -371;
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);

					ob2 = new FlxSprite().loadGraphic(Paths.image('backgrounds/reliable/bg', 'shared'));
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.setGraphicSize(Std.int(1425));
					ob2.updateHitbox();
					ob2.x = -539; ob2.y = -371;
					swagBacks['ob2'] = ob2;
					toAdd.push(ob2);
		
					ob3 = new FlxSprite().loadGraphic(Paths.image('backgrounds/reliable/door1', 'shared'));
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.setGraphicSize(Std.int(1425));
					ob3.updateHitbox();
					ob3.x = -539; ob3.y = -371;
					swagBacks['ob3'] = ob3;
					toAdd.push(ob3);
		
					ob4 = new FlxSprite().loadGraphic(Paths.image('backgrounds/reliable/door2', 'shared'));
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.setGraphicSize(Std.int(1425));
					ob4.updateHitbox();
					ob4.x = -539; ob4.y = -371;
					swagBacks['ob4'] = ob4;
					layInFront[1].push(ob4);
				case 'confusion':
					camZoom = 1;
					curStage = 'confusion';

					ob1 = new FlxSprite().loadGraphic(Paths.image('awards/tophamofficeblank', 'shared'));
					ob1.antialiasing = FlxG.save.data.antialiasing;
					ob1.setGraphicSize(Std.int(FlxG.width));
					ob1.screenCenter();
					swagBacks['ob1'] = ob1;
					toAdd.push(ob1);

					if(FlxG.state == PlayState.instance)
					{
					var playState = cast(FlxG.state, PlayState);
					playState.doMiddleScroll = true;
					}

					ob1.scrollFactor.set();

	var achievementsStuff:Array<Dynamic> = [
		['Welcome to Sodor!',			'(Play Puffball)',									'awardpuffball',		false],
		['Big Engine Brawl!',			'(Play the Main Week)',								'awardmainweek',		false],
		['Always and always and always.','(Play Sad Story)',								'awardsadstory',		false],
		['Old Tunes, New Twists!',		'(Play all the Remixes)',							'awardremix',			false],
		['It isn\'t wrong, but we just don\'t do it.',	'(Get a Game Over)',				'awardgameover',		false],
		['The Stout Gentleman.',		'(Play Confusion & Delay)',							'awardconfusiondelay',	false],
		['Express Coming Through!',		'(Full Combo the Main Week)',						'awardexpress',			false],
		['Hero of Sodor.',				'(Discover Loathed)',								'awardloathed',			false],
		['Really Useful Engine!',		'(Unlock all achievements)',						'awarduseful',			false],
		['Really Useful Engine!',		'(Unlock all achievements)',						'awardreallyuseful',	false]
	];


				for(i in 0...achievementsStuff.length-2)
					{
							achieves.push(achievementsStuff[i][2]);
					}

					var photos = new FlxSpriteGroup();
					var xFuckShit:Int = 0;
					for (i in 0...achieves.length)
						{
							var achieveImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('award portraits/${achieves[i]}', 'shared'));
							achieveImage.scale.x = 0.2;
							achieveImage.scale.y = 0.2;
							achieveImage.updateHitbox();
							achieveImage.x = 10 + achieveImage.width * i;
							if (i > 0)
								achieveImage.x += 15 * i;
							achieveImage.y += 25;
							if (xFuckShit > 4)
							{
								achieveImage.x = 10 + achieveImage.width * (i - 5);
								if (i - 5 > 0)
									achieveImage.x += 15 * (i - 5);
								achieveImage.y += achieveImage.height;
							}
							
							xFuckShit++;
							achieveImage.scrollFactor.set();
							photos.add(achieveImage);
						}

								achieves.push(achievementsStuff[achievementsStuff.length-1][2]);
					
var achieveImage:FlxSprite = new FlxSprite(FlxG.width/4*3 - 175, FlxG.height/2 - 225).loadGraphic(Paths.image('award portraits/${achieves[achieves.length-1]}', 'shared'));
								achieveImage.scale.x = 0.2;
								achieveImage.scale.y = 0.2;
								achieveImage.updateHitbox();
								photos.add(achieveImage);

					swagBacks['photos'] = photos;
					toAdd.push(photos);
					photos.scrollFactor.set();

					ob4 = new FlxSprite().loadGraphic(Paths.image('awards/topham3', 'shared'));
					ob4.antialiasing = FlxG.save.data.antialiasing;
					ob4.setGraphicSize(Std.int(FlxG.width));
					ob4.screenCenter();
					swagBacks['ob4'] = ob4;
					toAdd.push(ob4);
					ob4.scrollFactor.set();
					
					ob2 = new FlxSprite().loadGraphic(Paths.image('awards/awardsoverlaymultiply', 'shared'));
					ob2.antialiasing = FlxG.save.data.antialiasing;
					ob2.setGraphicSize(Std.int(FlxG.width));
					ob2.screenCenter();
					ob2.blend = MULTIPLY;
					ob2.scrollFactor.set();
					swagBacks['ob2'] = ob2;
					layInFront[2].push(ob2);

					ob3 = new FlxSprite().loadGraphic(Paths.image('awards/awardsoverlay2add', 'shared'));
					ob3.antialiasing = FlxG.save.data.antialiasing;
					ob3.setGraphicSize(Std.int(FlxG.width));
					ob3.screenCenter();
					ob3.blend = ADD;
					ob3.scrollFactor.set();
					swagBacks['ob3'] = ob3;
					layInFront[2].push(ob3);
					FlxG.sound.play(Paths.sound('cnd/freeplay/confusion_freeplay_${FlxG.random.int(1, 2)}', 'shared'));
			default:
				{
					camZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback', 'shared'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront', 'shared'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					swagBacks['stageFront'] = stageFront;
					toAdd.push(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains', 'shared'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					swagBacks['stageCurtains'] = stageCurtains;
					toAdd.push(stageCurtains);
				}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

			switch (curStage)
			{
				case 'loathed':
				if (ob10.x > -2000)
					ob10.x -= 20;
				if (ob10.x < -1000 && FlxG.random.int(0,800) == 0 && curLoathedState == 1)
					{
						ob10.loadGraphic(Paths.image('backgrounds/loathed/trains/${loathedTrains}${FlxG.random.int(1,15)}'));
						ob10.setPosition(1622,50 - ob10.height/2);
						FlxG.sound.play(Paths.sound('loathedtrainpass'));
					}
				case 'splendid':
				jamessky.x += (elapsed*200) * modifier;
				case 'ugh':
				jamessky.x += elapsed*200;
			}
	}

	override function stepHit()
	{
		super.stepHit();

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}
	}
}
