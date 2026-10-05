codeunit 50100 "HttpBin Client"
{
    procedure Send(Method: Enum "HttpBin Method"; Url: Text; Body: Text; RequestHeaders: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseContentHeaders: HttpHeaders;
        CollectedHeaders: TextBuilder;
        StartTime: DateTime;
    begin
        if Url = '' then
            Error(UrlRequiredErr);

        ClearResult();
        BuildRequest(Request, Method, Url, Body, RequestHeaders);
        Client.Timeout(TimeoutMs());

        StartTime := CurrentDateTime();
        if not Client.Send(Request, Response) then begin
            LastReasonPhrase := RequestNotSentErr;
            exit;
        end;
        LastDuration := CurrentDateTime() - StartTime;

        LastStatusCode := Response.HttpStatusCode();
        LastReasonPhrase := Response.ReasonPhrase();
        Response.Content.ReadAs(LastBody);
        CollectHeaders(Response.Headers, CollectedHeaders);
        Response.Content.GetHeaders(ResponseContentHeaders);
        CollectHeaders(ResponseContentHeaders, CollectedHeaders);
        LastHeaders := CollectedHeaders.ToText().TrimEnd();
    end;

    procedure StatusCode(): Integer
    begin
        exit(LastStatusCode);
    end;

    procedure ReasonPhrase(): Text
    begin
        exit(LastReasonPhrase);
    end;

    procedure Duration(): Duration
    begin
        exit(LastDuration);
    end;

    procedure ResponseBody(): Text
    begin
        exit(LastBody);
    end;

    procedure ResponseHeaders(): Text
    begin
        exit(LastHeaders);
    end;

    local procedure BuildRequest(var Request: HttpRequestMessage; Method: Enum "HttpBin Method"; Url: Text; Body: Text; RequestHeaders: Text)
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        MessageHeaders: HttpHeaders;
        RawLine: Text;
        Line: Text;
        HeaderName: Text;
        HeaderValue: Text;
        LineFeed: Text[1];
        Colon: Integer;
    begin
        Request.Method(Format(Method));
        Request.SetRequestUri(Url);
        Request.GetHeaders(MessageHeaders);

        if Body <> '' then
            Content.WriteFrom(Body);
        Content.GetHeaders(ContentHeaders);

        LineFeed[1] := 10;
        foreach RawLine in RequestHeaders.Split(LineFeed) do begin
            Line := RawLine.Trim();
            if Line <> '' then begin
                Colon := StrPos(Line, ':');
                if Colon < 2 then
                    Error(InvalidHeadersErr);
                HeaderName := CopyStr(Line, 1, Colon - 1).Trim();
                HeaderValue := CopyStr(Line, Colon + 1).Trim();

                if IsContentHeader(HeaderName) then begin
                    if Body <> '' then begin
                        ContentHeaders.Remove(HeaderName);
                        ContentHeaders.TryAddWithoutValidation(HeaderName, HeaderValue);
                    end;
                end else
                    MessageHeaders.TryAddWithoutValidation(HeaderName, HeaderValue);
            end;
        end;

        if Body <> '' then
            Request.Content := Content;
    end;

    local procedure IsContentHeader(HeaderName: Text): Boolean
    begin
        exit(LowerCase(HeaderName).StartsWith('content-'));
    end;

    local procedure CollectHeaders(Headers: HttpHeaders; var Result: TextBuilder)
    var
        HeaderName: Text;
        HeaderValues: array[10] of Text;
        HeaderValue: Text;
        Index: Integer;
    begin
        foreach HeaderName in Headers.Keys() do begin
            Clear(HeaderValues);
            Headers.GetValues(HeaderName, HeaderValues);

            HeaderValue := '';
            for Index := 1 to ArrayLen(HeaderValues) do
                if HeaderValues[Index] <> '' then begin
                    if HeaderValue <> '' then
                        HeaderValue += ', ';
                    HeaderValue += HeaderValues[Index];
                end;

            Result.AppendLine(StrSubstNo(HeaderLineTxt, HeaderName, HeaderValue));
        end;
    end;

    local procedure ClearResult()
    begin
        LastStatusCode := 0;
        LastReasonPhrase := '';
        LastBody := '';
        LastHeaders := '';
        LastDuration := 0;
    end;

    local procedure TimeoutMs(): Integer
    begin
        exit(10000);
    end;

    var
        LastStatusCode: Integer;
        LastReasonPhrase: Text;
        LastBody: Text;
        LastHeaders: Text;
        LastDuration: Duration;
        HeaderLineTxt: Label '%1: %2', Locked = true;
        UrlRequiredErr: Label 'Enter a URL.';
        InvalidHeadersErr: Label 'Enter each header on its own line as Name: Value.';
        RequestNotSentErr: Label 'The request could not be sent. Check the URL and that "Allow HttpClient Requests" is enabled for this app.';
}
