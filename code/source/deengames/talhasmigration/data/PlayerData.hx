package deengames.talhasmigration.data;

import flixel.util.FlxSave;

/**
 *  The actual player persistent data, like food eaten across games.
 *  This auto loads from persistent data, so you just instantiate it as needed
 *  or pass it around from state to state.
 */
class PlayerData
{
    public var foodCurrency(get, null):Int;
    private var save = new FlxSave();
    
    public function new()
    {
        save.bind("PlayerData");

        if (save.data.foodCurrency == null)
        {
            save.data.foodCurrency = 0;
            save.flush();
        }
    }

    // We could use fancy reflection, but game-domain methods are easy enough.
    public function addFoodCurrency(foodCurrency:Int):Void
    {
        if (foodCurrency > 0)
        {
            save.data.foodCurrency += foodCurrency;
            save.flush();
        }
    }

    public function get_foodCurrency():Int
    {
        return save.data.foodCurrency;
    }

    // buyUpgrade(upgradeName):Void
    // Decrements currency, notes permanent upgrade.
}