/// snippet.IMPLICIT_CONSTRUCTOR
let _ = Int()
/// snippet.STRING_INTERPOLATION
let _:String = "\(1959)"
/// snippet.end
let dictionary:[String: Never] = [:]
/// snippet.STRING_SUBSCRIPT
let _ = dictionary["key"]
/// snippet.end
struct Key:ExpressibleByStringLiteral
{
    init(stringLiteral:String) {}
}
/// snippet.STRING_LITERAL_EXPRESSIBLE
let _:Key = "key"
/// snippet.end
