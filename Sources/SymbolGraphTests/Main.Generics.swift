import BSON
import Signatures
import SymbolGraphs
import Testing_

extension Main
{
    struct Generics
    {
    }
}
extension Main.Generics:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Parameters"
        {
            let parameters:[GenericParameter] =
            [
                .init(name: "T", depth: 0),
                .init(name: "Element", depth: 0),
                .init(name: "Element", depth: 1),
                .init(name: "Element", depth: 12),
                .init(name: "🇺🇸", depth: 1776),
                .init(name: "🇺🇸", depth: .max),
            ]
            tests.do
            {
                let bson:BSON.List = .init(elements: parameters)
                let decoded:[GenericParameter] = try .init(bson: bson)

                tests.expect(parameters ..? decoded)
            }
        }
        if  let tests:TestGroup = tests / "Constraints"
        {
            for (name, whom):(String, GenericType<Int32>) in
            [
                ("nominal", .init(spelling: "", nominal: 13)),
                ("complex", .init(spelling: "Dictionary<Int, String>.Index", nominal: nil))
            ]
            {
                guard let tests:TestGroup = tests / name
                else
                {
                    continue
                }

                for what:GenericOperator in [.conformer, .subclass, .equal]
                {
                    guard
                    let tests:TestGroup = tests / "\(what)"
                    else
                    {
                        continue
                    }

                    let constraint:GenericConstraint<Int32> = .where("T.RawValue",
                        is: what,
                        to: whom)

                    tests.do
                    {
                        let bson:BSON.Document = .init(encoding: constraint)
                        let decoded:GenericConstraint<Int32> = try .init(bson: bson)

                        tests.expect(constraint ==? decoded)
                    }
                }
            }
        }
    }
}
