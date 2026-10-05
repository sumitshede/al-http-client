page 50101 "HttpBin Demo"
{
    Caption = 'HttpBin Demo';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(Request)
            {
                Caption = 'Request';

                field(MethodField; Method)
                {
                    Caption = 'Method';
                    ToolTip = 'Specifies the HTTP method of the request.';
                }
                field(UrlField; Url)
                {
                    Caption = 'URL';
                    ToolTip = 'Specifies the URL the request is sent to.';
                }
                field(RequestHeadersField; RequestHeaders)
                {
                    Caption = 'Headers';
                    ToolTip = 'Specifies the request headers, one Name: Value per line.';
                    MultiLine = true;
                }
                field(RequestBodyField; RequestBody)
                {
                    Caption = 'Body';
                    ToolTip = 'Specifies the request body.';
                    MultiLine = true;
                }
            }
            group(Response)
            {
                Caption = 'Response';
                Visible = HasResponse;

                field(StatusField; StatusSummary)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the HTTP status returned by the server.';
                    Editable = false;
                    StyleExpr = StatusStyle;
                }
                field(DurationField; ResponseDuration)
                {
                    Caption = 'Duration';
                    ToolTip = 'Specifies how long the request took.';
                    Editable = false;
                }
                field(ResponseHeadersField; ResponseHeaders)
                {
                    Caption = 'Headers';
                    ToolTip = 'Specifies the response headers.';
                    Editable = false;
                    MultiLine = true;
                }
                field(ResponseBodyField; ResponseBody)
                {
                    Caption = 'Body';
                    ToolTip = 'Specifies the response body.';
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadTestData)
            {
                Caption = 'Load test data';
                ToolTip = 'Loads a sample request.';
                Image = Import;

                trigger OnAction()
                begin
                    LoadSelectedSample();
                end;
            }
            action(Send)
            {
                Caption = 'Send request';
                ToolTip = 'Sends the request.';
                Image = Web;

                trigger OnAction()
                begin
                    HttpBinClient.Send(Method, Url, RequestBody, RequestHeaders);
                    ShowResponse();
                end;
            }
            action(ClearResponse)
            {
                Caption = 'Clear response';
                ToolTip = 'Hides the response.';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    HasResponse := false;
                end;
            }
        }
        area(Promoted)
        {
            actionref(LoadTestData_Promoted; LoadTestData)
            {
            }
            actionref(Send_Promoted; Send)
            {
            }
            actionref(ClearResponse_Promoted; ClearResponse)
            {
            }
        }
    }

    var
        HttpBinClient: Codeunit "HttpBin Client";
        HttpBinSamples: Codeunit "HttpBin Samples";
        Method: Enum "HttpBin Method";
        Url: Text;
        RequestHeaders: Text;
        RequestBody: Text;
        StatusSummary: Text;
        StatusStyle: Text;
        ResponseHeaders: Text;
        ResponseBody: Text;
        ResponseDuration: Duration;
        HasResponse: Boolean;
        StatusSummaryTxt: Label '%1 %2', Locked = true;
        ChooseSampleTxt: Label 'Load test data';

    trigger OnOpenPage()
    begin
        HttpBinSamples.Load(Enum::"HttpBin Sample"::GetQuery, Method, Url, RequestBody, RequestHeaders);
    end;

    local procedure LoadSelectedSample()
    var
        Ordinals: List of [Integer];
        Ordinal: Integer;
        Selection: Integer;
    begin
        Ordinals := Enum::"HttpBin Sample".Ordinals();
        Selection := StrMenu(GetSampleOptions(Ordinals), 1, ChooseSampleTxt);
        if Selection = 0 then
            exit;

        Ordinals.Get(Selection, Ordinal);
        HttpBinSamples.Load(Enum::"HttpBin Sample".FromInteger(Ordinal), Method, Url, RequestBody, RequestHeaders);
        HasResponse := false;
    end;

    local procedure GetSampleOptions(Ordinals: List of [Integer]): Text
    var
        Sample: Enum "HttpBin Sample";
        Ordinal: Integer;
        Options: Text;
    begin
        foreach Ordinal in Ordinals do begin
            Sample := Enum::"HttpBin Sample".FromInteger(Ordinal);
            if Options <> '' then
                Options += ',';
            Options += Format(Sample);
        end;
        exit(Options);
    end;

    local procedure ShowResponse()
    begin
        StatusSummary := StrSubstNo(StatusSummaryTxt, HttpBinClient.StatusCode(), HttpBinClient.ReasonPhrase());
        StatusStyle := GetStatusStyle(HttpBinClient.StatusCode());
        ResponseDuration := HttpBinClient.Duration();
        ResponseHeaders := HttpBinClient.ResponseHeaders();
        ResponseBody := HttpBinClient.ResponseBody();
        HasResponse := true;
    end;

    local procedure GetStatusStyle(StatusCode: Integer): Text
    begin
        case true of
            StatusCode in [200 .. 299]:
                exit('Favorable');
            StatusCode in [300 .. 399]:
                exit('Ambiguous');
            else
                exit('Unfavorable');
        end;
    end;
}
