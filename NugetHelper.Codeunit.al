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
}