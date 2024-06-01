extension Markdown.SwiftLanguage
{
    public
    protocol IndexStore:AnyObject
    {
        /// Returns a list of index markers, indexed by UTF-8 offset.
        func load(for path:String, utf8:[UInt8]) -> [Int: IndexMarker]
    }
}
