package deengames.loggerheadrush.states;

import deengames.loggerheadrush.data.PlayerData;
import deengames.loggerheadrush.entities.Player;
import deengames.loggerheadrush.entities.predators.MorayEel;
import deengames.loggerheadrush.entities.predators.Seal;
import deengames.loggerheadrush.entities.predators.Shark;
import deengames.loggerheadrush.entities.predators.SwimmingCrab;
import deengames.loggerheadrush.entities.prey.Jellyfish;
import deengames.loggerheadrush.entities.prey.Starfish;
import deengames.loggerheadrush.entities.prey.Squid;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.core.HelixText;
import helix.data.Config;
import helix.random.IntervalRandomTimer;

import polyglot.Translater;

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

	private var minIntervalSeconds:Float = Config.getFloat("minIntervalSeconds");
	private var maxIntervalSeconds:Float = Config.getFloat("maxIntervalSeconds");
	private var sessionStartTime:Float;

	// Stuff used in debugging
	private var isSilentPaused:Bool = false;
	private var watermark:HelixSprite;

	// Where the next entity will spawn.
	private var nextEntityX:Float = 0;
	private var nextEntityY:Float = 0;
	private var nextEntityType:Class<HelixSprite>;
	private var showNextTarget:Bool = false;
	private var nextTargetArrow:HelixSprite;

	private static var MORAY_EEL_HEIGHT:Float;
	private static var STARFISH_HEIGHT:Float;
	private static var SEAL_HEIGHT:Float;

	override public function create():Void
	{
		super.create();

		// Figure out heights
		var disposable:HelixSprite = new MorayEel();
		MORAY_EEL_HEIGHT = disposable.height;

		disposable = new Starfish();
		STARFISH_HEIGHT = disposable.height;

		disposable = new Seal();
		SEAL_HEIGHT = disposable.height;
		disposable.destroy();

		var bgRgb = Config.get("stages")[0].background;
		this.bgColor = flixel.util.FlxColor.fromRGB(bgRgb[0], bgRgb[1], bgRgb[2]);

		this.ground1 = new HelixSprite("assets/images/ground.png").collisionImmovable();
		this.ground2 = new HelixSprite("assets/images/ground.png").collisionImmovable();
		this.ceiling = new HelixSprite("assets/images/ceiling.png").collisionImmovable();

		this.nextTargetArrow = new HelixSprite("assets/images/ui/smell-neutral.png");
		this.nextTargetArrow.alpha = 0;

		this.healthText = new HelixText(0, UI_PADDING, "", UI_FONT_SIZE);
		this.distanceText = new HelixText(0, 0, "", UI_FONT_SIZE);
		this.foodPointsText = new HelixText(0, 2 * UI_PADDING, "", UI_FONT_SIZE);

		this.restart(); // common setup to start/restart

		// Restrict camera so that player can tell they're at the ceiling
		this.camera.minScrollY = this.ceiling.y;

		var random = Main.seededRandom;

		// Must be set the first time 
		this.nextEntityY = random.float(0, ground1.y);
		this.nextEntityType = Jellyfish;
		trace("J: " + this.nextEntityType);

		this.entitySpawner = new IntervalRandomTimer(this.minIntervalSeconds, this.maxIntervalSeconds, function()
		{
			if (!this.player.dead)
			{
				this.showNextTarget = false;

				var currentLevel:Int = this.getCurrentLevel();
				currentLevel = Std.int(Math.min(currentLevel, Config.getInt("maxLevel") - 1));
				var stage = Config.get("stages")[currentLevel];				

				// spawn creature
				// // If null, recycle failed in some horrible way ...
				var entity:HelixSprite;
				if (nextEntityType == Jellyfish || nextEntityType == Starfish || nextEntityType == Squid)
				{
					entity = this.preyGroup.recycle(nextEntityType);
					trace("PREY recycle: " + entity);
				}
				else
				{
					entity = this.predatorGroup.recycle(nextEntityType);
					trace("PREDATOR recycle: " + entity);
				}
				var x = this.nextEntityX == 1 ? this.camera.scroll.x + this.width : this.camera.scroll.x - entity.width;
				var y = this.nextEntityY;
				entity.reset(x, y);
				trace('Spawned ${Type.getClassName(nextEntityType)} : ${entity}');

				// Figure out the next thing that'll appear
				var weightArray:Array<Float> = [
					stage.jellyfishWeight,
					stage.swimmingCrabWeight,
					stage.morayEelWeight,
					stage.starfishWeight,
					stage.sealWeight,
					stage.sharkWeight,
					stage.squidWeight
				];

				var nextEntityPick = random.weightedPick(weightArray);

				// nextEntityX is +1 (RHS of screen) or -1 (LHS of screen)
				this.nextEntityX = 1;
				this.nextEntityY = random.float(0, ground1.y);

				if (nextEntityPick == 0) // Jellyfish
				{
					nextEntityType = Jellyfish;
				}
				else if (nextEntityPick == 1) // Swimming crab
				{
					nextEntityType = SwimmingCrab;
				}
				else if (nextEntityPick == 2) // Moral eel
				{
					nextEntityType = MorayEel;
					nextEntityY = ground1.y - (MORAY_EEL_HEIGHT / 2); // ground it
				}
				else if (nextEntityPick == 3) // Starfish
				{
					nextEntityType = Starfish;
					nextEntityY = ground1.y - STARFISH_HEIGHT; // ground it
				}
				else if (nextEntityPick == 4) // Seal
				{
					this.nextEntityY = -this.camera.scroll.y - SEAL_HEIGHT;
					nextEntityType = Seal;
				}
				else if (nextEntityPick == 5) // Shark
				{
					this.nextEntityX = -1;
					nextEntityType = Shark;
				}
				else if (nextEntityPick == 6) // Squid
				{
					nextEntityType = Squid;
				}
				else
				{
					throw 'Weighted entity array returned ${nextEntityType} but there is no implementation for that yet.';
				}

				trace('Next ${nextEntityPick} is a ${Type.getClassName(nextEntityType)}');

				// If the sense of smell upgrade picks it up, show it
				if (random.int(1, 100) <= player.smellProbability)
				{
					this.showNextTarget = true;
				}
				else
				{
					this.showNextTarget = false;
					this.nextTargetArrow.alpha = 0;
				}
			}
		});

		if (Config.getBool("debugMode") == true)
		{
			watermark = new HelixSprite("assets/images/watermark.png");
			watermark.alpha = 0.5;
		}
	}

	override public function update(elapsedSeconds:Float):Void
	{
		if (Config.getBool("debugMode") == true && this.wasJustPressed(FlxKey.P))
		{
			this.isSilentPaused = !this.isSilentPaused;
		}
		
		if (Config.getBool("debugMode") == true && this.isSilentPaused)
		{
			return;
		}

		super.update(elapsedSeconds);
		entitySpawner.update(elapsedSeconds);

		// Difficulty scales by increasing speed in Player.update
		// We also shrink the interval ever so slightly; in 30s, it reduces by ~0.1
		var intervalDiff:Float = elapsedSeconds * Config.getFloat("shrinkIntervalPerSecondBy");
		this.minIntervalSeconds -= intervalDiff;
		this.maxIntervalSeconds -= intervalDiff;

		this.nextEntityX = this.camera.scroll.x + (this.width * 1.5);

		this.ceiling.move(camera.scroll.x, Config.getInt("ceilingY"));
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
		this.distanceText.text = Translater.get("DISTANCE_UI", [Std.int(this.camera.scroll.x / Std.int(Config.getInt("pixelsPerMeter")))]);

		this.foodPointsText.x = this.distanceText.x;
		this.foodPointsText.y = this.distanceText.y + this.distanceText.height;

		if (this.showNextTarget == true)
		{
			// Oscillate from 0.5 to 1.0 in a sine wave.
			// http://www.wolframalpha.com/input/?i=y+%3D+0.75+%2B+sin(x)+%2F+4
			this.nextTargetArrow.alpha = 0.75 + Math.sin(4 * GameTime.totalGameTimeSeconds) / 4;
			this.nextTargetArrow.x = this.camera.scroll.x + this.width - this.nextTargetArrow.width;
			this.nextTargetArrow.y = this.nextEntityY;
		}

		watermark.move(this.camera.scroll.x + this.width - watermark.width - UI_PADDING, this.camera.scroll.y + this.height - watermark.height - UI_PADDING);
	}

	/**
	 *  Updates the display. Returns new food level (if levelled up); else, zero.
	 */
	private function updateFoodPointsDisplay(pointsGained:Int):Void
	{
		var pointsPerLevel:Int = Config.getInt("foodPointsRequiredPerLevel");
		player.foodPoints += pointsGained;		
		var currentFoodLevel:Int = Math.floor(player.foodPoints / pointsPerLevel);
		this.foodPointsText.text = Translater.get("FOOD_POINTS_UI", [player.foodPoints, (currentFoodLevel + 1) * pointsPerLevel]);
	}

	private function getCurrentLevel():Int
	{
		var pointsPerLevel:Int = Config.getInt("foodPointsRequiredPerLevel");
		var currentFoodLevel:Int = Math.floor(player.foodPoints / pointsPerLevel);
		return currentFoodLevel;
	}

	private function restart(?gameOverText:FlxText, ?restartButton:HelixSprite, ?shopButton:HelixSprite):Void
	{
		this.sessionStartTime = GameTime.totalGameTimeSeconds;
		this.minIntervalSeconds = Config.getFloat("minIntervalSeconds");
		this.maxIntervalSeconds = Config.getFloat("maxIntervalSeconds");

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

		if (shopButton != null)
		{
			shopButton.destroy();
			remove(shopButton);
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
		
		var playerData = new PlayerData();
		
		this.player = new Player(playerData);
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
				foodPoints = Config.getInt("foodPointsJellyfish");
			}
			else if (Std.is(prey, Starfish))
			{
				foodPoints = Config.getInt("foodPointsStarfish");
			}
			else if (Std.is(prey, Squid))
			{
				foodPoints = Config.getInt("foodPointsSquid");
			}
			else
			{
				throw 'Did not implement food points cost yet for ${Type.getClassName(Type.getClass(prey))}';
			}

			var previousLevel = this.getCurrentLevel();
			this.updateFoodPointsDisplay(foodPoints);
			var currentLevel = this.getCurrentLevel();			
			if (currentLevel > previousLevel && currentLevel < Config.getInt("maxLevel"))
			{
				var bgRgb = Config.get("stages")[currentLevel].background;
				this.bgColor = flixel.util.FlxColor.fromRGB(bgRgb[0], bgRgb[1], bgRgb[2]);
				player.transform(currentLevel);
			}
		});

		this.player.collide(this.predatorGroup, function(player:Player, predator:HelixSprite)
		{
			player.getHurt();
			this.updateHealthText();

			if (player.dead)
			{
				playerData.addFoodCurrency(player.foodPoints);

				this.remove(player);
				player.destroy();

				var restartButton = new HelixSprite("assets/images/ui/restart.png");				
				restartButton.y = this.camera.scroll.y + (this.height - restartButton.height) / 2;

				var gameOverText = new HelixText(0, 0, Translater.get("GAME_OVER"), 48);
				gameOverText.x = this.camera.scroll.x + (this.width - gameOverText.width) / 2;
				gameOverText.y = restartButton.y + restartButton.height + UI_PADDING;

				var shopButton = new HelixSprite("assets/images/shop.png");
				shopButton.y = restartButton.y;
				shopButton.onClick(function() {
					FlxG.switchState(new UpgradesShopState(playerData));
				});

				restartButton.x = this.camera.scroll.x + (this.width - restartButton.width - UI_PADDING - shopButton.width) / 2;
				shopButton.x = restartButton.x + restartButton.width + UI_PADDING;

				restartButton.onClick(function() { 
					this.restart(gameOverText, restartButton, shopButton);
				});

				var elapsed = GameTime.totalGameTimeSeconds - this.sessionStartTime;
			}
		});

		// set initial text
		this.updateFoodPointsDisplay(0);
		this.updateHealthText();
	}

	private function updateHealthText():Void
	{
		this.healthText.text = Translater.get("HEALTH_UI", [this.player.currentHealth, this.player.totalHealth]);
	}
}
