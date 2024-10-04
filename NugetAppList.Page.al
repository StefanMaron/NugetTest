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
                    begin
                        Load(NugetHelper.GetAppArray(SearchQueryServiceUrl + '?q=' + SearchValue), SearchQueryServiceUrl, FeedUrl);

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
                    DataCompression: Codeunit "Data Compression";
                    ExtensionManagement: Codeunit "Extension Management";
                    HttpResponseMessage: Codeunit "Http Response Message";
                    NugetHelper: Codeunit NugetHelper;
                    RestClient: Codeunit "Rest Client";
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    TempToken: JsonToken;
                    EntryList: List of [Text];
                    OutStr: OutStream;
                    DownloadUrl: Text;
                begin
                    HttpResponseMessage := RestClient.Get(NugetHelper.GetRegistrationsBaseUrl(FeedUrl) + Rec.Id.ToLower() + '/index.json');
                    HttpResponseMessage.GetContent().AsJson().SelectToken('$.items[0].items[0].packageContent', TempToken);
                    DownloadUrl := TempToken.AsValue().AsText();

                    HttpResponseMessage := RestClient.Get(DownloadUrl);
                    InStr := HttpResponseMessage.GetContent().AsInStream();

                    DataCompression.OpenZipArchive(InStr, false);
                    DataCompression.GetEntryList(EntryList);

                    TempBlob.CreateOutStream(OutStr);
                    DataCompression.ExtractEntry(EntryList.Get(2), OutStr);
                    Clear(InStr);
                    TempBlob.CreateInStream(InStr);

                    ExtensionManagement.UploadExtension(InStr, 1033);
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
            Rec.AppDescription := TempToken.AsValue().AsText();

            App.AsObject().Get('version', TempToken);
            Rec.AppVersion := TempToken.AsValue().AsText();

            App.AsObject().Get('authors', TempToken);
            Rec.Publisher := Format(TempToken.AsArray());

            Rec.Insert();
        end;

    end;
}