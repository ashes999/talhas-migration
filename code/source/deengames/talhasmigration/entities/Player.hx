package deengames.talhasmigration.entities;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;
 
// The player
class Player extends HelixSprite
{
    // Required because prey/predators require this as a constructor parameter,
    // except that we use FlxGroup.recycle, which demands parameterless constructors.
    public static var instance(default, null):Player;

    public var currentHealth(default, null):Int = Config.get("startingHealth");
    public var totalHealth(default, null):Int = Config.get("startingHealth");
    public var dead(get, null):Bool;
    public var foodPoints(default, default):Int = 0;
    private var lastHurtTime:TotalGameTime = 0;
    
    public function new()
    {
        super("assets/images/entities/turtle.png");
        Player.instance = this;
        this
            .moveWithKeyboard(Config.get("playerKeyboardMoveVelocity"))
            .setComponentVelocity("AutoMove", Config.get("playerAutoMoveVelocity"), 0)
            .trackWithCamera();
    }

    public function getHurt():Void
    {
        var invincibleDuration:Int = Config.get("gotHurtInvincibleSeconds");
        if (GameTime.totalGameTimeSeconds - lastHurtTime >= invincibleDuration)
        {
            lastHurtTime = GameTime.totalGameTimeSeconds;
            this.currentHealth -= 1;
            this.flicker(invincibleDuration);
        }
    }

    public function get_dead():Bool
    {
        return this.currentHealth <= 0;
    }
}