package deengames.talhasmigration.entities;

import flixel.math.FlxRandom;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.data.Config;
 
class Jellyfish extends HelixSprite
{
    public function new()
    {
        super("assets/images/jellyfish.png");

        var currentState:HelixState = HelixState.current;
        var random = new FlxRandom();
        // position randomly off-screen (RHS).
        var targetX = currentState.camera.scroll.x + (currentState.width * 1.5); // 1.5x => spawn slightly off-screen
        var maxY:Int = Std.int(currentState.height / 2); //padding to spawn above ground
        this.move(targetX, random.int(0, maxY));
    }
}