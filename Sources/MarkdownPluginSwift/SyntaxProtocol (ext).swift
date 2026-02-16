import SwiftSyntax

extension SyntaxProtocol {
    var trimmedPreservingLocation: TrimmedSyntax<Self> {
        .init(node: self)
    }
}
