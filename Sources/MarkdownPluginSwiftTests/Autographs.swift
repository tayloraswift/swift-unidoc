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

    private
    var dictionary:Signature<Symbol.Decl>.Fragment { .init("Dictionary", referent: .sSD) }
    private
    var array:Signature<Symbol.Decl>.Fragment { .init("Array", referent: .sSa) }
    private
    var optional:Signature<Symbol.Decl>.Fragment { .init("Optional", referent: .sSq) }

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

        #expect(self.landmarks.inputs == ["Equatable", "[Float:Bool]!"])
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
    func Var1()
    {
        let decl:String = "static var x: (String)? { get }"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [])
        #expect(self.landmarks.output == ["String?"])
    }

    @Test mutating
    func Var2()
    {
        let decl:String = "static var x: (T?, Set<T>) { get set }"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [])
        #expect(self.landmarks.output == ["T?", "Set<T>"])
    }

    @Test mutating
    func Var3()
    {
        let decl:String = "var x: (Int, Int) -> (Int) -> Int"
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [])
        #expect(self.landmarks.output == ["(Int,Int)->(Int)->Int"])
    }

    @Test mutating
    func SomeAndAnyTypes()
    {
        let decl:String = """
        func f(
            a: any Error,
            b: some Error & CustomStringConvertible,
            c: [some RandomAccessCollection<UInt8> & MutableCollection<UInt8>].Type)
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [
                "Error",
                "Error&CustomStringConvertible",
                "[RandomAccessCollection<UInt8>&MutableCollection<UInt8>].Type"
            ])
        #expect(self.landmarks.output == [])
    }

    /// Note that as of Swift 6.0, it is currently illegal to include primary associated types
    /// in an existential protocol composition type, although this is allowed for `some` types.
    @Test mutating
    func ProtocolCompositions()
    {
        let decl:String = """
        func f(
            a: any Error,
            b: any Error & CustomStringConvertible,
            c: any RandomAccessCollection & MutableCollection)
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [
                "Error",
                "Error&CustomStringConvertible",
                "RandomAccessCollection&MutableCollection"
            ])
        #expect(self.landmarks.output == [])
    }

    @Test mutating
    func Variadics()
    {
        let decl:String = """
        func f(
            a: String...,
            b: [String]...,
            c: Set<Int>...)
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [
                "String...",
                "[String]...",
                "Set<Int>..."
            ])
        #expect(self.landmarks.output == [])
    }

    @Test mutating
    func Packs()
    {
        let decl:String = """
        func f<each T>(x: repeat [each T])
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["[T]"])
        #expect(self.landmarks.output == [])
    }

    @Test mutating
    func Noncopyable()
    {
        let decl:String = """
        func f(a: borrowing some ~Copyable)
        """
        let _:Signature<Never>.Expanded = .init(decl, landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["~Copyable"])
        #expect(self.landmarks.output == [])
    }

    @Test mutating
    func Resugaring1()
    {
        let _:Signature<Symbol.Decl>.Expanded = .init([
                "func f<T, U, V>(\n    a: (",
                self.array,
                "<T>),\n    b: ",
                self.dictionary,
                "<U, V>.Type) -> ",
                self.optional,
                "<V>",
            ],
            sugarDictionary: .sSD,
            sugarArray: .sSa,
            sugarOptional: .sSq,
            landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["[T]", "[U:V].Type"])
        #expect(self.landmarks.output == ["V?"])
    }

    @Test mutating
    func Resugaring2()
    {
        let _:Signature<Symbol.Decl>.Expanded = .init([
                "func f(_: ", self.dictionary, "<Int, String>.Index)",
            ],
            sugarDictionary: .sSD,
            sugarArray: .sSa,
            sugarOptional: .sSq,
            landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["Dictionary<Int,String>.Index"])
        #expect(self.landmarks.output == [])
    }

    @Test mutating
    func Resugaring3()
    {
        let _:Signature<Symbol.Decl>.Expanded = .init([
                "func f(_: ",
                self.array,
                "<",
                self.dictionary,
                "<",
                self.optional,
                "<Int>, String>>?)",
            ],
            sugarDictionary: .sSD,
            sugarArray: .sSa,
            sugarOptional: .sSq,
            landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == ["[[Int?:String]]?"])
        #expect(self.landmarks.output == [])
    }

    @Test mutating
    func DesugaringStaticSelf()
    {
        let _:Signature<Symbol.Decl>.Expanded = .init([
                "func a(_: `Self`, _: [(`Self`)]) -> `Self`?"
            ],
            sugarDictionary: .sSD,
            sugarArray: .sSa,
            sugarOptional: .sSq,
            desugarSelf: "DesugaredSelf<A,B>.NestedType",
            landmarks: &self.landmarks)

        #expect(self.landmarks.inputs == [
                "DesugaredSelf<A,B>.NestedType",
                "[DesugaredSelf<A,B>.NestedType]"
            ])
        #expect(self.landmarks.output == [
                "DesugaredSelf<A,B>.NestedType?"
            ])
    }
}
