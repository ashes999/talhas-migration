package deengames.talhasmigration.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import turbo.ecs.TurboState;
import deengames.talhasmigration.entities.Turtle;
using turbo.ecs.EntityFluentApi;

class CoreGameState extends TurboState
{
	private var player:Turtle;

	override public function create():Void
	{
		super.create();
		this.player = new Turtle();
	}
}
