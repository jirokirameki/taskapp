//
//  InputViewController.swift
//  taskapp
//
//  Created by 浅尾栄志 on 2018/08/16.
//  Copyright © 2018年 jirokirameki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var task: Task!
    var allCategories: Results<Category>!
    let realm = try! Realm()
    
    // 新規にカテゴリーを作ったかどうかのフラグ
    // 0：カテゴリーに変化なし、1：新規カテゴリー追加、2：既存カテゴリー削除
    var flagCategory = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self;
        categoryPicker.dataSource = self;
        categoryPicker.showsSelectionIndicator = true;
        
        allCategories = realm.objects(Category.self)

        // はじめに表示する項目を指定
        var i = 0
        while i < allCategories.count {
            if task.category.id == allCategories[i].id {
                categoryPicker.selectRow(i, inComponent: 0, animated: true)
                break
            }
            i += 1
        }

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // 既知の値を事前にセット
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.titleTextField.text != "" || self.contentsTextView.text != "" {
            // 保存処理
            try! realm.write {
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date
                self.realm.add(self.task, update: true)
            }
            // タスクのローカル通知を登録する関数を呼ぶ
            setNotification(task: task)
            
            super.viewWillDisappear(animated)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    

    // 表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // アイテム表示個数を返す
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        // タスクにカテゴリーを事前登録
        try! realm.write {
            self.task.category = allCategories[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return allCategories[row].title
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("↓@inputViewController_will")
//        print(flagCreateCategory)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if flagCategory == 1 {
            // 戻ってくる直前の作業がカテゴリー作成
            categoryPicker.reloadAllComponents()
            categoryPicker.selectRow(allCategories.count - 1, inComponent: 0, animated: true)
        } else if flagCategory == 2 {
            // 戻ってくる直前の作業がカテゴリー削除
            categoryPicker.reloadAllComponents()
//            categoryPicker.selectRow(0, inComponent: 0, animated: true)
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
