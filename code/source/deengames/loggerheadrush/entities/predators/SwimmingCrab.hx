package deengames.loggerheadrush.entities.predators;

import helix.core.HelixSprite;
import helix.data.Config;

// https://en.wikipedia.org/wiki/Portunidae
class SwimmingCrab extends HelixSprite
{
    public function new()
    {
        super("assets/images/entities/swimmingCrab.png");
        this.revive();
    }

    override public function revive():Void
    {
        super.revive();
        
        var random = Main.seededRandom;
        var minVx:Int = Config.getInt("swimmingCrabVxMin");
        var maxVx:Int = Config.getInt("swimmingCrabVxMax");
        var minVy:Int = Config.getInt("swimmingCrabVyMin");
        var maxVy:Int = Config.getInt("swimmingCrabVyMax");

        var vx = random.int(minVx, maxVx);
        var vy = random.int(minVy, maxVy);

        this.setComponentVelocity("AutoMove", vx, vy);
    }
}