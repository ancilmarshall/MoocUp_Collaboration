//: Playground - noun: a place where people can play

import UIKit

let dictionaryArray = [["Cours" : "Français"], ["Cours" : "Anglais"], ["Vacances" : "Anglais"]]
let array = dictionaryArray.map {
    $0["Cours"]
}
println(array)

//let flatArray = dictionaryArray.flatMap {
//    $0["Cours"]
//}
//flatArray

