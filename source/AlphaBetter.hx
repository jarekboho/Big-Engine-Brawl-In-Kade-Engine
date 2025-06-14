package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flash.media.Sound;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class AlphaBetter extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;
	public var isFreeplay:Bool = false;
	public var textSize:Int = 1;
	public var sprTracker:FlxSprite;
	public var textTracker:AlphaBetter;
	public var copyAlpha:Bool = false;
	public var copyVisible:Bool = true;

	public var text:String = "";

	var _finalText:String = "";
	var yMulti:Float = 1;

	var xPosResetted:Bool = false;

	var splitWords:Array<String> = [];

	public var isBold:Bool = false;

	public var finishedText:Bool = false;
	public var typed:Bool = false;

	public var typingSpeed:Float = 0.05;

	var textObject:FlxText;
	var typedObject:FlxTypeText;
	var font = "vcr.ttf";
	public function new(x:Float, y:Float, FieldWidth:Float = 0, ?text:String = "", ?textSize:Int = 48, typed:Bool = false, ?font:String = "vcr.ttf", ?typingSpeed:Float = 0.05)
	{
		super(x, y);
		forceX = Math.NEGATIVE_INFINITY;
		this.textSize = textSize;
		this.font = font;

		_finalText = text;
		this.text = text;
		this.typed = typed;

		if (text != "")
		{
			if (typed)
			{
				startTypedText(typingSpeed);
			}
			else
			{
				addText();
			}
		} else {
			finishedText = true;
		}
	}

	

	public function addText()
	{
		if (textObject != null)
			{
				textObject.destroy();
				textObject = null;
			}
		textObject = new FlxText(0, 0, 0, text, textSize);
		textObject.setFormat(Paths.font(font), textSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textObject.borderSize = 4;
		if (FlxG.save.data.antialiasing)
		{
		textObject.antialiasing = true;
		}
		add(textObject);
	}

	public function changeText(newText:String)
		{
			if (textObject != null)
				{
					textObject.text = newText;
				}
		}

	public function setFormat(?fontString:String = "", size:Int = 48, color:FlxColor = FlxColor.WHITE, ?alignment:FlxTextAlign = LEFT, ?borderStyle:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE, borderColor:FlxColor = FlxColor.TRANSPARENT)
		{
			if (fontString != "")
				font = fontString;

			if (textObject != null)
				{
					textObject.setFormat(Paths.font(font), size, color, alignment, borderStyle, borderColor);
					textObject.borderSize = 4;
				}

		}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public function getWidth():Float
		{
			if (textObject != null)
				return textObject.width;
			else if (typedObject != null)
				return typedObject.width;
			else
				return 0.0;
		}

	var loopNum:Int = 0;
	var xPos:Float = 0;
	public var curRow:Int = 0;
	var dialogueSound:FlxSound = null;
	private static var soundDialog:Sound = null;
	var consecutiveSpaces:Int = 0;
	public static function setDialogueSound(name:String = '')
	{
		if (name == null || name.trim() == '') name = 'dialogue';
		soundDialog = sound(name);
		if(soundDialog == null) soundDialog = sound('dialogue');
	}

	var typeTimer:FlxTimer = null;
	public function startTypedText(speed:Float):Void
	{
		
	}

	

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
			{
				y = sprTracker.y;
				if (copyAlpha)
					alpha = sprTracker.alpha;
				if (copyVisible)
					visible = sprTracker.visible;
			}
		else if (textTracker != null)
			{
				y = textTracker.y;
				x = textTracker.x + textTracker.getWidth() + xAdd;
				if (copyAlpha)
					alpha = textTracker.alpha;
				if (copyVisible)
					visible = textTracker.visible;
			}
		else if (isMenuItem && !isFreeplay)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
			if(forceX != Math.NEGATIVE_INFINITY) {
				x = forceX;
			} else {
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
			}
		}
		else if (isMenuItem && isFreeplay)
			{
				var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
	
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
				y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
				if(forceX != Math.NEGATIVE_INFINITY) {
				} else {
				}
			} 

		super.update(elapsed);
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String) {
		@:privateAccess
		var gottenPath:String = Paths.getPath('$path/$key.$Paths.SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if(!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if(path == 'songs') folder = 'songs:';

			@:privateAccess
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + Paths.getPath('$path/$key.$Paths.SOUND_EXT', SOUND, library)));
		}
		return currentTrackedSounds.get(gottenPath);
	}
}
