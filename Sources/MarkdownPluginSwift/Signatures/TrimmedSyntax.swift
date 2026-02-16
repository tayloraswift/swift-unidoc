import SwiftSyntax

struct TrimmedSyntax<Node> where Node: SyntaxProtocol {
    let node: Node
}
