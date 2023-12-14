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

	// Guarda - Especifica quando a leitura das notificações ocorre
	some(u.notifications)
	// Efects - Especifica o que é alterado quando o user lê as notificações
	no(u.notifications')
	// Frame Conditions - Aquilo que não altera na leitura de notificações
	u.subscriptions' = u.subscriptions

}

pred subscribe [u : User, e : Event] {
	// Subscribe an event

	// Guarda - Especifica quando podemos dar subscribe num evento 
	historically e not in u.subscriptions
	// Efects - Especifica o que é alterado quando um user dá subscribe 
	u.subscriptions' = u.subscriptions + e 
	// Frame Conditions - Aquilo que não altera no subscribe 
	u.notifications' = u.notifications



}

pred unsubscribe [u : User, e : Event] {
	// Unsubscribe from a event

	// Guarda - Especifica quando podemos dar unsubscribe num evento 
	historically e in u.subscriptions
	// Efects - Especifica o que é alterado quando um user dá subscribe 
	u.subscriptions' = u.subscriptions - e 
	// Frame Conditions - Aquilo que não altera no subscribe 
	u.notifications' = u.notifications

}

pred occur [e : Event] {
	// Occurrence of an event

	// Guarda - Especifica quando podemos dar occur de um evento
	all u : User | e in u.subscriptions
	// Efects - Especifica o que é alterado quando acontece um occur 
	all u : User | e in u.subscriptions implies u.notifications' = u.notifications + e 
	// Frame Conditions - Aquilo que não altera no occur 
	all u : User | u.subscriptions' = u.subscriptions
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
	some e : Event, u : User {subscribe[u,e];occur[e];read[u]}

} expect 1

run Scenario2 {
	// An event is subscribed, unsubscribed, and then occurs
	some e : Event, u : User {subscribe[u,e];unsubscribed[u,e];occur[e]}
} expect 1

run Scenario3 {
	// An event is subscribed by two users and then occurs
	some e: Event, u1,u2 : User {subscribe[u1,e];subscribe[u2,e];occur[e]}

} expect 1

run Scenario4 {
	// An user subscribes two events, then both occur, then unsubscribes one of them, and finally reads the notifications
	some u : User , e1,e2 : Event {subscribe[u,e1];subscribe[u,e2];occur[e1];occur[e2];unsubscribe[u,e1];read[u]}
} expect 1

run Scenario5 {
	// An user subscribes the same event twice in a row
	some u : User, e : Event {subscribe[u,e];subscribe[u,e]}
} expect 0

run Scenario6 {
	// Eventually an user reads nofications twice in a row
	some u : User {read[u];read[u]}
} expect 0

// Verification 

check OP1 {
	// Users can only have notifications of subscribed events
	all u : User | u.notifications in u.subscriptions
}

check OP2 {
	// Its not possible to read notifications before some event is subscribed
	all u : User | some e: Event | always(read[u] implies once subscribe[u,e])
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
