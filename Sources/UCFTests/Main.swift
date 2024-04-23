import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Anchors.self,
        ParseCodelink.self,
        ParseDoclink.self,
    ]
}
