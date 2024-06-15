import PieCharts
import UnidocRecords

extension Unidoc.Stats.Decl:PieValues
{
    public
    typealias SectorKey = CodingKey

    public
    var sectors:KeyValuePairs<SectorKey, Int>
    {
        [
            .functions:             self.functions,
            .operators:             self.operators,
            .constructors:          self.constructors,
            .methods:               self.methods,
            .subscripts:            self.subscripts,
            .functors:              self.functors,
            .protocols:             self.protocols,
            .requirements:          self.requirements,
            .witnesses:             self.witnesses,
            .attachedMacros:        self.attachedMacros,
            .freestandingMacros:    self.freestandingMacros,
            .structures:            self.structures,
            .classes:               self.classes,
            .actors:                self.actors,
            .typealiases:           self.typealiases,
        ]
    }
}
