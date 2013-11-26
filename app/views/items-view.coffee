CollectionView = require 'views/base/collection-view'
ItemView = require 'views/item-view'

module.exports = class ItemsView extends CollectionView
  autoRender: true
  renderItems: true
  animationDuration: 0
  itemView: ItemView
  region: 'items'
  tagName: 'div'
  className: 'items'