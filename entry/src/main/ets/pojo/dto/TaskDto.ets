import Task from '../Task'

@Observed
export default class TaskDto extends Task {
  id: number

  constructor(id: number, title : string , content : string , date : string, reminderId ?: number, state ?: boolean | string) {



    super(title, content, date, (reminderId ? reminderId : -1))
    this.id = id
    this.title = title
    this.content = content
    this.date = date
    if (state) {
      this.state = state
    }
  }
}