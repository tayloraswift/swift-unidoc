import MarkdownABI

extension Declaration.Fragments
{
    @frozen public
    struct All:Equatable
    {
        public
        let bytecode:MarkdownBytecode
        public
        let links:[Symbol]

        @inlinable public
        init(bytecode:MarkdownBytecode = [], links:[Symbol] = [])
        {
            self.bytecode = bytecode
            self.links = links
        }
    }
}
extension Declaration.Fragments.All:Sendable where Symbol:Sendable
{
}
extension Declaration.Fragments.All
{
    @inlinable public
    func map<T>(_ transform:(Symbol) throws -> T) rethrows -> Declaration<T>.Fragments.All
    {
        .init(bytecode: self.bytecode, links: try self.links.map(transform))
    }
}
