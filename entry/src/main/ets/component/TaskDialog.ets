import TaskDto from '../pojo/dto/TaskDto'
import Task from '../pojo/Task'
import { taskReminderService, TaskReminderService } from '../service/TaskReminderService'
import { rdbUtil } from '../utils/RDBUtil'

// 添加弹窗
@CustomDialog
export struct AddTaskDialog {
  @State dialogSize: number = 200
  @State areaSize: number = 100
  @State isExpand: boolean = false
  @Consume arr: TaskDto[]

  addTaskDialogController: CustomDialogController
  title: string = ''
  content: string = ''
  date: Date = new Date()

  build() {
    Column() {
      Row() {
        Image($r('app.media.expand01'))
          .width(15)
          .onClick(() => {
            if (this.isExpand) {
              animateTo({ duration: 400, curve: Curve.Linear }, () => {
                this.dialogSize = 200
                this.areaSize = 100
              })
              this.isExpand = !this.isExpand
            } else {
              animateTo({ duration: 400, curve: Curve.Linear }, () => {
                this.dialogSize = 420
                this.areaSize = 200
              })
              this.isExpand = !this.isExpand
            }
          })
      }.justifyContent(FlexAlign.End).width('90%').height(15).margin({top: 5})

      if (this.isExpand) {
        TextInput({text: this.title, placeholder: '请输入标题'}).height(40).width('90%').margin({top: '3%'})
          .onChange((value: string) => {
            this.title = value
          })
      }

      TextArea({text: this.content, placeholder: '请输入任务内容'}).height(this.areaSize).width('90%').margin({top: '3%'})
        .onChange((value: string) => {
          this.content = value
        })
      if (this.isExpand)  {
        Button('设置提醒日期', {type: ButtonType.Normal}).height(40).margin({top: 20}).backgroundColor('#ff48cdc1').onClick(() => {
          DatePickerDialog.show({
            start: new Date("2000-1-1"),
            end: new Date("2100-12-31"),
            selected: this.date,
            showTime:true,
            useMilitaryTime:false,
            disappearTextStyle: {color: '#ffbfbfbf', font: {size: '22fp', weight: FontWeight.Bold}},
            textStyle: {color: '#ffbfbfbf', font: {size: '18fp', weight: FontWeight.Normal}},
            selectedTextStyle: {color: '#ff583db7', font: {size: '14fp', weight: FontWeight.Regular}},
            onDateAccept: (date: Date) => {
              this.date = date
              console.log(this.date.toString());
            }
          })
        })
      }
      Row() {
        // 取消Button
        Button('cancel').onClick(() => {
          AlertDialog.show({
            title: '警告',
            message: '取消将丢失所有内容',
            autoCancel: false,
            alignment: DialogAlignment.Center,
            primaryButton: {
              value: '取消',
              action: () => {}
            },
            secondaryButton: {
              value: '确认',
              action: () => {
                this.addTaskDialogController.close()
              }
            }
          })
        })
        // 确认Button 插入数据到RDB
        Button('confirm').onClick(() => {
          let task: Task
          task = this.isExpand ? new Task(this.title, this.content, this.date.toString()) : new Task('Task未命名' , this.content, new Date().toString())
          console.log(JSON.stringify(task))
          rdbUtil.insert <Task> ('Task', task).then(async (num) => {
            let taskDto = await rdbUtil.queryById <TaskDto> ('Task', num)
            this.arr.push(taskDto)
            // 相同 notificationID 的通知会覆盖
            taskReminderService.init(taskDto.id, taskDto.title, taskDto.date)
            taskReminderService.publish((reminderId: number) => {
              task.reminderId = reminderId
              rdbUtil.updateById <Task> ('Task', taskDto.id, task)
            })
          })
          this.addTaskDialogController.close()
        })
      }
      .width('80%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({top: 15})
    }
    .height(this.dialogSize)
    .justifyContent(FlexAlign.Start)
  }
}

// 编辑弹窗
@CustomDialog
export struct EditTaskDialog {

  @Consume arr: TaskDto[]
  @Prop index: number = -1
  @State title: string = ''
  @State content: string = ''
  @State date: Date = new Date()

  editTaskDialogController : CustomDialogController
  aboutToAppear() {
    let taskDto: TaskDto = this.arr[this.index]
    this.title = taskDto.title
    this.content = taskDto.content
    this.date = new Date(taskDto.date)
  }

  build() {
    Column() {
      TextInput({text: this.title, placeholder: '请输入标题'}).height(40).width('90%').margin({top: '3%'})
        .onChange((value: string) => {
          this.title = value
        })
      TextArea({text: this.content, placeholder: '请输入任务内容'}).height(200).width('90%').margin({top: '3%'})
        .onChange((value: string) => {
          this.content = value
        })
      Button('设置提醒日期', {type: ButtonType.Normal}).height(40).margin({top: 20}).backgroundColor('#ff48cdc1').onClick(() => {
        DatePickerDialog.show({
          start: new Date("2000-1-1"),
          end: new Date("2100-12-31"),
          selected: this.date,
          showTime:true,
          useMilitaryTime:false,
          disappearTextStyle: {color: '#ffbfbfbf', font: {size: '22fp', weight: FontWeight.Bold}},
          textStyle: {color: '#ffbfbfbf', font: {size: '18fp', weight: FontWeight.Normal}},
          selectedTextStyle: {color: '#ff583db7', font: {size: '14fp', weight: FontWeight.Regular}},
          onDateAccept: (date: Date) => {
            this.date = date
          }
        })
      })

      Row() {
        // 取消Button
        Button('cancel').onClick(() => {
          AlertDialog.show({
            title: '警告',
            message: '取消将丢失所有内容',
            autoCancel: false,
            alignment: DialogAlignment.Center,
            primaryButton: {
              value: '取消',
              action: () => {}
            },
            secondaryButton: {
              value: '确认',
              action: () => {
                this.editTaskDialogController.close()
              }
            }
          })
        })
        // 确认Button 更新数据到RDB
        Button('confirm').onClick(() => {
          let task: Task = new Task(this.title, this.content, this.date.toString())
          let id: number = this.arr[this.index].id
          rdbUtil.updateById <Task> ('Task', id, task).then(async (num) => {
            let taskDto = await rdbUtil.queryById <TaskDto> ('Task', id)
            this.arr[this.index] = taskDto
            // 相同 notificationID 的通知会覆盖
            taskReminderService.init(taskDto.id, taskDto.title, taskDto.date)
            taskReminderService.publish((reminderId: number) => {
              task.reminderId = reminderId
              rdbUtil.updateById <Task> ('Task', taskDto.id, task)
            })
          })
          this.editTaskDialogController.close()
        })
      }
      .width('80%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({top: 15})
    }
    .height(420)
    .justifyContent(FlexAlign.Start)
  }
}