package deengames.talhasmigration.entities;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;
 
// The player
class Player extends HelixSprite
{
    public var currentHealth(default, null):Int = Config.get("startingHealth");
    public var totalHealth(default, null):Int = Config.get("startingHealth");
    public var dead(get, null):Bool;
    public var foodPoints(default, null):Int = 0;
    private var lastHurtTime:TotalGameTime = 0;
    
    public function new()
    {
        super("assets/images/entities/turtle.png");
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

    public function eat(foodPointsGained:Int):Void
    {
        this.foodPoints += foodPointsGained;
        var velocityIncreasePerFoodPoint:Float = Config.get("autoMoveVelocityIncreasePerFoodPoint");
        this.setComponentVelocity("AutoMove for Food", this.foodPoints * velocityIncreasePerFoodPoint, 0);
    }
}