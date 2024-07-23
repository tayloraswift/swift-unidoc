import Testing_
import TopologicalSorting

extension Main
{
    struct Sorting
    {
    }
}
extension Main.Sorting
{
    struct TestNode:Identifiable, Equatable
    {
        let id:String

        init(id:String)
        {
            self.id = id
        }
    }
}
extension Main.Sorting.TestNode:CustomStringConvertible
{
    var description:String { self.id }
}
extension Main.Sorting.TestNode:ExpressibleByStringLiteral
{
    init(stringLiteral:String) { self.init(id: stringLiteral) }
}
extension Main.Sorting
{
    struct TestCase
    {
        let id:String
        let nodes:[TestNode]
        let edges:[(String, String)]
        let cyclic:Bool

        init(id:String,
            nodes:[TestNode],
            edges:KeyValuePairs<String, String>,
            cyclic:Bool = false)
        {
            self.id = id
            self.nodes = nodes
            self.edges = [_].init(edges)
            self.cyclic = cyclic
        }
    }
}
extension Main.Sorting.TestCase
{
    func run(in tests:TestGroup)
    {
        guard
        let tests:TestGroup = tests / self.id
        else
        {
            return
        }

        let shuffled:[Main.Sorting.TestNode] = self.nodes.shuffled()
        if  cyclic
        {
            tests.expect(nil: shuffled.sortedTopologically(by: self.edges.shuffled()))

        }
        else if
            let sorted:[Main.Sorting.TestNode] = tests.expect(
                value: shuffled.sortedTopologically(by: self.edges.shuffled()))
        {
            tests.expect(sorted ..? self.nodes)
        }
    }
}
extension Main.Sorting:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let cases:[TestCase] = [
            .init(id: "Empty", nodes: [], edges: [:]),
            .init(id: "Single", nodes: ["A"], edges: [:]),
            .init(id: "Multiple", nodes: ["A", "B", "C"], edges: [:]),

            .init(id: "LoopbackEdge", nodes: ["A", "B", "C"], edges: ["A": "A"],
                cyclic: true),

            .init(id: "Circular",
                nodes: ["A", "B", "C"],
                edges: [
                    "A": "B",
                    "B": "C",
                    "C": "A",
                ],
                cyclic: true),

            .init(id: "IgnoredEdge",
                nodes: ["A", "B", "C"],
                edges: ["A": "D"]),
            .init(id: "SingleEdge",
                nodes: ["B", "A", "C"],
                edges: ["B": "A"]),
            .init(id: "DuplicateEdge",
                nodes: ["B", "A", "C"],
                edges: ["B": "A", "B": "A"]),

            .init(id: "ConvergingStar",
                nodes: ["B", "C", "D", "A"],
                edges: [
                    "B": "A",
                    "C": "A",
                    "D": "A",
                ]),

            .init(id: "DivergingStar",
                nodes: ["A", "B", "C", "D"],
                edges: [
                    "A": "B",
                    "A": "C",
                    "A": "D",
                ]),

            .init(id: "Lips",
                nodes: ["4", "0", "1", "5", "2", "3"],
                edges: [
                    "4": "0",
                    "4": "1",
                    "1": "3",
                    "5": "2",
                    "2": "3",
                ]),

            .init(id: "LipsAsymmetric",
                nodes: ["4", "0", "5", "2", "3", "1"],
                edges: [
                    "4": "0",
                    "4": "1",
                    "3": "1",
                    "5": "2",
                    "2": "3",
                ]),
        ]

        for test:TestCase in cases
        {
            test.run(in: tests)
        }
    }
}
