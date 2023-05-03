extension SymbolGraph.Scalar
{
    struct Flags:RawRepresentable
    {
        let rawValue:Int32

        init(rawValue:Int32)
        {
            self.rawValue = rawValue
        }
    }
}
extension SymbolGraph.Scalar.Flags
{
    init(virtuality:ScalarVirtuality?, phylum:ScalarPhylum)
    {
        self.init(rawValue: .init(phylum.rawValue) << 8 | .init(virtuality?.rawValue ?? 0))
    }
    var virtuality:ScalarVirtuality?
    {
        .init(rawValue: .init(truncatingIfNeeded: self.rawValue))
    }
    var phylum:ScalarPhylum?
    {
        .init(rawValue: .init(truncatingIfNeeded: self.rawValue >> 8))
    }
}
