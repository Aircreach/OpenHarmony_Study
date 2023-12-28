@Observed
export default class Task {
  title: string
  content: string
  date: string
  reminderId: number = -1
  state: boolean | string = false
  isExpand: boolean | string = false

  constructor(title : string , content : string , date : string, reminderId ?: number, state ?: boolean | string) {
    this.title = title
    this.content = content
    this.date = date
    if (reminderId) {
      this.reminderId = reminderId
    }
    if (state) {
      this.state = state
    }
  }
}