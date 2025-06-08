package;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	public function changeIcon(char:String)
	{
		if (char != 'bf-old' && char != 'loathed-gordon2')
			char = char.split("-")[0];

		if(char.contains('bf') && char != 'bf-old')
		char = 'bf';

		if(char == 'james_phase2')
		char = 'james-fire';

		if(char == 'ughjames')
		char = 'james';

		if(char == 'gordondamn')
		char = 'gordon-rage';

		if(char == 'indighenry')
		char = 'madhenry';

		if(char == 'indigjames')
		char = 'madjames';

		if(char == 'loathed_gordon')
		char = 'gordon-rage';

		if(char == 'loathed-gordon2')
		char = 'gordon-rage';

		if (!OpenFlAssets.exists(Paths.image('icons/icon-' + char)))
			char = 'face';

		loadGraphic(Paths.loadImage('icons/icon-' + char), true, 150, 150);

		antialiasing = FlxG.save.data.antialiasing;

		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
