package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.filters.ShaderFilter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;

class GameOverSubstate extends MusicBeatSubstate
{
	var inMenu:Bool = false;
	var menuItems:Array<String> = ['Retry'];
	var curSelected:Int = 0;
	var camMenu:FlxCamera;
	var selectedSomethin:Bool = false;
	var gameOverSprite:FlxSprite;
	var grpMenuShit:FlxTypedGroup<AlphaBetter>;

	var tvFilter:ShaderFilter;
	var screenShader:Screen = new Screen();
	var shaderTime:Float = 0;

	var isLoathed:Bool = false;
	var loathedLoop:FlxSprite;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.Stage.curStage;

		super();

		isLoathed = (daStage == 'loathed');
		loathedLoop = new FlxSprite();

		tvFilter = new ShaderFilter(screenShader);
		screenShader.noiseIntensity.value = [0.75];

		menuItems.push('Quit');

		Conductor.songPosition = 0;

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		Conductor.changeBPM(100);

		grpMenuShit = new FlxTypedGroup<AlphaBetter>();
		add(grpMenuShit);

		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.add(camMenu);

		if(!isLoathed)
		{
			FlxG.camera.setFilters([tvFilter]);
			camMenu.setFilters([tvFilter]);
		}

		if (!isLoathed)
		{
			camMenu.flash(FlxColor.WHITE, 10);
			regenMenu();
		}
		else
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					camMenu.flash(FlxColor.WHITE, 3);
					loathedLoop.frames = Paths.getSparrowAtlas('gameover/loathed_gameover_loop');
					loathedLoop.animation.addByPrefix('loop','loathed gameover loop loop',24,true);
					loathedLoop.setGraphicSize(Std.int(FlxG.width*1.05));
					loathedLoop.updateHitbox();
					loathedLoop.screenCenter();
					loathedLoop.x -= 20;
					loathedLoop.y -= 80;
					loathedLoop.animation.play('loop');
					loathedLoop.cameras = [camMenu];
					add(loathedLoop);
				});
		}
	}

	function changeSelection(change:Int = 0):Void
	{
			curSelected += change;
	
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;
	
			var bullShit:Int = 0;
	
			for (item in grpMenuShit.members)
			{
				item.alpha = 0.6;
	
				if (item.ID == curSelected)
				{
					item.alpha = 1;
				}
			}

	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new AlphaBetter(0, 75 * i + FlxG.height/2 + 25, 0, menuItems[i], 48, false);
			item.alpha = 0;
			item.ID = i;
			item.cameras = [camMenu];
			item.screenCenter(X);
			grpMenuShit.add(item);

		}

		gameOverSprite = new FlxSprite().loadGraphic(Paths.image('game_over', 'shared'));
		gameOverSprite.setGraphicSize(Std.int(gameOverSprite.width/4));
		gameOverSprite.updateHitbox();
		gameOverSprite.screenCenter(X);
		gameOverSprite.y = 100;
		gameOverSprite.alpha = 0;
		gameOverSprite.cameras = [camMenu];
		add(gameOverSprite);

		setMenu();
	}

	function setMenu()
	{
			for (item in grpMenuShit)
				{
					if (item.ID == curSelected)
						FlxTween.tween(item, {alpha: 1}, 1, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
								{
									inMenu = true;
									changeSelection();
								}
						});
					else
						FlxTween.tween(item, {alpha: 0.6}, 1, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
								{

								}
						});
				}

					FlxTween.tween(gameOverSprite, {alpha: 1}, 1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
							{

							}
					});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		screenShader.iTime.value = [shaderTime];
		shaderTime += FlxG.elapsed;

		if (inMenu && !selectedSomethin && !isLoathed)
		{
					if (FlxG.keys.justPressed.UP)
					{
						changeSelection(-1);
					}
					if (FlxG.keys.justPressed.DOWN)
					{
						changeSelection(1);
					}
	
				if (controls.ACCEPT)
				{
					selectedSomethin = true;
					var daSelected:String = menuItems[curSelected];
					if (daSelected == "Retry")
						{
							FlxG.sound.play(Paths.sound('gameover/gameOverEnd'));
							FlxG.sound.music.stop();
						}
						else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							FlxG.sound.music.stop();
						}
						FlxFlicker.flicker(grpMenuShit.members[curSelected], 0.6, 0.05, true, false, function(flick:FlxFlicker)
						{
							switch (daSelected)
							{
								case "Retry":
									endBullshit();
								case "Quit":
									FlxG.sound.music.stop();
									PlayState.seenCutscene = false;

									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									CustomFadeTransition.nextCamera = PlayState.instance.camOther;
									FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
									CustomFadeTransition.finishCallback = function() {
									if (PlayState.isStoryMode)
									{
									GameplayCustomizeState.freeplayBf = 'bf';
									GameplayCustomizeState.freeplayDad = 'dad';
									GameplayCustomizeState.freeplayGf = 'gf';
									GameplayCustomizeState.freeplayNoteStyle = 'normal';
									GameplayCustomizeState.freeplayStage = 'stage';
									GameplayCustomizeState.freeplaySong = 'bopeebo';
									GameplayCustomizeState.freeplayWeek = 1;
									FlxG.switchState(new MainMenuState());
									}
									else
									FlxG.switchState(new FreeplayState());
									};
									PlayState.loadRep = false;
									PlayState.stageTesting = false;
							}
						});
					
				}
				if (controls.BACK)
				{
						curSelected = menuItems.length - 1;
						changeSelection();
				}
		}
		else if (isLoathed)
		{
				if (controls.ACCEPT)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('gameover/gameOverEnd'));
					FlxG.sound.music.stop();
					endBullshit();
				}
		
				if (controls.BACK)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.sound.music.stop();

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					CustomFadeTransition.nextCamera = PlayState.instance.camOther;
					FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
					CustomFadeTransition.finishCallback = function() {
					if (PlayState.isStoryMode)
					{
					GameplayCustomizeState.freeplayBf = 'bf';
					GameplayCustomizeState.freeplayDad = 'dad';
					GameplayCustomizeState.freeplayGf = 'gf';
					GameplayCustomizeState.freeplayNoteStyle = 'normal';
					GameplayCustomizeState.freeplayStage = 'stage';
					GameplayCustomizeState.freeplaySong = 'bopeebo';
					GameplayCustomizeState.freeplayWeek = 1;
					FlxG.switchState(new MainMenuState());
					}
					else
					FlxG.switchState(new FreeplayState());
					};
					PlayState.loadRep = false;
					PlayState.stageTesting = false;
				}
		}

			if (PlayState.SONG.stage == 'confusion' && !FlxG.sound.music.playing && !isEnding && !selectedSomethin)
			{
				coolStartDeath(0.2);

				FlxG.sound.play(Paths.sound('cnd/gameover/confusion_gameover_' + FlxG.random.int(1, 6)), 1, false, null, true, function() {
					if(!isEnding)
					{
						FlxG.sound.music.fadeIn(0.2, 1, 4);
					}
				});
			}
			else if (!FlxG.sound.music.playing && !isEnding && !selectedSomethin)
			{
				coolStartDeath();
			}

		if (FlxG.save.data.InstantRespawn)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			CustomFadeTransition.nextCamera = PlayState.instance.camOther;
			FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
			CustomFadeTransition.finishCallback = function() {
			LoadingState.loadAndSwitchState(new PlayState());
			};
		}
	}

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (!isLoathed)
		{
			FlxG.sound.playMusic(Paths.music('Game_Over_Start'), volume, false);
			FlxG.sound.music.onComplete = function()
				{
					FlxG.sound.playMusic(Paths.music('Game_Over_Loop'), volume, true);
				}
		}
		else
		{
			FlxG.sound.playMusic(Paths.music('altgameOver'), volume, false);
			FlxG.sound.music.onComplete = function()
				{
					FlxG.sound.playMusic(Paths.music('altgameOver_loop'), volume, true);
				}
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					CustomFadeTransition.nextCamera = PlayState.instance.camOther;
					FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
					CustomFadeTransition.finishCallback = function() {
					LoadingState.loadAndSwitchState(new PlayState());
					};
					PlayState.stageTesting = false;
				});
			});
		}
	}
}
