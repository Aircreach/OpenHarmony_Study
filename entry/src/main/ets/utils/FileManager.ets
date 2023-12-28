import fs from '@ohos.file.fs';
import { AsyncCallback, BusinessError, Callback } from '@ohos.base';
import common from '@ohos.app.ability.common';
import buffer from '@ohos.buffer';
import call from '@ohos.telephony.call';
import { transferToUtil } from './TransferToUtil';


export default class FileManager {

  private static context: common.UIAbilityContext

  public static init(context: common.UIAbilityContext) {
    FileManager.context = context
  }


  // 拷贝 rawfile => 沙箱目录
  public static async rawfileToSandbox(fileName: string) {
    try {
      let context: common.UIAbilityContext = FileManager.context
      let filesDir: string = context.filesDir
      let path = filesDir + '/' + fileName
      console.log('应用文件路径: ' + path)
      //获取 rawfile 目录文件

      let rawfileDes = context.resourceManager.getRawFdSync(fileName)
      let rawfileLength = rawfileDes.length
      let sbFile = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      let arrayBuffer = new ArrayBuffer(rawfileLength)
      let rawfileStream = fs.fdopenStreamSync(rawfileDes.fd, 'rw')
      // let readLen = rawfileStream.readSync(arrayBuffer, {offset: 0, length: rawfileLength})
      // let buf = buffer.from(arrayBuffer, 0, readLen)
      // console.log(buf.toString())
      // fs.writeSync(sbFile.fd, arrayBuffer,{encoding: 'utf-8'})

      FileManager.readRawFile(fileName).then((uint8Array: Uint8Array) => {
        arrayBuffer = transferToUtil.uint8arrayToArrayBuffer(uint8Array)
        console.log(transferToUtil.uint8ArrayToString(uint8Array))
        let buf = buffer.from(arrayBuffer, 0, rawfileLength)
        console.log(buf.toString());
        // sbStream.writeSync(arrayBuffer,{encoding: 'utf-8'})
        fs.writeSync(sbFile.fd, arrayBuffer)
        rawfileStream.closeSync()
        fs.close(sbFile)
        context.resourceManager.closeRawFdSync(fileName)
      })


      // sbStream.writeSync(arrayBuffer,{encoding: 'utf-8'})
      // rawfileStream.closeSync()
      // fs.close(sbFile)
      // context.resourceManager.closeRawFdSync(fileName)
    } catch (error) {
      console.info("[rawfile_copy_to_sandbox] ———————————————————————————————————————————————————————");
      console.info("[rawfile_copy_to_sandbox] api 运行失败" + '    ' + (error as BusinessError).code + '    ' + (error as BusinessError).message);
      console.log('[rawfile_copy_to_sandbox] rawfile/' + fileName + '文件拷贝失败');
    }
  }

  // 拷贝 沙箱目录 => rawfile
  public static async sandboxToRawfile(fileName: string) {}

  public static async getFileFromSB (filePath: string, callback: Callback<string>) {

    try {
      let context: common.UIAbilityContext = FileManager.context
      let path = context.filesDir + '/' + filePath

      let file = fs.openSync(path)
      let arrayBuffer = new ArrayBuffer(1024)

      let num: number = fs.readSync(file.fd, arrayBuffer)
      let buf: buffer.Buffer = buffer.from(arrayBuffer, 0, num)
      let fileContent = buf.toString()
      console.log('==================')
      console.info(`The content of file: ${fileContent}`)
      fs.closeSync(file)
      //   if (err) {
      //     console.info("mkdir failed with error message: " + err.message + ", error code: " + err.code)
      //   } else {
      //     console.info("read file data succeed")
      //     let buf: buffer.Buffer = buffer.from(arrayBuffer, 0, readLen)
      //     let fileContent = buf.toString('utf-8')
      //     console.log('==================');
      //     console.info(`The content of file: ${fileContent}`)
      //     fs.closeSync(file)
      //     callback(fileContent)
      //   }
      // })
      callback(fileContent)
    } catch (error) {
      console.error((error as BusinessError).code + '     ' + (error as BusinessError).message)
    }
  }


  public static readRawFile(fileName: string): Promise<Uint8Array> {
    // const filePath = this.getFilesDir() + '/' + fileName
    // this.rawfileToSandbox(filePath)
    return getContext().resourceManager.getRawFileContent(fileName).then((content) => {
      // 将文件内容解析为 Uint8Array
      const data: Uint8Array = content;
      // let that = new util.Base64Helper
      // return that.decode(data);
      // 返回 Promise 对象
      return Promise.resolve(data)
    })
  }
}