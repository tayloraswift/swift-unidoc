extension CodelinkResolver
{
    @frozen public
    enum Overloads:Equatable, Hashable, Sendable
    {
        case one  (Overload)
        case many([Overload])
    }
}
extension CodelinkResolver.Overloads?
{
    mutating 
    func append(_ overload:CodelinkResolver.Overload)
    {
        switch self
        {
        case nil: 
            self = .one(overload)
        
        case .one(let other)?: 
            self = .many([other, overload])
        
        case .many(var others)?:
            self = nil
            others.append(overload)
            self = .many(others)
        }
    }
}
