@frozen public
enum TargetType:String, Hashable, Equatable, Sendable
{
    case binary
    case executable
    case library = "regular"
    case macro
    case plugin
    
    //  We will never decode this from a manifest dump. But “extra” symbolgraphs
    //  are obviously snippets.
    case snippet

    case system
    case test
}
