package deengames.loggerheadrush.entities.prey;

import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;

import deengames.loggerheadrush.entities.Player;
 
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
        this.revive(); // construct
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
                (frequencyMultiplier * GameTime.totalElapsedSeconds)));
    }

    // Common code shared between constructor and recycle
    override function revive():Void
    {
        super.revive();
        
        this.waveAmplitude = Config.getInt("jellyfishWaveAmplitude");
        this.frequencyMultiplier = Config.getInt("jellyfishWaveFrequencyMultiplier");
        this.baseY = -1;

        var velocityPercent:Float = Std.int(Config.getInt("jellyfishVelocityPercent")) / 100.0;
        var vx:Int = Math.round(Player.instance.velocity.x * velocityPercent);
        this.setComponentVelocity("Escape", vx, 0);
        
        this.sineWaveOffset = Main.seededRandom.int(0, 1000);
    }
}