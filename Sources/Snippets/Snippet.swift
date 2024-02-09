import MarkdownABI

@frozen public
struct Snippet:Equatable, Sendable
{
    public
    let name:String

    public
    var overview:Markdown.Bytecode?
    public
    var slices:[Slice]

    @inlinable public
    init(name:String, overview:Markdown.Bytecode?, slices:[Slice])
    {
        self.name = name

        self.overview = overview
        self.slices = slices
    }
}
