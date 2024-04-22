import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        ParameterLists.self,
        Doclinks.self,
        SourcePositions.self,
    ]
}
