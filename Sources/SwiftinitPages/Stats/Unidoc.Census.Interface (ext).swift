import BSON
import UnidocProfiling
import UnidocRecords

extension Unidoc.Census.Interface:PieSectorKey
{
    public
    var id:String
    {
        switch self
        {
        case .unrestricted:     "none"
        case .underscored:      "underscored"
        case .spi(nil):         "unknown"
        case .spi(let name?):   "spi-\(name)"
        }
    }

    public
    var name:String
    {
        switch self
        {
        case .unrestricted:     "unrestricted"
        case .underscored:      "underscored"
        case .spi(nil):         "SPI (unknown)"
        case .spi(let name?):   "SPI (\(name))"
        }
    }
}
