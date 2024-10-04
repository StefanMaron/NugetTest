page 50101 NugetAppList
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = NugetApp;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Search)
            {
                field(SearchValue; SearchValue)
                {
                    trigger OnValidate()
                    var
                        NugetHelper: Codeunit NugetHelper;
                        Uri: Codeunit Uri;
                    begin
                        Load(NugetHelper.GetAppArray(SearchQueryServiceUrl + '?q=' + Uri.EscapeDataString(SearchValue)), SearchQueryServiceUrl, FeedUrl);
                    end;
                }

            }
            repeater(Main)
            {
                field(Id; Rec.Id)
                {
                }
                field(AppName; Rec.AppName)
                {
                }
                field(AppDescription; Rec.AppDescription)
                {
                }
                field(AppVersion; Rec.AppVersion)
                {
                }
                field(Publisher; Rec.Publisher)
                {
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ShowDetails)
            {
                trigger OnAction()
                var
                    NugetHelper: Codeunit NugetHelper;
                begin
                    NugetHelper.DownloadApp(FeedUrl, Rec);
                end;
            }
        }
    }

    var
        FeedUrl: Text;
        SearchQueryServiceUrl: Text;
        SearchValue: Text;

    internal procedure Load(Apps: JsonArray; SearchQueryServiceUrlIn: Text; FeedUrlIn: Text)
    var
        App: JsonToken;
        TempToken: JsonToken;
    begin
        Rec.DeleteAll();
        SearchQueryServiceUrl := SearchQueryServiceUrlIn;
        FeedUrl := FeedUrlIn;

        foreach App in Apps do begin
            Rec.Init();

            App.AsObject().Get('id', TempToken);
            Rec.Id := TempToken.AsValue().AsText();

            App.AsObject().Get('title', TempToken);
            Rec.AppName := TempToken.AsValue().AsText();

            App.AsObject().Get('description', TempToken);
            Rec.AppDescription := CopyStr(TempToken.AsValue().AsText(), 1, MaxStrLen(Rec.AppDescription));

            App.AsObject().Get('version', TempToken);
            Rec.AppVersion := TempToken.AsValue().AsText();

            App.AsObject().Get('authors', TempToken);
            Rec.Publisher := Format(TempToken.AsArray());

            Rec.Insert();
        end;

    end;
}