//
//  FirebaseAPI.swift
//  CSSGApp
//
//  Created by Erica Fearon on 5/1/17.
//  Copyright © 2017 Erica Fearon. All rights reserved.
//

import Foundation
import Firebase

/*
 These are the Mentor/Mentee questions for reference.
 
 
 var industryQuestion = Question(title: "What field are you most knowledgeable in?", subtitle: "We will try to match you with mentees interested in this field.", answers: ["Medicine", "Biology", "Chemistry", "Physics", "Mathematics", "Engineering", "Data Science", "Computer Science", "Design", "Visual Arts", "Performing Arts", "Psychology & Sociology", "English", "Linguistics & Spoken Languages", "History", "Public & Foreign Policy", "Law", "Business"])
 
 var problemSolvingQuestion = Question(title: "When you solve problems at work, how do you usually do it?", subtitle: "", answers: ["Reading about other people's previous solutions before taking action", "Talking individually colleagues people to get advice", "Consulting my boss for advice or direction", "Sitting down with a group of colleagues to brainstorm solutions", "Building lots of possible solutions until I make one that works"])
 
 var offerHelpQuestion = Question(title: "What is the number one skill you can offer to your mentee?", subtitle: "", answers: ["How to use LinkedIn", "How to apply to colleges", "How to be successful in college", "How to apply for jobs", "How to be successful in your current job", "How to find out what job opportunities are available", "How to decide on a long-term career path"])
 
 
 
 var subjectQuestion = Question(title: "What subject interests you the most?", subtitle: "We will try to find a mentor with work experience closest to your interests.", answers: ["Medicine", "Biology", "Chemistry", "Physics", "Mathematics", "Engineering", "Data Science", "Computer Science", "Design", "Visual Arts", "Performing Arts", "Psychology & Sociology", "English", "Linguistics & Spoken Languages", "History", "Public & Foreign Policy", "Law", "Business"])
 
 var solutionQuestion = Question(title: "If you were to solve a problem, how would you prefer to do it?", subtitle: "This helps us understand what type of job you might enjoy.", answers: ["Reading about other people's previous solutions before taking action", "Talking individually to other people to get advice", "Consulting an authority figure for advice or direction", "Sitting down with a group of people to brainstorm solutions", "Building lots of possible solutions until I make one that works"])
 
 var helpQuestion = Question(title: "What is the number one skill you would like your mentor to help you with?", subtitle: "", answers: ["Learning to use LinkedIn", "Applying to colleges", "Learning to be successful in college", "Applying for jobs", "Learning to be successful in my job", "Learning more about different jobs", "Learning what long-term career path is right for me"])*/


class FirebaseAPI {
    var refUsers: FIRDatabaseReference!
    var ref = FIRDatabase.database().reference()
    var questionMapping = [
        "qa" : "qd",
        "qb" : "qe",
        "qc" : "qf"
    ]
    
    var mentee : User?
    
    //------------- STRUCTS -------------
    
    struct Match {
        var id : String
        var mentorUserId : String
        var menteeUserId : String
        var state : String
        var score : Int
        
        init(id: String, mentor: String, mentee: String, state: String, score: Int) {
            self.id = id
            self.mentorUserId = mentor
            self.menteeUserId = mentee
            self.state = state
            self.score = score
        }
        
        var hashValue: Int {
            return self.id.hashValue
        }
    }
    
    struct User {
        var id : String
        var type : String
        var firstName : String
        var lastName : String
        var email : String
        var password : String
        var job : String
        var company : String
        var location : String
        var questionAnswers : [String: Int]
        
        init(id: String, type: String, first: String, last: String, email :String, password: String, job: String, company: String, location: String, questionAnswers: [String: Int]) {
            self.id = id
            self.type = type
            self.firstName = first
            self.lastName = last
            self.email = email
            self.password = password
            self.job = job
            self.company = company
            self.location = location
            self.questionAnswers = questionAnswers
        }
        
    }
    
    struct Question : Hashable {
        var id : String
        var text : String
        var answers : [String: Bool]
        var type: String
        
        init(id: String, text: String, answers: [String: Bool], type: String) {
            self.id = id
            self.text = text
            self.answers = answers
            self.type = type
        }
        
        var hashValue: Int {
            return self.id.hashValue
        }
    }
    
    //---------------- USERS ------------------
    
    
    func addUser(dictionary: [String: AnyObject]) {
        refUsers = FIRDatabase.database().reference().child("users")
        let key = refUsers.childByAutoId().key
        refUsers.child(key).setValue(dictionary)
    }
    
    func updateUsers(user: User) {
        //TODO: update an existing user in the db
    }
    
    func getUser(id: String) {
        refUsers = FIRDatabase.database().reference().child("users")
        let mentee = refUsers.child(id)
        print(mentee)
    }
    
    func getMentors(callback: @escaping ([User]) -> ()) {
        var users : [User] = []
        
        ref.child("users").observe(.value, with: { snapshot in
            for c in snapshot.children {
                print("this is c")
                print(c)
                let user = self.makeUserFromDB(currentData: c as AnyObject)
                users.append(user)
            }
            
            callback(users)
        })
    }
    
    
    //DONE BUT NOT TESTED
    //    func getMy_Mentees_Mentors_Matches(curUser: User, myType: String, matchStatus: String, callback: ([User]) -> Void) {
    //        //Get Matches -> matchStatus = "suggested"
    //        //Get Mentors/Mentees -> matchStatus = "accepted"
    //        //Get sent mentor requests -> matchStatus = "pending"
    //
    //        ref.child("matches").observeEventType(.Value, withBlock: { snapshot in
    //
    //            var matches : [String] = []
    //
    //            var matchType = ""
    //            if (myType == "mentee") {
    //                matchType = "mentorUserId"
    //            } else {
    //                matchType = "menteeUserId"
    //            }
    //
    //            if (snapshot.childrenCount == 0) {
    //                self.getAllMentors(curUser, finalCallback: callback)
    //
    //            } else {
    //                for c in snapshot.children {
    //                    if((c.value!.objectForKey(myType + "UserId") as! String) == curUser.id &&
    //                        c.value!.objectForKey("status") as! String == matchStatus) {
    //                        matches.append(c.value!.objectForKey(matchType) as! String)
    //                    }
    //                }
    //
    //                self.fromMatchesToUsers(matches, callback: callback)
    //            }
    //
    //        })
    //    }
    //
    //TODO: GET ID
    //    private func makeUserFromDB (c: AnyObject) -> User {
    //        return User(
    //            id: "TEST",
    //            type: c.value!.objectForKey("type") as! String,
    //            first: c.value!.objectForKey("firstname") as! String,
    //            last: c.value!.objectForKey("lastname") as! String,
    //            email: c.value!.objectForKey("email") as! String,
    //            job: c.value!.objectForKey("job") as! String,
    //            company: c.value!.objectForKey("company") as! String,
    //            location: c.value!.objectForKey("location") as! String,
    //            questionAnswers: c.value!.objectForKey("answers") as! [String: AnyObject]
    //    )}
    
    func makeUserFromDB(currentData: AnyObject) -> User {
        print("children")
        print(currentData)
        
//        let enumerator = currentData.children
//        while let listObject = enumerator?.nextObject() as? FIRDataSnapshot {
//            let object = listObject.value as! [String: AnyObject]
//            self.User.type = object["type"] as! String
//            print(self.User.type)
//        }
//        while let list_object = currentData.children.nextObject() as? FIRDataSnapshot {
//            
//            let object = list_object.value as! [String: AnyObject]
//            print(object["type"])
//        }
        
        //print(currentData["-KlRLaj0eSnP7SzZ4RRp/type"] as? String)
        //ref.observe(.childAdded, with: { snapshot in
        // if let snapshotValue = snapshot.value as? [String: Any],
        //    let currentData = snapshotValue["users"] as? [String:Any] {
        let type = (currentData["type"])! as! String
        let firstname = (currentData["first_name"])! as! String
        let lastname = (currentData["last_name"])! as! String
        let email = (currentData["email"])! as! String
        let password = (currentData["password"])! as! String
        let job = (currentData["job"])! as! String
        let company = (currentData["company"])! as! String
        let location = (currentData["location"])! as! String
        let questionAnswers = (currentData["answers"])! as! [String: Int]
        
        
        return User(id: "", type: type, first: firstname, last: lastname, email: email, password: password, job: job, company: company, location: location, questionAnswers: questionAnswers)
        //}
    }
    
    
    //----------- QUESTIONS --------------
    
    //DONE
    //    func getQuestions(type: String, callback: [Question] -> Void) {
    //
    //        ref.child("questions").observeEventType(.Value, withBlock: { snapshot in
    //
    //            var questions : [Question] = []
    //
    //            for c in snapshot.children {
    //                if ((c.value!.objectForKey("type") as! String) == type) {
    //                    questions.append((self.makeQuestionFromDB(c)))
    //                }
    //            }
    //
    //            callback(questions)
    //        })
    //    }
    //
    //    private func makeQuestionFromDB(c: AnyObject) -> Question {
    //        return Question(
    //            id: "TEST",
    //            text: c.value!.objectForKey("text") as! String,
    //            answers: c.value!.objectForKey("answers") as! [String: Bool],
    //            type: c.value!.objectForKey("type") as! String
    //    )}
    
    //--------------- MATCHES ------------
    
    //NOT TESTED
    //    private func fromMatchesToUsers(matches: [String], callback: @escaping ([User]) -> Void) {
    //
    //        ref.child("users").observe(.value, with: { snapshot in
    //            var users : [User] = []
    //            for c in snapshot.children {
    //                if (matches.contains((c as AnyObject).value!,objectForKey("id") as! String)) {
    //                    users.append(self.makeUserFromDB(c: c as AnyObject))
    //                }
    //            }
    //            callback(users)
    //        })
    //    }
    
    
    //    func updateMatches() {
    //    //TODO
    //    }
    
    //NOT TESTED
    //    private func getAllMentors(curUser: User, finalCallback: [User] -> Void) {
    //
    //        ref.child("users").observeEventType(.Value, withBlock: { snapshot in
    //
    //            var mentors : [User] = []
    //
    //            for c in snapshot.children {
    //                if ((c.value!.objectForKey("type") as! String) == "mentor") {
    //                    mentors.append((self.makeUserFromDB(c)))
    //                }
    //            }
    //
    //            self.matchAlgorithm(curUser, mentors: mentors, finalCallback: finalCallback)
    //        })
    //    }
    
    
    //NOT TESTED
    //    private func matchAlgorithm(curUser: User, mentors: [User], finalCallback: [User] -> Void) {
    //
    //        var matches : [Match] = []
    //        var mentorIds : [String] = []
    //
    //        for mentor in mentors {
    //            var compatibility = 0
    //
    //            for pair in questionMapping {
    //                let mentorAnswer = mentor.questionAnswers[pair.0] //TODO: may need to cast to Int
    //                let menteeAnswer = mentee!.questionAnswers[pair.1]
    //                let similarity = mentorAnswer! - menteeAnswer!
    //
    //                switch(similarity) {
    //                case 0:
    //                    compatibility += 10
    //                case 1:
    //                    compatibility += 5
    //                default:
    //                    compatibility += 1
    //                }
    //            }
    //
    //            let newMatch = Match.init(id: NSUUID.init().UUIDString, mentor: mentor.id, mentee: mentee!.id, state: "pending", score: compatibility)
    //
    //            matches.append(newMatch)
    //            mentorIds.append(mentor.id)
    //        }
    //
    //        //THIS WON'T WORK BECAUSE MENTORIDS HAS STRINGS, NOT SCORES. DICTIONARY???
    //        //matches = matches.sort({ $0.score > $1.score }) USE THIS AFTER fromMatchesToUsers
    //
    //        postMatches(matches)
    //        fromMatchesToUsers(mentorIds, callback: finalCallback)
    //    }
    
    func postMatches (matches: [Match]) {
        //TODO
    }
    
}

//------------ IMPLEMENTING HASHABLE STRUCTS -------------

extension FirebaseAPI.Question: Equatable {}

func == (lhs: FirebaseAPI.Question, rhs: FirebaseAPI.Question) -> Bool {
    return lhs.id == rhs.id
}

func ==(lhs: FirebaseAPI.User, rhs: FirebaseAPI.User) -> Bool {
    return lhs.id == rhs.id
}

func ==(lhs: FirebaseAPI.Match, rhs: FirebaseAPI.Match) -> Bool {
    return lhs.id == rhs.id
}
