permissionset 50100 GeneratedPermission
{
    Assignable = false;
    Permissions = table AppDetail = X,
        tabledata AppDetail = RIMD,
table NugetApp = X,
        tabledata NugetApp = RIMD,
        table NugetFeed = X,
        tabledata NugetFeed = RIMD,
        codeunit NugetHelper = X,
        page NugetAppList = X,
        page NugetFeedsList = X;
}