package deengames.talhasmigration.entities;

import helix.core.HelixSprite;
import helix.data.Config;
 
// The player
class Player extends HelixSprite
{
    public function new()
    {
        super("assets/images/turtle.png");
        this
            .moveWithKeyboard(Config.get("playerKeyboardMoveVelocity"))
            .setComponentVelocity("AutoMove", Config.get("playerAutoMoveVelocity"), 0)
            .trackWithCamera();
    }
}