import Testing
import TopologicalSorting

@Suite
enum Sorting
{
    @Test
    static func Empty()
    {
        Self.test(nodes: [], edges: [:])
    }
    @Test
    static func Single()
    {
        Self.test(nodes: ["A"], edges: [:])
    }
    @Test
    static func Multiple()
    {
        Self.test(nodes: ["A", "B", "C"], edges: [:])
    }
    @Test
    static func LoopbackEdge()
    {
        Self.test(nodes: ["A", "B", "C"], edges: ["A": "A"], cyclic: true)
    }

    @Test
    static func Circular()
    {
        Self.test(nodes: ["A", "B", "C"], edges: ["A": "B", "B": "C", "C": "A"], cyclic: true)
    }

    @Test
    static func IgnoredEdge()
    {
        Self.test(nodes: ["A", "B", "C"], edges: ["A": "D"])
    }
    @Test
    static func SingleEdge()
    {
        Self.test(nodes: ["B", "A", "C"], edges: ["B": "A"])
    }
    @Test
    static func DuplicateEdge()
    {
        Self.test(nodes: ["B", "A", "C"], edges: ["B": "A", "B": "A"])
    }

    @Test
    static func ConvergingStar()
    {
        Self.test(
            nodes: ["B", "C", "D", "A"],
            edges: [
                "B": "A",
                "C": "A",
                "D": "A",
            ])
    }

    @Test
    static func DivergingStar()
    {
        Self.test(
            nodes: ["A", "B", "C", "D"],
            edges: [
                "A": "B",
                "A": "C",
                "A": "D",
            ])
    }

    @Test
    static func Lips()
    {
        Self.test(
            nodes: ["4", "0", "1", "5", "2", "3"],
            edges: [
                "4": "0",
                "4": "1",
                "1": "3",
                "5": "2",
                "2": "3",
            ])
    }

    @Test
    static func LipsAsymmetric()
    {
        Self.test(
            nodes: ["4", "0", "5", "2", "3", "1"],
            edges: [
                "4": "0",
                "4": "1",
                "3": "1",
                "5": "2",
                "2": "3",
            ])
    }
}
extension Sorting
{
    private
    static func test(nodes:[TestNode], edges:KeyValuePairs<String, String>, cyclic:Bool = false)
    {
        let shuffled:[TestNode] = nodes.shuffled()
        let edges:[(String, String)] = [_].init(edges)

        if  cyclic
        {
            #expect(shuffled.sortedTopologically(by: edges.shuffled()) == nil)
        }
        else
        {
            #expect(shuffled.sortedTopologically(by: edges.shuffled()) == nodes)
        }
    }
}
