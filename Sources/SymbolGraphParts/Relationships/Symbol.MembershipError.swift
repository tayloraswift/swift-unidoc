import Symbols

extension Symbol {
    enum MembershipError: Error {
        case invalid(member: Symbol.Block)
    }
}
