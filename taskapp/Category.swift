//
//  Category.swift
//  taskapp
//
//  Created by 浅尾栄志 on 2018/08/17.
//  Copyright © 2018年 jirokirameki. All rights reserved.
//

import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // カテゴリー名
    @objc dynamic var title = ""
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
