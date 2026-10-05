enum 50101 "HttpBin Sample"
{
    Caption = 'HttpBin Sample';

    value(0; GetQuery)
    {
        Caption = 'GET with query string';
    }
    value(1; PostJson)
    {
        Caption = 'POST JSON body';
    }
    value(2; PutJson)
    {
        Caption = 'PUT JSON body';
    }
    value(3; DeleteRequest)
    {
        Caption = 'DELETE request';
    }
    value(4; NotFound)
    {
        Caption = '404 not found';
    }
    value(5; DelayedResponse)
    {
        Caption = 'Delayed response (2 seconds)';
    }
    value(6; EchoHeader)
    {
        Caption = 'Echo a custom header';
    }
}
