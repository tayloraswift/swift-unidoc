import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Bindings.self,
        Blockquotes.self,
        Lists.self,
        ListsWithMultipleItems.self,
        Parameters.self,
        Snippets.self,
        Topics.self,
    ]
}
