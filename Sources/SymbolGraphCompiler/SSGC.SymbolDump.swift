import SymbolGraphParts
import Symbols

extension SSGC
{
    @frozen public
    struct SymbolDump:Sendable
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
extension SSGC.SymbolDump
{
    private
    init(from part:borrowing SymbolGraphPart)
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

        //  Sort vertices and edges for determinism, since lib/SymbolGraphGen does not.
        self.vertices.sort { $0.usr < $1.usr }

        self.conformances.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.inheritances.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.requirements.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.memberships.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.witnessings.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.featurings.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.overrides.sort { ($0.source, $0.target) < ($1.source, $1.target) }
        self.extensions.sort { ($0.source, $0.target) < ($1.source, $1.target) }
    }

    public
    init(from part:borrowing SymbolGraphPart, base:borrowing Symbol.FileBase?) throws
    {
        self.init(from: part)

        for j:Int in self.vertices.indices
        {
            {
                //  Deport foreign doccomments.
                if  let doccomment:SymbolGraphPart.Vertex.Doccomment = $0.doccomment,
                        doccomment.culture != self.culture
                {
                    $0.doccomment = nil
                }
                //  Trim file path prefixes.
                //  As of 6.1, symbolgraph-extract sometimes emits paths from inside the swift
                //  installation directory.
                guard
                let base:Symbol.FileBase = copy base,
                let rebased:Symbol.File = try? $0.location?.file.rebased(against: base)
                else
                {
                    $0.location = nil
                    return
                }

                $0.location?.file = rebased

            } (&self.vertices[j])
        }
    }
}
