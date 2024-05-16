extension Markdown.SwiftLanguage
{
    public
    protocol IndexStore:AnyObject
    {
        func load(for path:String)
    }
}
