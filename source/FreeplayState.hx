package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import Song.SongData;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<FreeplaySongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	public static var songData:Map<String, Array<SongData>> = [];

	var diffMap:Map<String, String> = [
		'Easy' => 'Miniature',
		'Normal' => 'Narrow',
		'Hard' => 'Standard'
	];

	public static function loadDiff(diff:Int, songId:String, array:Array<SongData>)
	{
		var diffName:String = "";

		switch (diff)
		{
			case 0:
				diffName = "-easy";
			case 2:
				diffName = "-hard";
		}

		array.push(Song.conversionChecks(Song.loadFromJson(songId, diffName)));
	}

	public static var list:Array<String> = [];

	override function create()
	{
		clean();
		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		cached = false;

		populateSongData();
		PlayState.inDaPlay = false;
		PlayState.currentSong = "bruh";

		#if FEATURE_DISCORD
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		var steamTrans:FlxSprite = new FlxSprite(0, -1);
		steamTrans.frames = Paths.getSparrowAtlas('steamtransition', 'shared');
		steamTrans.animation.addByPrefix('intro','Intro',24,false);
		steamTrans.animation.addByPrefix('end','end',24,false);
		steamTrans.antialiasing = FlxG.save.data.antialiasing;
		add(steamTrans);
		steamTrans.animation.play('intro');
		steamTrans.alpha = 0.00000001;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('menuBGBlue'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 135, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 96, 0, "Rate: " + FlxMath.roundDecimal(rate, 2) + "x", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var skip:Bool = FlxTransitionableState.skipNextTransIn;

		super.create();

		if(skip) {
			CustomFadeTransition.nextCamera = null;
			openSubState(new CustomFadeTransition(0.7, true));
		}
	}

	public static var cached:Bool = false;

	static function populateSongData()
	{
		cached = false;
		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		songData = [];
		songs = [];

		for (i in 0...list.length)
		{
			var data:Array<String> = list[i].split(':');
			var songId = data[0];
			var meta = new FreeplaySongMetadata(songId, Std.parseInt(data[2]), data[1]);

			var diffs = [];
			var diffsThatExist = [];
			#if FEATURE_FILESYSTEM
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-hard')))
				diffsThatExist.push("Hard");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-easy')))
				diffsThatExist.push("Easy");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId')))
				diffsThatExist.push("Normal");

			if (diffsThatExist.length == 0)
			{
				Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
			}
			else
			{
			#else
			diffsThatExist = ["Easy", "Normal", "Hard"];
			#end
				if (diffsThatExist.contains("Easy"))
					FreeplayState.loadDiff(0, songId, diffs);
				if (diffsThatExist.contains("Normal"))
					FreeplayState.loadDiff(1, songId, diffs);
				if (diffsThatExist.contains("Hard"))
					FreeplayState.loadDiff(2, songId, diffs);

				meta.diffs = diffsThatExist;

				if (diffsThatExist.length != 3)
					trace("I ONLY FOUND " + diffsThatExist);

				FreeplayState.songData.set(songId, diffs);
				trace('loaded diffs for ' + songId);
				FreeplayState.songs.push(meta);

				sys.thread.Thread.create(() ->
				{
					FlxG.sound.cache(Paths.inst(songId));
				});
			}
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new FreeplaySongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';
		comboText.x = diffText.x + diffText.width + 15;

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;
		var dadDebug = FlxG.keys.justPressed.SIX;
		var charting = FlxG.keys.justPressed.SEVEN;
		var bfDebug = FlxG.keys.justPressed.ZERO;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.LEFT)
			{
				rate -= 0.05;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				rate += 0.05;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}

			if (FlxG.keys.justPressed.R)
			{
				rate = 1;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}

			if (rate > 3)
			{
				rate = 3;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}
			else if (rate < 0.5)
			{
				rate = 0.5;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}

			previewtext.text = "Rate: " + FlxMath.roundDecimal(rate, 2) + "x";
		}
		else
		{
			if (FlxG.keys.justPressed.LEFT)
				changeDiff(-1);
			if (FlxG.keys.justPressed.RIGHT)
				changeDiff(1);
		}

		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
		}
		#end

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
			loadSong();
		else if (charting)
			loadSong(true);

		#if debug
		if (dadDebug)
		{
			loadAnimDebug(true);
		}
		if (bfDebug)
		{
			loadAnimDebug(false);
		}
		#end
	}

	function loadAnimDebug(dad:Bool = true)
	{
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = hmm;

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		LoadingState.loadAndSwitchState(new AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);

		clean();
	}

	public static function loadSongInFreePlay(songName:String, difficulty:Int, isCharting:Bool, reloadSong:Bool = false)
	{
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		var currentSongData;
		try
		{
			if (songData.get(songName) == null)
				return;
			currentSongData = songData.get(songName)[difficulty];
			if (songData.get(songName)[difficulty] == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		PlayState.SONG = currentSongData;
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = difficulty;
		PlayState.storyWeek = songs[curSelected].week;
		Debug.logInfo('Loading song ${PlayState.SONG.songName} from week ${PlayState.storyWeek} into Free Play...');

		PlayState.songMultiplier = rate;

		if (isCharting)
		{
			LoadingState.loadAndSwitchState(new ChartingState(reloadSong));
		}
		else
		{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				CustomFadeTransition.nextCamera = null;
				FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
				CustomFadeTransition.finishCallback = function() {
				LoadingState.loadAndSwitchState(new PlayState());
				};
		}
	}

	function changeDiff(change:Int = 0)
	{
		if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty + change)))
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		diffText.text = diffMap.get(CoolUtil.difficultyFromInt(curDifficulty)).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].diffs.length != 3)
		{
			switch (songs[curSelected].diffs[0])
			{
				case "Easy":
					curDifficulty = 0;
				case "Normal":
					curDifficulty = 1;
				case "Hard":
					curDifficulty = 2;
			}
		}

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		diffText.text = diffMap.get(CoolUtil.difficultyFromInt(curDifficulty)).toUpperCase();

			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm != null)
			{
				Conductor.changeBPM(hmm.bpm);
				GameplayCustomizeState.freeplayBf = hmm.player1;
				GameplayCustomizeState.freeplayDad = hmm.player2;
				GameplayCustomizeState.freeplayGf = hmm.gfVersion;
				GameplayCustomizeState.freeplayNoteStyle = hmm.noteStyle;
				GameplayCustomizeState.freeplayStage = hmm.stage;
				GameplayCustomizeState.freeplaySong = hmm.songId;
				GameplayCustomizeState.freeplayWeek = songs[curSelected].week;
			}
		}
		catch (ex)
		{
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
} class FreeplaySongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public var diffs = [];

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
