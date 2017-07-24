package deengames.talhasmigration.data;

import flixel.util.FlxSave;
import helix.data.Config;

/**
 *  The actual player persistent data, like food eaten, across games.
 *  This auto loads from persistent data, so you just instantiate it as needed
 *  or pass it around from state to state.
 */
class PlayerData
{
    public var foodCurrency(get, null):Int;
    public var startingHealth(get, null):Int = 0;

    private var save = new FlxSave();
    
    public function new()
    {
        save.bind("PlayerData");

        if (Config.getBool("deletePersistentData") == true)
        {
            save.erase();
            save.bind("PlayerData");
        }

        // New set of data
        if (save.data.foodCurrency == null)
        {
            save.data.foodCurrency = 0;
            save.data.startingHealth = Config.getInt("startingHealth");
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

    public function get_startingHealth():Int
    {
        return save.data.startingHealth;
    }

    public function getNextHealthUpgradeCost():Int
    {
        if (this.startingHealth < Config.getInt("maxHealth"))
        {
            var baseCost = Config.getInt("healthUpgradeBaseCost");
            var costExponent = Config.getFloat("healthUpgradeCostExponent");
            var numPurchased = this.startingHealth - Config.getInt("startingHealth");
            // +1 because O^n = 0
            return Std.int(Math.floor(baseCost * Math.pow(numPurchased + 1, costExponent)));
        }
        else
        {
            return 0;
        }
    }
    
    public function buyHealthUpgrade():Void
    {
        if (this.startingHealth < Config.getInt("maxHealth") && this.foodCurrency >= this.getNextHealthUpgradeCost())
        {
            save.data.foodCurrency -= this.getNextHealthUpgradeCost();
            save.data.startingHealth += 1;
            save.flush();
        }
    }
}