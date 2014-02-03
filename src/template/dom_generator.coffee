
#  Errors
#-----------------------------------------------
class UndefinedCustomTagError extends Leaf.Error


#  Generator
#-----------------------------------------------
class Leaf.Template.DOMGenerator

  doc = document # copying global variable to local make js faster

  { customTags } = Leaf.Template

  constructor: ->

  init: (@tree, @obj) ->
    unless @tree
      throw new RequiredArgumentsError('tree')

    unless @obj
      throw new RequiredArgumentsError('obj')

    @binder = new Leaf.Template.Binder @obj
    @$parent = $ doc.createElement 'body'

  getBinder: (value) ->
    @binder.getBinder value, @obj

  bindAttributes: ($el, attrs) ->
    name = $el.get(0).nodeName.toLowerCase()

    _(attrs).forEach (val, key) =>
      bind = @getBinder val

      if 'value' == key && 'option' != name
        user = false

        bind (result) ->
          $el.val result unless user
          user = false
          null

        $el.data 'value-evaluator', bind.evaluate

        $el.on 'change keyup keydown keypress', =>
          user = true
          @obj.set val.expr, $el.val()
      else
        if 'option' == name
          $(document).on 'viewDidRender', -> # TODO: document is bad
            $select = $el.parent()

            if $select.length
              evaluate = $select.data 'value-evaluator'
              $el.prop 'selected', (evaluate() == bind.evaluate())

        bind (result) -> $el.attr key, result

  bindLocales: ($el, attrs) ->
    bindingObj = @binder.getBindingObject attrs

    $el.data 'leaf-locale', bindingObj

  registerActions: ($el, actions) ->
    _(actions).forEach (handler, event) ->
      $el.on event, (e) -> $el.trigger handler, [e]

    null

  createMarker: (node, closing) ->
    if Leaf.develop
      if node.type == T_INTERPOLATION
        $ doc.createComment "= '#{node.value.expr}'"
      else
        $ doc.createComment "<#{(if closing then '/' else '')}#{node.name}:#{node._nodeID}>"
    else
      $ doc.createTextNode ''

  createElement: (node, $parent) ->
    c = customTags.def[node.name]

    if node.customTag && !c
      throw new UndefinedCustomTagError "<#{node.name}>"

    c ?= {}

    if c.structure
      $begin = @createMarker node
      $begin.appendTo $parent

      $marker = @createMarker node, true
      $marker.appendTo $parent
      c.create? node, $marker, $parent, @obj

      return

    $el = $ doc.createElement node.name

    $el.attr node.attrs
    @bindAttributes $el, node.attrBindings
    @bindLocales $el, node.localeBindings
    @registerActions $el, node.actions

    $el.appendTo $parent

    if c.block
      $begin = @createMarker node
      $begin.appendTo $parent

      c.create? node, $el, $parent, @obj
    else
      @createNode $el, node.contents

  createTextNode: (node, $parent) ->
    $text = $ doc.createTextNode _.unescape(node.buffer)
    $text.appendTo $parent

  createInterpolationNode: (node, $parent) ->
    bind = @getBinder node.value

    $marker = @createMarker node
    $marker.appendTo $parent

    if node.escape
      el = doc.createTextNode ''
      $el = $ el
      $el.appendTo $parent

      bind (result) -> el.nodeValue = result
    else
      $el = null

      bind (result) ->
        if $el
          $el.remove()
          $el = null

        $el = $ $.parseHTML result
        $el.insertAfter $marker

  createNode: ($parent, node) ->
    if _.isArray node
      @createNode $parent, n for n in node
      return

    switch node.type
      when T_TAG_OPEN
        @createElement node, $parent
      when T_TAG_SELF
        @createElement node, $parent
      when T_TEXT
        @createTextNode node, $parent
      when T_INTERPOLATION
        @createInterpolationNode node, $parent

  getDOM: ->
    return @dom if @dom
    @createNode @$parent, @tree
    @dom = @$parent.contents()

