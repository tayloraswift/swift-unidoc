@frozen public
struct LexicalComponents<Last> where Last:LexicalContinuation
{
    public
    var prefix:[String]
    public
    var last:Last

    @inlinable public
    init(_ prefix:[String], _ last:Last)
    {
        self.prefix = prefix
        self.last = last
    }
}

extension LexicalComponents
{
    mutating
    func append(_ component:Last)
    {
        self.prefix.append(last.unencased)
        self.last = component
    }
}
extension LexicalComponents:Sendable where Last:Sendable
{
}
extension LexicalComponents:Equatable where Last:Equatable
{
}
extension LexicalComponents:Hashable where Last:Hashable
{
}
extension LexicalComponents:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int 
    {
        self.prefix.startIndex
    }
    @inlinable public
    var endIndex:Int 
    {
        self.prefix.endIndex + 1
    }
    @inlinable public
    subscript(index:Int) -> String
    {
        index < self.prefix.endIndex ? self.prefix[index] : self.last.description
    }
}
