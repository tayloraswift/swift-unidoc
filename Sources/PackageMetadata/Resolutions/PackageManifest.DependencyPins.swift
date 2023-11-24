import Symbols

extension PackageManifest
{
    /// An index of identifiable digraph nodes.
    @frozen public
    struct DependencyPins
    {
        @usableFromInline internal
        var index:[Symbol.Package: DependencyPin]

        @inlinable internal
        init(index:[Symbol.Package: DependencyPin] = [:])
        {
            self.index = index
        }
    }
}
extension PackageManifest.DependencyPins
{
    public
    init(indexing pins:[PackageManifest.DependencyPin]) throws
    {
        self.init()

        for pin:PackageManifest.DependencyPin in pins
        {
            if  case _? = self.index.updateValue(pin, forKey: pin.id)
            {
                throw PackageManifest.DependencyPinError.duplicate(pin.id)
            }
        }
    }
}
extension PackageManifest.DependencyPins
{
    @inlinable public
    func callAsFunction(_ id:Symbol.Package) throws -> PackageManifest.DependencyPin
    {
        if  let pin:PackageManifest.DependencyPin = self.index[id]
        {
            return pin
        }
        else
        {
            throw PackageManifest.DependencyPinError.undefined(id)
        }
    }
}
