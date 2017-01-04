//
//  ViewController.swift
//  Meal
//
//  Created by sunrin on 2016. 12. 26..
//  Copyright © 2016년 sunrin. All rights reserved.
//

import UIKit
import Alamofire

class MealListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let schoolSelectButtonItem = UIBarButtonItem(
        title: "학교 선택",
        style: .plain,
        target: nil,
        action: #selector(schoolSelectButtonItemDidSelect)
    )
    
    let tableView = UITableView()
    let toolbar = UIToolbar()
    let prevMonthButtonItem = UIBarButtonItem(
        title: "이전달",
        style: .plain,
        target: nil,
        action: nil
    )
    let nextMonthButtonItem = UIBarButtonItem(
        title: "다음달",
        style: .plain,
        target: nil,
        action: nil
    )
    var school: School?
    var date: (year: Int, month: Int)
    var meals: [Meal] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let today = Date()
        let year = Calendar.current.component(Calendar.Component.year, from: today)
        let month = Calendar.current.component(Calendar.Component.month, from: today)
        self.date = (year: year, month: month)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.schoolSelectButtonItem.target = self
        self.prevMonthButtonItem.target = self
        self.prevMonthButtonItem.action = #selector(prevMonthButtonItemDidSelect)
        self.nextMonthButtonItem.target = self
        self.nextMonthButtonItem.action = #selector(nextMonthButtonItemDidSelect)
        self.navigationItem.rightBarButtonItem = self.schoolSelectButtonItem
        self.tableView.register(MealCell.self, forCellReuseIdentifier:"mealCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset.bottom = 44
        self.tableView.scrollIndicatorInsets.bottom = 44
        self.tableView.frame = self.view.bounds
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.toolbar)
        self.toolbar.items = [
            self.prevMonthButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            self.nextMonthButtonItem,
        ]
        self.loadMeals()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
        self.toolbar.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height - 44,
            width: self.view.frame.size.width,
            height: 44
        )
    }
    
    func loadMeals(){
        guard let schoolCode = self.school?.code else {return}
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let urlString = "https://schoool.herokuapp.com/"
        let path = "school/\(schoolCode)/meals"
        let parameters : [String:Any] = [
            "year": self.date.year,
            "month": self.date.month,
        ]
        Alamofire.request(urlString+path, parameters:parameters).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard let json = response.result.value as? [String : [[String:Any]]],
                let dicts = json["data"]
            else {return}
            
            self.meals = dicts.flatMap{
                return Meal(dictionary: $0)
            }
            self.tableView.reloadData()
        }
                /*let dummyDictionary: [[String: Any]] = [
            [
                "date": "2017-1-1",
                "lunch": ["치킨", "햄버거","피자"],
                "dinner": ["삼겹살","오겹살"],
                ],
            [
                "date": "2017-1-2",
                "lunch": ["볶음밥", "자장면"],
                "dinner": [],
                ],
            [
                "date": "2017-1-3",
                "lunch": [],
                "dinner": ["탕수육"],
            ]
        ]*/
    }
    //무엇이 [did|will] 동사
    
    func schoolSelectButtonItemDidSelect(){
        let schoolSearchViewController = SchoolSearchViewController()
        schoolSearchViewController.didSelectSchool = { school in
            self.school = school
            self.loadMeals()
        }
        let navigationController = UINavigationController(
            rootViewController: schoolSearchViewController
        )
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func prevMonthButtonItemDidSelect(){
        var newYear = self.date.year
        var newMonth = self.date.month-1
        if newMonth <= 0 {
            newYear-=1
            newMonth=12
        }
        self.date = (year:newYear, month:newMonth)
        loadMeals()
    }
    
    func nextMonthButtonItemDidSelect(){
        var newYear = self.date.year
        var newMonth = self.date.month+1
        if newMonth >= 13{
            newYear+=1
            newMonth=1
        }
        self.date = (year:newYear, month:newMonth)
        loadMeals()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return self.meals.count
    }
    
    func tableView( _ tableView: UITableView,
                    numberOfRowsInSection section : Int )-> Int {
        return 2
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
        )-> String?{
        let meal = self.meals[section]
        return meal.date
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        )-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "mealCell",
            for: indexPath) as! MealCell
        
        cell.textLabel?.numberOfLines = 0
        let meal = self.meals[indexPath.section]
        if indexPath.row == 0 {
            cell.titleLabel.text = "점심"
            cell.contentLabel.text = meal.lunch.joined(separator: ", ")
        }else{
            cell.titleLabel.text = "저녁"
            cell.contentLabel.text = meal.dinner.joined(separator: ", ")
        }
        cell.contentLabel.numberOfLines = 0
        return cell
    }
    func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath)->CGFloat{
        let meal = self.meals[indexPath.section]
        if indexPath.row == 0 {
            return MealCell.height(
                width: tableView.frame.size.width,
                title:"점심",
                content: meal.lunch.joined(separator:", ")
            )
        }else{
            return MealCell.height(
                width: tableView.frame.size.width,
                title: "저녁",
                content: meal.dinner.joined(separator: ", ")
            )
        }
    }
}
