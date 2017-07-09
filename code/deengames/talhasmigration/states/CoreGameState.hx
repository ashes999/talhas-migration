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
import helix.data.Config;
import helix.random.IntervalRandomTimer;

import deengames.talhasmigration.entities.Player;
import deengames.talhasmigration.entities.predators.SwimmingCrab;
import deengames.talhasmigration.entities.prey.Jellyfish;

class CoreGameState extends HelixState
{
	private static inline var UI_PADDING:Int = 12;
	private static inline var UI_FONT_SIZE:Int = 24;

	// Entities
	private var player:Player;
	// Two pieces of ground, constantly move one ahead of the player so that
	// it looks like the ground is infinitely scrolling
	private var ground1:HelixSprite;
	private var ground2:HelixSprite;
	private var entitySpawner:IntervalRandomTimer;

	// Collision groups. Used to set collision handlers once.
	private var preyGroup = new FlxGroup();
	private var predatorGroup = new FlxGroup();

	// UI elements
	private var healthText:FlxText;
	private var foodPointsText:FlxText;

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

		this.player.collide(this.preyGroup, function(player:Player, prey:HelixSprite)
		{
			this.remove(prey);
			prey.destroy();			
			this.preyGroup.remove(prey);

			var foodPoints:Int = 0;
			// TODO: use reflection to decide config key OR, refactor points into a
			// prey class (or something) and use that to do this without a big if-statement
			if (Std.is(prey, Jellyfish))
			{
				foodPoints = Config.get("foodPointsJellyfish");
			}
			else
			{
				throw 'Did not implement food points cost yet for ${Type.getClassName(Type.getClass(prey))}';
			}

			this.updateFoodPointsDisplay(foodPoints);
		});

		this.player.collide(this.predatorGroup, function(player:Player, predator:HelixSprite)
		{
			this.remove(predator);
			predator.destroy();			
			this.predatorGroup.remove(predator);

			player.getHurt();
			this.healthText.text = 'Health: ${player.currentHealth}/${player.totalHealth}';
			
			if (player.dead)
			{
				this.remove(player);
				player.destroy();

				var gameOverText = this.addText(0, 0, "You Died!", 48);
				gameOverText.x = this.camera.scroll.x + (this.width - gameOverText.width) / 2;
				gameOverText.y = this.camera.scroll.y + (this.height - gameOverText.height) / 2;
			}
		});	

		var random:FlxRandom = new FlxRandom();

		entitySpawner = new IntervalRandomTimer(0.5, 1, function()
		{
			if (!player.dead)
			{
				var weightArray:Array<Float> = [Config.get("jellyfishWeight"), Config.get("swimmingCrabWeight")];

				// TODO: put constructors into an array, unify signatures, and turn the
				// random interval timer into a REAL spawner like it used to be.
				var nextEntityPick = random.weightedPick(weightArray);
				var nextEntity:HelixSprite;

				// position randomly off-screen (RHS).
				// 1.5x => spawn slightly off-screen
				var targetX = this.camera.scroll.x + (this.width * 1.5);
				var targetY = random.float(0, ground1.y);

				if (nextEntityPick == 0) // Jellyfish
				{
					nextEntity = new Jellyfish(this.player.velocity.x);
					this.preyGroup.add(nextEntity);				
				}
				else if (nextEntityPick == 1) // Swimming crab
				{
					nextEntity = new SwimmingCrab();
					this.predatorGroup.add(nextEntity);
				}
				else
				{
					throw 'Weighted entity array returned ${nextEntityPick} but there is no implementation for that yet.';
				}

				nextEntity.move(targetX, targetY);
			}
		});

		this.healthText = this.addText(0, UI_PADDING, 'Health: ${player.currentHealth}/${player.totalHealth}', UI_FONT_SIZE);
		this.foodPointsText = this.addText(0, 0, '', UI_FONT_SIZE);		
		this.updateFoodPointsDisplay(0); // set initial text
	}

	override public function update(elapsedSeconds:Float):Void
	{
		super.update(elapsedSeconds);
		entitySpawner.update(elapsedSeconds);

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

		// TODO: kill things that fall off the LHS of the screen?
		// http://forum.haxeflixel.com/topic/617/necessary-to-remove-off-screen-flxsprite-instances
	}

	// Done every tick
	private function updateUi():Void
	{
		this.healthText.x = this.camera.scroll.x + this.width - this.healthText.width - UI_PADDING;
		this.healthText.y = this.camera.scroll.y + UI_PADDING;

		this.foodPointsText.x = this.camera.scroll.x + UI_PADDING;
		this.foodPointsText.y = this.camera.scroll.y + UI_PADDING;
	}

	private function updateFoodPointsDisplay(pointsGained:Int):Void
	{
		player.eat(pointsGained);
		var pointsPerLevel:Int = Config.get("foodPointsRequiredPerLevel");
		var foodLevel:Int = Math.floor(player.foodPoints / pointsPerLevel);
		this.foodPointsText.text = 'Food: ${player.foodPoints}/${(foodLevel + 1) * pointsPerLevel}';
	}
}
