
class StringSupport

  pluralize: (str, count, withNumber) ->
    Leaf.Inflector.pluralize str, count, withNumber

  singularize: (str) ->
    Leaf.Inflector.singularize str

  camelize: (str, lowFirstLetter = false) ->
    str = str.replace /_([a-z])/g, (_, c) -> c.toUpperCase()
    str = @capitalize str unless lowFirstLetter
    str

  underscore: (str) ->
    str
    .replace(/\-+/g, '_')
    .replace /([a-z])([A-Z])/g, (_, l, r) ->
      "#{l}_#{r.toLowerCase()}"

  humanize: (str, lowFirstLetter = false) ->
    str = str.toLowerCase()
    str = str
      .replace(/(_ids|_id)$/g, '')
      .replace(/_/g, ' ')
    str = @capitalize str unless lowFirstLetter
    str

  capitalize: (str, lowOtherLetter = false) ->
    other = str[1..]
    other = other.toLowerCase() if lowOtherLetter
    str[0].toUpperCase() + other

  dasherize: (str) ->
    str.replace /[_\s]+/g, '-'

  NON_TITLECASED_WORDS = [
    'and', 'or', 'nor', 'a', 'an', 'the', 'so', 'but', 'to', 'of', 'at',
    'by', 'from', 'into', 'on', 'onto', 'off', 'out', 'in', 'over',
    'with', 'for'
  ]
  titleize: (str) ->
    str = @humanize str
    str = str.replace /\b[a-z]+\b/g, (word) ->
      if word in NON_TITLECASED_WORDS
        word
      else
        @capitalize word

  tableize: (str) ->
    @pluralize @underscore(str)

  classify: (str) ->
    @singularize @camelize(@underscore(str))

  foreignKey: (str, withUnderscore = true) ->
    @singularize(@underscore(str)) + ('_' if withUnderscore) + 'id'

  ordinalize: (str) ->
    str.replace /\b\d+\b/g, (num) ->
      Leaf.Support.Number.ordinalize parseInt(num)


Leaf.Support.add StringSupport

