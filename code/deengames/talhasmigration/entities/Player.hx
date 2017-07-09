package deengames.talhasmigration.entities;

import helix.core.HelixSprite;
import helix.data.Config;
 
// The player
class Player extends HelixSprite
{
    public var currentHealth(default, null):Int = Config.get("startingHealth");
    public var totalHealth(default, null):Int = Config.get("startingHealth");
    public var dead(get, null):Bool;
    public var foodPoints(default, null):Int = 0;
    
    public function new()
    {
        super("assets/images/turtle.png");
        this
            .moveWithKeyboard(Config.get("playerKeyboardMoveVelocity"))
            .setComponentVelocity("AutoMove", Config.get("playerAutoMoveVelocity"), 0)
            .trackWithCamera();
    }

    public function getHurt():Void
    {
        this.currentHealth -= 1;
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