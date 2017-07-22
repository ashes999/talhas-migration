package;

import flixel.FlxGame;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;

import polyglot.Translater;

class Main extends Sprite
{
	public function new()
	{
		super();

		var localizations = ["en-CA"];
		for (localization in localizations)
		{
			Translater.addLanguage(localization, Assets.getText('assets/data/localizations/${localization}.txt'));
		}
		Translater.selectLanguage(localizations[0]);

		addChild(new FlxGame(0, 0, deengames.talhasmigration.states.CoreGameState, 1, 60, 60, true));
	}
}
