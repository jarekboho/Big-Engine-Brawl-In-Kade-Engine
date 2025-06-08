package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;

class BebOptionsSubstate extends MusicBeatSubstate
{
    var diffs:Array<String> = ['easy', 'normal', 'hard'];
    var diffMap:Map<String, String> = [

		'easy' => 'mini',
		'normal' => 'nar',
		'hard' => 'stand'

	];
    var bg:FlxSprite;
    var allowedToChange:Bool = false;
    var backButton:FlxSprite;
    var grpDiffs:FlxSpriteGroup;

    override function create(){
        bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
	bg.antialiasing = FlxG.save.data.antialiasing;
        bg.screenCenter();
        bg.alpha = 0;
        add(bg);
        bg.scrollFactor.set(0, 0);

        FlxG.mouse.visible = true;

        backButton = new FlxSprite().loadGraphic(Paths.image('options/back_button', 'shared'));
        backButton.x = 10;
        backButton.setGraphicSize(Std.int(backButton.width * 0.8));
        backButton.updateHitbox();
        backButton.y = FlxG.height - backButton.height - 10;
        backButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25);
        add(backButton);
        backButton.scrollFactor.set(0, 0);

        grpDiffs = new FlxSpriteGroup();
        for(i in 0...diffs.length){
            var imgPath:String = 'options/difficulties/${diffs[i]}';
            var optionBar:FlxSprite = new FlxSprite(1280, FlxG.height/2 + (172 * (i - 1))).loadGraphic(Paths.image(imgPath, 'shared'));
            optionBar.scale.set(0.3, 0.3);
            optionBar.updateHitbox();
            optionBar.y -= optionBar.height / 2;
            optionBar.ID = i;
            grpDiffs.add(optionBar);
        }
        add(grpDiffs);
        grpDiffs.scrollFactor.set(0, 0);

                FlxG.sound.play(Paths.sound('topham_select', 'shared'));
                FlxTween.tween(bg, {alpha: 0.75}, 0.25, {ease: FlxEase.backInOut, onComplete: function(lol:FlxTween){
                    for(i in grpDiffs){
                        FlxTween.tween(i, {x: 808}, 0.75, {ease: FlxEase.backOut, onComplete: function(lol:FlxTween){allowedToChange = true;}});
                    }
                }});

			var mainMenuState = cast(FlxG.state, MainMenuState);
			@:privateAccess
			mainMenuState.menuItems.forEach(function(spr:FlxSprite)
			{
			if(spr.ID == 0)
			spr.visible = true;
			});

        super.create();
    }

var difficulty:Int = -1;

    override function update(elapsed:Float){
    if (allowedToChange)
    if (controls.BACK || FlxG.mouse.justPressedRight)
    back();

    if (allowedToChange && FlxG.mouse.overlaps(backButton))
    {
    backButton.loadGraphic(Paths.image('options/back_button_selected', 'shared'));
    if (FlxG.mouse.justPressed)
    back();
    }
    else
    backButton.loadGraphic(Paths.image('options/back_button', 'shared'));

            if(allowedToChange)
            {
            for(i in grpDiffs)
                {
                    if (FlxG.mouse.overlaps(i))
                    {
                        if (FlxG.mouse.justPressed)
                            {
                                FlxG.mouse.visible = false;
                                FlxG.sound.play(Paths.sound('confirmMenu'));
                                difficulty = i.ID;
                                trace('clicked on ${i.ID} | difficulty is: ${difficulty}');
                                i.loadGraphic(Paths.image('options/difficulties/${diffs[i.ID]} glow', 'shared'));
                                i.updateHitbox();
                                selectWeek();

			FlxTween.tween(backButton, {alpha: 0}, 0.25);
			for(i in grpDiffs)
			{
                        FlxTween.tween(i, {alpha: 0}, 0.25);
			}
			var mainMenuState = cast(FlxG.state, MainMenuState);
			@:privateAccess
			FlxFlicker.flicker(mainMenuState.menuItems.members[0], 1, 0.06, false, false);
			FlxTween.tween(bg, {alpha: 0}, 0.25, {onComplete: function(lol:FlxTween){
			close();
			}});
                            }
                    }
                    if (i.ID != difficulty)
                    {
                        i.loadGraphic(Paths.image('options/difficulties/${diffs[i.ID]}', 'shared'));
                        i.updateHitbox();
                    }
                }
            }
    }

    function back()
    {
    allowedToChange = false;

    FlxG.mouse.visible = false;

    FlxG.sound.play(Paths.sound('cancelMenu'));
    FlxTween.tween(backButton, {alpha: 0}, 0.25);
                    for(i in grpDiffs)
                    {
                        FlxTween.tween(i, {x: 1280}, 0.75, {ease: FlxEase.backIn});
                    }
			new FlxTimer().start(0.75, function(tmr:FlxTimer)
			{
			FlxTween.tween(bg, {alpha: 0}, 0.25, {onComplete: function(lol:FlxTween){
			close();
			var mainMenuState = cast(FlxG.state, MainMenuState);
			@:privateAccess
			mainMenuState.selectedSomethin = false;
			}});
			});
    }

	var curWeek:Int = 1;

	static function weekData():Array<String>
	{
		return ["flying-kipper", "splendid", "indignation"];
	}

	function selectWeek()
	{
			PlayState.storyPlaylist = weekData();
			PlayState.isStoryMode = true;
			PlayState.songMultiplier = 1;
			allowedToChange = false;

			PlayState.storyDifficulty = difficulty;

			var diff:String = ["-easy", "", "-hard"][PlayState.storyDifficulty];
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diff));
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				CustomFadeTransition.nextCamera = null;
				FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
				CustomFadeTransition.finishCallback = function() {
				LoadingState.loadAndSwitchState(new PlayState(), true);
				};
			});


	}
}