//
//  DynamicModelTests.swift
//  CoreStore
//
//  Copyright © 2017 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest

@testable
import CoreStore


class Animal: CoreStoreObject {
    
    let species = Value.Required<String>("species", default: "Swift")
    let master = Relationship.ToOne<Person>("master")
}

class Dog: Animal {
    
    let nickname = Value.Optional<String>("nickname")
    let age = Value.Required<Int>("age", default: 1)
    let friends = Relationship.ToManyUnordered<Dog>("friends")
    let friends2 = Relationship.ToManyUnordered<Dog>("friends2", inverse: { $0.friends })
}

class Person: CoreStoreObject {
    
    let name = Value.Required<String>("name")
    let pet = Relationship.ToOne<Animal>("pet", inverse: { $0.master })
}


// MARK: - DynamicModelTests

class DynamicModelTests: BaseTestDataTestCase {
    
    func testDynamicModels_CanBeDeclaredCorrectly() {
        
        let dataStack = DataStack(
            dynamicModel: DynamicModel(
                version: "V1",
                entities: [
                    Entity<Animal>("Animal"),
                    Entity<Dog>("Dog"),
                    Entity<Person>("Person")
                ]
            )
        )
        self.prepareStack(dataStack, configurations: [nil]) { (stack) in
            
            let k1 = Animal.keyPath({ $0.species })
            XCTAssertEqual(k1, "species")
            
            let k2 = Dog.keyPath({ $0.species })
            XCTAssertEqual(k2, "species")
            
            let k3 = Dog.keyPath({ $0.nickname })
            XCTAssertEqual(k3, "nickname")
            
            let updateDone = self.expectation(description: "update-done")
            let fetchDone = self.expectation(description: "fetch-done")
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let animal = transaction.create(Into<Animal>())
                    XCTAssertEqual(animal.species.value, "Swift")
                    XCTAssertTrue(type(of: animal.species.value) == String.self)
                    
                    animal.species .= "Sparrow"
                    XCTAssertEqual(animal.species.value, "Sparrow")
                    
                    let dog = transaction.create(Into<Dog>())
                    XCTAssertEqual(dog.species.value, "Swift")
                    XCTAssertEqual(dog.nickname.value, nil)
                    XCTAssertEqual(dog.age.value, 1)
                    
                    dog.species .= "Dog"
                    XCTAssertEqual(dog.species.value, "Dog")
                    
                    dog.nickname .= "Spot"
                    XCTAssertEqual(dog.nickname.value, "Spot")
                    
                    let person = transaction.create(Into<Person>())
                    XCTAssertNil(person.pet.value)
                    
                    person.pet .= dog
                    XCTAssertEqual(person.pet.value, dog)
                    XCTAssertEqual(person.pet.value?.master.value, person)
                    XCTAssertEqual(dog.master.value, person)
                    XCTAssertEqual(dog.master.value?.pet.value, dog)
                },
                success: {
                    
                    updateDone.fulfill()
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            stack.perform(
                asynchronous: { (transaction) in
                    
                    let p1 = Animal.where({ $0.species == "Sparrow" })
                    XCTAssertEqual(p1.predicate, NSPredicate(format: "%K == %@", "species", "Sparrow"))
                    
                    let bird = transaction.fetchOne(From<Animal>(), p1)
                    XCTAssertNotNil(bird)
                    XCTAssertEqual(bird!.species.value, "Sparrow")
                    
                    let p2 = Dog.where({ $0.nickname == "Spot" })
                    XCTAssertEqual(p2.predicate, NSPredicate(format: "%K == %@", "nickname", "Spot"))
                    
                    let dog = transaction.fetchOne(From<Dog>(), p2)
                    XCTAssertNotNil(dog)
                    XCTAssertEqual(dog!.nickname.value, "Spot")
                    XCTAssertEqual(dog!.species.value, "Dog")
                    
                    let person = transaction.fetchOne(From<Person>())
                    XCTAssertNotNil(person)
                    XCTAssertEqual(person!.pet.value, dog)
                    
                    let p3 = Dog.where({ $0.age == 10 })
                    XCTAssertEqual(p3.predicate, NSPredicate(format: "%K == %d", "age", 10))
                },
                success: {
            
                    fetchDone.fulfill()
                    withExtendedLifetime(stack, {})
                },
                failure: { _ in
                    
                    XCTFail()
                }
            )
            self.waitAndCheckExpectations()
        }
    }
    
    @nonobjc
    func prepareStack(_ dataStack: DataStack, configurations: [ModelConfiguration] = [nil], _ closure: (_ dataStack: DataStack) -> Void) {
        
        do {
            
            try configurations.forEach { (configuration) in
                
                try dataStack.addStorageAndWait(
                    SQLiteStore(
                        fileURL: SQLiteStore.defaultRootDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathComponent("\(type(of: self))_\((configuration ?? "-null-")).sqlite"),
                        configuration: configuration,
                        localStorageOptions: .recreateStoreOnModelMismatch
                    )
                )
            }
        }
        catch let error as NSError {
            
            XCTFail(error.coreStoreDumpString)
        }
        closure(dataStack)
    }
}