class Resources
  constructor: (@canvas) ->
    @resources = {}
    @bboxes = {}

  attachTo: (snapElement) ->
    @resourceGroup = snapElement.group().attr(display: 'none')

  copyIDsFrom: (snapElement, ids...) ->
    for id in ids
      node = snapElement.select("##{id}")
      node.transform('')
      @resourceGroup.append(node)
      @resources[id] = node

  clone: (id) ->
    @resources[id].use()

  copy: (id) ->
    @resources[id].clone()

  bbox: (id) ->
    @bboxes[id] ||= @resources[id].getBBox()

module.exports = Resources

