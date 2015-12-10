{CompositeDisposable} = require 'atom'
helpers = require('atom-linter')

module.exports =
  config:
    executablePath:
      type: 'string'
      title: 'twig-lint Path'
      default: 'twig-lint'
  activate: ->
    require('atom-package-deps').install()
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-twig.executablePath',
      (executablePath) =>
        @executablePath = executablePath
  deactivate: ->
    @subscriptions.dispose()
  provideLinter: ->
    provider =
      name: 'Twig'
      grammarScopes: ['text.html.twig']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) =>
        filePath = textEditor.getPath()
        command = @executablePath
        text = textEditor.getText()
        parameters = []
        parameters.push('lint')
        parameters.push('--format=csv')
        parameters.push('--only-print-errors')
        return helpers.exec(command, parameters , {stdin: text})
          .then (output) ->
            regex = /(\d+),(.*)/g
            messages = []
            while((match = regex.exec(output)) isnt null)
              messages.push
                type: 'Error'
                filePath: filePath
                range: helpers.rangeFromLineNumber(textEditor, match[1] - 1)
                text: match[2]
            return messages
