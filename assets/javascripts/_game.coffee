class FormulaGame
  constructor: () ->
    @setupBoard()
    @tick = undefined
    @unlocked = ["atrest", "stillatrest"]
    @startProblem("atrest")
    $("#play").click((e) =>
      @run()
    )

  setupBoard: () ->
    @svg = d3.select("#game-container")
      .append("svg:svg")
      .attr("width", 1000)
      .attr("height", 400)

    #svg.append("svg:rect")
      #.attr("x", 380)
      #.attr("y", 0)
      #.attr("height", 400)
      #.attr("width", 200)
      #.attr "fill", "lightyellow"

    #svg.append("svg:rect")
      #.attr("x", 580)
      #.attr("y", 0)
      #.attr("height", 400)
      #.attr("width", 300)
      #.attr "fill", "#C8A2C8"
      
    @svg.append("svg:rect")
      .attr("x", 80)
      .attr("y", 0)
      .attr("height", 400)
      .attr("width", 800)
      .attr "fill", "white"

    @svg.append("svg:rect")
      .attr("x", 10)
      .attr("y", 0)
      .attr("height", 400)
      .attr("width", 30)
      .attr "fill", "gray"

    @svg.append("svg:text")
      .attr("x", 60)
      .attr("y", 203)
      .text("0 m")
      .attr("font-family", "sans-serif")
      .attr("font-size", "10px")
      .attr("fill", "gray")

    @svg.append("svg:line")
      .attr("x1", 80)
      .attr("y1", 200)
      .attr("x2", 880)
      .attr("y2", 200)
      .attr "stroke", "#ddd"


  startProblem: (problemId) ->
    @problem = @getProblem(problemId)

    return unless @problem?
    @score = 0

    #updateScore
    $("#score").text(@score)

    @targetCount = Object.keys(@problem.targets).length

    @svg.selectAll(".target").remove()
    @svg.selectAll(".trail").remove()
    @svg.selectAll(".obstacle").remove()
    highlightedBtn = $("#problems button.btn-primary")
    unless highlightedBtn.id is problemId
      highlightedBtn.removeClass("btn-primary").addClass("btn-default")
      $("#" + problemId).removeClass("btn-default").addClass("btn-primary")

    $("#problem-title").text(@problem.title)
    $("#problem-description").html(markdown.toHTML(@problem.description))

    for time, target of @problem.targets
      t = time / @timePixelRatio()
      #console.log time
      #console.log target
      @svg.append("svg:circle")
        .attr("cx", 80 + parseFloat(t))
        .attr("cy", 200 - (target / @valPixelRatio()))
        .attr("r", 3)
        .attr("class", "target")
        .attr("fill", "orange")

    for time, obstacle of @problem.obstacles
      # lessThan
      t = time / @timePixelRatio()
      @svg.append("svg:line")
        .attr("x1", 80 + parseFloat(t))
        .attr("y1", 200 - obstacle.value)
        .attr("x2", 80 + parseFloat(t))
        .attr("y2", 400)
        .attr("class", "obstacle")
        .attr "stroke", "red"

  run: () ->
    console.log this
    @score = 0
    $("#score").text(@score)
    @svg.selectAll(".trail").remove()

    clearInterval @intervalId if @intervalId?
    @tick = 0

    @intervalId = setInterval(() =>
      @nextTick()
    , 20)
    return false

  nextTick: () ->
    console.log @tick
    unless d3.select("#particle")[0][0]?
      @svg.append("svg:rect")
        .attr("x", 23)
        .attr("y", 200)
        .attr("height", 10)
        .attr("width", 6)
        .attr("id", "particle")
        .attr "fill", "white"

    formula = $("#formula").val()
    convFunc = $("#conversion").val()
    fun = (time) ->
      math.eval(formula, { time: time })
      #Math.sin(time)

    gfun = (time) ->
      h = 0.001
      (-fun(time + 2 * h) + 8 * fun(time + h) - 8 * fun(time - h) + fun(time - 2 * h)) / (12 * h)

    hfun = (time) ->
      h = 0.0001
      (-fun(time + 2 * h) + 16 * fun(time + h) - 30 * fun(time) + 16 * fun(time - h) - fun(time - 2 * h)) / (12 * h * h)

    time = @tick * @timePixelRatio()
    d = fun(math.eval(convFunc, {time: time}))
    v = gfun(math.eval(convFunc, {time: time}))
    a = hfun(math.eval(convFunc, {time: time}))
    h = d
    #if ii < 300
      #h = d * 50
    #else if ii < 500
      #h = v * 50
    #else
      #h = a * 50

    $("#time").text("#{Math.round(time * 1000)/1000} s")
    $("#distance").text("#{Math.round(d * 1000)/1000} m")
    $("#velocity").text("#{Math.round(v * 1000)/1000} m/s")
    $("#acceleration").html("#{Math.round(a * 1000)/1000} m/s<sup>2</sup>")
    #console.log h if ii % 25 is 0

    checkPoint = @problem.targets[@tick * @timePixelRatio()]
    obstacle = @problem.obstacles[@tick * @timePixelRatio()]
    #if checkPoint?

    if isFinite(h)
      trail = @svg.append("svg:circle")
        .attr("cx", 80 + @tick)
        .attr("cy", 200 - (h / @valPixelRatio()))
        .attr("r", ((if checkPoint? then 2 else 0.5)))
        .attr("class", "trail")

      if checkPoint?
        if Math.abs(h - checkPoint) > 0.0001
          trail.attr("fill", "red")
          clearInterval @intervalId
        else
          @score++
          $("#score").text(@score)
          if @score is @targetCount
            clearInterval @intervalId
      if obstacle?
        if obstacle.value > h
          trail.attr("fill", "red")
            .attr("r", 1)
          clearInterval @intervalId

      d3.select("#particle").attr("y", 195 - d / @valPixelRatio())
    else
      d3.select("#particle").remove()

    @tick++
    clearInterval @intervalId if @tick >= 800
    return

  getProblem: (problemId) ->
    problem = null
    for p in window.Problems
      if p.id is problemId
        problem = p
    problem

  timePixelRatio: () ->
    @problem.board.timePixelRatio

  valPixelRatio: () ->
    0.01

window.game = new FormulaGame()
#GameState =
  #getProblem: ->
    #getProblem(this.selected)

#startProblem = (problemId) ->
  #problem = getProblem(problemId)
  #return unless problem?
  #GameState.selected = problemId
  #GameState.score = 0
  #$("#score").text(GameState.score)
  #GameState.targetCount = Object.keys(problem.targets).length

  #svg.selectAll(".target").remove()
  #svg.selectAll(".trail").remove()
  #svg.selectAll(".obstacle").remove()
  #highlightedBtn = $("#problems button.btn-primary")
  #unless highlightedBtn.id is problemId
    #highlightedBtn.removeClass("btn-primary").addClass("btn-default")
    #$("#" + problemId).removeClass("btn-default").addClass("btn-primary")

  #$("#problem-title").text(problem.title)
  #$("#problem-description").html(markdown.toHTML(problem.description))

  #for time, target of problem.targets
    ##console.log time
    ##console.log target
    #svg.append("svg:circle")
      #.attr("cx", 80 + parseFloat(time))
      #.attr("cy", 200 - (target))
      #.attr("r", 3)
      #.attr("class", "target")
      #.attr("fill", "orange")

  #for time, obstacle of problem.obstacles
    #svg.append("svg:line")
      #.attr("x1", 80 + parseFloat(time))
      #.attr("y1", 200 - obstacle.value)
      #.attr("x2", 80 + parseFloat(time))
      #.attr("y2", 400)
      #.attr("class", "obstacle")
      #.attr "stroke", "red"

#for problem in window.Problems
  #button = $("<button class='btn' id='#{problem.id}'></button>")
  #unless $.inArray(problem.id, GameState.unlocked) is -1
    #button.text(problem.title)
    #if GameState.selected is problem.id
      #button.addClass("btn-primary")
      #startProblem(problem.id)
    #else
      #button.addClass("btn-default")
    #do(btn = button, p = problem) ->
      #btn.click( ->
        #startProblem(p.id)
      #)
  #else
    #button.text(problem.title.replace(/./g, "X"))
    #button.addClass("disabled")
    
  #$("#problems").append button
  #$("#problems").append " "

