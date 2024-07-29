import UCF

extension UCF.Overload
{
    @frozen public
    enum Group:Equatable, Hashable
    {
        case one  (UCF.Overload<Scalar>)
        case some([UCF.Overload<Scalar>])
    }
}
extension UCF.Overload.Group:Sendable where Scalar:Sendable
{
}
extension UCF.Overload.Group
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
extension UCF.Overload.Group
{
    init(filtering overloads:[UCF.Overload<Scalar>],
        where predicate:(UCF.Overload<Scalar>) throws -> Bool) rethrows
    {
        self = .some([])
        for overload:UCF.Overload<Scalar> in overloads where
            try predicate(overload)
        {
            self.overload(with: overload)
        }
    }

    @inlinable mutating
    func overload(with overloads:Self)
    {
        switch (consume self, overloads)
        {
        case    (.one(let one), .one(let other)):
            self = .some([one, other])

        case    (.one(let one), .some([])),
                (.some([]), .one(let one)):
            self = .one(one)

        case    (.some(var some), .one(let one)),
                (.one(let one), .some(var some)):
            some.append(one)
            self = .some(some)

        case    (.some(var some), .some(let others)):
            some += others
            self = .some(some)
        }
    }

    @inlinable public mutating
    func overload(with overload:UCF.Overload<Scalar>)
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
