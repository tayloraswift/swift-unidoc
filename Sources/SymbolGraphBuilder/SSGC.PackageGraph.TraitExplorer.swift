import PackageMetadata
import SymbolGraphs
import Symbols

extension SSGC.PackageGraph {
    struct TraitExplorer: ~Copyable {
        private let context: [Symbol.Package: SPM.Manifest]
        private var traits: [Symbol.Package: Set<SymbolGraphMetadata.Trait>]

        private init(context: [Symbol.Package: SPM.Manifest]) {
            self.context = context
            self.traits = [:]
        }
    }
}
extension SSGC.PackageGraph.TraitExplorer {
    static func collect<E>(
        context: [Symbol.Package: SPM.Manifest],
        explore: (inout Self) throws(E) -> ()
    ) throws(E) -> [Symbol.Package: Set<SymbolGraphMetadata.Trait>] {
        var explorer: Self = .init(context: context)
        try explore(&explorer)
        return explorer.traits
    }

    mutating func walk(
        package: SPM.Manifest,
        traits: Set<SymbolGraphMetadata.Trait>
    ) {
        for dependency: SPM.Manifest.Dependency in package.dependencies {
            /// these are the traits in the dependency that can be blamed on the current package
            /// (other packages in the build tree might enable extra traits in this dependency)
            var blameable: Set<SymbolGraphMetadata.Trait> = dependency.traits.reduce(into: []) {
                // enablement of the dependency’s trait can be conditional on enablement of
                // a trait in the current package (but they do not share namespaces)
                if  $1.condition.traits.allSatisfy(traits.contains(_:)) {
                    $0.insert($1.id)
                }
            }

            guard let next: SPM.Manifest = self.context[dependency.id] else {
                // we might not have the manifest on hand, because that package was not
                // actually used when building the root package (possibly due to traits!)
                continue
            }

            next.densify(traits: &blameable)

            self.traits[dependency.id, default: []].formUnion(blameable)
            self.walk(package: next, traits: blameable)
        }
    }
}
