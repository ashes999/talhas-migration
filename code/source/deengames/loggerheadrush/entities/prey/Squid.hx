package deengames.loggerheadrush.entities.prey;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;

import deengames.loggerheadrush.entities.Player;
 
 // Eaten only during migration, according to Wikipedia
class Squid extends HelixSprite
{
    public function new()
    {
        super("assets/images/entities/squid.png");
        this.revive(); // construct
    }

    // Common code shared between constructor and recycle
    override function revive():Void
    {
        super.revive();
        
        var velocityDiff:Int = Config.get("squid").velocityDifference;
        var vx:Int = Config.get("playerAutoMoveVelocity") - velocityDiff;
        this.setComponentVelocity("Escape", vx, 0);        
    }
}