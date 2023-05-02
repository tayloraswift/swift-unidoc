extension Declaration
{
    @frozen public
    struct Fragments:Equatable
    {
        public
        let abridged:Abridged
        public
        let all:All

        @inlinable public
        init(abridged:Abridged = .init(), all:All = .init())
        {
            self.abridged = abridged
            self.all = all
        }
    }
}
extension Declaration.Fragments:Sendable where Symbol:Sendable
{
}
extension Declaration.Fragments
{
    @inlinable public
    func map<T>(_ transform:(Symbol) throws -> T) rethrows -> Declaration<T>.Fragments
    {
        .init(abridged: .init(bytecode: self.abridged.bytecode),
            all: try self.all.map(transform))
    }
}
