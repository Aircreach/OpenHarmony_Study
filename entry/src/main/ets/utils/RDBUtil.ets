import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { ValuesBucket, ValueType } from '@ohos.data.ValuesBucket';

const TAG: string = '[RDBUtil]'

class RDBUtil {
  private context: common.UIAbilityContext | undefined = undefined
  // 存储已创建的RdbStore
  private rdbMap = new Map<string,relationalStore.RdbStore>()
  private currentRDB: string = 'default'

  init(context: common.UIAbilityContext) {
    this.context = context
  }

  /**
   * 创建数据库/获取连接
   * @param rdbName
   * @param config
   * @returns
   */
  async createRDB(rdbName: string, config ?: relationalStore.StoreConfig): Promise<relationalStore.RdbStore> {
    let promise: Promise<relationalStore.RdbStore> = new Promise(async (resolve, reject) => {
      if (!this.context) {
        console.error(TAG, '  (init) ERROR => Context 未获取')
        reject(TAG + '  (init) ERROR => Context 未获取')
      }
      this.currentRDB = rdbName
      const STORE_CONFIG: relationalStore.StoreConfig = config ? config : {name: rdbName, securityLevel: 1}
      try {
        let rdb = this.rdbMap.get(rdbName)
        if (!rdb) {
          rdb = await relationalStore.getRdbStore(this.context, STORE_CONFIG)
          this.rdbMap.set(rdbName, rdb)
        }
        console.info(TAG, `  (createRDB)  SUCCESS TO CREATE: ${rdbName} => 创建连接成功`)
        resolve(rdb)
      } catch (err) {
        let code = (err as BusinessError).code
        let message = (err as BusinessError).message
        console.error(TAG, `  (createRDB)  FAIL TO CREATE: ${rdbName} => code: ${code}, message: ${message}`)
        reject(err as BusinessError)
      }
    })
    return promise
  }

  /**
   * 获取/切换 RDB数据库
   * @param rdbName
   * @returns RdbStore
   */
  async getConnection(rdbName: string): Promise<relationalStore.RdbStore> {
    try {
      this.currentRDB = rdbName
      let rdb = this.rdbMap.get(rdbName)
      if (!rdb) {
        console.error(TAG, `  (getConnection)   FAIL TO GET => ${this.currentRDB} RDB连接不存在 重新创建`)
        rdb = await this.createRDB(rdbName)
      }
      console.info(TAG, `  (getConnection)   SUCCESS TO GET => ${this.currentRDB} RDB连接获取成功`)
      return Promise.resolve(rdb)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (getConnection)  FAIL TO GET: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 插入对象
   * @param tableName
   * @param obj
   * @returns
   */
  async insert <T> (tableName: string, obj: T): Promise<number> {
    try {
      // 默认使用最近一次连接
      let rdb = this.rdbMap.get(this.currentRDB)
      if (!rdb) {
        console.error(TAG, `  (insert)   FAIL TO INSERT => ${this.currentRDB} 未获取RDB连接`)
        return Promise.reject(TAG + `  (insert)   FAIL TO INSERT => ${this.currentRDB} 未获取RDB连接`)
      }
      let value: ValuesBucket = this.obj2ValueBucket <T> (obj)
      let insertNum: number = await rdb.insert(tableName, value)
      console.info(TAG, `  (insert)   SUCCESS TO INSERT => ${this.currentRDB} ${tableName} INSERT ${insertNum}`)
      return Promise.resolve(insertNum)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (insert)  FAIL TO INSERT: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 批量插入数组
   * @param tableName
   * @param arr
   * @returns 插入成功数量
   */
  async batchInsert <T> (tableName: string, arr: T[]): Promise<number> {
    try {
      // 默认使用最近一次连接
      let rdb = this.rdbMap.get(this.currentRDB)
      let values: ValuesBucket[] = this.array2ValueBuckets <T> (arr)
      if (!rdb) {
        console.error(TAG, `  (batchInsert)   FAIL TO BATCHINSERT => ${this.currentRDB} 未获取RDB连接`)
        return Promise.reject(TAG + `  (batchInsert)   FAIL TO BATCHINSERT => ${this.currentRDB} 未获取RDB连接`)
      }
      let insertNum: number = await rdb.batchInsert(tableName, values)
      console.info(TAG, `  (batchInsert)   SUCCESS TO BATCHINSERT => ${this.currentRDB} ${tableName} BATCHINSERT ${insertNum}}`)
      return Promise.resolve(insertNum)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (batchInsert)  FAIL TO BATCHINSERT: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 查询
   * @param tableName
   * @param id
   * @param columns
   * @returns 对象
   */
  async queryById <T> (tableName: string, id: number|string, columns ?: Array<string>): Promise<T> {
    try {
      // 默认使用最近一次连接
      let rdb = this.rdbMap.get(this.currentRDB)
      if (!rdb) {
        console.error(TAG, `  (queryById)   FAIL TO QUERY => ${this.currentRDB} 未获取RDB连接`)
        return Promise.reject(TAG +  `  (queryById)   FAIL TO QUERY => ${this.currentRDB} 未获取RDB连接`)
      }
      let predicates = new relationalStore.RdbPredicates(tableName)
      predicates.equalTo('id', id)
      let resultSet: relationalStore.ResultSet
      if (columns) {
        resultSet = await rdb.query(predicates, columns)
      } else {
        resultSet = await rdb.query(predicates)
      }
      let arr: T[] = this.resultSet2Array <T> (resultSet)
      resultSet.close()
      if (arr.length == 0) {
        console.error(TAG, `  (queryById)   FAIL TO QUERY => 该表未查询到数据`)
        return Promise.reject(null)
      }
      console.info(TAG, `  (queryById)   SUCCESS TO QUERY => ${JSON.stringify(arr)}`)
      return Promise.resolve(arr[0])
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (queryById)  FAIL TO QUERY: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 批量查询
   * @param predicates
   * @param columns
   * @returns 所有数据 => 数组
   */
  async queryArray <T> (predicates: relationalStore.RdbPredicates, columns ?: Array<string>): Promise<T[]> {
    try {
      // 默认使用最近一次连接
      let rdb = this.rdbMap.get(this.currentRDB)
      if (!rdb) {
        console.error(TAG, `  (queryArray)   FAIL TO QUERY => ${this.currentRDB} 未获取RDB连接`)
        return Promise.reject(TAG +  `  (queryArray)   FAIL TO QUERY => ${this.currentRDB} 未获取RDB连接`)
      }
      let resultSet: relationalStore.ResultSet
      if (columns) {
        resultSet = await rdb.query(predicates, columns)
      } else {
        resultSet = await rdb.query(predicates)
      }
      let arr: T[] = this.resultSet2Array <T> (resultSet)
      resultSet.close()
      if (arr.length == 0) {
        console.error(TAG, `  (queryArray)   FAIL TO QUERY => 该表未查询到数据`)
        return Promise.resolve(arr)
      }
      console.info(TAG, `  (queryArray)   SUCCESS TO QUERY => ${JSON.stringify(arr)}`)
      return Promise.resolve(arr)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (queryArray)  FAIL TO QUERY: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 更新数据
   * @param obj
   * @param predicates
   * @returns 更新数量
   */
  async update <T> (obj: T, predicates: relationalStore.RdbPredicates): Promise<number> {
    try {
      // 默认使用最近一次连接
      let rdb = this.rdbMap.get(this.currentRDB)
      if (!rdb) {
        console.error(TAG, `  (update)   FAIL TO UPDATE => ${this.currentRDB} 未获取RDB连接`)
        return Promise.reject(TAG + `  (update)   FAIL TO UPDATE => ${this.currentRDB} 未获取RDB连接`)
      }
      let value = this.obj2ValueBucket <T>(obj)
      let updateNum = await rdb.update(value, predicates)
      console.info(TAG, `  (update)   SUCCESS TO UPDATE => ${this.currentRDB} UPDATE ${updateNum}`)
      return Promise.resolve(updateNum)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (update)  FAIL TO UPDATE: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 更新数据 ById
   * @param obj
   * @param predicates
   * @returns 成功更新数量
   */
  async updateById <T> (tableName: string, id: number|string, obj: T): Promise<number> {
    try {
      let value = this.obj2ValueBucket <T>(obj)
      let predicates = new relationalStore.RdbPredicates(tableName)
      predicates.equalTo('id', id)
      let updateNum = await this.update(value, predicates)
      console.info(TAG, `  (updateById)   SUCCESS TO UPDATE => ${this.currentRDB} UPDATE ${updateNum}`)
      return Promise.resolve(updateNum)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (updateById)  FAIL TO UPDATE: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 删除数据
   * @param obj
   * @param predicates
   * @returns 删除数量
   */
  async delete(predicates: relationalStore.RdbPredicates) :Promise<number> {
    try {
      // 默认使用最近一次连接
      let rdb = this.rdbMap.get(this.currentRDB)
      if (!rdb) {
        console.error(TAG, `  (delete)   FAIL TO DELETE => ${this.currentRDB} 未获取RDB连接`)
        return Promise.reject(TAG + `  (update)   FAIL TO DELETE => ${this.currentRDB} 未获取RDB连接`)
      }
      let deleteNum = await rdb.delete(predicates)
      console.info(TAG, `  (delete)   SUCCESS TO DELETE => ${this.currentRDB} DELETE ${deleteNum}}`)
      return Promise.resolve(deleteNum)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (delete)  FAIL TO DELETE: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * 删除数据 ById
   * @param obj
   * @param predicates
   * @returns 成功删除数量
   */
  async deleteById(tableName: string, id: number|string) :Promise<number> {
    try {
      let predicates = new relationalStore.RdbPredicates(tableName)
      predicates.equalTo('id', id)
      let deleteNum = await this.delete(predicates)
      console.info(TAG, `  (deleteById)   SUCCESS TO DELETE => ${this.currentRDB} DELETE ${deleteNum}}`)
      return Promise.resolve(deleteNum)
    } catch (err) {
      let code = (err as BusinessError).code
      let message = (err as BusinessError).message
      console.error(TAG, `  (deleteById)  FAIL TO DELETE: ${this.currentRDB} => code: ${code}, message: ${message}`)
      return Promise.reject(err as BusinessError)
    }
  }

  /**
   * ResultSet => Array
   * @param resultSet
   * @returns 数组
   */
  private resultSet2Array <T> (resultSet: relationalStore.ResultSet) : Array<T> {
    let arr: T[] = []
    if (resultSet.rowCount == 0 || resultSet.columnCount == 0){
      console.error(TAG, `  (resultSet2Array)  FAIL TO TRANSFER: ${this.currentRDB} => resultSet 为 null`)
      return []
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
      console.log(JSON.stringify(obj))
      str = '{'
    } while (resultSet.goToNextRow())
    return arr
  }

  /**
   * Object => ValueBucket
   * @param arr
   * @returns ValueBucket
   */
  private obj2ValueBucket <T> (obj: T) {
    let valuesBucket: ValuesBucket = {}
    // 获取对象属性/成员变量
    let keys: string[] = Object.keys(obj)
    for (let key of keys) {
      // 获取键值对
      let value: ValueType = obj[key]
      // 将键值对添加到ValuesBucket对象中
      valuesBucket[key] = value
    }
    return valuesBucket
  }

  /**
   * Array => ValueBucket[]
   * @param arr
   * @returns ValueBucket[]
   */
  private array2ValueBuckets <T> (arr: Array<T>) {
    let valuesBuckets: ValuesBucket[] = []
    // 遍历对象集合
    for (let obj of arr) {
      valuesBuckets.push(this.obj2ValueBucket <T> (obj))
    }
    // 返回ValuesBucket对象
    return valuesBuckets
  }
}


export let rdbUtil: RDBUtil = new RDBUtil()
