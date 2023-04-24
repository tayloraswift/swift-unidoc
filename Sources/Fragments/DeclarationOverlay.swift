//  https://github.com/apple/swift/blob/main/lib/SymbolGraphGen/DeclarationFragmentPrinter.cpp
@frozen public
struct DeclarationOverlay:RawRepresentable, Hashable, Equatable, Sendable
{
    public
    let rawValue:UInt8

    @inlinable public
    init(rawValue:UInt8)
    {
        self.rawValue = rawValue
    }
}
extension DeclarationOverlay
{
    @inlinable public
    init(classification:DeclarationFragmentClass?, elision:DeclarationFragmentElision?)
    {
        self.init(rawValue: (elision?.rawValue ?? 0) | (classification?.rawValue ?? 0))
    }
    @inlinable public
    var classification:DeclarationFragmentClass?
    {
        .init(rawValue: self.rawValue & 0x0f)
    }
    @inlinable public
    var elision:DeclarationFragmentElision?
    {
        .init(rawValue: self.rawValue & 0xf0)
    }
}
