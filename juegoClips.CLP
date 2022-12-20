(deftemplate habilidad
	(slot nombre)	
	(slot dano)
	(slot elemento)
	(slot mana)
)
(deftemplate personajes
	(slot nombre (type STRING))
	(multislot habilidades)
	(slot vida (type INTEGER)(range 25 100))
	(slot mana (type INTEGER)(range 20 200))
)
(deftemplate enemigo
	(slot nombre)
	(slot vida)
	(slot ataque)
	(slot debilidad)
)

(deffacts iniciales (habilidad (nombre ataque)(dano 10)(elemento normal)(mana 0))(habilidad (nombre defensa)(dano 0)(elemento normal)(mana 5))(personajes (nombre "guerrero")(habilidades ataque defensa)(vida 30)(mana 20))(enemigo (nombre "esqueleto")(vida 50)(ataque 10)(debilidad normal))(enemigo (nombre "zombie")(vida 80)(ataque 20)(debilidad fuego))(esperando)(enemigoActual "esqueleto"))


(defrule defender
	?defendiendo <-(guerrero D)
	=>
	(printout t "El guerrero se defiende" crlf)
	(retract ?defendiendo)
	(assert (ataque))
	(assert (defensa))
)

(defrule huir
	?huiendo <- (guerrero H)
	=>
	(printout t "La huida no ha sido implementada. El guerrero se encuentra confundido y el enemigo se aprovecha" crlf)
	(retract ?huiendo)
	(assert (ataque))
)

(defrule restandoVida
	?ataque <-(guerrero A)
	(enemigoActual ?ene)
	?enemigo <-(enemigo (nombre ?ene)(vida ?x)(debilidad ?deb))
	(habilidad (nombre ataque)(dano ?y)(elemento ?elemento))
	=>
	(bind ?total(- ?x ?y))
	(modify ?enemigo (vida ?total))
	(printout t "Al enemigo le quedan " ?total " de vida" crlf)
	(retract ?ataque)
	(assert (ataque))
)

(defrule restandoVidaCritico
	(declare (salience 100))
	(enemigoActual ?ene)
	?ataque <-(guerrero A)
	?enemigo <-(enemigo (nombre ?ene)(vida ?x)(debilidad ?deb))
	(habilidad (nombre ataque)(dano ?y)(elemento ?elemento))
	(test(eq ?elemento ?deb))
	=>
	(bind ?total(- ?x (* ?y 2)))
	(printout t "Al enemigo le quedan " ?total " de vida" crlf)
	(modify ?enemigo (vida ?total))
	(retract ?ataque)
	(assert (ataque))
)

(defrule victoria
	(declare (salience 100))
	?ataque<-(ataque)
	(enemigoActual ?ene)
	(enemigo (nombre ?ene)(vida ?x))
	(test(<= ?x 0))
	=>
	(printout t "Has derrotado a " ?ene crlf)
	(retract ?ataque)
)

(defrule turnoGuerrero
	?esperando<-(esperando)
	=>
	(printout t "¿Que hara el guerrero? atacar (A), defender (D) o huir (H)" crlf)
	(assert (guerrero (read)))
	(retract ?esperando)
)

(defrule comprobarTurno
	?turno <-(guerrero ?accion)
	(not (guerrero D))
	(not (guerrero A))
	(not (guerrero H))
	=>
	(printout t "Error en la accion del guerrero" crlf)
	(assert (esperando))
	(retract ?turno)
)

(defrule enemigoAtaque
	?ataque<-(ataque)
	(not (defensa))
	(enemigoActual ?ene)
	(enemigo (nombre ?ene)(ataque ?y))
	?guerrero <-(personajes (nombre "guerrero")(vida ?x))
	=>
	(bind ?total(- ?x ?y))
	(modify ?guerrero (vida ?total))
	(printout t "Te quedan " ?total " de vida" crlf)
	(retract ?ataque)
	(assert (esperando))
)
(defrule enemigoAtaqueCritico
	?ataque<-(ataque)
	(not (defensa))
	(enemigoActual ?ene)
	(enemigo (nombre ?ene)(ataque ?y))
	?guerrero <-(personajes (nombre "guerrero")(vida ?x))
	=>
	(bind ?total(- ?x (* ?y 2)))
	(modify ?guerrero (vida ?total))
	(printout t "Te quedan " ?total " de vida" crlf)
	(retract ?ataque)
	(assert (esperando))
)

(defrule guerreroDefendiendo
	?ataque<-(ataque)
	?defensa<-(defensa)
	(enemigoActual ?ene)
	(enemigo (nombre ?ene)(ataque ?y))
	=>
	(bind ?total (* ?y 2))
	(assert (esperando))
	(retract ?ataque)
	(retract ?defensa)
	(printout t "Te has protegido de un golpe critico de " ?total " de daño" crlf)
	
	
)

(defrule derrota
	(declare (salience 100))
	?esperando<-(esperando)
	(personajes (nombre "guerrero")(vida ?x))
	(test(<= ?x 0))
	=>
	(printout t "Te han derrotado. Fin de la partida" crlf)
	(retract ?esperando)
)