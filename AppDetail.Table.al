table 50102 AppDetail
{

    TableType = Temporary;

    fields
    {
        field(1; Version; Text[20])
        {
        }
        field(2; CommitId; Text[100])
        {
        }
        field(3; Dependencies; Text[2048])
        { }
    }

    keys
    {
        key(Key1; Version)
        {
            Clustered = true;
        }
    }
}