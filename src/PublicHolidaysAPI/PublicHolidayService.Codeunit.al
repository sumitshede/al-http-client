codeunit 50106 "Public Holiday Service"
{
    procedure GetHolidays(CountryCode: Code[10]; Year: Integer; var Holidays: JsonArray)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ResponseText: Text;
    begin
        if not Client.Get(StrSubstNo(HolidaysUrlTxt, Format(Year, 0, 9), CountryCode), Response) then
            Error(RequestNotSentErr);

        if not Response.IsSuccessStatusCode() then
            Error(UnexpectedStatusErr, Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content.ReadAs(ResponseText);
        Holidays.ReadFrom(ResponseText);
    end;

    var
        HolidaysUrlTxt: Label 'https://date.nager.at/api/v3/PublicHolidays/%1/%2', Locked = true;
        RequestNotSentErr: Label 'The request could not be sent. Check the network connection and that "Allow HttpClient Requests" is enabled for this app.';
        UnexpectedStatusErr: Label 'The holidays service returned an error: %1 %2.', Comment = '%1 = HTTP status code, %2 = reason phrase';
}
