tableextension 50100 "Base Calendar Ext" extends "Base Calendar"
{
    fields
    {
        field(50100; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
    }
}
