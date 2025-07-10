package;

import flixel.util.FlxSpriteUtil;
#if FEATURE_LUAMODCHART
import LuaClass.LuaCamera;
import LuaClass.LuaCharacter;
import LuaClass.LuaNote;
#end
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SongData;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import openfl.utils.Assets;
import Note.EventNote;
import openfl.system.Capabilities;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.group.FlxSpriteGroup;
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
import hxcodec.VideoSprite;
import openfl.geom.ColorTransform;
import flixel.graphics.tile.FlxGraphicsShader;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var SONG:SongData;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public static var noteskinSprite:FlxAtlasFrames;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if FEATURE_DISCORD
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1;

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	public var healthBarOverlay:FlxSprite;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camBAR:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true;
	var idleBeat:Int = 2;
	var forcedToIdle:Bool = false;
	var allowedToHeadbang:Bool = true;
	var allowedToCheer:Bool = false;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var songName:FlxText;

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	public var songtitleTxt:FlxText;
	public var composerTxt:FlxText;

	var songtocomposer:Map<String, String> = [
		'puffball' => 'DPZ',
		'flying kipper' => 'Jack Orange',
		'splendid' => 'ronbrazy',
		'indignation' => 'DPZ, ronbrazy and Jack Orange',
		'sad story' => 'Jack Orange',
		'confusion and delay' => 'DPZ',
		'loathed' => 'DPZ',
		'old reliable' => 'ronbrazy',
		'endless remix' => 'The Old Guards Van',
		'monochrome remix' => 'The Old Guards Van',
		'ugh remix' => 'The Old Guards Van',
		'godrays remix' => 'The Old Guards Van', 
	];

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;
	var replayTxt:FlxText;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;

	public static var theFunne:Bool = true;

	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	private var triggeredAlready:Bool = false;

	public static var songOffset:Float = 0;

	private var botPlayState:FlxText;
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis();

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	public var eventNotes:Array<EventNote> = [];

	public var gameBlackLayerAlphaTween:FlxTween;
	public var gameBlackLayer:FlxSprite;

	public var doMiddleScroll:Bool = false;

	var charToNoteSkin = [
		"henry" => "HenryNote",
		"indighenry" => "HenryNote",
		"james" => "jameNote",
		"james_phase2" => "jameNote",
		"ughjames" => "jameNote",
		"indigjames" => "jameNote",
		"sadhenry" => "HenryNote",
		"thomas" => "thomasNote",
		"gordon" => "gordonNote",
		"gordondamn" => "gordonNote",
		"loathed_gordon" => "gordonNote",
		"loathed-gordon2" => "gordonNote",
		"alfred" => "alfredNote",
		"alfred-2" => "alfredNote",
		"edward" => "edwardNote",
		"fatass" => "fatNote"
	];

	public var tvFilter:ShaderFilter;
	public var grayFilter:ShaderFilter;
	var screenShader:Screen = new Screen();
	var shaderTime:Float = 0;
	var grayScale:GrayScale = new GrayScale();

	var monochromeSprites:Array<String> = ['always', 'design', 'nobody', 'send', 'GETTHEFUCKOVERHERE'];

	var belowArrowGrp:FlxSpriteGroup;

	public var skipCountdown:Bool = false;

	var mech1:FlxSprite;

	var signalTween:FlxTween;

	public var songSpeed:Float = 0;

	public var flipFuckingEverything:Bool = false;

	var songEnded = false;

	var diffMap:Map<String, String> = [
		'Easy' => 'Miniature',
		'Normal' => 'Narrow',
		'Hard' => 'Standard'
	];

	function sectionStartTime(number:Int = 0):Float
	{
		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		if(number < 0)
		return 0;
		for (i in 0...number)
		{
			if(SONG.notes[i] != null)
			{
				if (SONG.notes[i].changeBPM)
				{
					daBPM = SONG.notes[i].bpm;
				}
				var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
				if (timingSeg != null)
				{
				var timingSegBpm = timingSeg.bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	public static var seenCutscene:Bool = false;

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;

		doMiddleScroll = FlxG.save.data.middleScroll;

		tvFilter = new ShaderFilter(screenShader);
		grayFilter = new ShaderFilter(grayScale);

		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
			Main.dumpCache();
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed / PlayState.songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false;
		#end

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		if (executeModchart)
			songMultiplier = 1;

		#if FEATURE_DISCORD
		storyDifficultyText = diffMap.get(CoolUtil.difficultyFromInt(storyDifficulty));

		iconRPC = SONG.player2;

		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		detailsPausedText = "Paused - " + detailsText;

		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.songName
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		camBAR = new FlxCamera();
		camBAR.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBAR);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camOther);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value;

				TimingStruct.addTiming(beat, bpm, endBeat, 0);

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
		}

		var stageCheck:String = 'stage';

		stageCheck = SONG.stage;

		if (isStoryMode)
			songMultiplier = 1;

		var gfCheck:String = 'gf';

		gfCheck = SONG.gfVersion;

		if (!stageTesting)
		{
			gf = new Character(400, 130, gfCheck);

			if (gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(400, 130, 'gf');
			}

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			if (boyfriend.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				#end
				boyfriend = new Boyfriend(770, 450, 'bf');
			}

			dad = new Character(100, 100, SONG.player2);

			if (dad.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				#end
				dad = new Character(100, 100, 'dad');
			}
		}

		if (!stageTesting)
			Stage = new Stage(SONG.stage);

		var positions = Stage.positions[Stage.curStage];
		if (positions != null && !stageTesting)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person.curCharacter == char)
						person.setPosition(pos[0], pos[1]);
		}
		for (i in Stage.toAdd)
		{
			add(i);
		}
		if (!PlayStateChangeables.Optimize)
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
if(Stage.curStage != 'sadstory' && Stage.curStage != 'splendid' && Stage.curStage != 'ugh' && Stage.curStage != 'indignation' && Stage.curStage != 'godraysremix' && Stage.curStage != 'loathed' && Stage.curStage != 'oldreliable' && Stage.curStage != 'confusion')
						add(gf);
						for (bg in array)
							add(bg);
					case 1:
						if(Stage.curStage != 'splendid' && Stage.curStage != 'ugh')
						add(dad);
						for (bg in array)
							add(bg);
					case 2:
						add(boyfriend);
						if(Stage.curStage == 'splendid' || Stage.curStage == 'ugh')
						add(dad);
						for (bg in array)
							add(bg);
				}
			}

		switch(Stage.curStage)
		{
			case 'sadstory':
				boyfriend.color = 0xFFB2B2B2;
			case 'confusion':
				boyfriend.visible = false;
				dad.alpha = 0.00001;
				boyfriend.scrollFactor.set();
				dad.scrollFactor.set();
				skipCountdown = true;
				camHUD.alpha = 0.00001;
			case 'loathed':
				flipFuckingEverything = true;
				skipCountdown = true;
		}

		if(currentSong.toLowerCase() == 'sad story')
		{
		screenShader.noiseIntensity.value = [0.75];
		resizeDaWindow([Std.int(800),Std.int(600)]);
		camGame.setFilters([tvFilter]);
		camHUD.setFilters([tvFilter]);
		}

		if(currentSong.toLowerCase() == 'monochrome remix')
		{
		screenShader.noiseIntensity.value = [0.75];
		resizeDaWindow([Std.int(800),Std.int(600)]);
		camGame.setFilters([grayFilter, tvFilter]);
		camHUD.setFilters([grayFilter, tvFilter]);
		}

		if(currentSong.toLowerCase() == 'old reliable')
		{
		screenShader.noiseIntensity.value = [0.50];
		camGame.setFilters([tvFilter]);
		camHUD.setFilters([tvFilter]);
		}

		if(Reflect.hasField(SONG, 'player3') && Reflect.field(SONG, 'player3') == null)
		camPos = new FlxPoint(0, 0);
		else
		camPos = new FlxPoint(gf.getGraphicMidpoint().x + -300, gf.getGraphicMidpoint().y + 140);

		Stage.update(0);

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (!isStoryMode && songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0)
				{
					var start = sectionStartTime(index);
					if (start > 5000)
					{
						needSkip = true;
						skipTo = start - 1000;
					}
					break;
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay && !PlayStateChangeables.Optimize)
		{
			if (!doMiddleScroll || executeModchart)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		belowArrowGrp = new FlxSpriteGroup();
		add(belowArrowGrp);

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);

		if (skipCountdown) skipArrowStartTween = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = cpuStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		switch (currentSong.toLowerCase())
		{
			case 'confusion and delay':
				mech1 = new FlxSprite(734,-265);
				mech1.frames = Paths.getSparrowAtlas('mech/cad/signalsign');
				mech1.animation.addByPrefix('move','mat',24,false);
				mech1.animation.play('move');
				mech1.antialiasing = FlxG.save.data.antialiasing;
				mech1.setGraphicSize(500);
				mech1.updateHitbox();
				mech1.cameras = [camHUD];
				mech1.alpha = 0.00001;
				if (!FlxG.save.data.downscroll)
					{
						mech1.x = 734;
						mech1.y = -265;
					}
				else
					{
						mech1.x = 734;
						mech1.y = 265;
					}
				if (doMiddleScroll)
					{
						mech1.x = 418;
					}
				add(mech1);
		}

		var steamTrans:FlxSprite = new FlxSprite(0, -1);
		steamTrans.frames = Paths.getSparrowAtlas('steamtransition', 'shared');
		steamTrans.animation.addByPrefix('intro','Intro',24,false);
		steamTrans.animation.addByPrefix('end','end',24,false);
		steamTrans.antialiasing = FlxG.save.data.antialiasing;
		add(steamTrans);
		steamTrans.animation.play('intro');
		steamTrans.alpha = 0.00000001;

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		if(eventNotes.length > 1)
		{
			eventNotes.sort(sortByTime);
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [PlayState.SONG.songId]);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camNotes").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
		}

		trace('generated');

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthbar/healthbar_white'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		if (flipFuckingEverything)
		{
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this,
			'health', 0, 2);
		}
		else
		{
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this,
			'health', 0, 2);
		}
		healthBar.scrollFactor.set();

		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ diffMap.get(CoolUtil.difficultyFromInt(storyDifficulty)),
			16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);
		if (PlayState.oreoWindow)
		kadeEngineWatermark.x += 140;

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}
		if (PlayState.oreoWindow)
		judgementCounter.x += 140;

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		replayTxt.cameras = [camHUD];
		if (loadRep)
		{
			add(replayTxt);
		}
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - 130;

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - 130;

		if (flipFuckingEverything)
		{
				iconP1.flipX = true;
				iconP2.flipX = true;
		}

		var shitfuckfart:FlxSprite = new FlxSprite().loadGraphic(Paths.image("healthbar/yea"));
		shitfuckfart.cameras = [camHUD];
		shitfuckfart.setPosition(healthBarBG.x - 0, healthBarBG.y);

		healthBarOverlay = new FlxSprite();
		healthBarOverlay.loadGraphic(Paths.image("healthbar/track_overlay_winning"));
		healthBarOverlay.loadGraphic(Paths.image("healthbar/track_overlay_losing"));
		healthBarOverlay.loadGraphic(Paths.image("healthbar/track_overlay_normal"));
		healthBarOverlay.setPosition(healthBarBG.x + 5, healthBarBG.y - (70));
		healthBarOverlay.cameras = [camHUD];

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(healthBarOverlay);
			add(shitfuckfart);
			add(iconP1);
			add(iconP2);

			reloadHealthBarColors();
		}

		songtitleTxt = new FlxText(0, 0, FlxG.width,"", 20);
		songtitleTxt.setFormat(Paths.font("vcr.ttf"), 100, 0xFFFF02, CENTER);
		songtitleTxt.text = SONG.song.toUpperCase();
		songtitleTxt.screenCenter(X);
		songtitleTxt.y = FlxG.height - (FlxG.height / 4);
		songtitleTxt.alpha = 0.00001;
		add(songtitleTxt);

		composerTxt = new FlxText(0, 0, FlxG.width,"", 20);
		composerTxt.setFormat(Paths.font("vcr.ttf"), 50, 0xFFFF02, CENTER);
		if(songtocomposer.get(SONG.song.toLowerCase()) != null)
		{
		composerTxt.text = 'Composed by ${songtocomposer.get(SONG.song.toLowerCase())}';
		}
		composerTxt.screenCenter(X);
		composerTxt.y = (FlxG.height - (FlxG.height / 4) + (songtitleTxt.height - (composerTxt.height / 2)));
		composerTxt.alpha = 0.00001;
		add(composerTxt);

		belowArrowGrp.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		songtitleTxt.cameras = [camHUD];
		composerTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];

		kadeEngineWatermark.cameras = [camHUD];

		gameBlackLayer = new FlxSprite().makeGraphic(FlxG.width * 10, FlxG.height * 10, FlxColor.BLACK);
		gameBlackLayer.scrollFactor.set();
		add(gameBlackLayer);

		gameBlackLayer.alpha = 0.00000001;
		gameBlackLayer.cameras = [camOther];

		if(Stage.curStage == 'indignation')
		{
			var barHeight:Int = 70;
			var blackBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, barHeight, FlxColor.BLACK);
			blackBar.cameras = [camBAR];
			add(blackBar);

			var blackBar:FlxSprite = new FlxSprite(0, FlxG.height - barHeight).makeGraphic(FlxG.width, barHeight, FlxColor.BLACK);
			blackBar.cameras = [camBAR];
			add(blackBar);
		}

		if(Stage.curStage == 'godraysremix')
		{
				var barHeight:Int = 70;
				var blackBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, barHeight, FlxColor.BLACK);
				blackBar.cameras = [camBAR];
				add(blackBar);
	
				var blackBar:FlxSprite = new FlxSprite(0, FlxG.height - barHeight).makeGraphic(FlxG.width, barHeight, FlxColor.BLACK);
				blackBar.cameras = [camBAR];
				add(blackBar);
		}

		if(Stage.curStage == 'loathed')
		{
				var barHeight:Int = 70;
				var blackBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, barHeight, FlxColor.BLACK);
				blackBar.cameras = [camBAR];
				add(blackBar);
	
				var blackBar:FlxSprite = new FlxSprite(0, FlxG.height - barHeight).makeGraphic(FlxG.width, barHeight, FlxColor.BLACK);
				blackBar.cameras = [camBAR];
				add(blackBar);
		}	

		startingSong = true;

		trace('starting');

		dad.dance();
		boyfriend.dance();
		gf.dance();

		if (!skipCountdown)
		FlxG.camera.flash(FlxColor.WHITE, 3);

if (!isStoryMode)
{
			if (!SONG.notes[0].mustHitSection)
			{
				switch (dad.curCharacter)
				{
					case 'thomas':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -200;
						camFollow.y += -30 + 0;
					case 'sadhenry':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -100 + 0;
						camFollow.y += -130 + 0;
					case 'henry':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -130 + -250;
						camFollow.y += -150 + -75;
					case 'james':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'james_phase2':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'ughjames':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'gordon':
						switch(singChar)
						{
						case 'henry':
						if (Stage.exChar1 != null)
						camFollow.x = Stage.exChar1.getMidpoint().x + 150;
						if (Stage.exChar1 != null)
						camFollow.y = Stage.exChar1.getMidpoint().y - 100;
						camFollow.x += 500 + -420;
						camFollow.y += -150 + 0;
						case 'james':
						if (Stage.exChar2 != null)
						camFollow.x = Stage.exChar2.getMidpoint().x + 150;
						if (Stage.exChar2 != null)
						camFollow.y = Stage.exChar2.getMidpoint().y - 100;
						camFollow.x += -180 + -420;
						camFollow.y += -150 + 0;
						case '':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
						default:
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
						}
					case 'gordondamn':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
					case 'alfred':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -600 + 0;
						camFollow.y += 40 + 0;
					case 'alfred-2':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -240 + 0;
						camFollow.y += 175 + 0;
					case 'edward':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -340 + 0;
						camFollow.y += -80 + 0;
					case 'fatass':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + 0;
						camFollow.y += -30 + 0;
				}
			}

			if (SONG.notes[0].mustHitSection)
			{
					switch (Stage.curStage)
					{
						case 'puffball':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 300;
						case 'endlessremix':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 300;
						case 'harbor':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 250;
						case 'sadstory':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 0;
						case 'splendid':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - -100;
							camFollow.y += -180 + 100;
						case 'ugh':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - -100;
							camFollow.y += -180 + 100;
						case 'indignation':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 270;
							camFollow.y += -180 + 70;
						case 'godraysremix':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 270;
							camFollow.y += -180 + 70;
						case 'loathed':
							switch(Stage.curLoathedState)
							{
							case 2:
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= -495 - 0;
							camFollow.y += 75 + 0;
							default:
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= -500 - 0;
							camFollow.y += 40 + 0;
							}
						case 'oldreliable':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 20 - 150;
							camFollow.y += 180 + 100;
						case 'confusion':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 0;
					}
			}
}

		if (Stage.curStage == 'loathed')
			{
				add(Stage.ob16);
			}

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "flying-kipper":
					if(seenCutscene)
					{
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
					}
					if(!seenCutscene)
					startVideo('kipper');
					seenCutscene = true;
				case "splendid":
					if(seenCutscene)
					{
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
					}
					if(!seenCutscene)
					startVideo('Splendid');
					seenCutscene = true;
				case "indignation":
					if(seenCutscene)
					{
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
					}
					if(!seenCutscene)
					startVideo('Indignation');
					seenCutscene = true;
				default:
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
			}
		}
		else
		{
			new FlxTimer().start(1, function(timer)
			{
				startCountdown();
			});
		}

		if (!loadRep)
			rep = new Replay("na");

		FlxG.keys.preventDefaultKeys = [];
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		var skip:Bool = FlxTransitionableState.skipNextTransIn;

		super.create();

		if(skip) {
			CustomFadeTransition.nextCamera = camOther;
			openSubState(new CustomFadeTransition(0.7, true));
		}
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		appearStaticArrows();

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		if (skipCountdown)
		{
		if (Stage.curStage == 'loathed') setSongTime(0);
		FlxTween.tween(camHUD, {alpha: 1}, 0.5, {startDelay: 4});
		}

if (isStoryMode)
{
			if (!SONG.notes[0].mustHitSection)
			{
				switch (dad.curCharacter)
				{
					case 'thomas':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -200;
						camFollow.y += -30 + 0;
					case 'sadhenry':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -100 + 0;
						camFollow.y += -130 + 0;
					case 'henry':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -130 + -250;
						camFollow.y += -150 + -75;
					case 'james':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'james_phase2':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'ughjames':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'gordon':
						switch(singChar)
						{
						case 'henry':
						if (Stage.exChar1 != null)
						camFollow.x = Stage.exChar1.getMidpoint().x + 150;
						if (Stage.exChar1 != null)
						camFollow.y = Stage.exChar1.getMidpoint().y - 100;
						camFollow.x += 500 + -420;
						camFollow.y += -150 + 0;
						case 'james':
						if (Stage.exChar2 != null)
						camFollow.x = Stage.exChar2.getMidpoint().x + 150;
						if (Stage.exChar2 != null)
						camFollow.y = Stage.exChar2.getMidpoint().y - 100;
						camFollow.x += -180 + -420;
						camFollow.y += -150 + 0;
						case '':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
						default:
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
						}
					case 'gordondamn':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
					case 'alfred':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -600 + 0;
						camFollow.y += 40 + 0;
					case 'alfred-2':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -240 + 0;
						camFollow.y += 175 + 0;
					case 'edward':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -340 + 0;
						camFollow.y += -80 + 0;
					case 'fatass':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + 0;
						camFollow.y += -30 + 0;
				}
			}

			if (SONG.notes[0].mustHitSection)
			{
					switch (Stage.curStage)
					{
						case 'puffball':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 300;
						case 'endlessremix':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 300;
						case 'harbor':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 250;
						case 'sadstory':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 0;
						case 'splendid':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - -100;
							camFollow.y += -180 + 100;
						case 'ugh':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - -100;
							camFollow.y += -180 + 100;
						case 'indignation':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 270;
							camFollow.y += -180 + 70;
						case 'godraysremix':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 270;
							camFollow.y += -180 + 70;
						case 'loathed':
							switch(Stage.curLoathedState)
							{
							case 2:
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= -495 - 0;
							camFollow.y += 75 + 0;
							default:
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= -500 - 0;
							camFollow.y += 40 + 0;
							}
						case 'oldreliable':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 20 - 150;
							camFollow.y += 180 + 100;
						case 'confusion':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 0;
					}
			}
}

			if (flipFuckingEverything && !doMiddleScroll)
			{
					var playerxs:Array<Float> = [];
					var oppxs:Array<Float> = [];
					for (i in 0...playerStrums.length) {
						playerxs.push(playerStrums.members[i].x);
					}
					for (i in 0...cpuStrums.length) {
						oppxs.push(cpuStrums.members[i].x);
						cpuStrums.members[i].x = playerxs[i];
					}
					for (i in 0...oppxs.length)
					{
						playerStrums.members[i].x = oppxs[i];
					}
			}

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (skipCountdown) return;
			if (allowedToHeadbang && swagCounter % gfSpeed == 0)
				gf.dance();
			if (swagCounter % idleBeat == 0)
			{
				if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
					boyfriend.dance(forcedToIdle);
				if (idleToBeat)
					dad.dance(forcedToIdle);
			}
			else if (dad.curCharacter == 'gf')
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('countdown/BEB_3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.cameras = [camHUD];
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/BEB_2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.cameras = [camHUD];
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/BEB_1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.cameras = [camHUD];
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (FileSystem.exists('assets/shared/sounds/countdown/BEB_GO_${dad.curCharacter.toLowerCase()}.ogg'))
					FlxG.sound.play(Paths.sound('countdown/BEB_GO_${dad.curCharacter.toLowerCase()}'), 0.6);
					else
					FlxG.sound.play(Paths.sound('countdown/BEB_GO_default'), 0.6);
			}

			swagCounter += 1;
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode)
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length)
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode)
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length)
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		});

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1)
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0)
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.20;
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if(currentSong.toLowerCase() != 'loathed')
		{
		FlxTween.tween(songtitleTxt, {alpha: 1}, 3, {ease: FlxEase.quadInOut, onComplete: function(shit:FlxTween){
			FlxTween.tween(songtitleTxt, {alpha: 0}, 3, {ease: FlxEase.quadInOut});
		}});
		FlxTween.tween(composerTxt, {alpha: 1}, 3, {ease: FlxEase.quadInOut, onComplete: function(shit:FlxTween){
			FlxTween.tween(composerTxt, {alpha: 0}, 3, {ease: FlxEase.quadInOut});
		}});
		}

		FlxG.sound.music.play();
		vocals.play();

		if (allowedToHeadbang)
			gf.dance();
		if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance(forcedToIdle);
		if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing"))
			dad.dance(forcedToIdle);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		FlxG.sound.music.pitch = songMultiplier;
		if (vocals.playing)
		vocals.pitch = songMultiplier;
		trace("pitched inst and vocals to " + songMultiplier);

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(339.5 + 80, healthBarBG.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
		}

		FlxG.sound.music.pause();

		if (SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
			add(songPosBar);

			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();

			songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);

			add(songName);

			songName.screenCenter(X);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0;

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var stepCrochet:Float = Conductor.stepCrochet;

				var timingSeg = TimingStruct.getTimingAtTimestamp(songNotes[0]);
				if (timingSeg != null)
				{
				var crochet:Float = ((60 / timingSeg.bpm) * 1000);
				stepCrochet = crochet / 4;
				}

				var gottaHitNote:Bool = true;

				if (songNotes[1] > 3 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < 4 && !section.mustHitSection)
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4]);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2])));
				if(songNotes[3] != null)
				swagNote.noteType = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (stepCrochet * susNote) + stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2;
					}

				switch(swagNote.noteType)
				{
					case 'James Note':
						sustainNote.reloadNote('notes/','jameNote');
					case 'Henry Note':
						sustainNote.reloadNote('notes/','HenryNote');
					default:
						if(!sustainNote.mustPress && charToNoteSkin.get(dad.curCharacter.toLowerCase()) != null)
						sustainNote.reloadNote('notes/', charToNoteSkin.get(dad.curCharacter.toLowerCase()));
						if(sustainNote.mustPress && charToNoteSkin.get(boyfriend.curCharacter.toLowerCase()) != null)
						sustainNote.reloadNote('notes/', charToNoteSkin.get(boyfriend.curCharacter.toLowerCase()));
				}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					sustainNote.stepMania();
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2;
				}

				switch(swagNote.noteType)
				{
					case 'James Note':
						swagNote.reloadNote('notes/','jameNote');
					case 'Henry Note':
						swagNote.reloadNote('notes/','HenryNote');
					case 'Whistle Note':
						swagNote.reloadNote('notes/','whistle_special_note');
					case 'Signal Note':
						swagNote.reloadNote('notes/','signal_special_notes');
					default:
						if(!swagNote.mustPress && charToNoteSkin.get(dad.curCharacter.toLowerCase()) != null)
						swagNote.reloadNote('notes/', charToNoteSkin.get(dad.curCharacter.toLowerCase()));
						if(swagNote.mustPress && charToNoteSkin.get(boyfriend.curCharacter.toLowerCase()) != null)
						swagNote.reloadNote('notes/', charToNoteSkin.get(boyfriend.curCharacter.toLowerCase()));
				}
				swagNote.stepMania();
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");

		var file:String = '';
		var currentSong2 = currentSong.replace(' ', '-');
		file = Paths.json('songs/' + currentSong2.toLowerCase() + '/events');
		if (Assets.exists(file)) {
			var eventsData:Array<Dynamic> = Song.loadFromJson2('events', currentSong2.toLowerCase()).events;
			for (event in eventsData)
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0],
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false;
	private function generateStaticArrows(player:Int):Void
	{
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);
			babyArrow.frames = noteskinSprite;
		for (i in 0...4)
		{
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			noteTypeCheck = SONG.noteStyle;

			switch (noteTypeCheck)
			{
				default:
					if(player == 0)
					{
					if(charToNoteSkin.get(dad.curCharacter.toLowerCase()) != null)
					{
					babyArrow.frames = Paths.getSparrowAtlas('notes/' + charToNoteSkin.get(dad.curCharacter.toLowerCase()));
					babyArrow.reloaded = true;
					}
					else
					babyArrow.frames = noteskinSprite;
					}
					if(player == 1)
					{
					if(charToNoteSkin.get(boyfriend.curCharacter.toLowerCase()) != null)
					{
					babyArrow.frames = Paths.getSparrowAtlas('notes/' + charToNoteSkin.get(boyfriend.curCharacter.toLowerCase()));
					babyArrow.reloaded = true;
					}
					else
					babyArrow.frames = noteskinSprite;
					}
					Debug.logTrace(babyArrow.frames);
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.y -= 10;
				if (!doMiddleScroll || executeModchart || player == 1)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (skipArrowStartTween)
			{
				if (!doMiddleScroll || executeModchart || player == 1)
				babyArrow.alpha = 1;
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize || (doMiddleScroll && !executeModchart))
				babyArrow.x -= 320;

				if (oreoWindow && !doMiddleScroll && player == 0)
				babyArrow.x += 12;

				if (oreoWindow && !doMiddleScroll && player == 1)
				babyArrow.x -= 50;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode && !doMiddleScroll || executeModchart)
				babyArrow.alpha = 1;
			if (index > 3 && doMiddleScroll)
				babyArrow.alpha = 1;
			index++;
		});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
			if (gameBlackLayerAlphaTween != null)
				gameBlackLayerAlphaTween.active = false;
			if(signalTween != null)
				signalTween.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (gameBlackLayerAlphaTween != null)
				gameBlackLayerAlphaTween.active = true;
			if(signalTween != null)
				signalTween.active = true;

			paused = false;

			#if FEATURE_DISCORD
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.songName + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition;
		vocals.time = FlxG.sound.music.time;

		FlxG.sound.music.pitch = songMultiplier;
		if (vocals.playing)
		vocals.pitch = songMultiplier;

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	public var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	private var isCameraOnForcedPos:Bool = false;

	var singChar:String = '';

	public var canReset:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize)
			Stage.update(elapsed);

		if (!addedBotplay && FlxG.save.data.botplay)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					new LuaNote(dunceNote, currentLuaIndex);
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (executeModchart)
				{
					#if FEATURE_LUAMODCHART
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}

		if (FlxG.sound.music.playing)
		{
		FlxG.sound.music.pitch = songMultiplier;
		if (vocals.playing)
		vocals.pitch = songMultiplier;
		}

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				if (FlxG.sound.music.time / songMultiplier / 1000 > (songLength - 2))
				{
					Debug.logTrace("we're fuckin ending the song ");

					endingSong = true;
					new FlxTimer().start(2, function(timer)
					{
						endSong();
					});
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value;

					TimingStruct.addTiming(beat, bpm, endBeat, 0);

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
				}
			}

			var newScroll = 1.0;

			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);

			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll", "bool");

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gppauseBind]))
			&& startedCountdown
			&& canPause
			&& !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
				clean();
			}
			else
				openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.FIVE && songStarted)
		{
			songMultiplier = 1;
			cannotDie = true;

			FlxG.switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
			cannotDie = true;

			FlxG.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (flipFuckingEverything)
		{
		iconP1.x = (healthBar.x + healthBar.width) - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP1.width - iconOffset);
		iconP2.x = (healthBar.x + healthBar.width) - (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) + iconOffset);
		}
		else
		{
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (iconP1.animation.curAnim.curFrame == 1)
			{
				if (!flipFuckingEverything)
					healthBarOverlay.loadGraphic(Paths.image('healthbar/track_overlay_losing'));
				else
					healthBarOverlay.loadGraphic(Paths.image('healthbar/track_overlay_winning'));
				healthBarOverlay.setPosition(healthBarBG.x + 4, healthBarBG.y - (72));
			}
		else if (iconP2.animation.curAnim.curFrame == 1)
			{
				if (!flipFuckingEverything)
					healthBarOverlay.loadGraphic(Paths.image('healthbar/track_overlay_winning'));
				else
					healthBarOverlay.loadGraphic(Paths.image('healthbar/track_overlay_losing'));
				healthBarOverlay.setPosition(healthBarBG.x + 7, healthBarBG.y - (72));
			}
		else if (iconP1.animation.curAnim.curFrame == 0 && iconP2.animation.curAnim.curFrame == 0)
			{
				healthBarOverlay.loadGraphic(Paths.image('healthbar/track_overlay_normal'));
				healthBarOverlay.setPosition(healthBarBG.x + 13, healthBarBG.y - (72));

			}

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug(dad.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (!PlayStateChangeables.Optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				paused = true;
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in Stage.swagGroup)
					{
						remove(group);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});
				FlxG.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO && songStarted)
		{
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
			if(currentSong.toLowerCase() == 'old reliable')
			{
			dad.specialAnim = false;
			dad.dance(false);
			}
			if(currentSong.toLowerCase() == 'loathed')
			{
			camFollow.setPosition(dad.getMidpoint().x + 150 + -600, dad.getMidpoint().y - 100 + 40);
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * songMultiplier;
			Conductor.rawPosition = FlxG.sound.music.time;
			songPositionBar = ((Conductor.songPosition / songMultiplier) - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			if (!paused)
			{
				screenShader.iTime.value = [shaderTime];
				shaderTime += FlxG.elapsed;
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				var curTime:Float = FlxG.sound.music.time / songMultiplier;
				if (curTime < 0)
					curTime = 0;

				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
				if (secondsTotal < 0)
					secondsTotal = 0;

				if (FlxG.save.data.songPosition)
					songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
			}
		}

		if (generatedMusic && currentSection != null)
		{
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end

			if(!isCameraOnForcedPos)
			{
			if (camFollow.x != dad.getMidpoint().x + 150 && !currentSection.mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end

				switch (dad.curCharacter)
				{
					case 'thomas':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -200;
						camFollow.y += -30 + 0;
					case 'sadhenry':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -100 + 0;
						camFollow.y += -130 + 0;
					case 'henry':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -130 + -250;
						camFollow.y += -150 + -75;
					case 'james':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'james_phase2':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'ughjames':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -900 + -300;
						camFollow.y += -130 + 0;
					case 'gordon':
						switch(singChar)
						{
						case 'henry':
						if (Stage.exChar1 != null)
						camFollow.x = Stage.exChar1.getMidpoint().x + 150;
						if (Stage.exChar1 != null)
						camFollow.y = Stage.exChar1.getMidpoint().y - 100;
						camFollow.x += 500 + -420;
						camFollow.y += -150 + 0;
						case 'james':
						if (Stage.exChar2 != null)
						camFollow.x = Stage.exChar2.getMidpoint().x + 150;
						if (Stage.exChar2 != null)
						camFollow.y = Stage.exChar2.getMidpoint().y - 100;
						camFollow.x += -180 + -420;
						camFollow.y += -150 + 0;
						case '':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
						default:
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
						}
					case 'gordondamn':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + -420;
						camFollow.y += -30 + 0;
					case 'alfred':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -600 + 0;
						camFollow.y += 40 + 0;
					case 'alfred-2':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -240 + 0;
						camFollow.y += 175 + 0;
					case 'edward':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -340 + 0;
						camFollow.y += -80 + 0;
					case 'fatass':
						camFollow.x = dad.getMidpoint().x + 150;
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x += -60 + 0;
						camFollow.y += -30 + 0;
				}
			}

			if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
				if (!PlayStateChangeables.Optimize)
					switch (Stage.curStage)
					{
						case 'puffball':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 300;
						case 'endlessremix':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 300;
						case 'harbor':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 250;
						case 'sadstory':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 0;
						case 'splendid':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - -100;
							camFollow.y += -180 + 100;
						case 'ugh':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - -100;
							camFollow.y += -180 + 100;
						case 'indignation':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 270;
							camFollow.y += -180 + 70;
						case 'godraysremix':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 270;
							camFollow.y += -180 + 70;
						case 'loathed':
							switch(Stage.curLoathedState)
							{
							case 2:
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= -495 - 0;
							camFollow.y += 75 + 0;
							default:
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= -500 - 0;
							camFollow.y += 40 + 0;
							}
						case 'oldreliable':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 20 - 150;
							camFollow.y += 180 + 100;
						case 'confusion':
							camFollow.x = boyfriend.getMidpoint().x - 100;
							camFollow.y = boyfriend.getMidpoint().y - 100;
							camFollow.x -= 130 - 0;
							camFollow.y += -180 + 0;
					}
			}
			}
		}

		if (camZooming && Conductor.bpm < 320)
		{
			if (Conductor.bpm > 320)
			{
				camZooming = false;
			}

			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.pause();
				FlxG.sound.music.pause();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton && canReset)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.pause();
				FlxG.sound.music.pause();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

			notes.forEachAlive(function(daNote:Note)
			{
				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
									2)))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
									2)))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height - stepHeight;

							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) * songMultiplier) * (FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
									2)))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) * songMultiplier) * (FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed + songSpeed : PlayStateChangeables.scrollSpeed + songSpeed,
									2)))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							if(daNote.parent.noteType != 'No Animation' && daNote.parent.noteType != 'Henry Note' && daNote.parent.noteType != 'James Note')
							dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if(daNote.parent.noteType == 'Alt Animation')
							dad.playAnim('sing' + dataSuffix[singData] + '-alt', true);

							if(daNote.parent.noteType == 'Henry Note')
							{
							if (Stage.exChar1 != null)
							Stage.exChar1.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if (Stage.exChar1 != null)
							Stage.exChar1.holdTimer = 0;
							}

							if(daNote.parent.noteType == 'James Note')
							{
							if (Stage.exChar2 != null)
							Stage.exChar2.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							if (Stage.exChar2 != null)
							Stage.exChar2.holdTimer = 0;
							}

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
								});
							}

							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							dad.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						if(daNote.noteType != 'No Animation' && daNote.noteType != 'Henry Note' && daNote.noteType != 'James Note')
						dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if(daNote.noteType == 'Alt Animation')
						dad.playAnim('sing' + dataSuffix[singData] + '-alt', true);

						if(daNote.noteType == 'Henry Note')
						{
						if (Stage.exChar1 != null)
						Stage.exChar1.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (Stage.exChar1 != null)
						Stage.exChar1.holdTimer = 0;
						}

						if(daNote.noteType == 'James Note')
						{
						if (Stage.exChar2 != null)
						Stage.exChar2.playAnim('sing' + dataSuffix[singData] + altAnim, true);
						if (Stage.exChar2 != null)
						Stage.exChar2.holdTimer = 0;
						}

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
							});
						}

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				if (!daNote.mustPress && doMiddleScroll && !executeModchart)
					daNote.alpha = 0;

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
				}

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
					&& daNote.mustPress
					&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale)
					&& songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						if (loadRep && daNote.isSustainNote)
						{
							if (findByTime(daNote.strumTime) != null)
								totalNotesHit += 1;
							else
							{
								if(daNote.noteType != 'Whistle Note')
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									noteMiss(daNote.noteData, daNote);
								}
								if (daNote.isParent)
								{
									if(daNote.noteType != 'Whistle Note' && daNote.noteType != 'Signal Note')
									health -= 0.15;
									if(daNote.noteType == 'Signal Note')
									health -= 0.01;
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
										{
											misses++;
											totalNotesHit -= 1;
										}
										updateAccuracy();
									}
									else if (!daNote.wasGoodHit && !daNote.isSustainNote)
									{
										if(daNote.noteType != 'Whistle Note' && daNote.noteType != 'Signal Note')
										health -= 0.15;
										if(daNote.noteType == 'Signal Note')
										health -= 0.01;
									}
								}
							}
						}
						else
						{
							if(daNote.noteType != 'Whistle Note')
							vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent && daNote.visible)
							{
								if(daNote.noteType != 'Whistle Note' && daNote.noteType != 'Signal Note')
								health -= 0.15;
								if(daNote.noteType == 'Signal Note')
								health -= 0.01;
								trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
									{
										misses++;
										totalNotesHit -= 1;
									}
									updateAccuracy();
								}
								else if (!daNote.wasGoodHit && !daNote.isSustainNote)
								{
									if(daNote.noteType != 'Whistle Note' && daNote.noteType != 'Signal Note')
									health -= 0.15;
									if(daNote.noteType == 'Signal Note')
									health -= 0.01;
								}
							}
						}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
			checkEventNote();
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		return SONG.notes[curSection2];
	}

	public function getSectionByTime2(ms:Float):Int
	{
		var start = [];
		var end = [];
		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		for (i in 0...SONG.notes.length)
		{
			if(SONG.notes[i] != null)
			{
				start[i] = daPos;
				if (SONG.notes[i].changeBPM)
				{
					daBPM = SONG.notes[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
				end[i] = daPos;
			}
		}

		for (i in 0...SONG.notes.length)
		{
			if(SONG.notes[i] != null)
			{
			if (ms >= start[i] && ms < end[i])
			{
				return i;
			}
			}
		}

		return 0;
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null) section = curSection2;
		var val:Null<Float> = null;
		
		if(SONG.notes[section] != null) val = SONG.notes[section].sectionBeats;
		return val != null ? val : 4;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length)
		{
			var section = SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

var seenCutscene2 = false;

	function endSong():Void
	{
		if (currentSong.toLowerCase() == 'indignation' && isStoryMode && !seenCutscene2)
		{
			startVideo('Finale');
			seenCutscene2 = true;
			return;
		}
		if(songEnded) return;
		songEnded = true;
		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		seenCutscene = false;

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			FlxG.switchState(new StageDebugState(Stage.curStage));
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						if (FlxG.save.data.songPosition)
						{
							FlxTween.tween(songPosBar, {alpha: 0}, 1);
							FlxTween.tween(bar, {alpha: 0}, 1);
							FlxTween.tween(songName, {alpha: 0}, 1);
						}
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						GameplayCustomizeState.freeplayBf = 'bf';
						GameplayCustomizeState.freeplayDad = 'dad';
						GameplayCustomizeState.freeplayGf = 'gf';
						GameplayCustomizeState.freeplayNoteStyle = 'normal';
						GameplayCustomizeState.freeplayStage = 'stage';
						GameplayCustomizeState.freeplaySong = 'bopeebo';
						GameplayCustomizeState.freeplayWeek = 1;
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						CustomFadeTransition.nextCamera = PlayState.instance.camOther;
						FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
						CustomFadeTransition.finishCallback = function() {
						FlxG.switchState(new MainMenuState());
						};
						clean();
					}

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}
				}
				else
				{
					var diff:String = ["-easy", "", "-hard"][storyDifficulty];

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
					FlxG.sound.music.stop();

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					CustomFadeTransition.nextCamera = PlayState.instance.camOther;
					FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
					CustomFadeTransition.finishCallback = function() {
					LoadingState.loadAndSwitchState(new PlayState());
					};
					clean();
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					CustomFadeTransition.nextCamera = PlayState.instance.camOther;
					FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
					CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(new FreeplayState());
					};
					clean();
				}
			}
		}
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float;
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset;
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.1;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = null;

			rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = [];
				var directionList:Array<Int> = [];
				var dumbNotes:Array<Note> = [];
				var directionsAccounted:Array<Bool> = [false, false, false, false];

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i);
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (loadRep)
					{
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = 0;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = 0;
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
				boyfriend.dance();
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon') && !blockInput)
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		switch(daNote.noteType) {
		case 'Whistle Note':
		return;
		case 'Signal Note':
				if(!blockInput)
					{
						FlxG.sound.play(Paths.sound('SignalNote'));
						mech1.animation.play('move');
						FlxTween.tween(mech1, {alpha: 1}, 0.3, {ease: FlxEase.cubeInOut});
						blockInput = true;
signalTween = FlxTween.tween(mech1, {alpha: 0.00001}, 0.3, {ease: FlxEase.cubeInOut, startDelay: 5, onComplete: function(twn:FlxTween){blockInput = false; signalTween = null;}});
					}
		return;
		}

		if (!boyfriend.stunned)
		{
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (combo != 0)
			{
				combo = 0;
				popUpScore(null);
			}
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
				]);
				saveJudge.push("miss");
			}

			totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
			}

			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	var blockInput:Bool = false;
	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
	if (blockInput) return;
					switch(note.noteType) {
						case 'Whistle Note':
							if(!PlayStateChangeables.botPlay)
							{
							FlxG.sound.play(Paths.sound('GuardsWhistleNote'));
							songSpeed += 0.3;
							note.kill();
							notes.remove(note, true);
							note.destroy();
							}
							return;
						case 'Signal Note':
							note.kill();
							notes.remove(note, true);
							note.destroy();
							return;
					}

		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}

			var altAnim:String = "";

			boyfriend.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * songMultiplier)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * songMultiplier)))
		{
			resyncVocals();
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (currentSection != null)
		{
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
				if (Stage.exChar1 != null && idleToBeat && !Stage.exChar1.animation.curAnim.name.startsWith('sing'))
					Stage.exChar1.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (Stage.exChar2 != null &&idleToBeat && !Stage.exChar2.animation.curAnim.name.startsWith('sing'))
					Stage.exChar2.dance(forcedToIdle, currentSection.CPUAltAnim);
			}
			else if (dad.curCharacter == 'gf' && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance(forcedToIdle, currentSection.CPUAltAnim);
		}
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && Conductor.bpm < 340)
		{
			if (PlayState.SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}
		if (Conductor.bpm < 340)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		else
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 4));
			iconP2.setGraphicSize(Std.int(iconP2.width + 4));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (!endingSong && currentSection != null)
		{
			if (allowedToHeadbang)
			{
				gf.dance();
			}

			if (PlayStateChangeables.Optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
		}
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Change Loathed Background':
				switch(value1)
				{
					case 'phase2':
						if(Stage.ob1 != null)
						Stage.ob1.alpha = 0;
						if(Stage.ob2 != null)
						Stage.ob2.alpha = 0;
						if(Stage.ob3 != null)
						Stage.ob3.alpha = 0;
						if(Stage.ob4 != null)
						Stage.ob4.alpha = 0;
						if(Stage.ob5 != null)
						Stage.ob5.alpha = 1;
						if(Stage.ob6 != null)
						Stage.ob6.alpha = 1;
						if(Stage.ob7 != null)
						Stage.ob7.alpha = 1;
						Stage.curLoathedState = 2;
						gf.setPosition(550, -130);
						boyfriend.setPosition(-800 + 50, -700 + 300);
						dad.setPosition(760 + -700, -320 + -300);

					case 'phase1':
						if(Stage.ob1 != null)
						Stage.ob1.alpha = 1;
						if(Stage.ob2 != null)
						Stage.ob2.alpha = 1;
						if(Stage.ob3 != null)
						Stage.ob3.alpha = 1;
						if(Stage.ob4 != null)
						Stage.ob4.alpha = 1;
						if(Stage.ob5 != null)
						Stage.ob5.alpha = 0;
						if(Stage.ob6 != null)
						Stage.ob6.alpha = 0;
						if(Stage.ob7 != null)
						Stage.ob7.alpha = 0;
						Stage.curLoathedState = 1;
						gf.setPosition(550, -130);
						boyfriend.setPosition(-800, -700 + 350);
						dad.setPosition(760, -320);
				}

			case 'Add Camera Zoom':
				if(FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

				case 'Set Cam Zoom':
					camZooming = false;
					Stage.camZoom = Std.parseFloat(value1);
					camZooming = true;

			case 'Play Animation':
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'henry':
						if (Stage.exChar1 != null)
						char = Stage.exChar1;
					case 'james':
						if (Stage.exChar2 != null)
						char = Stage.exChar2;
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.dance();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}
			
			case 'White Flash':
				camOther.flash(FlxColor.WHITE,Std.parseFloat(value1));
				if(Stage.curStage == "splendid"){
					Stage.ob5.alpha = 1;
					Stage.ob6.alpha = 1;
					Stage.ob4.alpha = 1;
					Stage.ob3.alpha = 0;
					Stage.modifier = 3;
				}

			case 'Kill Topham':
				if(Stage.curStage == "confusion"){
				Stage.ob4.visible = false;
				}
				dad.alpha = 1;

			case 'BF Fade':
				FlxTween.tween(boyfriend, {alpha: Std.parseFloat(value2)}, Std.parseFloat(value1), {
					ease: FlxEase.cubeInOut
				});
			case 'HUD Fade':
				FlxTween.tween(camHUD, {alpha: Std.parseFloat(value2)}, Std.parseFloat(value1), {
					ease: FlxEase.cubeInOut
				});
			case 'Set Health Bar':
					switch(value1)
					{
						case 'henry':
							iconP2.changeIcon('madhenry');
						case 'james':
							iconP2.changeIcon('madjames');
						case 'gordon':
							iconP2.changeIcon('gordon');
						case 'gordon2':
							iconP2.changeIcon('gordon-rage');
								
					}

					reloadHealthBarColors(value1);
			case 'Set Camera Target':
				if (value1 == 'gordon')
				{
					singChar = '';
				}
				else
				{
					singChar = value1;
				}
				
				if(value2 == 'true')
				{
					switch(singChar)
					{
					case 'henry':
					if (Stage.exChar1 != null)
					camFollow.x = Stage.exChar1.getMidpoint().x + 150;
					if (Stage.exChar1 != null)
					camFollow.y = Stage.exChar1.getMidpoint().y - 100;
					camFollow.x += 500 + -420;
					camFollow.y += -150 + 0;
					case 'james':
					if (Stage.exChar2 != null)
					camFollow.x = Stage.exChar2.getMidpoint().x + 150;
					if (Stage.exChar2 != null)
					camFollow.y = Stage.exChar2.getMidpoint().y - 100;
					camFollow.x += -180 + -420;
					camFollow.y += -150 + 0;
					case '':
					camFollow.x = dad.getMidpoint().x + 150;
					camFollow.y = dad.getMidpoint().y - 100;
					camFollow.x += -60 + -420;
					camFollow.y += -30 + 0;
					default:
					camFollow.x = dad.getMidpoint().x + 150;
					camFollow.y = dad.getMidpoint().y - 100;
					camFollow.x += -60 + -420;
					camFollow.y += -30 + 0;
					}
				}

			case 'Camera Fade':
				if (gameBlackLayerAlphaTween != null)
				{
					gameBlackLayerAlphaTween.cancel();
					gameBlackLayerAlphaTween = null;
				}
				var leAlpha:Float = Std.parseFloat(value1);
				if(Math.isNaN(leAlpha)) leAlpha = 1;

				leAlpha = 1 - leAlpha;

				var duration:Float = Std.parseFloat(value2);
				if(Math.isNaN(duration)) duration = 1;

				if (duration > 0)
				{
					gameBlackLayerAlphaTween = FlxTween.tween(gameBlackLayer, {alpha: leAlpha}, duration, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							gameBlackLayerAlphaTween = null;
						}
					});
				}
				else
				{
					gameBlackLayer.alpha = leAlpha;
				}

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							boyfriend.dance();
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							dad.dance();
							iconP2.changeIcon(value2);
						}

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
								gf.dance();
							}
						}
				}
				reloadHealthBarColors();

							switch(Stage.curLoathedState)
							{
							case 2:
							gf.setPosition(550, -130);
							boyfriend.setPosition(-800 + 50, -700 + 300);
							dad.setPosition(760 + -700, -320 + -300);
							case 1:
							gf.setPosition(550, -130);
							boyfriend.setPosition(-800, -700 + 350);
							dad.setPosition(760, -320);
							}

			case 'Start Rain':
				if(Stage.curStage == "sadstory"){
				FlxTween.tween(Stage.ob6, {alpha: 1}, 0.4, {ease: FlxEase.linear, onComplete:
					function (twn:FlxTween)
					{
						
					}
				});

				FlxTween.tween(Stage.ob7, {alpha: 0.60}, 0.4, {ease: FlxEase.linear, onComplete:
					function (twn:FlxTween)
					{
						
					}
				});
				}

			case 'fnaf2':
				var randomNumber:Int = FlxG.random.int(0, 100);
				var randomSprite:Int = FlxG.random.int(0, 3);
				if (randomNumber == 0) randomSprite == 4;

				var jumpScare:FlxSprite = new FlxSprite().loadGraphic(Paths.image('monochrome/${monochromeSprites[randomSprite]}'));
				jumpScare.setGraphicSize(Std.int(FlxG.width));
				jumpScare.updateHitbox();
				jumpScare.cameras = [camHUD];
				belowArrowGrp.add(jumpScare);
				new FlxTimer().start(0.15, function(timer:FlxTimer)
					{
						belowArrowGrp.remove(jumpScare);

						var randomNumber2:Int = FlxG.random.int(0, 100);
						var randomSprite2:Int = FlxG.random.int(0, 3);
						if (randomNumber2 == 0) randomSprite2 == 4;
						var jumpScare2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('monochrome/${monochromeSprites[randomSprite2]}'));
						jumpScare2.setGraphicSize(Std.int(FlxG.width));
						jumpScare2.updateHitbox();
						jumpScare2.cameras = [camHUD];
						belowArrowGrp.add(jumpScare2);
						new FlxTimer().start(0.15, function(timer:FlxTimer)
							{
								belowArrowGrp.remove(jumpScare2);
		
								var randomNumber3:Int = FlxG.random.int(0, 100);
								var randomSprite3:Int = FlxG.random.int(0, 3);
								if (randomNumber3 == 0) randomSprite3 == 4;
								var jumpScare3:FlxSprite = new FlxSprite().loadGraphic(Paths.image('monochrome/${monochromeSprites[randomSprite3]}'));
								jumpScare3.setGraphicSize(Std.int(FlxG.width));
								jumpScare3.updateHitbox();
								jumpScare3.cameras = [camHUD];
								belowArrowGrp.add(jumpScare3);
								new FlxTimer().start(0.15, function(timer:FlxTimer)
									{
										belowArrowGrp.remove(jumpScare3);
									});
							});
					});

			case 'spawn image':
				var jumpScare:FlxSprite = new FlxSprite().loadGraphic(Paths.image('endless/${value1}'));
				jumpScare.setGraphicSize(Std.int(jumpScare.width * 0.3));
				jumpScare.updateHitbox();
				jumpScare.screenCenter();
				jumpScare.cameras = [camHUD];
				add(jumpScare);
				FlxTween.tween(jumpScare, {alpha: 0}, Std.parseFloat(value2), {ease: FlxEase.cubeInOut, onComplete: function(tween:FlxTween)
					{
						remove(jumpScare);
					}});

			case 'opendoor':
				if(Stage.curStage == "indignation"){
				switch(value1)
				{
					case 'henry':
						Stage.ob2.animation.play('indig_shed dooropen');
						Stage.ob2.animation.finishCallback = function(name:String)
							{
								if(name == 'indig_shed dooropen')
									{
										Stage.ob2.animation.play('indig_shed dooropenidle');
									}
							}

					case 'james':
						Stage.ob3.animation.play('indig_shed dooropen');
						Stage.ob3.animation.finishCallback = function(name:String)
							{
								if(name == 'indig_shed dooropen')
									{
										Stage.ob3.animation.play('indig_shed dooropenidle');
									}
							}
					case 'gordon':
						if (value2 == 'open')
						{
							Stage.ob4.animation.play('indig_shed dooropen');
							Stage.ob4.animation.finishCallback = function(name:String)
								{
									if(name == 'indig_shed dooropen')
										{
											Stage.ob4.animation.play('indig_shed dooropenidle');
										}
								}
						}
						if (value2 == 'close')
							{
								Stage.ob4.animation.play('indig_shed doorclose');
								Stage.ob4.animation.finishCallback = function(name:String)
									{
										if(name == 'indig_shed doorclose')
											{
												Stage.ob4.animation.play('indig_shed doorcloseidle');
											}
									}
							}
				}
				}
			case 'Play Video':
				if (value1 != 'train_standoff')
				{
					var whiteSprite:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
					whiteSprite.cameras = [camHUD];
					add(whiteSprite);
				}
				canPause = false;
				startVideo(value1);
		}
	}

	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function reloadHealthBarColors(?chara:String) {
		var healthbarWhite = Paths.loadImage('healthbar/healthbar_white');
		var barDad = cloneFlxGraphic(healthbarWhite);
		var barBf = cloneFlxGraphic(healthbarWhite);

var dadColor:FlxColor = 0xFFFF0000;
var bfColor:FlxColor = 0xFF66FF33;
if (FlxG.save.data.colour)
{
dadColor = dad.barColor;
if(chara == 'henry' && Stage.curStage == 'indignation')
if (Stage.exChar1 != null)
dadColor = Stage.exChar1.barColor;
if(chara == 'james' && Stage.curStage == 'indignation')
if (Stage.exChar2 != null)
dadColor = Stage.exChar2.barColor;
bfColor = boyfriend.barColor;
}

var rect = barDad.bitmap.rect;
var rect2 = barBf.bitmap.rect;

var colorTransform = new ColorTransform(dadColor.redFloat, dadColor.greenFloat, dadColor.blueFloat, healthBar.alpha);
var colorTransform2 = new ColorTransform(bfColor.redFloat, bfColor.greenFloat, bfColor.blueFloat, healthBar.alpha);

barDad.bitmap.colorTransform(rect, colorTransform);
barBf.bitmap.colorTransform(rect2, colorTransform2);

		healthBar.createImageBar(barDad, barBf);

		healthBar.updateBar();
	}

function cloneFlxGraphic(original:FlxGraphic):FlxGraphic {
    var clonedBitmap:BitmapData = original.bitmap.clone();

    var clonedGraphic:FlxGraphic = FlxGraphic.fromBitmapData(clonedBitmap);

    return clonedGraphic;
}

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					insert(members.indexOf(boyfriend), newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					if(boyfriend != null)
					{
					newBoyfriend.x = boyfriend.x;
					newBoyfriend.y = boyfriend.y;
					}
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					insert(members.indexOf(dad), newDad);
					newDad.alpha = 0.00001;
					if(dad != null)
					{
					newDad.x = dad.x;
					newDad.y = dad.y;
					}
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(gf.x, gf.y, newCharacter);
					gfMap.set(newCharacter, newGf);
					insert(members.indexOf(gf), newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			case 'Play Video':
				var filepath:String = '';
				filepath = Paths.video(event.value1);
				#if sys
				if(!FileSystem.exists(filepath))
				#else
				if(!OpenFlAssets.exists(filepath))
				#end
				{
				FlxG.log.warn('Couldnt find video file: ' + event.value1);
				return;
				}
				var video:MP4Handler = new MP4Handler();
				video.playVideo(filepath);
				video.stop();
				video.alpha = 0.00000001;
		}
	}

	var sizeTarg:Float = 0;

	public static var oreoWindow:Bool = false;
	public static var oreoXpos:Int = 0;
	public static var oreoYpos:Int = 0;

	function resizeDaWindow(newWinSizeTarg:Array<Int>)
		{
			oreoWindow = true;
			oreoXpos = Application.current.window.x;
			oreoYpos = Application.current.window.y;
			FlxG.resizeWindow(newWinSizeTarg[0],newWinSizeTarg[1]);
			FlxG.scaleMode = new RatioScaleMode(true);
			Application.current.window.fullscreen = false;
			Application.current.window.resizable = false;
			var targetPos:Array<Float> = [(Capabilities.screenResolutionX/2)-(newWinSizeTarg[0]/2),(Capabilities.screenResolutionY/2)-(newWinSizeTarg[1]/2)];
			Application.current.window.x = Std.int(targetPos[0]);
			Application.current.window.y = Std.int(targetPos[1]);
			sizeTarg = newWinSizeTarg[0];
		}

	public static function resetWindow()
		{
			FlxG.resizeWindow(1280,720);
			FlxG.scaleMode = new RatioScaleMode(false);
			Application.current.window.resizable = true;
			Application.current.window.x = oreoXpos;
			Application.current.window.y = oreoYpos;
			oreoWindow = false;
		}

	override function destroy()
	{
		if (oreoWindow)
			resetWindow();

		super.destroy();
	}

	public function startVideo(name:String)
	{
		if (name != 'train_standoff')
		inCutscene = true;

		var whiteSprite:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteSprite.cameras = [camOther];
		whiteSprite.screenCenter();

		if (name == 'kipper')
		{
			canPause = false;
			add(whiteSprite);
		}

		if (name == 'Splendid')
		{
			canPause = false;
			add(whiteSprite);
		}

		if (name == 'Indignation')
		{
			canPause = false;
			add(whiteSprite);
		}

		if (name == 'Finale')
		{ 
			canPause = false;
			endingSong = true;
			var blackSprite:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackSprite.cameras = [camOther];
			blackSprite.screenCenter();
			add(blackSprite);
		}

		if (name == 'jamescrashscene')
		{
		endingSong = true;
		}

		canReset = false;

		var filepath:String = '';
		filepath = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		if (name == 'train_standoff')
			video.skipKeys = [FlxKey.SPACE];
		else if (name == 'jamescrashscene')
			video.skipKeys = [];
		else
			video.skipKeys = [FlxKey.ENTER];
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			if (name == 'train_standoff')
			{
				Stage.curLoathedState = 1;
				FlxTween.tween(songtitleTxt, {alpha: 1}, 3, {ease: FlxEase.quadInOut, onComplete: function(shit:FlxTween){
					FlxTween.tween(songtitleTxt, {alpha: 0}, 3, {ease: FlxEase.quadInOut});
				}});
				FlxTween.tween(composerTxt, {alpha: 1}, 3, {ease: FlxEase.quadInOut, onComplete: function(shit:FlxTween){
					FlxTween.tween(composerTxt, {alpha: 0}, 3, {ease: FlxEase.quadInOut});
				}});
				canPause = true;
				if (Stage.ob16 != null) remove(Stage.ob16);
			}
			else
			{
				inCutscene = false;
				startAndEnd();
				if (name == 'kipper')
				{
				canPause = true;
				remove(whiteSprite);
				}

				if (name == 'Splendid')
				{
				canPause = true;
				remove(whiteSprite);
				}

				if (name == 'Indignation')
				{
				canPause = true;
				remove(whiteSprite);
				}
			}
			canReset = true;
			return;
		}
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
		{
			startCountdown();
			if (!skipCountdown)
			FlxG.camera.flash(FlxColor.WHITE, 3, null, true);
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = songMultiplier;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = songMultiplier;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}
}
