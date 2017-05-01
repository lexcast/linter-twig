{CompositeDisposable} = require 'atom'
helpers = require('atom-linter')

module.exports =
  config:
    executablePath:
      type: 'string'
      title: 'twig-lint Path'
      default: 'twig-lint'

  activate: ->
    requestIdleCallback ->
      require('atom-package-deps').install('linter-twig')

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-twig.executablePath',
      (executablePath) =>
        @executablePath = executablePath

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    linter =
      name: 'Twig'
      grammarScopes: ['text.html.twig']
      scope: 'file'
      lintsOnChange: true
      lint: (textEditor) =>
        filePath = textEditor.getPath()
        command = @executablePath
        text = textEditor.getText()
        parameters = []
        parameters.push('lint')
        parameters.push('--format=csv')
        parameters.push('--only-print-errors')
        return helpers.exec(command, parameters, {stdin: text, ignoreExitCode: true})
          .then (output) ->
            regex = /(\d+),(.*)/g
            messages = []
            while((match = regex.exec(output)) isnt null)
              messages.push
                severity: 'error'
                location:
                  file: filePath
                  position: helpers.generateRange(textEditor, match[1] - 1)
                excerpt: match[2]
            return messages
