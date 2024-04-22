import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Diffs.self,
        Signatures.self,
        Snippets.self,
        InterestingKeywords.self,
    ]
}
