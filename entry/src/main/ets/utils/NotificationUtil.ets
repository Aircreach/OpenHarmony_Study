import notificationManager from '@ohos.notificationManager';
import { WantAgent } from '@ohos.wantAgent';
import image from '@ohos.multimedia.image';


const TAG: string = '[NotificationUtil]'



class NotificationUtil {
  private isPromptTone: boolean = false
  private isVibrationEffect: boolean = false
  private promptToneSrc: string = 'file:///system/etc/capture.ogg'

  promptTone(flag: boolean = this.isPromptTone, promptToneSrc: string): boolean {
    this.isPromptTone = flag
    if (promptToneSrc) {
      this.promptToneSrc = promptToneSrc
    }
    return this.isPromptTone
  }

  vibrationEffect(flag: boolean = this.isVibrationEffect): boolean {
    this.isVibrationEffect = flag
    return this.isVibrationEffect
  }

  /**
   * 使能通知开关
   */
  async enableNotification() {
    try {
      await notificationManager.requestEnableNotification()
      console.info(TAG, ` (enableNotification) success`)
    } catch (err) {
      console.error(TAG, `  (enableNotification) error => ${JSON.stringify(err)}`)
    }
  }

  /**
   * 发布通知
   * @param notificationRequest
   * @param id, Support specifying notification id when publishing notifications
   */
  async publishNotification(notificationRequest: notificationManager.NotificationRequest, id?: number) {
    if (id && id > 0) {
      notificationRequest.id = id
    }
    try {
      let notificationSlot: notificationManager.NotificationSlot = {
        type: notificationManager.SlotType.CONTENT_INFORMATION,
        level: notificationManager.SlotLevel.LEVEL_DEFAULT
      }
      // 通知提示音
      if (this.isPromptTone) {
        notificationSlot.sound = this.promptToneSrc
      }
      // 通知震动
      if (this.isVibrationEffect) {
        notificationSlot.vibrationEnabled = true
        notificationSlot.vibrationValues = [200]
      }
      await notificationManager.removeAllSlots()
      await notificationManager.addSlot(notificationSlot.type)
      await notificationManager.publish(notificationRequest)
      // 通知管理器添加新通知
      // await notificationManagement.addNotification(notificationRequest)
      console.info(TAG, `  (publishNotification) success => ${notificationRequest}`)
    } catch (err) {
      console.error(TAG, `  (publishNotification) error => ${JSON.stringify(err)}`)
    }
  }

  /**
   * 取消通知 BY ID
   */
  async cancelNotificationById(id: number) {
    try {
      await notificationManager.cancel(id)
      console.info(TAG, `cancel success`)
    } catch (err) {
      console.info(TAG, `cancel err ${JSON.stringify(err)}`)
    }
  }

  /**
   * 取消所有通知
   */
  async cancelAllNotifications() {
    try {
      await notificationManager.cancelAll()
      console.info(TAG, `cancel all success`)
    } catch (err) {
      console.error(TAG, `cancel all err ${JSON.stringify(err)}`)
    }
  }
}

class NotificationRequestUtil {

  /**
   * 初始化 BasicNotificationRequest
   * @param notificationContent
   * @returns NotificationRequest
   */
  initBasicNotificationRequest(notificationContent: notificationManager.NotificationContent): notificationManager.NotificationRequest {
    return {
      slotType: notificationManager.SlotType.CONTENT_INFORMATION,
      // 通知id，默认为1
      id: 1,
      content: notificationContent
    }
  }

  /**
   * 初始化 (行为意图) WantAgent NotificationRequest
   * @param notificationContent
   * @param notificationWantAgent
   * @return NotificationRequest
   */
  initWantAgentNotificationRequest(notificationContent: notificationManager.NotificationContent, notificationWantAgent: WantAgent): notificationManager.NotificationRequest {
    return {
      slotType: notificationManager.SlotType.CONTENT_INFORMATION,
      // 通知id，默认为1
      id: 1,
      content: notificationContent,
      wantAgent: notificationWantAgent
    }
  }

  /**
   * 初始化 Buttons NotificationRequest
   * @param notificationContent
   * @param notificationActionButtons
   * @return NotificationRequest
   */
  initButtonNotificationRequest(notificationContent: notificationManager.NotificationContent, notificationActionButtons: notificationManager.NotificationActionButton[]): notificationManager.NotificationRequest {
    let actionButtons = notificationActionButtons
    // 当前通知接口最大允许按钮数: 2
    if (notificationActionButtons.length > 2) {
      actionButtons = notificationActionButtons.splice(0, 2)
    }
    return {
      slotType: notificationManager.SlotType.CONTENT_INFORMATION,
      // 通知id，默认为1
      id: 1,
      content: notificationContent,
      actionButtons: actionButtons
    }
  }
}

class NotificationContentUtil {

  /**
   * 初始化 (基础) basic notification content
   * @param basicContent
   * @return return the created NotificationContent
   */
  initBasicNotificationContent(basicContent: notificationManager.NotificationBasicContent): notificationManager.NotificationContent {
    return {
      // 通知内容类型
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      // 基本类型通知内容
      normal: basicContent
    }
  }

  /**
   *  初始化 (长文本) longtext notification content
   * @param basicContent
   * @param notificationLongText
   * @param notificationBriefText
   * @param notificationExpandedTitle
   * @return NotificationContent
   */
  initNotificationLongTextContent(basicContent: notificationManager.NotificationBasicContent, notificationLongText: string, notificationBriefText: string, notificationExpandedTitle: string): notificationManager.NotificationContent {
    return {
      // 通知内容类型
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
      longText: {
        // 通知标题
        title: basicContent.title,
        // 通知内容
        text: basicContent.text,
        // 通知次要内容
        additionalText: basicContent.additionalText ? basicContent.additionalText : '',
        // 通知的长文本
        longText: notificationLongText,
        // 通知概要内容，是对通知内容的总结
        briefText: notificationBriefText,
        // 通知展开时的标题
        expandedTitle: notificationExpandedTitle
      }
    }
  }

  /**
   * 初始化 (多行文本) multiline notification content
   * @param basicContent
   * @param notificationBriefText
   * @param notificationLongTitle
   * @param notificationLines
   * @return NotificationContent
   */
  initNotificationMultiLineContent(basicContent: notificationManager.NotificationBasicContent, notificationBriefText: string, notificationLongTitle: string, notificationLines: Array<string>): notificationManager.NotificationContent {
    return {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_MULTILINE,
      multiLine: {
        title: basicContent.title,
        text: basicContent.text,
        additionalText: basicContent.additionalText ? basicContent.additionalText : '',
        briefText: notificationBriefText,
        longTitle: notificationLongTitle,
        lines: notificationLines
      }
    }
  }

  /**
   * 初始化 (图片) picture notification content
   * @param basicContent
   * @param notificationBriefText
   * @param notificationExpandedTitle
   * @param notificationPicture
   * @return NotificationContent
   */
  initNotificationPictureContent(basicContent: notificationManager.NotificationBasicContent, notificationBriefText: string, notificationExpandedTitle: string, notificationPicture: image.PixelMap): notificationManager.NotificationContent {
    return {
      contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_PICTURE,
      picture: {
        title: basicContent.title,
        text: basicContent.text,
        additionalText: basicContent.additionalText ? basicContent.additionalText : '',
        briefText: notificationBriefText,
        expandedTitle: notificationExpandedTitle,
        // 通知的图片
        picture: notificationPicture
      }
    }
  }
}

export let notificationUtil = new NotificationUtil()
export let notificationRequestUtil = new NotificationRequestUtil()
export let notificationContentUtil = new NotificationContentUtil()