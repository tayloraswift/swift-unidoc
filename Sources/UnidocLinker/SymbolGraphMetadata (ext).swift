import ModuleGraphs
import SemanticVersions
import SymbolGraphs

extension SymbolGraphMetadata
{
    public
    var pin:Snapshot.ID
    {
        switch (self.package, self.swift, self.commit?.refname)
        {
        case (.swift, let version?, _):
            return .init(package: .swift, version: version, triple: self.triple)

        case (.swift, nil, _):
            return .init(package: .swift, refname: nil, triple: self.triple)

        case (let package, _, let refname):
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
        if  let version:AnyVersion = self.swift
        {
            pins.reserveCapacity(self.dependencies.count + 1)
            pins.append(.init(package: .swift, version: version, triple: self.triple))
        }
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
