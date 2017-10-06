;; tvsm - a tv show manager.
;; Copyright © 2017 Vasili Karaev
;;
;; This file is part of tvsm.
;;
;; tvsm is free software: you can redistribute  it and/or modify
;; it under the terms of the GNU Lesser General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; tvsm is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of 
;; MERCHENTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public License
;; along with tvsm. If not, see <http://www.gnu.org/licenses/>.

(define-module (tvsm cmd play)
  #:export     (play-show-db)
  #:use-module (tvsm base show)
  #:use-module (tvsm base config)
  #:use-module (tvsm util color))

;; ------------------------------------------------------------------------ ;;
;; Play an episode of a show.                                               ;;
;; ------------------------------------------------------------------------ ;;
;; #:param: show-name :: string - show name                                 ;;
;;                                                                          ;;
;; #:param: increment? :: bool - if #t episode index of a show is           ;;
;;          incremented after it is played                                  ;;
;;                                                                          ;;
;; #:param: episode :: int - number of the episode which is, if specified,  ;;
;;          played instead of the current episode                           ;;
;; ------------------------------------------------------------------------ ;;
(define* (play-show-db show-name #:key (increment? #t) (episode #f))
  (call-with-show-list
    #:overwrite
      increment?
    #:proc
      (lambda (show-list)
        (let* ((show-db (find-show show-name show-list))
               (show
                 (cond
                   ((not show-db)
                    (throw 'show-not-found-exception
                           (format #f "cannot play '~a': No such show" show-name)))
                   (episode
                    (remake-show show-db #:ep/current episode))
                   (else
                    show-db))))
          (if (not (show-playable? show))
            (throw 'show-not-playable-exception
                   (format #f "cannot play '~a': ~a"
                           show-name
                           (if (show:airing? show)
                             "No new episodes"
                             "No episodes left")))
            (let ((episode-path (show:ep/current-path show)))
              (format #t "Playing episode no. ~a of '~a'~%"
                      (colorize-string
                        (number->string (show:ep/current show))
                        'BOLD)
                      (colorize-string
                        (show:name show)
                        'BOLD))
              (catch
                #t
                ;; thunk
                (lambda ()
                  (play-episode episode-path)
                  (cons (show:ep/index-inc show)
                        (remove-show show-name show-list)))
                ;; handler
                (lambda (key message)
                  (throw key (format #f "could not play '~a': ~a" show-name message))))))))))

;; ------------------------------------------------------------ ;;
;; Get absolute path to the current episode of a show.          ;;
;; ------------------------------------------------------------ ;;
;; #:param: show :: show - show                                 ;;
;;                                                              ;;
;; #:return: x :: string - absolute path to the current episode ;;
;; ------------------------------------------------------------ ;;
(define (show:ep/current-path show)
  (let ((format-string (if (string-suffix? "/" (show:path show))
                         "\"~a~a\""
                         "\"~a/~a\"")))
    (format #f format-string
            (show:path show)
            (list-ref (show:ep/list show)
                      (show:ep/index show)))))

;; ------------------------------------------------------------ ;;
;; Play an episode using user-defined media player command.     ;;
;; ------------------------------------------------------------ ;;
;; #:param: episode-path :: string - absolute path to episode   ;;
;; ------------------------------------------------------------ ;;
(define (play-episode episode-path)
  (let ((command (config 'media-player-command)))
    (cond
      ((not command)
       (throw 'command-not-set-exception
              "Media player command is not set"))
      ((or (not (string? command)) (not (string-contains command "~a")))
       (throw 'command-malformed-exception
              "Media player command is malformed"))
      ((not (zero? (system (format #f command episode-path))))
       (throw 'command-failed-exception
              "Media player command failed")))))
