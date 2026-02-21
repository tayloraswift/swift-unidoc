import UnidocRecords

extension Unidoc {
    struct StemComponents {
        let namespace: Substring
        let scope: [Substring]
        let last: Substring

        init(namespace: Substring, scope: [Substring], last: Substring) {
            self.namespace = namespace
            self.scope = scope
            self.last = last
        }
    }
}
extension Unidoc.StemComponents {
    init(_ stem: Unidoc.Stem) throws {
        guard
        let (namespace, scope, last): (Substring, [Substring], Substring) = stem.split() else {
            throw Unidoc.StemComponentError.empty
        }

        self.init(namespace: namespace, scope: scope, last: last)
    }

    var breadcrumbs: [Substring]? {
        self.scope.isEmpty ? nil : self.scope
    }
}
