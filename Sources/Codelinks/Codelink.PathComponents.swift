extension Codelink
{
    @frozen public
    struct PathComponents<Last> where Last:CustomStringConvertible
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
}
extension Codelink.PathComponents
{
    mutating
    func append(_ component:Last)
    {
        self.prefix.append(last.description)
        self.last = component
    }
}
extension Codelink.PathComponents:Sendable where Last:Sendable
{
}
extension Codelink.PathComponents:Equatable where Last:Equatable
{
}
extension Codelink.PathComponents:Hashable where Last:Hashable
{
}
extension Codelink.PathComponents:RandomAccessCollection
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
