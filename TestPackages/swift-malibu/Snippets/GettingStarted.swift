//  This snippet shows how to use
//  the `swift-malibu` package.
//
//  This description can contain more than one paragraph.

print("Hi Barbie!")

//  snippet.end

//  This part of the snippet is not included in the rendered documentation.
print("Hi Ken!")

//  snippet.F
func f()
{
    let _:String = """
    This is an expression embedded inside a code block
    """ //  snippet.NOT_A_VALID_SLICE_BECAUSE_IT_IS_NOT_AT_THE_BEGINNING_OF_THE_LINE

    //  snippet.hide

    //  This part is hidden.

    //  snippet.show

    let _:String = """
    This is another expression embedded inside a code block
    """

    //  snippet.end
}
