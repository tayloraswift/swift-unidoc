import GenericExtensions

extension Unmanaged.Nested where U:Collection
{
    public
    func foo<V>(_:V) where V:Error
    {
    }
}
