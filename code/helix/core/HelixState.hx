package helix.core;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

import helix.core.HelixSprite;

class HelixState extends FlxState
{
    public static var current(default, null):HelixState;

    public var width(get, null):Int;
    public var height(get, null):Int;
    public var movesToKeyboard:HelixSprite;

    public function new()
    {
        super();
        HelixState.current = this;
    }

    public function get_width():Int
    {
        return FlxG.stage.stageWidth;
    }

    public function get_height():Int
    {
        return FlxG.stage.stageHeight;
    }
}