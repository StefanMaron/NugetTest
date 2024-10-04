codeunit 50100 NugetHelper
{

    procedure BrowseApps(FeedUrl: Text)
    var
        NugetAppList: Page NugetAppList;
        Apps: JsonArray;
        SearchQueryServiceUrl: Text;
    begin
        SearchQueryServiceUrl := GetSearchQueryServiceUrl(FeedUrl);
        Apps := GetAppArray(SearchQueryServiceUrl);

        NugetAppList.Load(Apps, SearchQueryServiceUrl, FeedUrl);
        NugetAppList.Run();
    end;

    procedure GetSearchQueryServiceUrl(FeedUrl: Text): Text
    begin
        exit(GetTypeUrl(FeedUrl, 'SearchQueryService'));
    end;

    procedure GetRegistrationsBaseUrl(FeedUrl: Text): Text
    begin
        exit(GetTypeUrl(FeedUrl, 'RegistrationsBaseUrl'));
    end;

    procedure GetTypeUrl(FeedUrl: Text; Type: Text): Text
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        RestClient: Codeunit "Rest Client";
        Resources: JsonArray;
        TempToken: JsonToken;
        TempToken2: JsonToken;
    begin
        HttpResponseMessage := RestClient.Get(FeedUrl);
        HttpResponseMessage.GetContent().AsJson().AsObject().Get('resources', TempToken);
        Resources := TempToken.AsArray();

        foreach TempToken in Resources do begin
            TempToken.AsObject().Get('@type', TempToken2);
            if TempToken2.AsValue().AsText().StartsWith(Type) then begin
                TempToken.AsObject().Get('@id', TempToken2);
                exit(TempToken2.AsValue().AsText());
            end;
        end;
    end;

    procedure GetAppArray(SearchQueryServiceUrl: Text) Apps: JsonArray;
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        RestClient: Codeunit "Rest Client";
        TempToken: JsonToken;
    begin
        HttpResponseMessage := RestClient.Get(SearchQueryServiceUrl);

        HttpResponseMessage.GetContent().AsJson().AsObject().Get('data', TempToken);
        Apps := TempToken.AsArray();
    end;

    procedure GetDetails(FeedUrl: Text; Rec: Record "NugetApp"): JsonArray
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        NugetHelper: Codeunit NugetHelper;
        RestClient: Codeunit "Rest Client";
        TempToken: JsonToken;
    begin
        HttpResponseMessage := RestClient.Get(NugetHelper.GetRegistrationsBaseUrl(FeedUrl) + Rec.Id.ToLower() + '/index.json');
        HttpResponseMessage.GetContent().AsJson().SelectToken('$.items[0].items', TempToken);
        exit(TempToken.AsArray());
    end;

    procedure InstallApps(DownloadUrl: Text)
    var
        ExtensionManagement: Codeunit "Extension Management";
        TempBlob: Codeunit "Temp Blob";
        ListOfApps: List of [Codeunit "Temp Blob"];
    begin
        DownloadApp(DownloadUrl, ListOfApps);
        foreach TempBlob in ListOfApps do
            ExtensionManagement.UploadExtension(TempBlob.CreateInStream(), 1033);
    end;

    procedure DownloadApp(DownloadUrl: Text; var ListOfApps: List of [Codeunit "Temp Blob"])
    var
        DataCompression: Codeunit "Data Compression";
        HttpResponseMessage: Codeunit "Http Response Message";
        RestClient: Codeunit "Rest Client";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        EntryList: List of [Text];
        Entry: Text;
    begin
        HttpResponseMessage := RestClient.Get(DownloadUrl);
        InStr := HttpResponseMessage.GetContent().AsInStream();

        DataCompression.OpenZipArchive(InStr, false);
        DataCompression.GetEntryList(EntryList);

        foreach Entry in EntryList do
            if Entry.EndsWith('.app') then begin
                Clear(TempBlob);
                DataCompression.ExtractEntry(Entry, TempBlob.CreateOutStream());
                ListOfApps.Add(TempBlob);
            end;
    end;


    //TODO: Testcode
    procedure GetPackageDetail(var TempBlob: Codeunit "Temp Blob")
    var
        AppAttributesXmlBuffer, IdRangeXmlBuffer, XmlBuffer : Record "XML Buffer" temporary;
        DataCompression: Codeunit "Data Compression";
        EntryList: List of [Text];
        InStr: InStream;
    begin
        InStr := TempBlob.CreateInStream(TextEncoding::UTF8);

        InStr.Position(41);

        DataCompression.OpenZipArchive(InStr, false);

        DataCompression.GetEntryList(EntryList);
        DataCompression.ExtractEntry('NavxManifest.xml', TempBlob.CreateOutStream(TextEncoding::UTF8));

        XmlBuffer.LoadFromStream(TempBlob.CreateInStream(TextEncoding::UTF8));
        XmlBuffer.FindNodesByXPath(AppAttributesXmlBuffer, '/Package/App/@*');
        // XmlBuffer.FindNodesByXPath(IdRangeXmlBuffer, '/Package/App/@*')

        Message(AppAttributesXmlBuffer.GetAttributeValue('Id'));
    end;
}