page 50102 AppDetailList
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = AppDetail;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field("Version"; Rec."Version")
            {
            }
            field(CommitId; Rec.CommitId)
            {
            }
            field(Dependencies; Rec.Dependencies)
            {
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }


    internal procedure Load(FeedUrl: Text; NugetApp: Record "NugetApp"): JsonToken
    var
        NugetHelper: Codeunit NugetHelper;
        AppDetails: JsonArray;
        App: JsonToken;
        TempToken: JsonToken;
    begin
        Rec.DeleteAll();

        AppDetails := NugetHelper.GetDetails(FeedUrl, NugetApp);

        foreach App in AppDetails do begin
            Rec.Init();

            App.AsObject().SelectToken('$.catalogEntry.version', TempToken);
            Rec.Version := TempToken.AsValue().AsText();

            App.AsObject().Get('commitId', TempToken);
            Rec.CommitId := TempToken.AsValue().AsText();

            App.AsObject().Get('packageContent', TempToken);
            Rec.DownloadUrl := TempToken.AsValue().AsText();

            App.AsObject().SelectToken('$.catalogEntry.dependencyGroups[0].dependencies', TempToken);
            TempToken.WriteTo(Rec.Dependencies);

            Rec.Insert();
        end;
    end;
}