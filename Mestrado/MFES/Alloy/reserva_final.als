/*

Finish the specification of this reservation concept,
including its events, scenarios, and operational principles.

*/ 

sig Resource {}

sig User {
	var reservations : set Resource
}

var sig Available in Resource {}

pred reserve[u : User, r : Resource] {
	// Make a reservation
	// Guard - Pré condição para que a reserva possa ser efetuada
	// Para que um recurso possa ser reservado, este têm de estar disponível 
	r in Available 
	all ou: User - u | r not in ou.reservations
	// Efects - Condições que são alteradas na reserva de um recurso por parte de um User u 
	Available' = Available - r 
	u.reservations' = u.reservations + r 
	// Frame Condictions - Condições que não são alteradas no processo de reserva de um recurso
	all x:User-u | x.reservations'= x.reservations
}

pred cancel[u : User, r : Resource] {
	// Cancel a reservation
	// Guard - Pré condição para que a reserva possa ser cancelada 
	r in u.reservations
	// Efects - Condições que são alteradas no cancelamento de uma reserva de um recurso por parte de um User u
  	Available' = Available + r 
  	u.reservations' = u.reservations - r 
	// Frame Condictions - Condições que não são alteradas no processo cancelamento de reserva de um recurso
  	all x:User-u | x.reservations'= x.reservations
}

pred use[u : User, r : Resource] {
	// Use a reserved resource
	// Guard - Pré condição para que o recurso possa ser usado 
	r in u.reservations
	// Efects - Condições que são alteradas no uso de um recurso por parte de um User u
	u.reservations' = u.reservations - r
	// Frame Condictions - Condições que não são alteradas no uso de um recurso
	Available' = Available
	all x:User-u | x.reservations'= x.reservations
}

pred cleanup {
	// Make all used resources available again
	Available' = (Available-User.reservations) + Available 
	all u: User | u.reservations' = u.reservations
}

pred stutter {
	Available' = Available
	reservations' = reservations
}

fact {
	Available = Resource
	no reservations
	always {
		stutter
		or 
		cleanup
		or 
		(some u : User , r : Resource| reserve[u,r] or cancel[u,r] or use[u,r])
	}
}

// Validation

run Example {
	// Empty run to be used for simulation
}

run Scenario1 {
	// An user reserves a resource, uses it, and finally a cleanup occurs
	some u : User , r : Resource { reserve[u,r] ; use[u,r];cleanup}

} expect 1

run Scenario2 {
	// An user reserves a resource, cancels the reservation, and reserves again
	some u : User, r : Resource { reserve[u,r];cancel[u,r]; reserve[u,r]}

} expect 1

run Scenario3 {
	// An user reserves two resources, cancels one, uses the other, and finally a cleanup occurs
	some u : User, r1,r2 : Resource {reserve[u,r1];reserve[u,r2];cancel[u,r1];use[u,r2];cleanup}

} expect 1

run Scenario4 {
	// Two users try to reserve the same resource
	some u1,u2: User, r : Resource {reserve[u1,r];reserve[u2,r]}

} expect 0

run Scenario5 {
	// Eventually a cleanup is performed twice in a row
	{cleanup;cleanup}

} expect 0

// Verification

check OP1 {
	// Reserved resources aren't available
	all r: Resource | always{(r in User.reservations implies r not in Available)}

}

check OP2 {
	// Used resources were reserved before
	all u : User , r : Resource | use[u,r] implies before{reserve[u,r]}
}

check OP3 {
	// Used resourcse can only be reserved again after a cleanup
	all r : Resource | some u : User | reserve[u,r] implies before{cleanup}

}

check OP4 {
	// After a cleanup all unreserved resources are available

}

check OP5 {
	// Cancel undoes reserve

}

check OP6 {
	// If a cleanup occurs some resource was used before

}

check OP7 {
	// Used resource were not canceled since being reserved

}

check OP8 {
	// Reserved resources can be used while not used or cenceled

}

check OP9 {
	// The first event to occur will be a reservation

}

check OP10 {
	// If cleanups and cancels never occur the available resources keep diminishing

}
