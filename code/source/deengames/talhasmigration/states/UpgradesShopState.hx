package deengames.talhasmigration.states;

import deengames.talhasmigration.data.PlayerData;
import flixel.FlxG;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.core.HelixText;

class UpgradesShopState extends HelixState
{
    private static inline var UI_PADDING:Int = 16;
    private static inline var UI_FONT_SIZE:Int = 32;

    private var playerData:PlayerData;

    private var totalFoodLabel:HelixText;
    private var healthIndicator:HelixText;
    private var buyHealthButton:HelixText;

    public function new(playerData:PlayerData)
    {
        super();
        this.playerData = playerData;
    }

    override public function create()
    {
        super.create();

        this.totalFoodLabel = this.addText(UI_PADDING, UI_PADDING, 'Total Food: ${playerData.foodCurrency}', UI_FONT_SIZE);
        this.healthIndicator = this.addText(UI_PADDING, 3 * UI_PADDING, 'Starting Health: ${playerData.startingHealth}', UI_FONT_SIZE);
        this.buyHealthButton = this.addText(Std.int(healthIndicator.x  + healthIndicator.width + UI_PADDING), Std.int(healthIndicator.y), "", UI_FONT_SIZE);
        var cost = playerData.getNextHealthUpgradeCost();
        this.buyHealthButton.onClick(function()
        {
            if (cost > 0 && playerData.foodCurrency >= cost)
            {
                playerData.buyHealthUpgrade();
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
        this.totalFoodLabel.text = 'Total Food: ${playerData.foodCurrency}';
        this.healthIndicator.text = 'Starting Health: ${playerData.startingHealth}';

        var cost = playerData.getNextHealthUpgradeCost();        
        if (cost > 0) // not maxed out
        {
            this.buyHealthButton.text = '(+1 costs ${cost})';
        }
        else
        {
            this.buyHealthButton.text = "(MAX)";
        }
    }
}