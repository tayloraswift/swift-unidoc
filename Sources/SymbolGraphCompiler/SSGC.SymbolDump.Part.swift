import SymbolGraphParts
import Symbols

extension SSGC.SymbolDump
{
    @frozen @usableFromInline
    struct Part
    {
        let culture:Symbol.Module
        let colony:Symbol.Module?

        private(set)
        var conformances:[Symbol.ConformanceRelationship]
        private(set)
        var inheritances:[Symbol.InheritanceRelationship]

        private(set)
        var requirements:[Symbol.RequirementRelationship]
        private(set)
        var memberships:[Symbol.MemberRelationship]

        private(set)
        var witnessings:[Symbol.IntrinsicWitnessRelationship]
        private(set)
        var featurings:[Symbol.FeatureRelationship]
        private(set)
        var overrides:[Symbol.OverrideRelationship]
        private(set)
        var extensions:[Symbol.ExtensionRelationship]

        private(set)
        var vertices:[SymbolGraphPart.Vertex]

        private
        init(culture:Symbol.Module, colony:Symbol.Module?, vertices:[SymbolGraphPart.Vertex])
        {
            self.culture = culture
            self.colony = colony

            self.conformances = []
            self.inheritances = []

            self.requirements = []
            self.memberships = []

            self.witnessings = []
            self.featurings = []
            self.overrides = []
            self.extensions = []

            self.vertices = vertices
        }
    }
}
extension SSGC.SymbolDump.Part
{
    init(from part:SymbolGraphPart)
    {
        self.init(culture: part.culture, colony: part.colony, vertices: part.vertices)

        for relationship:Symbol.AnyRelationship in part.relationships
        {
            switch relationship
            {
            case .conformance(let edge):        self.conformances.append(edge)
            case .inheritance(let edge):        self.inheritances.append(edge)
            case .requirement(let edge):        self.requirements.append(edge)
            case .member(let edge):             self.memberships.append(edge)
            case .intrinsicWitness(let edge):   self.witnessings.append(edge)
            case .feature(let edge):            self.featurings.append(edge)
            case .override(let edge):           self.overrides.append(edge)
            case .extension(let edge):          self.extensions.append(edge)
            }
        }
    }
}
