import relationalStore from '@ohos.data.relationalStore'
import util from '@ohos.util'
import { ValuesBucket, ValueType } from '@ohos.data.ValuesBucket'
import FileManager from './FileManager'

class TransferToUtil {

  uint8arrayToArrayBuffer (uint8array: Uint8Array) : ArrayBuffer{
    // 获取uint8array的buffer属性，它是一个arraybuffer
    let buffer = uint8array.buffer;
    // 获取uint8array的byteOffset和byteLength属性，它们表示uint8array在buffer中的起始位置和长度
    let byteOffset = uint8array.byteOffset;
    let byteLength = uint8array.byteLength;
    // 使用buffer的slice方法，根据byteOffset和byteLength，截取一个新的arraybuffer
    let arrayBuffer = buffer.slice (byteOffset, byteOffset + byteLength);
    // 返回新的arraybuffer
    return arrayBuffer;
  }

  // unit8Array => string
  uint8ArrayToString(uint8Array: Uint8Array) : string {
    let decoder : util.TextDecoder = util.TextDecoder.create('utf-8')
    let str : string = decoder.decodeWithStream(uint8Array)
    return str
  }

  async json2Arr <T> (filePath: string): Promise<Array<T>> {
    const data = await FileManager.readRawFile(filePath);
    const json: string = this.uint8ArrayToString(data);
    const array = JSON.parse(json) as Array<T>
    return array;
  }

  resultSet2Array <T> (resultSet: relationalStore.ResultSet) : Array<T> {
    let arr: T[] = []

    if (resultSet.rowCount == 0){
      console.error('result 为 null');
    }
    resultSet.goToFirstRow()
    let str : string = '{'
    do {
      for (let index = 0; index < resultSet.columnCount; index++) {

        str += `"${resultSet.getColumnName(index)}":"${resultSet.getString(index)}"`
        if (index != resultSet.columnCount - 1) {
          str += ','
        }
      }
      str +='}'
      let obj: T = JSON.parse(str)
      arr.push(obj)
      console.log(JSON.stringify(obj));
      str = '{'
    } while (resultSet.goToNextRow())
    return arr
  }

  array2ValueBucket <T> (arr: Array<T>) {
    // let entries: [string, T][] = Object.entries(arr)
    // console.log(entries.toString());

    let valuesBuckets: ValuesBucket[] = []
    // 遍历对象集合
    for (let obj of arr) {
      let valuesBucket: ValuesBucket = {}
      // 获取对象属性/成员变量
      let keys: string[] = Object.keys(obj)
      for (let key of keys) {
        // 获取键值对
        let value: ValueType = obj[key]
        // console.log(key)
        // console.log(value.toString())
        // 将键值对添加到ValuesBucket对象中
        valuesBucket[key] = value;

      }
      valuesBuckets.push(valuesBucket)
    }
    // 返回ValuesBucket对象
    return valuesBuckets;
  }
}

export let transferToUtil: TransferToUtil = new TransferToUtil()