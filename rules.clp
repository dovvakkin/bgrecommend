(deffunction ask-enum (?question $?allowed-values)
	(printout t ?question crlf)
	(bind ?answer (read))
 	(if (lexemep ?answer) then
    (bind ?answer (lowcase ?answer))
  )
 	(while (not (member$ ?answer ?allowed-values)) do
    (printout t ?question crlf) (bind ?answer (read))
    (if (lexemep ?answer) then
      (bind ?answer (lowcase ?answer))
    )
  )
 	?answer
)

(deffunction ask-int (?question)
	(printout t ?question crlf)
	(bind ?answer (read))
 	(while (not (integerp ?answer)) do
    (printout t "Enter a number" crlf)
    (bind ?answer (read))
	)
 	?answer
)

; price
; is_big_company
;   - yes -> is_party_game
;     - yes -> is_obscene_things_acceptable
;   - no -> single | duel | only_not_duel
; is_fancy_components
; is_agressve_competitiveness
;   - yes

(defrule zero-rule
	(not (result $?)) ; в РП еще нет факта-рекомендации
=>
	(bind ?response (ask-int "How much you want to pay for game?"))
	(assert (result ?response))
)

(defrule is-big-company-rule
  ?data-facts <- (result ?result-price)
  (party_game (name ?)
              (is_obscene_things ?)
              (price ?pg-price))
  (board_game (name ?)
              (is_for_big_company ?)
              (players_type ?)
              (is_fancy_components ?)
              (is_agressve_competitiveness ?)
              (competitiveness ?)
              (price ?bg-price))
  (test
    (or
      (<= ?pg-price ?result-price)
      (<= ?bg-price ?result-price)
    )
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Is your party big (more than 4 players)? (yes/no)" yes no))
  (if (eq ?response yes) then
    (assert (result ?result-price TRUE))
  else
    (assert (result not_party ?result-price FALSE))
  )
)

; -------------party-games-rules-start-here-------------

(defrule is-party-game-rule
  ?data-facts <- (result ?result-price TRUE)
  (party_game (name ?)
              (is_obscene_things ?)
              (price ?pg-price))
  (test
    (<= ?pg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Are you looking for party game? (yes/no)" yes no))
  (if (eq ?response yes) then
    (assert (result party ?result-price))
  else
    (assert (result not_party ?result-price TRUE only_not_duel)) ; big games are not suitable for duels
  )
)

; ask about obscene things only if we really have options
(defrule is-obscene-party-game-rule
  ?data-facts <- (result party ?result-price)
  (party_game (name ?)
              (is_obscene_things TRUE)
              (price ?pg-price1))
  (test
    (<= ?pg-price1 ?result-price)
  )
  (party_game (name ?)
              (is_obscene_things FALSE)
              (price ?pg-price2))
  (test
    (<= ?pg-price2 ?result-price)
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Do you apreciate 18+ jokes? (yes/no)" yes no))
  (if (eq ?response yes) then
    (assert (result party ?result-price TRUE))
  else
    (assert (result party ?result-price FALSE))
  )
)

(defrule only-obscene-rule
  ?data-facts <- (result party ?result-price)
  (party_game (name ?)
              (is_obscene_things TRUE)
              (price ?pg-price1))
  (test
    (<= ?pg-price1 ?result-price)
  )
=>
  (retract ?data-facts)
  (assert (result party ?result-price TRUE))
)

(defrule only-not-obscene-rule
  ?data-facts <- (result party ?result-price)
  (party_game (name ?)
              (is_obscene_things FALSE)
              (price ?pg-price1))
  (test
    (<= ?pg-price1 ?result-price)
  )
=>
  (retract ?data-facts)
  (assert (result party ?result-price FALSE))
)

(defrule print-party-game
  (declare (salience 100))
  ?data-facts <- (result party ?result-price ?result-obscene)
  (party_game (name ?result-name)
              (is_obscene_things ?result-obscene)
              (price ?pg-price))
  (test
    (<= ?pg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (printout t "I recommend party game \"" ?result-name "\" for you" crlf)
  (printout t "Which costs " ?pg-price crlf)
  (if (eq ?result-obscene TRUE) then
    (printout t "Be careful! This game contain obscene elements!" crlf)
  )
  (halt)
)

; -------------party-games-rules-end-here-------------




; -------------board-game-rules-start-here-------------
(defrule players-type-rule
  ?data-facts <- (result not_party ?result-price ?result-big-company)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?)
              (is_fancy_components ?)
              (is_agressve_competitiveness ?)
              (competitiveness ?)
              (price ?bg-price))
  (test
    (<= ?bg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Tell me about your party. Do you want to play alone or in duel format? (single/duel/only_not_duel)" single duel only_not_duel))
  (if (eq ?response single) then
    (assert (result single ?result-price))
  else
    (assert (result not_party ?result-price ?result-big-company ?response))
  )
)


; print single board games
(defrule print-single-game
  (declare (salience 100))
  ?data-facts <- (result single ?result-price)
  (board_game (name ?result-name)
              (is_for_big_company FALSE)
              (players_type single)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness FALSE)
              (competitiveness players_vs_game)
              (price ?bg-price))
  (test
    (<= ?bg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (printout t "I recommend single player game \"" ?result-name "\" for you" crlf)
  (printout t "Which costs " ?bg-price crlf)
  (halt)
)


(defrule competitiveness-rule
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components ?)
              (is_agressve_competitiveness ?)
              (competitiveness ?)
              (price ?bg-price))
  (test
    (<= ?bg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Do you prefer competitive or cooperative (maybe versus game master) games? (competitive/cooperative/players_vs_game)" competitive cooperative players_vs_game))
  (if (eq ?response competitive) then
    (assert (result
             not_party
             ?result-price
             ?result-big-company
             ?result-players
             ?response))
  else
    (assert (result
             not_party
             ?result-price
             ?result-big-company
             ?result-players
             ?response
             FALSE))
  )
)


; ask about agressive games only if we really have options
(defrule is-agressive-competitiveness
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  competitive)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type only_not_duel)
              (is_fancy_components ?result-components)
              (is_agressve_competitiveness TRUE)
              (competitiveness competitive)
              (price ?bg-price1))
  (test
    (<= ?bg-price1 ?result-price)
  )
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type only_not_duel)
              (is_fancy_components ?result-components)
              (is_agressve_competitiveness FALSE)
              (competitiveness competitive)
              (price ?bg-price2))
  (test
    (<= ?bg-price2 ?result-price)
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Do you like games with high, argessive competitiveness? (yes/no)" yes no))
  (if (eq ?response yes) then
    (assert (result
             not_party
             ?result-price
             ?result-big-company
             ?result-players
             competitive
             TRUE))
  else
    (assert (result
             not_party
             ?result-price
             ?result-big-company
             ?result-players
             competitive
             FALSE))
  )
)


(defrule only-no-agressive-rule
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  competitive)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components ?result-components)
              (is_agressve_competitiveness FALSE)
              (competitiveness competitive)
              (price ?bg-price))
  (test
    (<= ?bg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (assert (result
           not_party
           ?result-price
           ?result-big-company
           ?result-players
           competitive
           FALSE))
)

(defrule only-agressive-rule
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  competitive)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components ?result-components)
              (is_agressve_competitiveness TRUE)
              (competitiveness competitive)
              (price ?bg-price))
  (test
    (<= ?bg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (assert (result
           not_party
           ?result-price
           ?result-big-company
           ?result-players
           competitive
           TRUE))
)


; ask about components only if we really have options
(defrule is-fancy-components-rule
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  ?result-competitiveness
                  ?result-is-agressive)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components TRUE)
              (is_agressve_competitiveness ?result-is-agressive)
              (competitiveness ?result-competitiveness)
              (price ?bg-price1))
  (test
    (<= ?bg-price1 ?result-price)
  )
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness ?result-is-agressive)
              (competitiveness ?result-competitiveness)
              (price ?bg-price2))
  (test
    (<= ?bg-price2 ?result-price)
  )
=>
  (retract ?data-facts)
  (bind ?response (ask-enum "Are you interested in games with fancy components (miniatures, gems, etc)? (yes/no)" yes no))
  (if (eq ?response yes) then
    (assert (result
             not_party
             ?result-price
             ?result-big-company
             ?result-players
             ?result-competitiveness
             ?result-is-agressive
             TRUE))
  else
    (assert (result
             not_party
             ?result-price
             ?result-big-company
             ?result-players
             ?result-competitiveness
             ?result-is-agressive
             FALSE))
  )
)

(defrule only-no-fancy-components-rule
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  ?result-competitiveness
                  ?result-is-agressive)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness ?result-is-agressive)
              (competitiveness ?result-competitiveness)
              (price ?bg-price1))
  (test
    (<= ?bg-price1 ?result-price)
  )
=>
  (retract ?data-facts)
  (assert (result
           not_party
           ?result-price
           ?result-big-company
           ?result-players
           ?result-competitiveness
           ?result-is-agressive
           FALSE))
)


(defrule only-fancy-components-rule
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  ?result-competitiveness
                  ?result-is-agressive)
  (board_game (name ?)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components TRUE)
              (is_agressve_competitiveness ?result-is-agressive)
              (competitiveness ?result-competitiveness)
              (price ?bg-price1))
  (test
    (<= ?bg-price1 ?result-price)
  )
=>
  (retract ?data-facts)
  (assert (result
           not_party
           ?result-price
           ?result-big-company
           ?result-players
           ?result-competitiveness
           ?result-is-agressive
           TRUE))
)


(defrule print-board-game
  (declare (salience 100))
  ?data-facts <- (result
                  not_party
                  ?result-price
                  ?result-big-company
                  ?result-players
                  ?result-competitiveness
                  ?result-is-agressive
                  ?result-components)
  (board_game (name ?result-name)
              (is_for_big_company ?result-big-company)
              (players_type ?result-players)
              (is_fancy_components ?result-components)
              (is_agressve_competitiveness ?result-is-agressive)
              (competitiveness ?result-competitiveness)
              (price ?bg-price))
  (test
    (<= ?bg-price ?result-price)
  )
=>
  (retract ?data-facts)
  (printout t "I recommend game \"" ?result-name "\" for you" crlf)
  (printout t "Which costs " ?bg-price crlf)
  (if (eq ?result-components TRUE) then
    (printout t "This game has pretty nice components, you will like them!" crlf)
  )
  (if (eq ?result-is-agressive TRUE) then
    (printout t "But be careful, process in this game is very rough and argessive. Don't break up with your friends!" crlf)
  )
  (halt)
)



(defrule fuckup
  (declare (salience -100))
=>
  (printout t "Nothing matching your parameters found :(" crlf)
  (printout t "Try change it or increase budget" crlf)
  (halt)
)
