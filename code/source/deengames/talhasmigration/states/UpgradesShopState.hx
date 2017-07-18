package deengames.talhasmigration.states;

import deengames.talhasmigration.data.PlayerData;
import flixel.FlxG;
import helix.core.HelixSprite;
import helix.core.HelixState;

class UpgradesShopState extends HelixState
{
    private static inline var UI_PADDING:Int = 16;
    private static inline var UI_FONT_SIZE:Int = 32;
    private var playerData:PlayerData;

    public function new(playerData:PlayerData)
    {
        super();
        this.playerData = playerData;
    }

    override public function create()
    {
        super.create();

        this.addText(UI_PADDING, UI_PADDING, 'Total Food: ${playerData.foodCurrency}', UI_FONT_SIZE);

        var goButton = new HelixSprite("assets/images/ui/play.png").onClick(function()
        {
            FlxG.switchState(new CoreGameState());
        });

        goButton.x = (this.width - goButton.width) / 2;
        goButton.y = this.height - goButton.height - UI_PADDING;
    }
}