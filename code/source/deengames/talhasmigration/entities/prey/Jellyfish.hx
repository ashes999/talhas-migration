package deengames.talhasmigration.entities.prey;

import flixel.math.FlxRandom;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;

import deengames.talhasmigration.entities.Player;
 
 // Eaten only during migration, according to Wikipedia
class Jellyfish extends HelixSprite
{
    private var waveAmplitude:Float;
    private var frequencyMultiplier:Float;
    private var baseY:Float = -1;
    private var sineWaveOffset:Float; // Jellyfish shouldn't sine-wave in synch ...

    public function new()
    {
        super("assets/images/entities/jellyfish.png");
        this.reset(0, 0); // construct
    }

    override public function update(elapsedSeconds:Float):Void
    {
        // Not settable during constructor because it hasn't moved yet
        if (baseY == -1)
        {
            baseY = this.y;
        }

        super.update(elapsedSeconds);
        this.y = this.baseY + (this.waveAmplitude * 
            Math.sin(sineWaveOffset +
                (frequencyMultiplier * GameTime.totalGameTimeSeconds)));
    }

    // Common code shared between constructor and recycle
    override function reset(x:Float, y:Float):Void
    {
        super.reset(x, y);
        this.waveAmplitude = Config.get("jellyfishWaveAmplitude");
        this.frequencyMultiplier = Config.get("jellyfishWaveFrequencyMultiplier");
        this.baseY = -1;

        var velocityPercent:Float = Std.int(Config.get("jellyfishVelocityPercent")) / 100.0;
        var vx:Int = Math.round(Player.instance.velocity.x * velocityPercent);
        this.setComponentVelocity("Escape", vx, 0);
        
        this.sineWaveOffset = new FlxRandom().int(0, 1000);
    }
}