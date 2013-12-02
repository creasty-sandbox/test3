
describe 'Tokenizer', ->

  it 'should be defined', ->
    expect(Tokenizer).toBeDefined()


  describe '#getToken', ->

    getTokenizer = (html) ->
      pf = new HtmlPreformatter html
      pf.minify()

      tokenizer = new Tokenizer pf.getHtml()
      tokenizer


    it 'should return tag element and text node tokens', ->
      html = """
        <div id="foo" class="bar">the quick <i>brown</i> fox <img src="img.gif"></div>
      """

      tokens = [
        {
          type: T_TAG_OPEN
          token: '<div id="foo" class="bar">'
          name: 'div'
          attrs: { 'id': 'foo', 'class': 'bar' }
        }
        {
          type: T_TEXT
          token: 'the quick '
        }
        {
          type: T_TAG_OPEN
          token: '<i>'
          name: 'i'
        }
        {
          type: T_TEXT
          token: 'brown'
        }
        {
          type: T_TAG_CLOSE
          token: '</i>'
          name: 'i'
        }
        {
          type: T_TEXT
          token: ' fox '
        }
        {
          type: T_TAG_SELF
          token: '<img src="img.gif">'
          name: 'img'
          attrs: { 'src': 'img.gif' }
        }
        {
          type: T_TAG_CLOSE
          token: '</div>'
          name: 'div'
        }
      ]

      tk = getTokenizer html

      expect(tk.getToken()).toHaveContent token for token in tokens


    describe 'Data bindings', ->

      it 'should return tokens with data binding of attributes', ->
        html = """
          <img class="foo" $src="image.url">
        """
        token =
          type: T_TAG_SELF
          token: '<img $src="image.url">'
          name: 'img'
          attrs: { 'class': 'foo' }
          attrBindings: { 'src': 'image.url' }

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContent token


      it 'should return tokens with data binding of internal variables', ->
        html = """
          <div $model="model"></div>
        """

        token =
          type: T_TAG_OPEN
          token: '<div $model="model">'
          name: 'div'
          bindings: { 'model': 'model' }

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContent token

      it 'should return tokens with data binding of text nodes', ->
        html = """
          the quick brown {{ animal.name }} jumps
        """

        tokens = [
          {
            type: T_TEXT
            token: 'the quick brown '
          }
          {
            type: T_TEXT_INTERP
            token: '{{ animal.name }}'
            textBinding: 'animal.name'
          }
          {
            type: T_TEXT
            token: ' jumps'
          }
        ]

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContent token for token in tokens


