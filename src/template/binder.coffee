
class Leaf.Template.Binder

  constructor: (@obj) ->

  getFunction: (expr, vars) ->
    try
      fn = new Function vars..., "return (#{expr})"
      fn.expr = expr
      fn
    catch e
      Leaf.warn 'Syntax error:', expr
      _.noop

  getEvaluator: (fn, vars) ->
    evaluate = =>
      args = vars.map (v) => @obj._get v
      try
        fn.apply @obj, args
      catch e
        Leaf.warn 'Invalid expression:', fn.expr
        return ''

  getBinder: ({ expr, vars }) ->
    value = @getFunction expr, vars

    evaluate = @getEvaluator value, vars

    bind = (routine) =>
      @obj._beginTrack 'getter' unless value._dependents

      result = evaluate()

      if (dependents = @obj._endTrack 'getter')
        value._dependents = dependents
        @obj.observe d, (-> routine evaluate()) for d in dependents

      routine result

  mergeWithScope: (scope, obj = @obj) ->
    withScope = obj.clone()

    _(scope).forEach (value, name) =>
      bind = @getBinder value
      bind (result) -> withScope.set name, result

    withScope

  getScopeObject: (scope) ->
    obj = new Leaf.Observable {}
    @mergeWithScope scope, obj

