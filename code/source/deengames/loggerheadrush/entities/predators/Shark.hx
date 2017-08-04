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

    override public function reset(x:Float, y:Float):Void
    {
        var x:Float = FlxG.camera.scroll.x - this.width; // Off the LHS of the screen
        var minY:Int = Std.int(FlxG.camera.scroll.y);
        var y:Float = Main.seededRandom.int(minY, minY + FlxG.camera.height - Std.int(this.height));
        super.reset(x, y);
    }
}