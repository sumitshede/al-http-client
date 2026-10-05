codeunit 50102 "Exchange Rate Service"
{
    procedure GetLatestRates(BaseCurrency: Code[10]; var RateDate: Date; var Rates: JsonObject)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseJson: JsonObject;
        DateToken: JsonToken;
        RatesToken: JsonToken;
        ResponseText: Text;
    begin
        Client.Timeout(TimeoutMs());

        if not Client.Get(StrSubstNo(LatestUrlTxt, BaseCurrency), Response) then
            Error(RequestNotSentErr);

        if not Response.IsSuccessStatusCode() then
            Error(UnexpectedStatusErr, Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content.ReadAs(ResponseText);
        if not ResponseJson.ReadFrom(ResponseText) then
            Error(InvalidResponseErr);

        if not ResponseJson.Get('date', DateToken) then
            Error(InvalidResponseErr);
        if not ResponseJson.Get('rates', RatesToken) then
            Error(InvalidResponseErr);
        if not RatesToken.IsObject() then
            Error(InvalidResponseErr);

        Evaluate(RateDate, DateToken.AsValue().AsText(), 9);
        Rates := RatesToken.AsObject();
    end;

    local procedure TimeoutMs(): Integer
    begin
        exit(10000);
    end;

    var
        LatestUrlTxt: Label 'https://api.frankfurter.dev/v1/latest?base=%1', Locked = true;
        RequestNotSentErr: Label 'The request could not be sent. Check the network connection and that "Allow HttpClient Requests" is enabled for this app.';
        UnexpectedStatusErr: Label 'The rates service returned an error: %1 %2.', Comment = '%1 = HTTP status code, %2 = reason phrase';
        InvalidResponseErr: Label 'The rates service returned a response that could not be read.';
}
