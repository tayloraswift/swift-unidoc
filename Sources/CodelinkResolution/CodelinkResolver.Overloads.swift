extension CodelinkResolver
{
    @frozen public
    enum Overloads:Equatable, Hashable
    {
        case one  (Overload)
        case some([Overload])
    }
}
extension CodelinkResolver.Overloads:Sendable where Scalar:Sendable
{
}
extension CodelinkResolver.Overloads
{
    var isEmpty:Bool
    {
        switch self
        {
        case .one:                  false
        case .some(let overloads):  overloads.isEmpty
        }
    }
}
extension CodelinkResolver.Overloads
{
    init(filtering overloads:[CodelinkResolver<Scalar>.Overload],
        where predicate:(CodelinkResolver<Scalar>.Overload) throws -> Bool) rethrows
    {
        self = .some([])
        for overload:CodelinkResolver<Scalar>.Overload in overloads where
            try predicate(overload)
        {
            self.overload(with: overload)
        }
    }

    @inlinable public mutating
    func overload(with overload:CodelinkResolver<Scalar>.Overload)
    {
        switch self
        {
        case .one(let other):
            self = .some([other, overload])

        case .some(var others):
            if  others.isEmpty
            {
                self = .one(overload)
            }
            else
            {
                self = .some([])
                others.append(overload)
                self = .some(others)
            }
        }
    }
}
