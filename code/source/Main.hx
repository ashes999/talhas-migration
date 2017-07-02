package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, deengames.talhasmigration.states.CoreGameState, 0, 60, 60, true));
	}
}
