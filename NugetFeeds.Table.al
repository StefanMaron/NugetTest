table 50100 NugetFeed
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; EntryNo; Integer)
        {
            AutoIncrement = true;
        }
        field(2; FeedUrl; Text[250])
        {
        }
        field(3; Description; Text[250])
        {
        }
        field(4; Token; Text[100])
        {
            // ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
    }
}