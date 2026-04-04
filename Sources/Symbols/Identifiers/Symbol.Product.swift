extension Symbol {
    @frozen public struct Product: PackageNamespaced {
        public let package: Package
        public let name: String

        @inlinable public init(package: Package, name: String) {
            self.package = package
            self.name = name
        }
    }
}
extension Symbol.Product: CustomStringConvertible, LosslessStringConvertible {}
