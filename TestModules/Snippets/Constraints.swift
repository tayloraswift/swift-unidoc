public
enum Constraints<T> where T:Equatable
{
}
extension Constraints
{
    public
    func unconstrainedExtensionMethod(_:T)
    {
    }
}
extension Constraints where T:Comparable
{
    public
    func constrainedExtensionMethod(_:T)
    {
    }
}
extension Constraints where T:Equatable
{
    public
    func redundantlyConstrainedExtensionMethod(_:T)
    {
    }
}
extension Constraints<Int>
{
    public
    func concretelyConstrainedExtensionMethod(_:T)
    {
    }
}
extension Constraints
{
    public
    func locallyConstrainedExtensionMethod(_:T) where T:Comparable
    {
    }
}
extension Constraints
{
    public
    enum Shadowed<T, A> where T:Equatable
    {
    }
}
extension Constraints.Shadowed where T:AnyKeyPath
{
    public
    func shadowed<T, B>(_:T, _:B) where T:FixedWidthInteger
    {
    }
}
extension Constraints where [T: Never]:Any
{
    public
    func complex(_:T)
    {
    }
}
extension Sequence where Self:Equatable
{
    public
    func protocolExtensionMethod()
    {
    }
}
