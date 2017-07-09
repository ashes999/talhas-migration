package deengames.talhasmigration.entities;

import flixel.math.FlxRandom;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.data.Config;
 
class Jellyfish extends HelixSprite
{
    private var waveAmplitude:Float = Config.get("jellyfishWaveAmplitude");
    private var frequencyMultiplier:Float = Config.get("jellyfishWaveFrequencyMultiplier");
    private var baseY:Float = -1;
    private var sineWaveOffset:Float = 0; // Jellyfish shouldn't sine-wave in synch ...

    public function new(playerVx:Float)
    {
        super("assets/images/jellyfish.png");
        var velocityPercent:Float = Std.int(Config.get("jellyfishVelocityPercent")) / 100.0;
        var vx:Int = Math.round(playerVx * velocityPercent);
        this.setComponentVelocity("Escape", vx, 0);
        this.sineWaveOffset = new FlxRandom().int(0, 1000);
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
}