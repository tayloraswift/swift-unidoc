public
enum ConcreteStruct
{
    public
    enum NestedEnum
    {
    }

    public
    func a(_:Self) -> Self { fatalError() }
    public
    func b(_:Self.NestedEnum) -> Self.NestedEnum { fatalError() }

    public
    func c<Self>(_:Self) -> Self { fatalError() }
}
public
enum GenericStruct<T>
{
    public
    func a(_:Self) -> Self { fatalError() }
}
