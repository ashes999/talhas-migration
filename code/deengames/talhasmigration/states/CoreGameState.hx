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
using turbo.ecs.components.SpriteComponent;

import deengames.talhasmigration.entities.Turtle;

class CoreGameState extends TurboState
{
	private var player:Turtle;
	// Two pieces of ground, constantly move one ahead of the player so that
	// it looks like the ground is infinitely scrolling
	private var ground1:Entity;
	private var ground2:Entity;

	override public function create():Void
	{
		super.create();
		this.bgColor = flixel.util.FlxColor.fromRGB(0, 0, 64);

		ground1 = new Entity("ground").image("assets/images/ground.png").immovable();
		ground1.move(0, this.height - 32);
		this.addEntity(ground1);

		ground2 = new Entity("ground").image("assets/images/ground.png").immovable();
		ground2.move(ground1.x + ground1.width, ground1.y);
		this.addEntity(ground2);
		
		this.player = new Turtle();
		this.player.move(this.width / 2, (this.height - player.height) / 2);
		this.addEntity(this.player);
	}

	override public function update(elapsedSeconds:Float):Void
	{
		// trace('----------- ${Date.now()} ----------');
		super.update(elapsedSeconds);
		var previousGround:Entity = ground1.x < ground2.x ? ground1 : ground2;
		var aheadGround:Entity = previousGround == ground1 ? ground2 : ground1;

		// this.width/2 and player.width/2 must be accounted for because of centering the camera
		// otherwise, we get artifacts (slight empty areas) when the ground moves.
		if (this.player.x + (player.width / 2) > previousGround.x + previousGround.width + (this.width / 2))
		{
			previousGround.move(aheadGround.x + aheadGround.width, previousGround.y);
		}
		// trace("------------------------------------");
	}
}
