import BSON
import UnidocProfiling

extension Unidoc.Stats.SPIs
{
    enum SectorKey
    {
        case none
        case unknown
        case nominal(String)
    }
}
extension Unidoc.Stats.SPIs.SectorKey
{
    init(key:BSON.Key)
    {
        switch key
        {
        case "":            self = .none
        case "__unknown__": self = .unknown
        case let key:       self = .nominal(key.rawValue)
        }
    }
}
extension Unidoc.Stats.SPIs.SectorKey:PieSectorKey
{
    var id:String
    {
        switch self
        {
        case .none:                 "none"
        case .unknown:              "unknown"
        case .nominal(let name):    "spi-\(name)"
        }
    }

    var name:String
    {
        switch self
        {
        case .none:                 "not gated"
        case .unknown:              "SPI (unknown)"
        case let .nominal(name):    "SPI (\(name))"
        }
    }
}
