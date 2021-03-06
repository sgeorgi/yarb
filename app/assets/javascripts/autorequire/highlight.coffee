
jQuery ->

  # Execute higlight.js for all pre-elements.
  # Adjusts output from JS to fit our domain.

  $(document).ready ->
    $('pre').each ->
      new CodeHighlighter( $(this) )


# Writting Markdown:
#   ```ruby
#     ...
#   ```
# Results in:
#   <pre lang='ruby'>
#     <code lang='something set by github-markdown'>
#   # But for Highlight.js we need this:
#   <pre>
#     <code class='ruby'>
class @CodeHighlighter

  constructor: (element) ->
    if element.children().length > 0
      @element = element
      @code    = element.children().first()
      if @code[0].localName ==  'code'
        @getLangFromSurroundingPre()
        @highlight()
        @removeLangFromSurroundingPre()

  getLangFromSurroundingPre:  =>
    @lang = @element[0].lang

  removeLangFromSurroundingPre:  =>
    @element.parent().attr('lang', null )

  highlight: =>
    @code.addClass(@lang)
    _hl = hljs.highlightAuto(@code.text())
    @code[0].innerHTML = _hl.value

