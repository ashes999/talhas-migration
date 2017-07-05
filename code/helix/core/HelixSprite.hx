package helix.core;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;

class HelixSprite extends FlxSprite
{
    public var keyboardMoveSpeed(default, null):Float = 0;
    private var componentVelocities = new Map<String, FlxPoint>();

    public function new(filename:String):Void
    {
        super();
        this.loadGraphic(filename);
        HelixState.current.add(this);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        if (keyboardMoveSpeed > 0)
        {
            var vx:Float = 0;
            var vy:Float = 0;
            var isMoving:Bool = false;

            if (isPressed(FlxKey.LEFT) || isPressed(FlxKey.A))
            {
                vx = -this.keyboardMoveSpeed;
                isMoving = true;
            }
            else if (isPressed(FlxKey.RIGHT) || isPressed(FlxKey.D))
            {
                vx = this.keyboardMoveSpeed;
                isMoving = true;
            }
                
            if (isPressed(FlxKey.UP) || isPressed(FlxKey.W))            
            {
                vy = -this.keyboardMoveSpeed;
                isMoving = true;
            }
            else if (isPressed(FlxKey.DOWN) || isPressed(FlxKey.S))
            {
                vy = this.keyboardMoveSpeed;
                isMoving = true;
            }

            if (isMoving)
            {
                this.setComponentVelocity("Movement", vx, vy);
            }
            else
            {
                this.setComponentVelocity("Movement", 0, 0);
            }
        }
    }

    /// Start: fluent API

    public function collisionImmovable():HelixSprite
    {
        this.immovable = true;
        return this;
    }

    public function move(x:Float, y:Float):HelixSprite
    {
        this.x = x;
        this.y = y;
        return this;
    }

    public function moveWithKeyboard(keyboardMoveSpeed:Float):HelixSprite
    {
        this.keyboardMoveSpeed = keyboardMoveSpeed;
        return this;
    }

    public function trackWithCamera():HelixSprite
    {
        FlxG.camera.follow(this);
        return this;
    }

    /// End: fluent API

    private function setComponentVelocity(name:String, vx:Float, vy:Float):Void
    {
        this.componentVelocities.set(name, new FlxPoint(vx, vy));

        // Cached so accessing velocity is blazing fast (120FPS? no problem!)
        var total = new FlxPoint();
        for (v in this.componentVelocities)
        {
            total.add(v.x, v.y);
        }
        this.velocity.copyFrom(total);
    }

    private function isPressed(keyCode:Int):Bool
    {
        return FlxG.keys.checkStatus(keyCode, FlxInputState.PRESSED);
    }
}