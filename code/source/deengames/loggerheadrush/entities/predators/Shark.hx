package deengames.loggerheadrush.entities.predators;

import flixel.FlxG;
import helix.core.HelixSprite;
import helix.data.Config;

class Shark extends HelixSprite
{
    public function new()
    {
        super("assets/images/entities/shark.png");
        this.revive();
    }

    override public function revive():Void
    {
        super.revive();        
        var velocity = Config.get("shark").velocity;
        var vx:Int = velocity.x;
        var vy:Int = Main.seededRandom.int(-velocity.y, velocity.y);
        this.setComponentVelocity("AutoMove", vx, vy);
    }
}