{Emitter, Disposable, CompositeDisposable, File} = require 'atom'
# {$, $$$, ScrollView} = require 'atom-space-pen-views'
{ScrollView} = require 'atom-space-pen-views'
{TextEditorView} = require 'atom-space-pen-views'


module.exports =
class TasksCalendarView extends ScrollView
  calFiles: null
  @content: ->
    @div =>
      @div "calendar Files: #{@calFiles}"
      @subview 'answer', new TextEditorView(mini: true)
      @button "ok"

  constructor: ({@editorId, @filePath}) ->
    super
    @emitter = new Emitter
    @disposables = new CompositeDisposable
    @loaded = false
    @calFiles = atom.config.get('tasks-calendar.calendarFiles') ? []
    console.log @calFiles

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('wordcount')

    # Create message element
    message = document.createElement('div')
    message.textContent = "file path: #{@calFiles}!"
    message.classList.add('message')
    @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    # @element.remove()

  getElement: ->
    # @element

  getTitle: ->
      "TasksCalendar Preview"
