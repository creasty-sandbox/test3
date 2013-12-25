
#  Component
#-----------------------------------------------
class Leaf.Component

  @components: {}

  @regulateName: (name) ->
    return '' unless name

    name
    .replace(/([a-z])([A-Z])/g, ((_0, _1, _2) -> "#{_1}-#{_2.toLowerCase()}"))
    .replace(/\//g, ':')
    .replace(/[^a-z\-:]/ig, '')
    .replace(/\-*:+\-*/g, ':')
    .replace(/\-+/g, '-')
    .replace(/^(\-|:)|(\-|:)$/g, '')
    .replace(/^component:/, '')

  @register: (name, node) ->
    name = @regulateName name
    Leaf.Component.components[name] = node.contents
    Leaf.Template.registerTag "component:#{name}", ComponentView

  @get: (name) ->
    name = @regulateName name
    Leaf.Component.components[name]

  @unregister: (name) ->
    name = @regulateName name
    @components[name] = undefined
    Leaf.Template.unregisterTag "component:#{name}"

  @reset: ->
    @unregister name for name in _.keys(@components)


#  Error
#-----------------------------------------------
class NoNameAttributeWithComponentTagError extends Leaf.Error
class UndefinedComponentTagError extends Leaf.Error


#  Component view
#-----------------------------------------------
class ComponentView

  @structure: true

  @create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()

    binder = new Leaf.Template.Binder obj
    withScope = binder.getScopeObject node.localeBindings
    tree = Leaf.Component.get node.name

    unless tree
      throw new UndefinedComponentTagError "<#{node.name}>"

    view.init tree, withScope

    $el = view.getDOM()
    $el.appendTo $parent


#  Component def tag
#-----------------------------------------------
Leaf.Template.registerTag 'component',
  structure: true

  open: (node, parent) ->
    { name } = node.attrs

    unless name
      throw new NoNameAttributeWithComponentTagError()

    Leaf.Component.register name, node

