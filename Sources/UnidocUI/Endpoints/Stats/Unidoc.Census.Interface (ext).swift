import PieCharts
import UnidocRecords

extension Unidoc.Census.Interface: Pie.ChartKey {
    public var id: String {
        switch self {
        case .unrestricted:     "none"
        case .underscored:      "underscored"
        case .spi(nil):         "unknown"
        case .spi(let name?):   "spi-\(name)"
        }
    }

    public var name: String {
        switch self {
        case .unrestricted:     "unrestricted"
        case .underscored:      "underscored"
        case .spi(nil):         "SPI (unknown)"
        case .spi(let name?):   "SPI (\(name))"
        }
    }
}
