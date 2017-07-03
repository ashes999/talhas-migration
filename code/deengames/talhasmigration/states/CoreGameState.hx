package deengames.talhasmigration.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

import turbo.ecs.Entity;
import turbo.ecs.TurboState;
using turbo.ecs.EntityFluentApi;

import deengames.talhasmigration.entities.Turtle;

class CoreGameState extends TurboState
{
	private var player:Turtle;

	override public function create():Void
	{
		super.create();
		var wall = new Entity("Wall").size(640, 8).colour(255, 255, 255).immovable();
		this.addEntity(wall);
		
		this.player = new Turtle();
		this.player.move(32, 32);
		this.addEntity(this.player);
		this.player.collideWith("Wall");
	}
}
