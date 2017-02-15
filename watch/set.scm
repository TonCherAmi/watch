(define-module (watch set)
  #:export     (rename-show-db
                set-show-path-db
                set-current-episode-index-db
                jump-to-next-episode-db
                jump-to-previous-episode-db)
  #:use-module (watch show-utils))


;; ------------------------------------------------------ ;;
;; Rename a show in the db.                               ;;
;; ------------------------------------------------------ ;;
;; #:param: old-show-name - a string representing         ;; 
;;          the name of the show that is being renamed    ;;
;; #:param: new-show-name - a string representing the new ;;
;;          name that the show will bear                  ;;
;; ------------------------------------------------------ ;;
(define (rename-show-db old-show-name new-show-name)
  (let ((new-show-list
          (let* ((show-list-db (read-show-list-db))
                 (new-show
                   (let ((show-db (find-show old-show-name show-list-db)))
                     (if (not show-db)
                       (throw 'show-not-found-exception
                              (format #f "cannot rename '~a': No such show" old-show-name))
                       (make-show new-show-name 
                                  (show:path show-db)
                                  (show:current-episode show-db))))))
            (cons new-show (remove-show old-show-name show-list-db)))))
    (write-show-list-db new-show-list)))

;; ------------------------------------------------------ ;;
;; Set a new path for a show.                             ;;
;; ------------------------------------------------------ ;;
;; #:param: show-name - a string representing the name of ;;
;;          the show whose path is being set              ;;
;; #:param: new-show-path - a string representing the new ;;
;;          path to the show directory                    ;;
;; ------------------------------------------------------ ;;
(define (set-show-path-db show-name new-show-path)
  (let ((new-show-list
          (let* ((show-list-db (read-show-list-db))
                 (new-show
                   (let ((show-db (find-show show-name show-list-db)))
                     (if (not show-db)
                       (throw 'show-not-found-exception
                              (format #f "cannot set path for '~a': No such show" show-name))
                       (make-show (show:name show-db)
                                  new-show-path
                                  (show:current-episode show-db))))))
            (if (show:current-episode-out-of-bounds? new-show)
              (throw 'episode-out-of-bounds-exception
                     (format #f "cannot set path for '~a': Episode out of bounds" show-name))
              (cons new-show (remove-show show-name show-list-db))))))
    (write-show-list-db new-show-list)))

;; ------------------------------------------------------ ;;
;; Set current episode index of show called show-name     ;;
;; in the db.                                             ;;
;; ------------------------------------------------------ ;;
;; #:param: show-name - a string representing the name of ;;
;;          the show whose index is being modified        ;;
;; #:param: new-index - an integer representing the new   ;;
;;          index that will be set                        ;;
;; ------------------------------------------------------ ;;
(define (set-current-episode-index-db show-name new-index)
  (let ((new-show-list
          (let* ((show-list-db (read-show-list-db))
                 (new-show 
                   (let ((show-db (find-show show-name show-list-db)))
                     (if (not show-db)
                       (throw 'show-not-found-exception
                              (format #f "cannot set current episode for '~a': No such show" show-name))
                       (make-show (show:name show-db)
                                  (show:path show-db)
                                  new-index)))))
            (if (show:current-episode-out-of-bounds? new-show)
              (throw 'episode-out-of-bounds-exception
                     (format #f "cannot set current episode for '~a': Episode out of bounds" show-name))
              (cons new-show (remove-show show-name show-list-db))))))
    (write-show-list-db new-show-list)))

;; ------------------------------------------------------ ;;
;; Jump to next episode of show called show-name.         ;;
;;                                                        ;;
;; Essentially what this does is it increments current-   ;;
;; episode index of the specified show and writes         ;;
;; the result to the show db.                             ;;
;; ------------------------------------------------------ ;;
;; #:param: show-name - a string representing the name of ;;
;;          the show whose index is being incremented     ;;
;; ------------------------------------------------------ ;;
(define (jump-to-next-episode-db show-name)
  (let ((new-show-list
          (let* ((show-list-db (read-show-list-db))
                 (new-show
                   (let ((show-db (find-show show-name show-list-db)))
                     (if (not show-db)
                       (throw 'show-not-found-exception
                              (format #f "cannot jump to next episode of '~a': No Such show" show-name))
                       (show:current-episode-inc show-db)))))
            (cons new-show (remove-show show-name show-list-db)))))
    (write-show-list-db new-show-list)))

;; ------------------------------------------------------ ;;
;; Jump to previous episode of show called show-name.     ;;
;;                                                        ;;
;; Essentially what this does is it decrements current-   ;;
;; episode index of the specified show and writes         ;;
;; the result to the show db.                             ;;
;; ------------------------------------------------------ ;;
;; #:param: show-name - a string representing the name of ;;
;;          the show whose index is being decremented     ;;
;; ------------------------------------------------------ ;;
(define (jump-to-previous-episode-db show-name)
  (let ((new-show-list
          (let* ((show-list-db (read-show-list-db))
                 (new-show
                   (let ((show-db (find-show show-name show-list-db)))
                     (if (not show-db)
                       (throw 'show-not-found-exception
                              (format #f "cannot jump to previous episode of '~a': No Such show" show-name))
                       (show:current-episode-dec show-db)))))
            (cons new-show (remove-show show-name show-list-db)))))
    (write-show-list-db new-show-list)))
