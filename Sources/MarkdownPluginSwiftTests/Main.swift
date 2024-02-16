import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Diffs.self,
        Signatures.self,
        InterestingKeywords.self,
    ]
}
