protocol SignatureParameter {
    static func += (signature: inout SignatureSyntax.Encoder, self: Self)
}
