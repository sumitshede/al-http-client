codeunit 50103 "Exchange Rate Updater"
{
    trigger OnRun()
    begin
        Update();
    end;

    procedure Update(): Integer
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        ExchangeRateService: Codeunit "Exchange Rate Service";
        Rates: JsonObject;
        RateToken: JsonToken;
        RateDate: Date;
        UpdatedCount: Integer;
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("LCY Code");
        ExchangeRateService.GetLatestRates(GeneralLedgerSetup."LCY Code", RateDate, Rates);

        if Currency.FindSet() then
            repeat
                if Rates.Get(Currency.Code, RateToken) then begin
                    SaveRate(Currency.Code, RateDate, RateToken.AsValue().AsDecimal());
                    UpdatedCount += 1;
                end;
            until Currency.Next() = 0;

        exit(UpdatedCount);
    end;

    local procedure SaveRate(CurrencyCode: Code[10]; StartingDate: Date; Rate: Decimal)
    var
        ExchangeRate: Record "Currency Exchange Rate";
    begin
        if not ExchangeRate.Get(CurrencyCode, StartingDate) then begin
            ExchangeRate.Init();
            ExchangeRate."Currency Code" := CurrencyCode;
            ExchangeRate."Starting Date" := StartingDate;
            ExchangeRate.Insert(true);
        end;

        ExchangeRate.Validate("Exchange Rate Amount", Rate);
        ExchangeRate.Validate("Adjustment Exch. Rate Amount", Rate);
        ExchangeRate.Validate("Relational Exch. Rate Amount", 1);
        ExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 1);
        ExchangeRate.Modify(true);
    end;
}
