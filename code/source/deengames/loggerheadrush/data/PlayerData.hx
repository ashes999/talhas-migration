package deengames.loggerheadrush.data;

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
    public var smellUpgrades(get, null):Int = 0;

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
            save.data.smellUpgrades = 0;            
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
        if (this.startingHealth < Config.get("upgradeData").maxHealth)
        {
            var baseCost:Int = Config.get("upgradeData").healthUpgradeBaseCost;
            var costExponent:Float = Config.get("upgradeData").healthUpgradeCostExponent;
            var numPurchased = this.startingHealth - Config.getInt("startingHealth");
            // +1 because 0^n = 0, and n * 0 = 0
            return Std.int(Math.floor(baseCost * Math.pow(numPurchased + 1, costExponent)));
        }
        else
        {
            return 0;
        }
    }
    
    public function buyHealthUpgrade():Void
    {
        if (this.startingHealth < Config.get("upgradeData").maxHealth && this.foodCurrency >= this.getNextHealthUpgradeCost())
        {
            save.data.foodCurrency -= this.getNextHealthUpgradeCost();
            save.data.startingHealth += 1;
            save.flush();
        }
    }

    public function get_smellUpgrades():Int
    {
        return save.data.smellUpgrades;
    }

    public function getNextSmellUpgradeCost():Int
    {
        if (this.smellUpgrades < Config.get("upgradeData").maxSmellUpgrades)
        {
            var baseCost:Int = Config.get("upgradeData").smellUpgradeBaseCost;
            var costExponent:Float = Config.get("upgradeData").smellUpgradeCostExponent;
            // +1 because 0^n = 0, and n * 0 = 0
            return Std.int(Math.floor(baseCost * Math.pow(this.smellUpgrades + 1, costExponent)));
        }
        else
        {
            return 0;
        }
    }
    
    public function buySmellUpgrade():Void
    {
        if (this.smellUpgrades < Config.get("upgradeData").maxSmellUpgrades && this.foodCurrency >= this.getNextSmellUpgradeCost())
        {
            save.data.foodCurrency -= this.getNextSmellUpgradeCost();
            save.data.smellUpgrades += 1;
            save.flush();
        }
    }
}