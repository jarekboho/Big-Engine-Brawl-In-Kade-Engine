package;

import flixel.FlxSprite;

class EventNoteSprite extends FlxSprite
{
	public var strumTime:Float = 0;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		this.strumTime = strumTime;
	}
}
