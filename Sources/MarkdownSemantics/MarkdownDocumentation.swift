@frozen public
struct MarkdownDocumentation
{
    public
    let parameters:[Parameter]
    public
    let returns:Returns?
    public
    let `throws`:Throws?
    public
    let article:MarkdownTree
}



extension MarkdownDocumentation
{
    @frozen public
    struct Returns
    {
        public
        var elements:[MarkdownTree.Block]

        @inlinable public
        init(_ elements:[MarkdownTree.Block])
        {
            self.elements = elements
        }
    }
}
extension MarkdownDocumentation
{
    @frozen public
    struct Throws
    {
        public
        var elements:[MarkdownTree.Block]

        @inlinable public
        init(_ elements:[MarkdownTree.Block])
        {
            self.elements = elements
        }
    }
}
extension MarkdownDocumentation
{
    @frozen public
    struct Parameter
    {
        public
        let name:String
        public
        var elements:[MarkdownTree.Block]

        @inlinable public
        init(name:String, elements:[MarkdownTree.Block])
        {
            self.name = name
            self.elements = elements
        }
    }
}
