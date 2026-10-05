pageextension 50100 "Currency Exchange Rates Ext" extends "Currency Exchange Rates"
{
    actions
    {
        addlast(Processing)
        {
            action(UpdateFromFrankfurter)
            {
                ApplicationArea = All;
                Caption = 'Update from Frankfurter';
                ToolTip = 'Downloads the latest exchange rates for the currencies set up in Business Central.';
                Image = Refresh;

                trigger OnAction()
                var
                    ExchangeRateUpdater: Codeunit "Exchange Rate Updater";
                begin
                    Message(UpdatedMsg, ExchangeRateUpdater.Update());
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        UpdatedMsg: Label '%1 exchange rates updated.', Comment = '%1 = number of exchange rates updated';
}
