package deengames.talhasmigration.entities;

import flixel.math.FlxRandom;

import helix.GameTime;

// Spawns objects on a random interval, uniformly, between min and max time.
class IntervalSpawner
{
    private var minIntervalSeconds:Float = 0;
    private var maxIntervalSeconds:Float = 0;
    private var random = new FlxRandom();
    private var onSpawn:Void->Void;

    private var createdOn:Float; // GameTime
    private var nextSpawnOn:Float; // GameTime

    public function new(minIntervalSeconds:Float, maxIntervalSeconds:Float, onSpawn:Void->Void)
    {
        this.minIntervalSeconds = minIntervalSeconds;
        this.maxIntervalSeconds = maxIntervalSeconds;
        this.onSpawn = onSpawn;
        this.createdOn = GameTime.totalGameTimeSeconds;
        this.nextSpawnOn = this.createdOn; // Don't spawn immediately
        this.pickNextInterval();
    }

    public function update(elapsedSeconds:Float):Void
    {
        if (GameTime.totalGameTimeSeconds >= this.nextSpawnOn)
        {
            // SPAWN MORE OVERLORDS!            
            this.onSpawn();
            this.pickNextInterval();
        }
    }

    private function pickNextInterval():Void
    {
        // Convert from seconds to milliseconds
        this.nextSpawnOn += random.float(minIntervalSeconds, maxIntervalSeconds);
    }
}