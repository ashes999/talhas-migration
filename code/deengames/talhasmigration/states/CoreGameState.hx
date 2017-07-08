package deengames.talhasmigration.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import helix.core.HelixSprite;
import helix.core.HelixState;

import deengames.talhasmigration.entities.IntervalSpawner;
import deengames.talhasmigration.entities.Jellyfish;
import deengames.talhasmigration.entities.Player;

class CoreGameState extends HelixState
{
	private static inline var UI_PADDING:Int = 12;

	private var player:Player;
	// Two pieces of ground, constantly move one ahead of the player so that
	// it looks like the ground is infinitely scrolling
	private var ground1:HelixSprite;
	private var ground2:HelixSprite;
	private var jellyfishSpawner:IntervalSpawner;
	private var healthText:FlxText;
	private var allJellyfish = new FlxGroup();

	override public function create():Void
	{
		super.create();
		this.bgColor = flixel.util.FlxColor.fromRGB(0, 0, 64);

		ground1 = new HelixSprite("assets/images/ground.png").collisionImmovable();
		ground1.move(0, this.height - 32);

		ground2 = new HelixSprite("assets/images/ground.png").collisionImmovable();
		ground2.move(ground1.x + ground1.width, ground1.y);
		
		this.player = new Player();
		this.player.move(this.width / 2, (this.height - player.height) / 2);

		this.player.collideResolve(ground1);
		this.player.collideResolve(ground2);

		this.player.collide(this.allJellyfish, function(player:Player, jellyfish:Jellyfish) {
			this.remove(jellyfish);
			player.getHurt();
			jellyfish.destroy();			
			this.allJellyfish.remove(jellyfish);
		});

		var random:FlxRandom = new FlxRandom();

		jellyfishSpawner = new IntervalSpawner(0.5, 1, function()
		{
			var jellyfish:Jellyfish = new Jellyfish();
			// position randomly off-screen (RHS).
			 // 1.5x => spawn slightly off-screen
			var targetX = this.camera.scroll.x + (this.width * 1.5);
			jellyfish.move(targetX, random.float(0, ground1.y));
			allJellyfish.add(jellyfish);			
		});

		this.healthText = this.addText(0, UI_PADDING, 'Health: ${player.currentHealth}/${player.totalHealth}', 24);
	}

	override public function update(elapsedSeconds:Float):Void
	{
		super.update(elapsedSeconds);
		jellyfishSpawner.update(elapsedSeconds);

		var previousGround:HelixSprite = ground1.x < ground2.x ? ground1 : ground2;
		var aheadGround:HelixSprite = previousGround == ground1 ? ground2 : ground1;

		// Allow colliding with stuff outside of the screen
		this.setCollisionBounds(0, 0, aheadGround.x + aheadGround.width, this.height);

		// ONLY WORKS if ground width > viewport width
		// this.width/2 and player.width/2 must be accounted for because of centering the camera
		// otherwise, we get artifacts (slight empty areas) when the ground moves.
		if (this.player.x + (player.width / 2) > previousGround.x + previousGround.width + (this.width / 2))
		{
			previousGround.move(aheadGround.x + aheadGround.width, previousGround.y);
		}

		this.updateUi();
	}

	private function updateUi():Void
	{
		this.healthText.text = 'Health: ${player.currentHealth}/${player.totalHealth}';
		this.healthText.x = this.camera.scroll.x + this.width - this.healthText.width - UI_PADDING;
		this.healthText.y = this.camera.scroll.y + UI_PADDING;
	}
}
