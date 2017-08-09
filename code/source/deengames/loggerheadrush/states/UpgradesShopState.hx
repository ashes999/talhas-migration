package deengames.loggerheadrush.states;

import deengames.loggerheadrush.data.PlayerData;
import flixel.FlxG;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.core.HelixText;
import polyglot.Translater;

class UpgradesShopState extends HelixState
{
    private static inline var UI_PADDING:Int = 16;
    private static inline var UI_FONT_SIZE:Int = 32;

    private var playerData:PlayerData;

    private var totalFoodLabel:HelixText;
    private var healthIndicator:HelixText;
    private var buyHealthButton:HelixText;
    private var smellIndicator:HelixText;    
    private var buySmellButton:HelixText;

    public function new(playerData:PlayerData)
    {
        super();
        this.playerData = playerData;
    }

    override public function create()
    {
        super.create();

        this.totalFoodLabel = new HelixText(UI_PADDING, UI_PADDING, "", UI_FONT_SIZE);

        this.healthIndicator = new HelixText(UI_PADDING, 3 * UI_PADDING, "", UI_FONT_SIZE);
        this.buyHealthButton = new HelixText(0, Std.int(healthIndicator.y), "", UI_FONT_SIZE);
        var cost = playerData.getNextHealthUpgradeCost();
        this.buyHealthButton.onClick(function()
        {
            if (cost > 0 && playerData.foodCurrency >= cost)
            {
                playerData.buyHealthUpgrade();
                this.updateUi();
            }
        });

        this.smellIndicator = new HelixText(UI_PADDING, 5 * UI_PADDING, "", UI_FONT_SIZE);
        this.buySmellButton = new HelixText(0, Std.int(smellIndicator.y), "", UI_FONT_SIZE);
        var cost = playerData.getNextSmellUpgradeCost();
        this.buySmellButton.onClick(function()
        {
            if (cost > 0 && playerData.foodCurrency >= cost)
            {
                playerData.buySmellUpgrade();
                this.updateUi();
            }
        }); 

        var goButton = new HelixSprite("assets/images/ui/play.png").onClick(function()
        {
            FlxG.switchState(new CoreGameState());
        });

        goButton.x = (this.width - goButton.width) / 2;
        goButton.y = this.height - goButton.height - UI_PADDING;

        this.updateUi();
    }

    private function updateUi():Void
    {
        this.totalFoodLabel.text = Translater.get("UPGRADES_TOTAL_FOOD", [playerData.foodCurrency]);

        this.healthIndicator.text = Translater.get("UPGRADES_STARTING_HEALTH", [playerData.startingHealth]);
        this.buyHealthButton.x = healthIndicator.x  + healthIndicator.width + UI_PADDING;
        var cost = playerData.getNextHealthUpgradeCost();        
        if (cost > 0) // not maxed out
        {
            this.buyHealthButton.text = Translater.get("UPGRADES_BUY_NEXT", [cost]);
        }
        else
        {
            this.buyHealthButton.text = Translater.get("UPGRADES_MAXED_OUT");
        }
        
        this.smellIndicator.text = Translater.get("UPGRADES_SMELL_LEVEL", [playerData.smellUpgrades]);
        this.buySmellButton.x = smellIndicator.x  + smellIndicator.width + UI_PADDING;
        var cost = playerData.getNextSmellUpgradeCost();        
        if (cost > 0) // not maxed out
        {
            this.buySmellButton.text = Translater.get("UPGRADES_BUY_NEXT", [cost]);
        }
        else
        {
            this.buySmellButton.text = Translater.get("UPGRADES_MAXED_OUT");
        }
    }
}