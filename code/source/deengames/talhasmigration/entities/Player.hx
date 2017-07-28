package deengames.loggerheadrush.entities;

import deengames.loggerheadrush.data.PlayerData;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;
 
// The player
class Player extends HelixSprite
{
    // Required because prey/predators require this as a constructor parameter,
    // except that we use FlxGroup.recycle, which demands parameterless constructors.
    public static var instance(default, null):Player;

    public var currentHealth(default, null):Int = 0;
    public var totalHealth(default, null):Int = 0;
    public var dead(get, null):Bool;
    public var foodPoints(default, default):Int = 0;
    private var lastHurtTime:TotalGameTime = 0;
    
    public function new(playerData:PlayerData)
    {
        super("assets/images/entities/turtle.png");

        Player.instance = this;

        this.currentHealth = this.totalHealth = playerData.startingHealth;

        this
            .moveWithKeyboard(Config.getInt("playerKeyboardMoveVelocity"))
            .setComponentVelocity("AutoMove", Config.getInt("playerAutoMoveVelocity"), 0)
            // Buoyancy is set in update
            .trackWithCamera();
    }

    public function getHurt():Void
    {
        var invincibleDuration:Int = Config.getInt("gotHurtInvincibleSeconds");
        if (GameTime.totalGameTimeSeconds - lastHurtTime >= invincibleDuration)
        {            
            lastHurtTime = GameTime.totalGameTimeSeconds;
            this.currentHealth -= 1;
            this.flicker(invincibleDuration);

            if (this.currentHealth <= 0)
            {
                this.setComponentVelocity("AutoMove", 0, 0);
            }
        }
    }

    public function get_dead():Bool
    {
        return this.currentHealth <= 0;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (this.currentHealth > 0)
        {
            var baseVelocity:Int = Config.getInt("playerAutoMoveVelocity");
            var elapsedTimeVelocity = GameTime.totalGameTimeSeconds * Config.getInt("autoMoveVelocityIncreasePerSecond");
            var totalVelocity = Math.min(baseVelocity + elapsedTimeVelocity, Config.getInt("maxVelocity"));
            
            totalVelocity = Std.int(Math.floor(totalVelocity));
            this.setComponentVelocity("AutoMove", totalVelocity, 0);

            if (this.hasComponentVelocity("Movement"))
            {
                this.setComponentVelocity("Buoyancy", 0, 0);
            }
            else
            {
                this.setComponentVelocity("Buoyancy", 0, Config.get("buoyancy").velocity);
            }
        }
    }
}