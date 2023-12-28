import font from '@ohos.font'
import relationalStore from '@ohos.data.relationalStore'
import { AddTaskDialog, EditTaskDialog } from '../component/TaskDialog'
import { TaskListItem } from '../component/TaskListItem'
import { TaskProgress } from '../component/TaskProgress'
import { rdbUtil } from '../utils/RDBUtil'
import TaskDto from '../pojo/dto/TaskDto'
import TaskMenuItem from '../pojo/TaskMenuItem'
import router from '@ohos.router'
import { taskReminderService } from '../service/TaskReminderService'

@Entry
@Component
struct TaskPage {
  @Provide arr: TaskDto[] = []
  @Provide progress: number = 0
  @State index: number = -1
  @State isChecked: boolean = false
  @State menuItems: TaskMenuItem[] = [new TaskMenuItem('全部', '#ffffd88b', true), new TaskMenuItem('待完成', '#ffff', false), new TaskMenuItem('已完成', '#ffff', false)]
  @State menuIndex: number = 0
  addTaskDialogController: CustomDialogController = new CustomDialogController({
    builder: AddTaskDialog()
  })
  editTaskDialogController: CustomDialogController = new CustomDialogController({
    builder: EditTaskDialog({index: this.index})
  })

  build() {
    Column() {
      Row() {
        Text('任务进度:').fontSize(30).fontWeight(FontWeight.Bold).fontFamily('02').margin({ left: 10 })
        TaskProgress().margin({ right: 40 }).id('TaskProgress')
      }
      .backgroundColor('#ffff')
      .borderRadius(20)
      .width('90%')
      .height('20%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20 })

      Row() {
        Button('添加任务').margin({ left: 10 })
          .onClick(() => {
            this.addTaskDialogController.open()
          })
        Text('全选').fontSize(17).fontWeight(FontWeight.Bold).margin({ left: '45%' })
        Checkbox().width(15).onChange((flag: boolean) => {
          this.isChecked = flag
        })
        Image($r('app.media.screen')).width(30).bindMenu(this.filter_Menu())
      }.width('90%').height('5%').margin({ top: 20 })

      List({ space: 10 }) {
        ForEach(this.arr, (item: TaskDto, index: number) => {
          ListItem() {
            TaskListItem({ taskDto: this.arr[index], isChecked: this.isChecked})
          }.swipeAction({
            start: {
              builder: this.taskListItem_Menu(index)
            }
          })
        })
      }.width('90%').height('65%').margin({ top: 20 })

    }.width('100%').backgroundColor('#ffe9e6e6').justifyContent(FlexAlign.Center)
  }

  // 生命周期 初始化数据
  async aboutToAppear() {
    // 注册字体
    font.registerFont({
      familyName: '01',
      familySrc: $rawfile('font/media.ttf')
    })
    font.registerFont({
      familyName: '02',
      familySrc: $rawfile('font/02.ttf')
    })
    font.registerFont({
      familyName: '03',
      familySrc: $rawfile('font/YanZhenQingDuoBaoTaBei-2.ttf')
    })
    await rdbUtil.createRDB('Task').then((rdb) => {
      rdb.executeSql('create table if not exists Task(id integer primary key autoincrement, title string, content string, date string, reminderId integer, state boolean, isExpand boolean)')
    })
    let pre = new relationalStore.RdbPredicates('Task')
    this.arr = await rdbUtil.queryArray <TaskDto> (pre)
    this.progress = this.getProgress()
  }

  // 获取数据
  getData() {
    let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('Task')
    switch (this.menuIndex) {
      case 0:
        predicates.orderByAsc('state').orderByDesc('id')
        rdbUtil.queryArray <TaskDto> (predicates).then((value: TaskDto[]) => {
          this.arr = value
        })
        return
      case 1:
        predicates.equalTo('state', '0')
        rdbUtil.queryArray <TaskDto> (predicates).then((value: TaskDto[]) => {
          this.arr = value
        })
        return
      case 2:
        predicates.equalTo('state', '1')
        rdbUtil.queryArray <TaskDto> (predicates).then((value: TaskDto[]) => {
          this.arr = value
        })
        return
    }
  }

  // 获取当前完成任务数
  getProgress() : number {
    let num: number = 0
    for (let item of this.arr) {
      if (item.state == '1') {
        num++
      }
    }
    return num
  }

  // 自定义组件 ListItemMenu
  @Builder taskListItem_Menu(index: number) {
    Row({space: 2}) {
      Image($r('app.media.edit03')).width(30).onClick(() => {
        this.index = index
        this.editTaskDialogController.open()
        // router.pushUrl({
        //   url: 'pages/DetailsPage',
        //   params: this.arr[index]
        // }).then(() => {
        //   this.getData()
        // })
      })
      Image($r('app.media.delete03')).width(30).onClick(() => {
        rdbUtil.deleteById('Task', this.arr[index].id)
        // taskReminderService
        this.getData()
      })
    }.width(65)
  }

  // 自定义组件 过滤菜单
  @Builder filter_Menu() {
    Menu() {
      ForEach(this.menuItems, (item: TaskMenuItem, index: number) => {
        MenuItem({content: item.itemContent}).selected(item.isSelected).backgroundColor(item.isSelected ? '#ffffd88b' : '#ffff').onClick(() => {
          this.menuItems.forEach((it: TaskMenuItem, i: number) => {
            if (i == index) {
              it.isSelected = true
            } else {
              it.isSelected = false
            }
          })
          this.menuIndex = index
          this.getData()
        })
      })
    }
  }
}