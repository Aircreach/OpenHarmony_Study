import { Driver } from '@ohos.UiTest'
import TaskDto from '../pojo/dto/TaskDto'
import Task from '../pojo/Task'
import { rdbUtil } from '../utils/RDBUtil'

@Component
export struct TaskListItem {
  @State isSelected: boolean = false
  @State isExpand: boolean = false
  @Consume progress: number
  @Link isChecked: boolean
  @ObjectLink taskDto: TaskDto

  aboutToAppear() {
    this.isSelected = (this.taskDto.state == '0') ? false : true
    this.isExpand = (this.taskDto.isExpand == '1')
  }

  build() {
    Column() {
      Row() {

        Text(this.taskDto.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isSelected ? '#ffa7a2a2' : '#ff000000')
          .decoration({type: this.isSelected ? TextDecorationType.LineThrough : TextDecorationType.None, color: '#ffff008f'})
          .maxLines(1).width('90%')

        Checkbox().select(this.isChecked ? true : this.isSelected).width(15).onChange((flag) => {
          this.taskDto.state = flag ? '1' : '0'
          this.isSelected = !this.isSelected
          if (!flag) {
            this.isChecked = false
            this.progress --
          } else {
            this.progress ++
          }
          rdbUtil.updateById <TaskDto> ('Task', this.taskDto.id, this.taskDto)
        })

        Image($r('app.media.expand02')).width(20).rotate({angle: this.isExpand ? 0 : -90}).margin({left: 2})
          .onClick(() => {
            this.isExpand = !this.isExpand
            this.taskDto.isExpand = this.isExpand ? '1' : '0'
            rdbUtil.updateById <TaskDto> ('Task', this.taskDto.id, this.taskDto)
          })

      }.width('95%').height(50).padding(10)

      if (this.isExpand) {
        Text(this.taskDto.content).fontSize(16.5).fontFamily('03').width('90%')
        Text(new Date(this.taskDto.date).toLocaleString()).fontSize(14).fontStyle(FontStyle.Italic).fontColor('#ff835ff5').opacity(0.3).textAlign(TextAlign.End).width('90%')
      }
    }.backgroundColor('#ffff').borderRadius(20).width('100%')
  }
}