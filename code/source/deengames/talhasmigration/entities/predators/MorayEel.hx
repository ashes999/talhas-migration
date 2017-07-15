package deengames.talhasmigration.entities.predators;

import helix.core.HelixSprite;
import helix.data.Config;

import deengames.talhasmigration.entities.Player;

class MorayEel extends HelixSprite
{
    private var hasLaunched:Bool;
    private var baseY:Float;

    private var targetDistanceSquared:Float;
    private var travelHeight:Int;

    public function new()
    {
        super("assets/images/entities/eel.png");
        this.reset(0, 0);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var player = Player.instance;

        if (this.baseY == -1)
        {
            // this isn't moved to its position in the constructor            
            this.baseY = this.y;
        }

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

    override public function reset(x:Float, y:Float):Void
    {
        super.reset(x, y);
        this.hasLaunched = false;
        this.baseY = -1;
        this.targetDistanceSquared = Math.pow(Config.get("morayEelDetectionRange"), 2);
        this.travelHeight = Config.get("morayEelTravelHeight");
    }
}