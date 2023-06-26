import MarkdownABI

extension Signature
{
    @frozen public
    struct Expanded:Equatable
    {
        public
        let bytecode:MarkdownBytecode
        public
        let links:[Scalar]

        @inlinable public
        init(bytecode:MarkdownBytecode = [], links:[Scalar] = [])
        {
            self.bytecode = bytecode
            self.links = links
        }
    }
}
extension Signature.Expanded:Sendable where Scalar:Sendable
{
}
extension Signature.Expanded
{
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T) rethrows -> Signature<T>.Expanded
    {
        .init(bytecode: self.bytecode, links: try self.links.map(transform))
    }
}
