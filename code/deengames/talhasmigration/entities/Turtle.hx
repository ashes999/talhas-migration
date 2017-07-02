package deengames.talhasmigration.entities;

import turbo.ecs.Entity;
using turbo.ecs.EntityFluentApi;
 
// The player
class Turtle extends Entity
{
    public function new()
    {
        super();
        this.size(32, 32).colour(255, 0, 0).moveWithKeyboard(100);
    }
}