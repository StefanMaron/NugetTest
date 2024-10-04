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
            repeater(Main)
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
    }

    actions
    {
        area(Processing)
        {
            action(Install)
            {

                trigger OnAction()
                var
                    NugetHelper: Codeunit NugetHelper;
                begin
                    NugetHelper.InstallApps(Rec.DownloadUrl);
                end;
            }
            action(ShowDetails)
            {
                trigger OnAction()
                var
                    NugetHelper: Codeunit NugetHelper;
                    TempBlob: Codeunit "Temp Blob";
                    ListOfApps: List of [Codeunit "Temp Blob"];
                begin
                    NugetHelper.DownloadApp(Rec.DownloadUrl, ListOfApps);
                    foreach TempBlob in ListOfApps do
                        NugetHelper.GetPackageDetail(TempBlob);
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