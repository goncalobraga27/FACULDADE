/*

Finish the specification of this notification concept,
including its events, scenarios, and operational principles.

*/ 

sig Resource {}

sig User {
	var reservations : set Resource
}

var sig Available in Resource {}

pred reserve[u : User, r : Resource] {
	// Make a reservation

	// Guarda - Quando se pode realizar uma reserva 
	r in Available
	all us : User - u | r not in us.reservations
	// Efects - O que é alterado quando efetuamos uma reserva 
	Available' = Available - r 
	u.reservations' = u.reservations + r 
	// Frame Condition - O que não é alterado nas reservas 
	all us : User - u | us.reservations' = us.reservations 

}

pred cancel[u : User, r : Resource] {
	// Cancel a reservation

	// Guarda - Quando é que se pode realizar uma operação de cancel 
	r in u.reservations 
	// all us : User - u | r not in us.reservations 
	// Efeitos - O que é alterado com o cancel de uma reserva 
	Available' = Available + r 
	u.reservations' = u.reservations - r 
	// Frame conditions - A quilo que não é alterado com a ação 
	all us : User - u | us.reservations' = us.reservations 

}

pred use[u : User, r : Resource] {
	// Use a reserved resource
	// Guarda - Quando é que se pode realizar uma operação de use 
	r in u.reservations 
	// Efeitos - O que é alterado com o use 
	u.reservations' = u.reservations - r 
	// Frame condition - O que não é alterado com o use 
	Available = Available'
	all us : User - u | us.reservations' = us.reservations
}

pred cleanup {
	// Make all used resources available again
	// Guarda - Quando é que se pode realizar uma função de cleanup
	some r : Resource | r not in User.reservations and r not in Available 
	// Efeitos - Aquilo que altera com o cleanup
	all r : Resource | (r not in User.reservations and r not in Available) implies Available' = Available + r 
	// Frame Conditions - Aquilo que não é alterado com o cleanup
	all u : User | u.reservations' = u.reservations 
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
	some u : User , r : Resource {reserve[u,r];use[u,r];cleanup}
} expect 1

run Scenario2 {
	// An user reserves a resource, cancels the reservation, and reserves again
	some u : User , r : Resource {reserve[u,r];cancel[u,r];reserve[u,r]}
} expect 1

run Scenario3 {
	// An user reserves two resources, cancels one, uses the other, and finally a cleanup occurs
	some u : User , disj r1,r2 : Resource {reserve[u,r1];reserve[u,r2];cancel[u,r1];use[u,r2];cleanup}
} expect 1

run Scenario4 {
	// Two users try to reserve the same resource
	some disj u1,u2 : User , r : Resource {reserve[u1,r];reserve[u2,r]}
} expect 0

run Scenario5 {
	// Eventually a cleanup is performed twice in a row
	{cleanup;cleanup}
} expect 0

// Verification

check OP1 {
	// Reserved resources aren't available
	all r : Resource | always( r in User.reservations implies r not in Available)
}

check OP2 {
	// Used resources were reserved before
	all r : Resource | all u : User | always(use[u,r] implies once reserve[u,r])
}

check OP3 {
	// Used resources can only be reserved again after a cleanup
	all r : Resource | all u : User | always(use[u,r] implies after cleanup and reserve[u,r] implies once cleanup)
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
	// Used resources were not canceled since being reserved

}

check OP8 {
	// Reserved resources can be used while not used or canceled

}

check OP9 {
	// The first event to occur will be a reservation

}

check OP10 {
	// If cleanups and cancels never occur the available resources keep diminishing

}
