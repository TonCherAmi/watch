(define-module (watch config)
  #:export (home-directory
            resources-directory
            show-database-path
            ask-on-existing-show-overwrite?))

(define home-directory (string-append (getenv "HOME") "/"))

;(define resources-directory (string-append home-directory ".local/share/watch"))
; Development ONLY!
(define resources-directory (string-append home-directory "code/scheme-projects/watch"))

(define show-database-path (format #f "~a/~a" resources-directory "shows"))

(define ask-on-existing-show-overwrite? #t)
