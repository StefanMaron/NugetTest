table 50101 NugetApp
{
    TableType = Temporary;

    fields
    {
        field(1; Id; Text[250])
        {
        }
        field(2; AppName; Text[250])
        {
        }
        field(3; AppVersion; Text[250])
        {
        }
        field(4; AppDescription; Text[2048])
        {
        }
        field(5; Publisher; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}