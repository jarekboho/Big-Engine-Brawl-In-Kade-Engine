package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;
import flixel.text.FlxText;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0;
	public var noteSection:Int = 0;

	public var luaID:Int = 0;

	public var isAlt:Bool = false;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public var beat:Float = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0;
	public var localAngle:Float = 0;
	public var originAngle:Float = 0;

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, GREEN_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public var noteType:String = "";

	public var reloaded = false;

	public var noteCharterObject2:FlxText;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false, ?bet:Float = 0)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		beat = bet;

		this.isAlt = isAlt;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}

		if (this.strumTime < 0)
			this.strumTime = 0;

		if (!inCharter)
			y += FlxG.save.data.offset + PlayState.songOffset;

		this.noteData = noteData;

		var daStage:String = ((PlayState.instance != null && !PlayStateChangeables.Optimize) ? PlayState.Stage.curStage : 'stage');

		var noteTypeCheck:String = 'normal';

		if (inCharter)
		{
			frames = PlayState.noteskinSprite;

			for (i in 0...4)
			{
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone');
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold');
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail');
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			noteTypeCheck = PlayState.SONG.noteStyle;

			switch (noteTypeCheck)
			{
				default:
					frames = PlayState.noteskinSprite;

					for (i in 0...4)
					{
						animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone');
						animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold');
						animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail');
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();

					antialiasing = FlxG.save.data.antialiasing;
			}
		}

		x += swagWidth * noteData;
		animation.play(dataColor[noteData] + 'Scroll');
		originColor = noteData;

		if (FlxG.save.data.stepMania && !isSustainNote && !PlayState.instance.executeModchart)
		{
			var col:Int = 0;

			var beatRow = Math.round(beat * 48);

			if (beatRow % (192 / 4) == 0)
				col = quantityColor[0];
			else if (beatRow % (192 / 8) == 0)
				col = quantityColor[2];
			else if (beatRow % (192 / 12) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 16) == 0)
				col = quantityColor[6];
			else if (beatRow % (192 / 24) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 32) == 0)
				col = quantityColor[4];

			originColor2 = col;
			var localAngle2 = 0 - arrowAngles[col];
			localAngle2 += arrowAngles[noteData];
			originAngle2 = localAngle2;
		}

		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		var songSpeed:Float = 0;

		if(PlayState.instance != null)
		songSpeed = PlayState.instance.songSpeed;

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
			2)) * PlayState.songMultiplier;
		if(FlxG.save.data.downscroll)
		{
		stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
			2)) / PlayState.songMultiplier;
		}

		if (isSustainNote && prevNote != null)
		{
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);

			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor;
			originAngle = prevNote.originAngle;

			animation.play(dataColor[originColor] + 'holdend');
			updateHitbox();

			x -= width / 2;

			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();

				if (antialiasing)
					prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		resizeByRatio();
		if (!modifiedByLua)
			angle = modAngle + localAngle;
		else
			angle = modAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
		}
		else
		{
			canBeHit = false;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		reloaded = true;
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';

		var skin:String = texture;
		if(texture.length < 1) {
			if(skin == null || skin.length < 1) {
				prefix = 'noteskins';
				skin = 'Arrows';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var blahblah:String = arraySkin.join('/');

		if (texture.contains('whistle'))
			{
				loadGraphic(Paths.image(blahblah), true, 222, 128);
				antialiasing = FlxG.save.data.antialiasing;
				for (i in ['blue','green','purple','red','blue hold end','blue hold piece','green hold end','green hold piece','pruple end hold','purple hold piece','red hold end','red hold piece'])
				{
					animation.add(i,[0],1);
				}
				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
			}
		else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = FlxG.save.data.antialiasing;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);
		updateHitbox();
	}

	private var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];

	function loadNoteAnims() {
		animation.addByPrefix(colArray[noteData] + 'Scroll', colArray[noteData] + '0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix(colArray[noteData] + 'holdend', colArray[noteData] + ' hold end');
			animation.addByPrefix(colArray[noteData] + 'hold', colArray[noteData] + ' hold piece');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	public function resizeByRatio()
	{
if(isSustainNote && animation.curAnim.name.endsWith('end'))
{
		var songSpeed:Float = 0;

		if(PlayState.instance != null)
		songSpeed = PlayState.instance.songSpeed;

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
			2)) * PlayState.songMultiplier;
		if(FlxG.save.data.downscroll)
		{
		stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
			2)) / PlayState.songMultiplier;
		}
noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
}
		if(isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
		var songSpeed:Float = 0;

		if(PlayState.instance != null)
		songSpeed = PlayState.instance.songSpeed;

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
			2)) * PlayState.songMultiplier;
		if(FlxG.save.data.downscroll)
		{
		stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? PlayState.SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
			2))/ PlayState.songMultiplier;
		}
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);

				animation.play(dataColor[originColor] + 'hold');
				updateHitbox();

				scale.y *= stepHeight / height;
				updateHitbox();

				if (antialiasing)
					scale.y *= 1.0 + (1.0 / frameHeight);
		}
	}

var originColor2 = 0;
var originAngle2 = 0;

		public function stepMania()
		{
		if(reloaded) return;

		if (FlxG.save.data.stepMania && !isSustainNote && !PlayState.instance.executeModchart)
		{
			animation.play(dataColor[originColor2] + 'Scroll');
			localAngle -= arrowAngles[originColor2];
			localAngle += arrowAngles[noteData];
			originColor = originColor2;
			originAngle = originAngle2;
		}

		if (FlxG.save.data.stepMania && isSustainNote && !PlayState.instance.executeModchart)
		{
			if (isSustainNote && prevNote != null)
			{
			animation.play(dataColor[prevNote.originColor2] + 'holdend');
			updateHitbox();
			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.originColor2] + 'hold');
				prevNote.updateHitbox();
			}
			originColor2 = prevNote.originColor2;
			originColor = prevNote.originColor2;
			originAngle2 = prevNote.originAngle2;
			originAngle = prevNote.originAngle2;
			}
		}
		}
}
