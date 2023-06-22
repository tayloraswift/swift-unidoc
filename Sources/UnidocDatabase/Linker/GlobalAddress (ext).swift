import SymbolGraphs

extension GlobalAddress
{
    init(package:Int32, version:Int32, culture:Int)
    {
        /// Standalone articles use the tag value `0x8000_0000`, so we
        /// assign the tag value `0x4000_0000` for modules. (Addresses are
        /// 24 bits, so we have 8 tag bits and 256 tag values to choose
        /// from.)
        self.init(
            package: package,
            version: version,
            citizen: .init(culture) | 0x40_00_00_00)
    }
    init(package:Int32, version:Int32, address:Int32)
    {
        /// Standalone articles use the tag value `0x8000_0000`, so we
        /// assign the tag value `0x4000_0000` for modules. (Addresses are
        /// 24 bits, so we have 8 tag bits and 256 tag values to choose
        /// from.)
        self.init(
            package: package,
            version: version,
            citizen: .init(bitPattern: address))
    }

    var culture:Int?
    {
        0xFF_00_00_00 & self.citizen != 0x40_00_00_00 ?
            nil : .init(self.citizen  & 0x00_FF_FF_FF)
    }
    var address:Int32?
    {
        0xFF_00_00_00 & self.citizen == 0x40_00_00_00 ?
            nil : .init(bitPattern: self.citizen)
    }
}
