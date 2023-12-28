@Observed
export default class TaskMenuItem {
  itemContent: string
  bgColor: string
  isSelected: boolean

  constructor(itemContent: string, bgColor: string, isSelected: boolean) {
    this.itemContent = itemContent
    this.bgColor = bgColor
    this.isSelected = isSelected
  }
}