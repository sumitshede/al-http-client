codeunit 50107 "Public Holiday Importer"
{
    procedure Import(BaseCalendar: Record "Base Calendar"; Year: Integer): Integer
    var
        CountryRegion: Record "Country/Region";
        PublicHolidayService: Codeunit "Public Holiday Service";
        Holidays: JsonArray;
        HolidayToken: JsonToken;
        ImportedCount: Integer;
    begin
        BaseCalendar.TestField("Country/Region Code");
        CountryRegion.Get(BaseCalendar."Country/Region Code");
        CountryRegion.TestField("ISO Code");
        PublicHolidayService.GetHolidays(CountryRegion."ISO Code", Year, Holidays);

        foreach HolidayToken in Holidays do
            if SaveHoliday(BaseCalendar.Code, HolidayToken.AsObject()) then
                ImportedCount += 1;

        exit(ImportedCount);
    end;

    local procedure SaveHoliday(BaseCalendarCode: Code[10]; Holiday: JsonObject): Boolean
    var
        BaseCalendarChange: Record "Base Calendar Change";
        Token: JsonToken;
        HolidayDate: Date;
        WeekdayNo: Integer;
    begin
        Holiday.Get('global', Token);
        if not Token.AsValue().AsBoolean() then
            exit(false);

        Holiday.Get('date', Token);
        Evaluate(HolidayDate, Token.AsValue().AsText(), 9);

        WeekdayNo := Date2DWY(HolidayDate, 1);
        if BaseCalendarChange.Get(BaseCalendarCode, BaseCalendarChange."Recurring System"::" ", HolidayDate, WeekdayNo) then
            exit(false);

        Holiday.Get('name', Token);
        BaseCalendarChange.Init();
        BaseCalendarChange."Base Calendar Code" := BaseCalendarCode;
        BaseCalendarChange."Recurring System" := BaseCalendarChange."Recurring System"::" ";
        BaseCalendarChange.Date := HolidayDate;
        BaseCalendarChange.Day := WeekdayNo;
        BaseCalendarChange.Description := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(BaseCalendarChange.Description));
        BaseCalendarChange.Nonworking := true;
        BaseCalendarChange.Insert(true);
        exit(true);
    end;
}
