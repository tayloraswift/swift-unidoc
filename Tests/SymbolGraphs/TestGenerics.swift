import BSONDecoding
import BSONEncoding
import Generics
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
        for (name, expression):(String, GenericConstraint<ScalarAddress>.TypeExpression) in
        [
            ("nominal", .nominal(.init(exactly: 13)!)),
            ("complex", .complex("Dictionary<Int, String>.Index"))
        ]
        {
            guard let tests:TestGroup = tests / name
            else
            {
                continue
            }

            for (name, relation):(String, GenericConstraint<ScalarAddress>.TypeRelation) in
            [
                ("conformer", .conformer(of: expression)),
                ("subclass", .subclass(of: expression)),
                ("type", .type(expression)),
            ]
            {
                guard let tests:TestGroup = tests / name
                else
                {
                    continue
                }

                let constraint:GenericConstraint<ScalarAddress> = .init("T.RawValue",
                    is: relation)
                
                tests.do
                {
                    let bson:BSON.Document = .init(encoding: constraint)

                    let decoded:GenericConstraint<ScalarAddress> = try .init(bson: .init(bson))

                    tests.expect(constraint ==? decoded)
                }
            }
        }
    }
}
