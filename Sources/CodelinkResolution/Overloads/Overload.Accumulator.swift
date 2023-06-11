extension Overload
{
    @frozen public
    enum Accumulator
    {
        case none
        case one  (Overload<Address>)
        case many([Overload<Address>])
    }
}
extension Overload.Accumulator
{
    init(filtering overloads:[Overload<Address>],
        where predicate:(Overload<Address>) throws -> Bool) rethrows
    {
        self = .none
        for overload:Overload<Address> in overloads where try predicate(overload)
        {
            self.append(overload)
        }
    }

    mutating
    func append(_ overload:Overload<Address>)
    {
        switch self
        {
        case .none:
            self = .one(overload)

        case .one(let other):
            self = .many([other, overload])

        case .many(var others):
            self = .none
            others.append(overload)
            self = .many(others)
        }
    }
}
