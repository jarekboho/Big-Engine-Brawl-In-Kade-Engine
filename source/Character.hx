package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;

	public var holdTimer:Float = 0;

	public var idleSuffix:String = '';

	public var specialAnim:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('DADDY_DEAREST', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				animation.addByIndices('idleLoop', "Dad idle dance", [11, 12], "", 12, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFFaf66ce;

				playAnim('idle');
			case 'bf':
				parseDataFile();

				flipX = true;

				scale.set(0.8, 0.8);
				updateHitbox();
			case 'gf':
				parseDataFile();
				scale.set(0.8, 0.8);
				updateHitbox();
			case 'thomas':
				parseDataFile();
				scale.set(1.6, 1.6);
				updateHitbox();
			case 'henry':
				parseDataFile();
				scale.set(1.8, 1.8);
				updateHitbox();
			case 'sadhenry':
				parseDataFile();
				scale.set(4, 4);
				updateHitbox();
			case 'sadbf':
				parseDataFile();

				scale.set(1.3, 1.3);
				updateHitbox();

				flipX = true;
			case 'james':
				parseDataFile();
				scale.set(2, 2);
				updateHitbox();
			case 'splendidbf':
				parseDataFile();

				scale.set(1.9, 1.9);
				updateHitbox();

				flipX = true;
			case 'james_phase2':
				parseDataFile();
				scale.set(2, 2);
				updateHitbox();
			case 'splendidbf2':
				parseDataFile();

				scale.set(1.9, 1.9);
				updateHitbox();

				flipX = true;
			case 'ughjames':
				parseDataFile();
				scale.set(2, 2);
				updateHitbox();
			case 'gordon':
				parseDataFile();
				scale.set(1.6, 1.6);
				updateHitbox();
			case 'indigbf':
				parseDataFile();
				scale.set(0.9, 0.9);
				updateHitbox();

				flipX = true;
			case 'indighenry':
				parseDataFile();
				scale.set(1.6, 1.6);
				updateHitbox();
			case 'indigbf-henry':
				parseDataFile();
				scale.set(0.9, 0.9);
				updateHitbox();

				flipX = true;
			case 'indigjames':
				parseDataFile();
				scale.set(1.6, 1.6);
				updateHitbox();
			case 'indigbf-james':
				parseDataFile();
				scale.set(0.9, 0.9);
				updateHitbox();

				flipX = true;
			case 'gordondamn':
				parseDataFile();
				scale.set(1.6, 1.6);
				updateHitbox();
			case 'alfred':
				parseDataFile();
				scale.set(0.9, 0.9);
				updateHitbox();
			case 'loathed_gordon':
				parseDataFile();
				scale.set(0.9, 0.9);
				updateHitbox();

				flipX = true;
			case 'alfred-2':
				parseDataFile();
				scale.set(0.7, 0.7);
				updateHitbox();
			case 'loathed-gordon2':
				parseDataFile();
				scale.set(0.9, 0.9);
				updateHitbox();

				flipX = true;
			case 'edward':
				parseDataFile();
				scale.set(1.8, 1.8);
				updateHitbox();
			case 'reliablebf':
				parseDataFile();
				scale.set(0.3, 0.3);
				updateHitbox();

				flipX = true;
			case 'fatass':
				parseDataFile();
				scale.set(0.677, 0.677);
				updateHitbox();
			default:
				parseDataFile();
		}

		if (curCharacter.startsWith('bf'))
			dance();

		if (isPlayer && frames != null)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.contains('bf') && curCharacter != 'loathed_gordon' && curCharacter != 'loathed-gordon2')
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	function parseDataFile()
	{
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = Paths.loadJSON('characters/${curCharacter}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var data:CharacterData = cast jsonData;

		var tex:FlxAtlasFrames = Paths.getSparrowAtlas(data.asset, 'shared');
		frames = tex;
		if (frames != null)
			for (anim in data.animations)
			{
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipX = anim.flipX == null ? false : anim.flipX;
				var flipY = anim.flipY == null ? false : anim.flipY;

				if (anim.frameIndices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
				}

				animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
			}

		barColor = FlxColor.fromString(data.barColor);

		playAnim(data.startingAnim);
	}

	public function loadOffsetFile(character:String, library:String = 'shared')
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}
		}
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (animation.getByName('idleLoop') != null)
			{
				if (!animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
					playAnim('idleLoop');
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			else if (curCharacter == 'gf')
				dadVar = 4.1; // fix double dances
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				if (curCharacter == 'gf')
					playAnim('danceLeft'); // overridden by dance correctly later
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				{
					danced = true;
					playAnim('danceRight');
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode && !specialAnim)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair') && !animation.curAnim.name.startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				default:
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt', forced);
					else
						playAnim('idle' + idleSuffix, forced);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
		{
			#if debug
			FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

typedef CharacterData =
{
	var name:String;
	var asset:String;
	var startingAnim:String;

	var barColor:String;

	var animations:Array<AnimationData>;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var ?offsets:Array<Int>;

	var ?looped:Bool;

	var ?flipX:Bool;
	var ?flipY:Bool;

	var ?frameRate:Int;

	var ?frameIndices:Array<Int>;
}
