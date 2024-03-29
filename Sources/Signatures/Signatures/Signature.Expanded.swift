import MarkdownABI

extension Signature
{
    @frozen public
    struct Expanded:Equatable
    {
        public
        let bytecode:Markdown.Bytecode
        public
        let scalars:[Scalar]

        @inlinable public
        init(bytecode:Markdown.Bytecode = [], scalars:[Scalar] = [])
        {
            self.bytecode = bytecode
            self.scalars = scalars
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
        .init(bytecode: self.bytecode, scalars: try self.scalars.map(transform))
    }
}
