page 50100 NugetFeedsList
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = NugetFeed;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field(FeedUrl; Rec.FeedUrl)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Token; Rec.Token)
                {
                }
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
                var
                    NugetHelper: Codeunit NugetHelper;
                begin
                    NugetHelper.BrowseApps(Rec.FeedUrl);
                end;
            }
        }
    }

}