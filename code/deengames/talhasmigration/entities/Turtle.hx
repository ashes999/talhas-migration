package deengames.talhasmigration.entities;

import turbo.ecs.Entity;
using turbo.ecs.EntityFluentApi;
 
// The player
class Turtle extends Entity
{
    public function new()
    {
        super("player"); // tags are needed for collision
        this.size(32, 32).colour(255, 0, 0).moveWithKeyboard(100).velocity(250, 0).trackWithCamera();
    }
}