package deengames.talhasmigration.entities;

import flixel.math.FlxRandom;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.data.Config;
 
class Jellyfish extends HelixSprite
{
    public function new(playerVx:Float)
    {
        super("assets/images/jellyfish.png");
        var velocityPercent:Float = Std.int(Config.get("jellyfishVelocityPercent")) / 100.0;
        var vx:Int = Math.round(playerVx * velocityPercent);
        this.setComponentVelocity("Escape", vx, 0);
    }
}