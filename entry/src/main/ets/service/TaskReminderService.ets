
import reminderAgentManager from '@ohos.reminderAgentManager'
import { BusinessError, Callback } from '@ohos.base'

const TAG = '[TaskReminderService]'
export class TaskReminderService {

  reminderRequest: reminderAgentManager.ReminderRequest = {
    reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,

    title: 'Task',
    content: 'dsvvnhdsf',
  }

  timer: reminderAgentManager.ReminderRequestCalendar = {
    reminderType: 1,
    actionButton: [
      {title: '忽略', type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE},
      {title: '延时', type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_SNOOZE}
    ],
    title: '[Task]',
    dateTime: this.str2DateTime(new Date().toLocaleString())
  }

  init (id: number, content: string, dateTime: string) {
    this.timer.notificationId = id
    this.timer.content  = content
    this.timer.dateTime = this.str2DateTime(dateTime)
  }

  publish (callback: Callback<number>) {
    try {
      reminderAgentManager.publishReminder(this.timer, (err: BusinessError, reminderId: number) => {
        if (err) {
          console.error(TAG, `  (publish) ERROR => ${JSON.stringify(err)}`)
        } else {
          console.info(TAG, `  (publish) SUCCESS => ${reminderId}`)
          callback(reminderId)
        }
      })
    } catch (error) {
      console.error(TAG, `  (publish) ERROR => ${JSON.stringify(error as BusinessError)}`)
    }
  }

  cancel(id: number) {
    reminderAgentManager.getValidReminders()
  }

  private str2DateTime(str: string): reminderAgentManager.LocalDateTime {
    let date = new Date(str)
    let datetime: reminderAgentManager.LocalDateTime = {
      year: date.getFullYear(),
      // 注意: getMonth 返回 => month - 1
      month: date.getMonth() + 1,
      day: date.getDate(),
      hour: date.getHours(),
      minute: date.getMinutes(),
      second: date.getSeconds()
    }
    return datetime
  }

}
export let taskReminderService = new TaskReminderService()