extension Unidoc {
    struct PackageContext {
        private(set) var principal: PackageMetadata?
        private(set) var metadata: [Package: PackageMetadata]

        private init(principal: PackageMetadata?, metadata: [Package: PackageMetadata]) {
            self.principal = principal
            self.metadata = metadata
        }
    }
}
extension Unidoc.PackageContext {
    init(principal: Unidoc.Package, metadata: __shared [Unidoc.PackageMetadata]) {
        self.init(principal: nil, metadata: .init(minimumCapacity: metadata.count))

        for package: Unidoc.PackageMetadata in metadata {
            self.metadata[package.id] = package
            if  principal == package.id {
                self.principal = package
            }
        }
    }
}
