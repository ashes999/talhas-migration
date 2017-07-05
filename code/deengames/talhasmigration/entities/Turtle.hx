package deengames.talhasmigration.entities;

import turbo.ecs.Entity;
using turbo.ecs.EntityFluentApi;
 
// The player
class Turtle extends Entity
{
    public function new()
    {
        super("player"); // tags are needed for collision
        this
            //.size(32, 32).colour(255, 0, 0)
            .image("assets/images/turtle.png")
            .moveWithKeyboard(300)
            .velocity(0, 0).trackWithCamera().collideWith("ground");
    }
}