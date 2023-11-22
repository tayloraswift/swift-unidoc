import ModuleGraphs
import SemanticVersions
import SymbolGraphs

extension SymbolGraphMetadata
{
    public
    var pin:Snapshot.ID
    {
        switch (self.package, self.commit?.refname)
        {
        case (.swift, _):
            return .init(package: .swift, version: self.swift, triple: self.triple)

        case (let package, let refname):
            return .init(package: package, refname: refname, triple: self.triple)
        }
    }

    /// Returns all the relevant documentation object’s dependencies’ identity strings,
    /// including the one for its toolchain dependency, unless it is itself a toolchain
    /// snapshot.
    public
    func pins() -> [Snapshot.ID]
    {
        if  case .swift = self.package
        {
            return []
        }

        var pins:[Snapshot.ID] = []
            pins.reserveCapacity(self.dependencies.count + 1)

        pins.append(.init(package: .swift, version: self.swift, triple: self.triple))

        for dependency:Dependency in self.dependencies
        {
            pins.append(.init(
                package: dependency.package,
                version: dependency.version,
                triple: self.triple))
        }
        return pins
    }
}
