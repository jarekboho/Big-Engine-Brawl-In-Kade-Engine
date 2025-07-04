package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transGradient:FlxSprite;
	var steamTrans:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);

		steamTrans = new FlxSprite(0, -1);
		steamTrans.frames = Paths.getSparrowAtlas('steamtransition', 'shared');
		steamTrans.animation.addByPrefix('intro','Intro',24,false);
		steamTrans.animation.addByPrefix('end','end',24,false);
		steamTrans.antialiasing = FlxG.save.data.antialiasing;
		add(steamTrans);
		steamTrans.scrollFactor.set(0, 0);
		
		if (!isTransIn) 
		{
				steamTrans.animation.play('intro');
				steamTrans.animation.finishCallback = function(name:String){finishCallback();};
		}
		else 
		{
				steamTrans.animation.play('end');
				steamTrans.animation.finishCallback = function(name:String){close();};
		}

		if(nextCamera != null) {
			steamTrans.cameras = [nextCamera];
		}

		
		nextCamera = null;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}