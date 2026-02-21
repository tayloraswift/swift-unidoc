import Symbols
import UCF

extension UCF {
    @frozen public struct ArticleTable {
        @usableFromInline var entries: [ResolutionPath: Int32]

        @inlinable public init() {
            self.entries = [:]
        }
    }
}
extension UCF.ArticleTable {
    @inlinable public subscript(prefix: Prefix, name: String) -> Int32? {
        _read {
            yield  self.entries[.join(prefix + [name])]
        }
        _modify {
            yield &self.entries[.join(prefix + [name])]
        }
    }
}
extension UCF.ArticleTable {
    func resolve(_ link: Doclink, in scope: UCF.ArticleScope) -> Int32? {
        if !link.absolute {
            if  let namespace: Symbol.Module = scope.namespace {
                for prefix: Prefix in [.documentation(namespace), .tutorials(namespace)] {
                    for index: Int in prefix.indices.reversed() {
                        let path: UCF.ResolutionPath = .join(prefix[...index] + link.path)
                        if  let address: Int32 = self.entries[path] {
                            return address
                        }
                    }
                }
            }
        }
        return self.entries[.join(link.path)]
    }

    func resolve(_ doclink: Doclink, docc: Bool, in scope: UCF.ArticleScope) -> Int32? {
        if  let resolved: Int32 = self.resolve(doclink, in: scope) {
            return resolved
        }

        guard docc,
        let namespace: Symbol.Module = scope.namespace else {
            return nil
        }

        //  You really have to wonder what the hell the [people] at Apple were thinking...
        let prefix: Prefix
        switch (doclink.absolute, doclink.path.first) {
        case (false, "tutorials"?):     prefix = .tutorials(namespace)
        case (false, "documentation"?): prefix = .documentation(namespace)
        default:                        return nil
        }

        let path: UCF.ResolutionPath = .join([_].init(prefix) + doclink.path.dropFirst())
        return self.entries[path]
    }
}
