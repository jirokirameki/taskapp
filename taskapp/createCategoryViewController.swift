//
//  createCategoryViewController.swift
//  taskapp
//
//  Created by 浅尾栄志 on 2018/08/17.
//  Copyright © 2018年 jirokirameki. All rights reserved.
//

import UIKit
import RealmSwift

class createCategoryViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // 新規にカテゴリーを作ったかどうかのフラグ
    // 0：カテゴリーに変化なし、1：新規カテゴリー追加、2：既存カテゴリー削除
    var flag = 0
    let realm = try! Realm()
    
    var allCategories: Results<Category>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // createCategoryViewController自身をDelegate委託相手とする。
        navigationController?.delegate = self
        
        allCategories = realm.objects(Category.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.categoryTextField.text != "" {
            var i = 0
            var exist = false
            while i < allCategories.count {
                if allCategories[i].title == self.categoryTextField.text {
                    exist = true
                    break
                }
                i += 1
            }
            
            if exist == false {
                // 保存処理
                try! realm.write {
                    let category = Category()
    //                let allCategories = realm.objects(Category.self)
                    
                    if allCategories.count != 0 {
                        print(allCategories)
                        category.id = allCategories.max(ofProperty: "id")! + 1
                    }
                    category.title = self.categoryTextField.text!
                    self.realm.add(category, update: true)
                    
                    // フラグ更新
                    self.flag = 1
                }
            }
        }
        super.viewWillDisappear(animated)
    }
    
    // UINavigationControllerDelegateのメソッド。遷移する直前の処理。
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 遷移先が、InputViewControllerだったら……
        if let inputViewController = viewController as? InputViewController {
            // InputViewControllerのプロパティflagCreateCategoryの値変更。
            inputViewController.flagCategory = self.flag
        }
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCategories.count  // ←追加する
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.
        let task = allCategories[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        if allCategories[indexPath.row].id == 0 {
            // デフォルト値（ALL）だった場合は削除不可
            return .none
        }
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // データベースから削除する
            try! realm.write {
                // 削除前にこれから削除するカテゴリーを持っているタスクのカテゴリーを全てALLに
                let taskArray = try! Realm().objects(Task.self)
                var i = 0
                while i < taskArray.count {
                    if taskArray[i].category.id == allCategories[indexPath.row].id {
                       taskArray[i].category = allCategories[0]
                    }
                    i += 1
                }
                
                self.realm.delete(self.allCategories[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // フラグ更新
                flag = 2
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
