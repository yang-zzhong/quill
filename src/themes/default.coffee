_     = require('lodash')
_.str = require('underscore.string')


class ScribeDefaultTheme
  @OPTIONS: {}

  constructor: (@scribe, options) ->
    @editor = @scribe.editor
    @editorContainer = @editor.root
    @modules = {}
    _.each(options.modules, (option, name) =>
      this.addModule(name, option)
    )

  addModule: (name, options) ->
    className = _.str.capitalize(_.str.camelize(name))
    moduleClass = @scribe.constructor.Module[className]
    options = {} unless _.isObject(options)  # Allow for addModule('module', true)
    options = _.defaults(options, this.constructor.OPTIONS[name] or {}, moduleClass.DEFAULTS or {})
    @scribe.editor.logger.debug('Initializing module', name, options)
    @modules[name] = new moduleClass(@scribe, @editorContainer, options)
    @scribe.emit(@scribe.constructor.events.MODULE_INIT, name, @modules[name])
    return @modules[name]

  onModuleLoad: (name, callback) ->
    if (@modules[name]) then return callback(@modules[name])
    @scribe.on(@scribe.constructor.events.MODULE_INIT, (moduleName, module) ->
      callback(module) if moduleName == name
    )


module.exports = ScribeDefaultTheme
