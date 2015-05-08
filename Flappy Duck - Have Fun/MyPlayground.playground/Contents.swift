//: Playground - noun: a place where people can play

import UIKit
import XCPlayground // Required for XCPShowView


func +(left: Vector, right: Vector) -> Vector {
    var x = left.x + right.x
    var y = left.y + right.y
    var z = left.z + right.z
    
    return Vector(x: x, y: y, z: z)
}


struct Vector {
    var x: Float
    var y: Float
    var z: Float
    
    mutating func add(vector: Vector){
        x += vector.x
        y += vector.y
        z += vector.z
    }
    
    static func vector(defaultValue: Float) -> Vector {
        return Vector(x: defaultValue, y: defaultValue, z: defaultValue)
    }
}

var vectorA = Vector(x: 0, y: 4, z: 15)
var vectorB = Vector(x: 10, y: 20, z: 15)

Vector.vector(1)



var vectorC = vectorA + vectorB

vectorC

