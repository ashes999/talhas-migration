package deengames.loggerheadrush.entities.prey;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;

import deengames.loggerheadrush.entities.Player;
 
 // Eaten only during migration, according to Wikipedia
class Squid extends HelixSprite
{
    public static var MAX_Y(null, default):Int;
    
    private var targetY:Int = 0;    

    public function new()
    {
        super("assets/images/entities/squid.png");
        this.revive(); // construct
    }

    // Common code shared between constructor and recycle
    override function revive():Void
    {
        super.revive();
        this.targetY = Main.seededRandom.int(0, Squid.MAX_Y);
        var velocityDiff:Int = Config.get("squid").xVelocityDifference;
        var vx:Int = Config.get("playerAutoMoveVelocity") - velocityDiff;
        this.setComponentVelocity("Escape", vx, 0);

        var vy:Int = Config.get("squid").vy * (targetY < this.y ? -1 : 1);
        this.setComponentVelocity("Target", 0, vy);        
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        var vy = this.componentVelocities.get("Target").y;
        if ((this.y >= this.targetY && vy > 0) ||
            (this.y <= this.targetY && vy < 0))
        {
            this.targetY = Main.seededRandom.int(0, Squid.MAX_Y);
            var vy:Int = Config.get("squid").vy * (targetY < this.y ? -1 : 1);
            this.setComponentVelocity("Target", 0, vy);            
        }
    }
}