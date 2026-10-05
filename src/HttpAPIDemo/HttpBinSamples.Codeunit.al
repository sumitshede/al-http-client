codeunit 50101 "HttpBin Samples"
{
    procedure Load(Sample: Enum "HttpBin Sample"; var Method: Enum "HttpBin Method"; var Url: Text; var Body: Text; var RequestHeaders: Text)
    var
        Uri: Codeunit Uri;
        Headers: TextBuilder;
    begin
        Body := '';
        Headers.AppendLine(AcceptHeaderTxt);

        case Sample of
            Sample::GetQuery:
                begin
                    Method := Method::GET;
                    Url := StrSubstNo(GetUrlTxt, Uri.EscapeDataString(GreetingTxt));
                end;
            Sample::PostJson:
                begin
                    Method := Method::POST;
                    Url := PostUrlTxt;
                    Body := JsonBodyTxt;
                    Headers.AppendLine(ContentTypeHeaderTxt);
                end;
            Sample::PutJson:
                begin
                    Method := Method::PUT;
                    Url := PutUrlTxt;
                    Body := JsonBodyTxt;
                    Headers.AppendLine(ContentTypeHeaderTxt);
                end;
            Sample::DeleteRequest:
                begin
                    Method := Method::DELETE;
                    Url := DeleteUrlTxt;
                end;
            Sample::NotFound:
                begin
                    Method := Method::GET;
                    Url := NotFoundUrlTxt;
                end;
            Sample::DelayedResponse:
                begin
                    Method := Method::GET;
                    Url := DelayUrlTxt;
                end;
            Sample::EchoHeader:
                begin
                    Method := Method::GET;
                    Url := HeadersUrlTxt;
                    Headers.AppendLine(DemoHeaderTxt);
                end;
        end;

        RequestHeaders := Headers.ToText().TrimEnd();
    end;

    var
        GetUrlTxt: Label 'https://httpbin.org/get?greeting=%1', Locked = true;
        PostUrlTxt: Label 'https://httpbin.org/post', Locked = true;
        PutUrlTxt: Label 'https://httpbin.org/put', Locked = true;
        DeleteUrlTxt: Label 'https://httpbin.org/delete', Locked = true;
        NotFoundUrlTxt: Label 'https://httpbin.org/status/404', Locked = true;
        DelayUrlTxt: Label 'https://httpbin.org/delay/2', Locked = true;
        HeadersUrlTxt: Label 'https://httpbin.org/headers', Locked = true;
        GreetingTxt: Label 'Hello from Business Central', Locked = true;
        JsonBodyTxt: Label '{"greeting": "Hello from Business Central", "source": "Business Central"}', Locked = true;
        AcceptHeaderTxt: Label 'Accept: application/json', Locked = true;
        ContentTypeHeaderTxt: Label 'Content-Type: application/json', Locked = true;
        DemoHeaderTxt: Label 'X-Demo-Header: demo', Locked = true;
}
