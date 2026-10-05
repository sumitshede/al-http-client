codeunit 50104 "VIES Service"
{
    procedure Check(CountryCode: Code[10]; VatNumber: Text; var RegisteredName: Text): Enum "VIES Result"
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseJson: JsonObject;
        Token: JsonToken;
        ResponseText: Text;
    begin
        if not Client.Get(StrSubstNo(CheckUrlTxt, CountryCode, VatNumber), Response) then
            exit(Enum::"VIES Result"::Unavailable);

        if not Response.IsSuccessStatusCode() then
            exit(Enum::"VIES Result"::Unavailable);

        Response.Content.ReadAs(ResponseText);
        if not ResponseJson.ReadFrom(ResponseText) then
            exit(Enum::"VIES Result"::Unavailable);

        if not ResponseJson.Get('isValid', Token) then
            exit(Enum::"VIES Result"::Unavailable);

        if Token.AsValue().AsBoolean() then begin
            if ResponseJson.Get('name', Token) then
                RegisteredName := Token.AsValue().AsText();
            exit(Enum::"VIES Result"::Valid);
        end;

        if ResponseJson.Get('userError', Token) then
            if Token.AsValue().AsText() = InvalidErrorTxt then
                exit(Enum::"VIES Result"::Invalid);

        exit(Enum::"VIES Result"::Unavailable);
    end;

    var
        CheckUrlTxt: Label 'https://ec.europa.eu/taxation_customs/vies/rest-api/ms/%1/vat/%2', Locked = true;
        InvalidErrorTxt: Label 'INVALID', Locked = true;
}
