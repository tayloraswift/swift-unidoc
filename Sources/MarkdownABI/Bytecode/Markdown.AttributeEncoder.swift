extension Markdown {
    @frozen public struct AttributeEncoder {
        @usableFromInline internal var bytecode: Bytecode

        @inlinable internal init(bytecode: Bytecode) {
            self.bytecode = bytecode
        }
    }
}
extension Markdown.AttributeEncoder {
    /// Serializes an empty attribute, if the assigned boolean is true.
    /// Does nothing if it is false. The getter always returns false.
    @inlinable public subscript(attribute: Markdown.Bytecode.Attribute) -> Bool {
        get {
            false
        }
        set(bool) {
            self[attribute] = bool ? "" : nil
        }
    }
    @inlinable public subscript(attribute: Markdown.Bytecode.Attribute) -> String? {
        get {
            nil
        }
        set(text) {
            if let text: String {
                self.bytecode.write(attribute)
                self.bytecode.write(text: text)
            }
        }
    }
    @inlinable public subscript(attribute: Markdown.Bytecode.Attribute) -> Int? {
        get {
            nil
        }
        set(reference) {
            if  let reference: Int {
                self.bytecode.write(attribute, reference: reference)
            }
        }
    }
}
