//
//  School.swift
//  Meal
//
//  Created by sunrin on 2017. 1. 2..
//  Copyright © 2017년 sunrin. All rights reserved.
//


struct School{
    var code: String
    var name: String
    var type: String
    
    init?(dictionary:[String:Any]){
        guard let code = dictionary["code"] as? String,
            let name = dictionary["name"] as? String,
            let type = dictionary["type"] as? String
        else {return nil}
    
        self.code = code
        self.name = name
        self.type = type
    }
    
    func toJSON() -> [String:Any]{
        return [
            "code": self.code,
            "name": self.name,
            "type": self.type
        ]
    }
}
