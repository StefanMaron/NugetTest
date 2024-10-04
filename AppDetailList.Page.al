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
}