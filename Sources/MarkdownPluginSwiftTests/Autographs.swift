import Signatures
import Symbols
import Testing

@_spi(testable)
import MarkdownPluginSwift

@Suite
struct Autographs
{
    private
    var landmarks:SignatureLandmarks

    init()
    {
        self.landmarks = .init()
    }

    @Test mutating
    func Func1()
    {
        let decl:String = "func f(a: Int, b: [Float]) -> String?"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["Int", "[Float]"])
        #expect(self.landmarks.output == ["String?"])
    }

    @Test mutating
    func Func2()
    {
        let decl:String = "func f(a: Int, b: [Float]) -> (String?, Set<Int>)"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["Int", "[Float]"])
        #expect(self.landmarks.output == ["String?", "Set<Int>"])
    }

    @Test mutating
    func Func3()
    {
        let decl:String = """
        func f(
            a: @Sendable @escaping (Int, Int) -> Int,
            b: inout ([Float]),
            c: (x: Double, y: Double)) -> (String?, (Set<Int>) async throws -> Int)
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["(Int,Int)->Int", "[Float]", "(Double,Double)"])
        #expect(self.landmarks.output == ["String?", "(Set<Int>)->Int"])
    }

    @Test mutating
    func Subscript1()
    {
        let decl:String = "subscript(a: some Equatable, b: [Float: Bool]!) -> (String)?"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["_", "[Float:Bool]!"])
        #expect(self.landmarks.output == ["String?"])
    }

    @Test mutating
    func Subscript2()
    {
        let decl:String = "subscript<T>(a: T, b: [T]) -> (T?, Set<T>) where T: Hashable"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["T", "[T]"])
        #expect(self.landmarks.output == ["T?", "Set<T>"])
    }

    @Test mutating
    func Subscript3()
    {
        let decl:String = """
        subscript(
            a: @escaping ((Int, Int) -> Int),
            b: [Unicode.Scalar].Type) -> (Int) -> (Int) -> Int
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["(Int,Int)->Int", "[Unicode.Scalar].Type"])
        #expect(self.landmarks.output == ["(Int)->(Int)->Int"])
    }

    @Test mutating
    func Resugaring()
    {
        let dictionary:Signature<Symbol.Decl>.Fragment = .init("Dictionary", referent: .sSD)
        let array:Signature<Symbol.Decl>.Fragment = .init("Array", referent: .sSa)
        let optional:Signature<Symbol.Decl>.Fragment = .init("Optional", referent: .sSq)

        let _:Signature<Symbol.Decl>.Expanded = .init([
                "func f<T, U, V>(\n    a: (",
                array,
                "<T>),\n    b: ",
                dictionary,
                "<U, V>.Type) -> ",
                optional,
                "<V>",
            ],
            sugarDictionary: .sSD,
            sugarArray: .sSa,
            sugarOptional: .sSq,
            landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["[T]", "[U:V].Type"])
        #expect(self.landmarks.output == ["V?"])
    }
}
