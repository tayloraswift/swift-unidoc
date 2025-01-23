import BSON
import Signatures
import SymbolGraphs
import Testing

@Suite
struct Generics
{
    @Test
    static func Parameters() throws
    {
        let parameters:[GenericParameter] = [
            .init(name: "T", depth: 0),
            .init(name: "Element", depth: 0),
            .init(name: "Element", depth: 1),
            .init(name: "Element", depth: 12),
            .init(name: "🇺🇸", depth: 1776),
            .init(name: "🇺🇸", depth: .max),
        ]

        let bson:BSON.List = .init(elements: parameters)
        let decoded:[GenericParameter] = try .init(bson: bson)

        #expect(parameters == decoded)
    }

    @Test(arguments: [
            .init(spelling: "", nominal: 13),
            .init(spelling: "Dictionary<Int, String>.Index", nominal: nil),
        ] as [GenericType<Int32>],
        [
            .conformer,
            .subclass,
            .equal
        ] as [GenericOperator])
    static func Constraints(_ whom:GenericType<Int32>, _ what:GenericOperator) throws
    {
        let constraint:GenericConstraint<Int32> = .where("T.RawValue",
            is: what,
            to: whom)

        let bson:BSON.Document = .init(encoding: constraint)
        let decoded:GenericConstraint<Int32> = try .init(bson: bson)

        #expect(constraint == decoded)
    }
}
