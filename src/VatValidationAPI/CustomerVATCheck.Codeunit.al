codeunit 50105 "Customer VAT Check"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'VAT Registration No.', false, false)]
    local procedure CheckVatRegistrationNo(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        VIESService: Codeunit "VIES Service";
        CountryCode: Code[10];
        RegisteredName: Text;
    begin
        if CurrFieldNo <> Rec.FieldNo("VAT Registration No.") then
            exit;
        if Rec."VAT Registration No." = '' then
            exit;

        CountryCode := GetCountryCode(Rec."Country/Region Code");
        case VIESService.Check(CountryCode, GetVatNumber(Rec."VAT Registration No.", CountryCode), RegisteredName) of
            Enum::"VIES Result"::Valid:
                Message(ValidMsg, RegisteredName);
            Enum::"VIES Result"::Invalid:
                Message(InvalidMsg);
            Enum::"VIES Result"::Unavailable:
                Message(UnavailableMsg);
        end;
    end;

    local procedure GetCountryCode(CustomerCountryCode: Code[10]): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        CountryCode: Code[10];
    begin
        CountryCode := CustomerCountryCode;
        if CountryCode = '' then begin
            CompanyInformation.Get();
            CountryCode := CompanyInformation."Country/Region Code";
        end;

        if CountryRegion.Get(CountryCode) then
            if CountryRegion."EU Country/Region Code" <> '' then
                exit(CountryRegion."EU Country/Region Code");

        exit(CountryCode);
    end;

    local procedure GetVatNumber(VatRegistrationNo: Text; CountryCode: Code[10]): Text
    var
        VatNumber: Text;
    begin
        VatNumber := DelChr(VatRegistrationNo, '=', ' ');
        if UpperCase(VatNumber).StartsWith(CountryCode) then
            exit(CopyStr(VatNumber, StrLen(CountryCode) + 1));
        exit(VatNumber);
    end;

    var
        ValidMsg: Label 'The VAT number is valid. Registered name: %1', Comment = '%1 = registered name';
        InvalidMsg: Label 'The VAT number is not valid.';
        UnavailableMsg: Label 'The VAT number could not be checked because VIES is not available.';
}
