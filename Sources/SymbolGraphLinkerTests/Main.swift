import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Bindings.self,
        Blockquotes.self,
        LinkResolution.self,
        Lists.self,
        ListsWithMultipleItems.self,
        Parameters.self,
        Topics.self,
    ]
}
