import PackageMetadata
import Symbols

extension SSGC.BookBuild
{
    @frozen public
    enum ID:Hashable, Sendable
    {
        case unversioned(Symbol.Package)
        case versioned(SPM.DependencyPin, reference:String)
    }
}
extension SSGC.BookBuild.ID
{
    var package:Symbol.Package
    {
        switch self
        {
        case .unversioned(let id):      id
        case .versioned(let pin, _):    pin.identity
        }
    }
    var pin:SPM.DependencyPin?
    {
        switch self
        {
        case .unversioned:              nil
        case .versioned(let pin, _):    pin
        }
    }
}
