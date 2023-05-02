import MarkdownABI

extension Declaration
{
    @frozen public
    struct Expanded:Equatable
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
extension Declaration.Expanded:Sendable where Symbol:Sendable
{
}
extension Declaration.Expanded
{
    @inlinable public
    func map<T>(_ transform:(Symbol) throws -> T) rethrows -> Declaration<T>.Expanded
    {
        .init(bytecode: self.bytecode, links: try self.links.map(transform))
    }
}
