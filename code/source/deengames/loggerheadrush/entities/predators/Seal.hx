package deengames.loggerheadrush.entities.predators;

import helix.core.HelixSprite;
import helix.data.Config;

import deengames.loggerheadrush.entities.Player;

class Seal extends HelixSprite
{
    private var hasLaunched:Bool;

    private var targetDistanceSquared:Float;

    public function new()
    {
        super("assets/images/entities/seal.png");
        this.revive();
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var player = Player.instance;

        if (this.hasLaunched == false && this.velocity.y == 0)
        {
            var dSquared = Math.pow(this.x - player.x, 2) + Math.pow(this.y - player.y, 2);
            if (dSquared <= targetDistanceSquared)
            {
                // Using a fixed velocity V becomes the hypotenuse of the triangle formed
                // by using the vector of the player and seal. Calculate the x and y
                // components of that using sine law.
                var velocity = Config.get("seal").attackVelocity;
                var dx = player.x - this.x;
                var dy = player.y - this.y;
                var theta = Math.atan2(dy, dx);
                // 180 - 90 - theta => pi/2 - pi/4 - theta => pi/4 - theta
                var vx = velocity * Math.sin(Math.PI / 4 - theta);
                var vy = velocity * Math.sin(theta);
                this.setComponentVelocity("Launch", vx, vy);
            }
        }
    }

    override public function revive():Void
    {
        super.revive();
        this.hasLaunched = false;
        this.targetDistanceSquared = Math.pow(Config.get("seal").detectionRange, 2);
    }
}