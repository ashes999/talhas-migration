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
import helix.core.HelixText;
import helix.data.Config;
import helix.random.IntervalRandomTimer;

import deengames.talhasmigration.entities.Player;
import deengames.talhasmigration.entities.predators.MorayEel;
import deengames.talhasmigration.entities.predators.SwimmingCrab;
import deengames.talhasmigration.entities.prey.Jellyfish;
import deengames.talhasmigration.entities.prey.Starfish;

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
	private var ceiling:HelixSprite;
	private var entitySpawner:IntervalRandomTimer;

	// Collision groups. Used to set collision handlers once.
	private var preyGroup = new FlxTypedGroup<HelixSprite>(); // FlxGroup<HelixSprite>
	private var predatorGroup = new FlxTypedGroup<HelixSprite>();

	// UI elements
	private var healthText:FlxText;
	private var foodPointsText:FlxText;
	private var distanceText:FlxText;

	override public function create():Void
	{
		super.create();
		this.bgColor = flixel.util.FlxColor.fromRGB(0, 0, 64);

		this.ground1 = new HelixSprite("assets/images/ground.png").collisionImmovable();
		this.ground2 = new HelixSprite("assets/images/ground.png").collisionImmovable();
		this.ceiling = new HelixSprite("assets/images/ceiling.png").collisionImmovable();

		this.healthText = new HelixText(0, UI_PADDING, "Health: 0/0", UI_FONT_SIZE);
		this.distanceText = new HelixText(0, 0, "", UI_FONT_SIZE);
		this.foodPointsText = new HelixText(0, 2 * UI_PADDING, "", UI_FONT_SIZE);

		this.restart(); // common setup to start/restart

		// Restrict camera so that player can tell they're at the ceiling
		this.camera.minScrollY = this.ceiling.y;

		var random:FlxRandom = new FlxRandom();

		this.entitySpawner = new IntervalRandomTimer(0.5, 1, function()
		{
			if (!this.player.dead)
			{
				var weightArray:Array<Float> = [
					Config.get("jellyfishWeight"),
					Config.get("swimmingCrabWeight"),
					Config.get("morayEelWeight"),
					Config.get("starfishWeight")
				];

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
					nextEntity = this.preyGroup.recycle(Jellyfish);		
				}
				else if (nextEntityPick == 1) // Swimming crab
				{
					nextEntity = this.predatorGroup.recycle(SwimmingCrab);
				}
				else if (nextEntityPick == 2) // Moral eel
				{
					nextEntity = this.predatorGroup.recycle(MorayEel);
					targetY = ground1.y - (nextEntity.height / 2); // ground it
				}
				else if (nextEntityPick == 3) // Starfish
				{
					nextEntity = this.preyGroup.recycle(Starfish);
					targetY = ground1.y - nextEntity.height; // ground it					
				}
				else
				{
					throw 'Weighted entity array returned ${nextEntityPick} but there is no implementation for that yet.';
				}

				// If null, recycle failed in some horrible way ...
				// HaxeFlixel doesn't call reset for some reason.
				nextEntity.reset(targetX, targetY);
			}
		});
	}

	override public function update(elapsedSeconds:Float):Void
	{
		super.update(elapsedSeconds);
		entitySpawner.update(elapsedSeconds);

		this.ceiling.move(camera.scroll.x, Config.get("ceilingY"));
		var previousGround:HelixSprite = ground1.x < ground2.x ? ground1 : ground2;
		var aheadGround:HelixSprite = previousGround == ground1 ? ground2 : ground1;

		// Allow colliding with stuff outside of the screen
		this.setCollisionBounds(previousGround.x, camera.scroll.y, previousGround.width + aheadGround.width, camera.height);

		// ONLY WORKS if ground width > viewport width
		// this.width/2 and player.width/2 must be accounted for because of centering the camera
		// otherwise, we get artifacts (slight empty areas) when the ground moves.
		if (this.player.x + (player.width / 2) > previousGround.x + previousGround.width + (this.width / 2))
		{
			previousGround.move(aheadGround.x + aheadGround.width, previousGround.y);
		}

		// UI is affected by speed. How can we do this after HelixSprite.update?
		this.updateUi();

		// TODO: kill things that fall off the LHS of the screen. Stuff spawns on the RHS off-screen.
		// http://forum.haxeflixel.com/topic/617/necessary-to-remove-off-screen-flxsprite-instances
		for (prey in this.preyGroup)
		{
			if (prey.exists && prey.x < this.camera.scroll.x - prey.width)
			{
				prey.exists = false;
			}
		}

		for (predator in this.predatorGroup)
		{
			if (predator.exists && predator.x < this.camera.scroll.x - predator.width)
			{
				predator.exists = false;
			}
		}
	}

	// Done every tick
	private function updateUi():Void
	{
		this.healthText.x = this.camera.scroll.x + this.width - this.healthText.width - UI_PADDING;
		this.healthText.y = this.camera.scroll.y + UI_PADDING;

		this.distanceText.x = this.camera.scroll.x + 2 * UI_PADDING;
		this.distanceText.y = this.camera.scroll.y + UI_PADDING;
		this.distanceText.text = '${Std.int(this.camera.scroll.x / Std.int(Config.get("pixelsPerMeter")))}m';

		this.foodPointsText.x = this.distanceText.x;
		this.foodPointsText.y = this.distanceText.y + this.distanceText.height;
	}

	private function updateFoodPointsDisplay(pointsGained:Int):Void
	{
		player.foodPoints += pointsGained;
		var pointsPerLevel:Int = Config.get("foodPointsRequiredPerLevel");
		var foodLevel:Int = Math.floor(player.foodPoints / pointsPerLevel);
		this.foodPointsText.text = 'Food: ${player.foodPoints}/${(foodLevel + 1) * pointsPerLevel}';
	}

	private function restart(?gameOverText:FlxText, ?restartButton:HelixSprite):Void
	{
		if (gameOverText != null)
		{
			gameOverText.destroy();
			remove(gameOverText);
		}

		if (restartButton != null)
		{
			restartButton.destroy();
			remove(restartButton);
		}

		// Destroy. Everything.
		for (predator in predatorGroup)
		{
			predator.exists = false;
		}

		for (prey in preyGroup)
		{
			prey.exists = false;
		}

		ground1.move(0, this.height - 32);
		ground2.move(ground1.x + ground1.width, ground1.y);
		
		this.player = new Player();
		this.player.move(this.width / 2, (this.height - player.height) / 2);

		this.player.collideResolve(this.ground1);
		this.player.collideResolve(this.ground2);
		this.player.collideResolve(this.ceiling);

		this.player.collide(this.preyGroup, function(player:Player, prey:HelixSprite)
		{
			prey.exists = false;

			var foodPoints:Int = 0;
			// TODO: use reflection to decide config key OR, refactor points into a
			// prey class (or something) and use that to do this without a big if-statement
			if (Std.is(prey, Jellyfish))
			{
				foodPoints = Config.get("foodPointsJellyfish");
			}
			else if (Std.is(prey, Starfish))
			{
				foodPoints = Config.get("foodPointsStarfish");
			}
			else
			{
				throw 'Did not implement food points cost yet for ${Type.getClassName(Type.getClass(prey))}';
			}

			this.updateFoodPointsDisplay(foodPoints);
		});

		this.player.collide(this.predatorGroup, function(player:Player, predator:HelixSprite)
		{
			player.getHurt();
			this.updateHealthText();

			if (player.dead)
			{
				this.remove(player);
				player.destroy();

				var restartButton = new HelixSprite("assets/images/ui/restart.png");				

				restartButton.move(this.camera.scroll.x + (this.width - restartButton.width) / 2,
					this.camera.scroll.y + (this.height - restartButton.height) / 2);

				this.add(restartButton);

				var gameOverText = new HelixText(0, 0, "You Died!", 48);
				gameOverText.x = this.camera.scroll.x + (this.width - gameOverText.width) / 2;
				gameOverText.y = restartButton.y + restartButton.height + UI_PADDING;

				restartButton.onClick(function() { 
					this.restart(gameOverText, restartButton);
				});
			}
		});

		// set initial text
		this.updateFoodPointsDisplay(0);
		this.updateHealthText();
	}

	private function updateHealthText():Void
	{
		this.healthText.text = 'Health: ${this.player.currentHealth}/${this.player.totalHealth}';		
	}
}
