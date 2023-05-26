import ModuleGraphs

extension Repository
{
    /// An index of identifiable digraph nodes.
    @frozen public
    struct Pins
    {
        @usableFromInline internal
        var index:[PackageIdentifier: Pin]

        @inlinable internal
        init(index:[PackageIdentifier: Pin] = [:])
        {
            self.index = index
        }
    }
}
extension Repository.Pins
{
    public
    init(indexing pins:[Repository.Pin]) throws
    {
        self.init()

        for pin:Repository.Pin in pins
        {
            if  case _? = self.index.updateValue(pin, forKey: pin.id)
            {
                throw Repository.PinError.duplicate(pin.id)
            }
        }
    }
}
extension Repository.Pins
{
    @inlinable public
    func callAsFunction(_ id:PackageIdentifier) throws -> Repository.Pin
    {
        if  let pin:Repository.Pin = self.index[id]
        {
            return pin
        }
        else
        {
            throw Repository.PinError.undefined(id)
        }
    }
}
