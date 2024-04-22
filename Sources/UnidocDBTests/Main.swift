import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        DatabaseSetup.self,
        Packages.self,
        SymbolGraphs.self,
    ]
}
