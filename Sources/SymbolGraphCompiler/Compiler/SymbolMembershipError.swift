public
enum SymbolMembershipError:Equatable, Error
{
    case none
    case multiple(SymbolIdentifier, SymbolIdentifier)
}
