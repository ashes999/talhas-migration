package deengames.talhasmigration.entities;

import flixel.math.FlxRandom;

import helix.GameTime;
import helix.core.HelixState;
import helix.core.HelixSprite;

// Spawns objects on a random interval, uniformly, between min and max time.
class IntervalSpawner
{
    private var minIntervalSeconds:Float = 0;
    private var maxIntervalSeconds:Float = 0;
    private var random = new FlxRandom();
    private var entityClass:Class<HelixSprite>;

    private var createdOn:Float; // GameTime
    private var nextSpawnOn:Float; // GameTime

    public function new(entityClass:Class<HelixSprite>, minIntervalSeconds:Float, maxIntervalSeconds:Float)
    {
        this.minIntervalSeconds = minIntervalSeconds;
        this.maxIntervalSeconds = maxIntervalSeconds;
        this.entityClass = entityClass;
        this.createdOn = GameTime.totalGameTimeSeconds;
        this.nextSpawnOn = this.createdOn; // Don't spawn immediately
        this.pickNextInterval();
    }

    public function update(elapsedSeconds:Float):Void
    {
        if (GameTime.totalGameTimeSeconds >= this.nextSpawnOn)
        {
            // SPAWN MORE OVERLORDS!            
            var entity = Type.createInstance(this.entityClass, []);
            HelixState.current.add(entity);
            this.pickNextInterval();
        }
    }

    private function pickNextInterval():Void
    {
        // Convert from seconds to milliseconds
        this.nextSpawnOn += random.float(minIntervalSeconds, maxIntervalSeconds);
    }
}