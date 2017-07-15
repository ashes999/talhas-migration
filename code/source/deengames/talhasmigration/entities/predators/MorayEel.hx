package deengames.talhasmigration.entities.predators;

import flixel.math.FlxRandom;

import helix.core.HelixSprite;
import helix.data.Config;

import deengames.talhasmigration.entities.Player;

class MorayEel extends HelixSprite
{
    private var hasLaunched:Bool = false;
    private var baseY:Float = -1;
    private var player:Player;

    private var targetDistanceSquared:Float = Math.pow(Config.get("morayEelDetectionRange"), 2);
    private var travelHeight:Int = Config.get("morayEelTravelHeight");

    public function new(player:Player)
    {
        super("assets/images/entities/eel.png");
        this.player = player;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        if (this.baseY == -1)
        {
            // this isn't moved to its position in the constructor            
            this.baseY = this.y;
        }

        super.update(elapsedSeconds);
        if (this.hasLaunched == false && this.velocity.y == 0)
        {
            var dSquared = Math.pow(this.x - player.x, 2) + Math.pow(this.y - player.y, 2);
            if (dSquared <= targetDistanceSquared)
            {
                this.setComponentVelocity("Launch", 0, Config.get("morayEelAttackVelocity"));
            }
        } 
        else if (this.hasLaunched == false && this.velocity.y != 0)
        {
            // Reached peak of travel height
            if (this.baseY - this.y >= travelHeight)
            {
                // Reverse back down
                this.velocity.y *= -1;
            }
            else if (this.y >= this.baseY)
            {
                // Reached resting place
                this.velocity.y = 0;
                this.hasLaunched = true;                
            }
        }
    }
}