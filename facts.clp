; price
; is_big_company
;   - yes -> is_party_game
;     - yes -> is_obscene_things_acceptable
;   - no -> single | duel | only_not_duel
; is_fancy_components
; is_agressve_competitiveness
;   - yes
;   - no -> competitive | cooperative | players_vs_game


(deftemplate board_game
	(slot name (type STRING)
		(default ?NONE))
	(slot is_for_big_company (type SYMBOL) ; TRUE, FALSE
		(default ?NONE))
	(slot players_type (type SYMBOL) ; single, duel, only_not_duel
		(default ?NONE))
	(slot is_fancy_components (type SYMBOL) ; TRUE, FALSE
		(default ?NONE))
	(slot is_agressve_competitiveness (type SYMBOL) ; TRUE, FALSE
		(default ?NONE))
  (slot competitiveness (type SYMBOL) ; competitive, cooperative, players_vs_game
    (default ?NONE))
	(slot price (type INTEGER)
		(default ?NONE))
)

(deftemplate party_game
	(slot name (type STRING)
		(default ?NONE))
  (slot is_obscene_things (type SYMBOL) ; TRUE, FALSE
    (default ?NONE))
	(slot price (type INTEGER)
		(default ?NONE))
)

(deffacts party_game "Party games list"
  (party_game (name "500 злобных карт")
              (is_obscene_things TRUE)
              (price 1990))
  (party_game (name "UNO")
              (is_obscene_things FALSE)
              (price 790))
)

(deffacts board_game "Board games list"
  (board_game (name "Цитадели")
              (is_for_big_company TRUE)
              (players_type only_not_duel)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness TRUE)
              (competitiveness competitive)
              (price 990))
  (board_game (name "Агентство <<Время>>")
              (is_for_big_company FALSE)
              (players_type single)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness FALSE)
              (competitiveness players_vs_game)
              (price 2300))
  (board_game (name "Splendor")
              (is_for_big_company FALSE)
              (players_type only_not_duel)
              (is_fancy_components TRUE)
              (is_agressve_competitiveness FALSE)
              (competitiveness competitive)
              (price 3190))
  (board_game (name "Каркассон")
              (is_for_big_company TRUE)
              (players_type only_not_duel)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness TRUE)
              (competitiveness competitive)
              (price 1990))
  (board_game (name "Берсерк. Герои")
              (is_for_big_company FALSE)
              (players_type duel)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness TRUE)
              (competitiveness competitive)
              (price 990))
  (board_game (name "Hive")
              (is_for_big_company FALSE)
              (players_type duel)
              (is_fancy_components TRUE)
              (is_agressve_competitiveness TRUE)
              (competitiveness competitive)
              (price 2990))
  (board_game (name "Blood rage")
              (is_for_big_company TRUE)
              (players_type only_not_duel)
              (is_fancy_components TRUE)
              (is_agressve_competitiveness FALSE)
              (competitiveness competitive)
              (price 1990))
  (board_game (name "Пандемия")
              (is_for_big_company TRUE)
              (players_type only_not_duel)
              (is_fancy_components TRUE)
              (is_agressve_competitiveness FALSE)
              (competitiveness cooperative)
              (price 2990))
  (board_game (name "Ужас Аркхэма")
              (is_for_big_company FALSE)
              (players_type only_not_duel)
              (is_fancy_components FALSE)
              (is_agressve_competitiveness FALSE)
              (competitiveness cooperative)
              (price 6490))
)
