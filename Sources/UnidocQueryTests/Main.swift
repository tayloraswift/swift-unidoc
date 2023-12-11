import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        PackageQueries.self,
        VolumeQueries.self,
        SymbolQueries.self,
    ]
}
