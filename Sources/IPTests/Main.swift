import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Mapping.self,
        MaskingV6.self,
        ParsingV6.self,
        ParsingV4.self,
    ]
}
