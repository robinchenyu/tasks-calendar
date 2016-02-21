url = require 'url'

TasksCalendarView = require './tasks-calendar-view'
{CompositeDisposable} = require 'atom'

createTasksCalendarView = (state) ->
  TasksCalendarView ?= require './tasks-calendar-view'
  new TasksCalendarView(state)

isTasksCalendarView = (object) ->
  TasksCalendarView ?= require './tasks-preview-view'
  object instanceof TasksCalendarView

module.exports =
  config:
    liveUpdate:
      type: 'boolean'
      default: true
      description: 'Re-render the preview as the contents of the source changes.'
    calendarFiles:
      type: 'array'
      default:
        [
          '~/blogs/work.todo'
        ]
      description: 'files to be parsed for calendar views'

  tasksCalendarView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # @tasksCalendarView = new TasksCalendarView(state.tasksCalendarViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @tasksCalendarView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'tasks-calendar:toggle': => @toggle()

    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
        console.log "protocol, host, pathname is #{protocol} #{host} #{pathname}"
      catch error
        return

      console.log "protocol: #{protocol}" 
      return unless protocol is 'tasks-calendar:'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
        createTasksCalendarView(editorId: pathname.substring(1))
      else
        createTasksCalendarView(filePath: pathname)

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @tasksCalendarView.destroy()

  uriForEditor: (editor) ->
    "tasks-calendar://editor/#{editor.id}"

  removePreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    previewPane = atom.workspace.paneForURI(uri)
    if previewPane?
      previewPane.destroyItem(previewPane.itemForURI(uri))
      true
    else
      false

  addPreviewForEditor: (editor) ->
    if !isTasksCalendarView(editor)
      console.log editor
      # return
    uri = @uriForEditor(editor)
    previousActivePane = atom.workspace.getActivePane()
    options =
      searchAllPanes: true
    # if atom.config.get('tasks-calendar.openPreviewInSplitPane')
    options.split = 'right'
    atom.workspace.open(uri, options).then (tasksCalendarView) ->
      console.log tasksCalendarView
      previousActivePane.activate()

  serialize: ->
    tasksCalendarViewState: @tasksCalendarView.serialize()

  toggle: ->
    liveUpdate = atom.config.get('tasks-calendar.liveUpdate') ? []

    console.log "TasksCalendar was toggled! liveUpdate = #{liveUpdate}"
    edt = atom.workspace.getActiveTextEditor()
    @addPreviewForEditor(edt)
    # console.log edt
    # console.log edt.id
    # edt.insertText( "Hello World!~~~")
    # console.log edt.getText()
    # console.log "first 3 lines \n" + edt.getTextInBufferRange([[0,1], [3, 1]])
    # console.log "lines #{edt.getScreenLineCount()}/#{edt.getLineCount()}"
    #
    # i = 0
    # while i < edt.getLineCount()
    #   # console.log "ll: #{i}"
    #   i += 1
    #   console.log "line: #{i} is #{cnt} " if cnt = edt.lineTextForBufferRow(i)
    #
    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()
