import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        ParseCodelink.self,
        ParseDoclink.self,
    ]
}
