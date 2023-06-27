import BSONDecoding
import BSONEncoding
import Signatures
import SymbolGraphs
import Testing

func TestGenerics(_ tests:TestGroup?)
{
    if  let tests:TestGroup = tests / "parameters"
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
            let decoded:[GenericParameter] = try .init(bson: .init(bson))

            tests.expect(parameters ..? decoded)
        }
    }
    if  let tests:TestGroup = tests / "constraints"
    {
        for (name, whom):(String, GenericType<Int32>) in
        [
            ("nominal", .nominal(13)),
            ("complex", .complex("Dictionary<Int, String>.Index"))
        ]
        {
            guard let tests:TestGroup = tests / name
            else
            {
                continue
            }

            for what:GenericOperator in [.conformer, .subclass, .equal]
            {
                guard let tests:TestGroup = tests / "\(what)"
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

                    let decoded:GenericConstraint<Int32> = try .init(bson: .init(bson))

                    tests.expect(constraint ==? decoded)
                }
            }
        }
    }
}
