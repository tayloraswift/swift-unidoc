@frozen public
struct GenericType<Scalar>
{
    public
    let spelling:String
    public
    let nominal:Scalar?

    @inlinable public
    init(spelling:String, nominal:Scalar? = nil)
    {
        self.spelling = spelling
        self.nominal = nominal
    }
}
extension GenericType:Equatable where Scalar:Equatable
{
}
extension GenericType:Hashable where Scalar:Hashable
{
}
extension GenericType:Sendable where Scalar:Sendable
{
}
extension GenericType:Comparable where Scalar:Comparable
{
    @inlinable public
    static func < (a:Self, b:Self) -> Bool
    {
        switch (a.nominal, b.nominal)
        {
        case (let i?, let j?):  (i, a.spelling) < (j, b.spelling)
        case (_?, nil):         true
        case (nil, _?):         false
        case (nil, nil):        a.spelling < b.spelling
        }
    }
}
extension GenericType
{
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T?) rethrows -> GenericType<T>
    {
        .init(spelling: self.spelling, nominal: try self.nominal.map(transform) ?? nil)
    }
}
