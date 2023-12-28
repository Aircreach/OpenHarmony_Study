import TaskDto from '../pojo/dto/TaskDto'

@Component
export struct TaskProgress {

  @Consume arr: TaskDto[]
  @Consume progress: number

  // getProgress() : number {
  //   let num: number = 0
  //   for (let item of this.arr) {
  //     if (item.state == '1') {
  //       num++
  //     }
  //   }
  //   return num
  // }

  build() {
    Stack() {
      Progress({value: this.progress, total: this.arr.length, type: ProgressType.Ring})
        .width(100)
        .color('#ff60b1e9')
        .backgroundColor('#ffe75b82')
        .style({status: ProgressStatus.PROGRESSING, enableSmoothEffect: true})

      Text() {
        Span(this.progress.toString())
        Span('/')
        Span(this.arr.length.toString())
      }.fontSize(25)
    }
  }
}