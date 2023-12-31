/*

Finish the specification of this notification concept,
including its events, scenarios, and operational principles.

*/ 

sig Event {}

sig User {
	var subscriptions : set Event,
	var notifications : set Event
}

pred stutter {
	subscriptions' = subscriptions
	notifications' = notifications
}

pred read [u : User] {
  // Read all notifications
  //guard
  some u.notifications
  //effect
  no u.notifications' 
  //frame
  all us:User | us.subscriptions' = us.subscriptions
  all us:User-u | us.notifications'= us.notifications

}

pred subscribe [u : User, e : Event] {
	// Subscribe an event
  	//guard
  	e not in u.subscriptions
  	//effect
  	u.subscriptions'= u.subscriptions+e
  	//frame
  	all us:User-u | us.subscriptions' = us.subscriptions
  	all us:User | us.notifications'= us.notifications

}

pred unsubscribe [u : User, e : Event] {
	// Unsubscribe from a event
  	//guard
  	e in u.subscriptions
  	//effect
  	u.subscriptions'= u.subscriptions-e
  	u.notifications'= u.notifications-e 
  	//frame
  	all us:User-u | us.subscriptions' = us.subscriptions
  	all us:User-u | us.notifications'= us.notifications
  	

}

pred occur [e : Event] {
	// Occurrence of an event
  	//guard
  	//some User.subscriptions & e
  	//effect
  	all u:User | e in u.subscriptions implies u.notifications'=u.notifications+e
  	//frame
  	all u:User | e not in u.subscriptions implies u.notifications'=u.notifications
  	all u:User | u.subscriptions' = u.subscriptions

}

fact {
	no subscriptions
	no notifications
	always {
		stutter or
		(some u : User | read[u]) or
		(some u : User, e : Event | subscribe[u,e] or unsubscribe[u,e]) or
		(some e : Event | occur[e])
	}
}

// Validation

run Example {
	// Empty run to be used for simulation
}

run Scenario1 {
	// An event is subscribed, then occurs, and the respective notification is read 
  some e:Event,u:User {subscribe[u,e];occur[e];read[u]}
  	

} expect 1

run Scenario2 {
	// An event is subscribed, unsubscribed, and then occurs
  	some e:Event,u:User {subscribe[u,e];unsubscribe[u,e];occur[e]}

} expect 1

run Scenario3 {
	// An event is subscribed by two users and then occurs
  	some disj u1,u2:User, e:Event { subscribe[u1,e];subscribe[u2,e];occur[e]}

} expect 1

run Scenario4 {
	// An user subscribes two events, then both occur, then unsubscribes one of them, and finally reads the notifications
  	some u:User,disj e1,e2:Event {subscribe[u,e1];subscribe[u,e2]; occur[e1];occur[e2];unsubscribe[u,e1];read[u]}

} expect 1

run Scenario5 {
	// An user subscribes the same event twice in a row
  	some u:User,e:Event {subscribe[u,e];subscribe[u,e]}

} expect 0

run Scenario6 {
	// Eventually an user reads nofications twice in a row
  	some u:User{read[u];read[u]}

} expect 0

// Verification 

check OP1 {
	// Users can only have notifications of subscribed events
  	all u:User | always (u.notifications in u.subscriptions)

}

check OP2 {
	// Its not possible to read notifications before some event is subscribed
	all u:User | always (read[u] implies once (some e:Event | subscribe[u,e]) )
}

check OP3 {
	// Unsubscribe undos subscribe
  	

}

check OP4 {
	// Notify is idempotent

}

check OP5 {
	// After reading the notifications it is only possible to read again after some notification on a subscribed event occurs

}
