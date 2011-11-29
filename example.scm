#!/bin/sh
# vim:syntax=scheme filetype=scheme expandtab
GUILE_LOAD_PATH=./ guile -l example.scm
!#
;;; This file implements a simple net-snmp subagent

(use-modules (rnrs bytevectors)
             ((agentx net)     :renamer (symbol-prefix-proc 'net:))
             ((agentx session) :renamer (symbol-prefix-proc 'sess:)))

(define subtree '(1 3 6 1 4 1 18072))

(define test-number 666)
(define test-string "hello world")
(define test-big-number 12345678900)

(define (getters)
  (list (cons (append subtree '(1 0)) (lambda () `(integer . ,test-number)))
        (cons (append subtree '(2 0)) (lambda () `(octet-string . ,(string->utf8 test-string))))
        (cons (append subtree '(3 0)) (lambda () `(counter64 . ,test-big-number)))))

(define (setters)
  (list (cons (append subtree '(1 0)) (lambda (v) (set! test-number v)))
        (cons (append subtree '(2 0)) (lambda (v) (set! test-string (utf8->string v))))))

(define subagent (net:make-subagent "simple" subtree getters setters))

(call-with-new-thread (lambda () (net:loop subagent)))

(let loop ()
  (sleep 5)
  (display "Notify!\n")
  (net:notify subagent
    (list (list 'time-ticks sess:sys-uptime-0 12345)
          (list 'object-identifier sess:snmp-trap-oid-0 '(1 3 6 1 4 1 18072 1 0))
          (list 'octet-string (append subtree '(2 0)) (string->utf8 "HELLO!"))))
  (loop))

