package;

import flixel.FlxGame;
import flixel.math.FlxRandom;

import helix.data.Config;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;

import polyglot.Translater;

class Main extends Sprite
{
	public static var seededRandom;

	public function new()
	{
		super();

		// Could be null, which causes a new random seed to generate
		var seed:Int = Config.getInt("randomSeed");
		Main.seededRandom = new FlxRandom(seed);		

		trace('Random seed: ${seededRandom.currentSeed}');

		var localizations = ["en-CA", "ar-SA"];
		for (localization in localizations)
		{
			Translater.addLanguage(localization, Assets.getText('assets/data/localizations/${localization}.txt'));
		}
		Translater.selectLanguage(localizations[0]);

		addChild(new FlxGame(0, 0, deengames.talhasmigration.states.CoreGameState, 1, 60, 60, true));
	}
}
