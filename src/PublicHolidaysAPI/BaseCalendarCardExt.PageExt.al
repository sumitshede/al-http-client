pageextension 50101 "Base Calendar Card Ext" extends "Base Calendar Card"
{
    layout
    {
        addlast(General)
        {
            field("Country/Region Code"; Rec."Country/Region Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the country or region whose public holidays are imported into this calendar.';
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(ImportPublicHolidays)
            {
                ApplicationArea = All;
                Caption = 'Import public holidays';
                ToolTip = 'Imports the public holidays of the calendar''s country or region for the current year.';
                Image = Import;

                trigger OnAction()
                var
                    PublicHolidayImporter: Codeunit "Public Holiday Importer";
                    Year: Integer;
                begin
                    Year := Date2DMY(WorkDate(), 3);
                    Message(ImportedMsg, PublicHolidayImporter.Import(Rec, Year), Year);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        ImportedMsg: Label '%1 public holidays imported for %2.', Comment = '%1 = number of holidays imported, %2 = year';
}
