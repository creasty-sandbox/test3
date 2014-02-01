
#  Error
#-----------------------------------------------
class NoIteratorBindingsError extends Leaf.Error
class NonIteratableObjectError extends Leaf.Error

  setMessage: (iterator, obj) ->
    "`#{iterator}` is #{Object::toString.call obj}"


#  Iterator
#-----------------------------------------------
class IteratorView extends Leaf.Object

  @structure: true

  @open: (node, parent) ->
    node.iterator = null

    for key, value of node.localeBindings when value.expr.match /\w+\[\]$/
      value.expr = value.expr.replace '[]', ''
      node.iterator = key
      break

    unless node.iterator
      throw new NoIteratorBindingsError()

  @create: (node, $marker, $parent, obj) ->
    iv = new IteratorView()
    iv.init node, $marker, $parent, obj

  init: (@node, @$marker, @$parent, @obj) ->
    @collectionViews = new Leaf.ObservableArray()

    binder = new Leaf.Template.Binder @obj
    bindingObj = binder.getBindingObject @node.localeBindings

    @collection = bindingObj.get @node.iterator

    unless @collection instanceof Leaf.ObservableArray
      throw new NonIteratableObjectError @node.iterator, @collection

    @collection.forEach @addOne
    @collection.observe @update

  addOne: (item) =>
    view = @createView item
    view.$view.insertBefore @$marker
    @collectionViews.push view

  createView: (item) ->
    id = "#{@node._nodeID}:#{item._observableID}"

    IteratorItemView.findOrCreate id, (klass) =>
      scope = @obj.delegatedClone()
      scope.set @node.iterator, item, overrideDelegate: true

      new klass
        tree: @node.contents
        obj: scope
      ,
        model: item
        collection: @collection

  update: =>
    @applyPatch @collection.getPatch()

  applyPatch: (patch) ->
    for p in patch
      switch p.method
        when 'insertAt'
          view = @createView p.element
          $idx = @collectionViews[p.index]?.$view ? @$marker
          view.$view.insertBefore $idx
          @collectionViews.insertAt p.index, [view]
        when 'removeAt'
          if (cv = @collectionViews[p.index])
            cv.detach()
            @collectionViews.removeAt p.index


#  Iterator item
#-----------------------------------------------
class IteratorItemView extends Leaf.View


#  Registeration
#-----------------------------------------------
Leaf.Template.registerTag 'each', IteratorView

