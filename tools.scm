; vim:syntax=scheme expandtab
;;; This file implements some small tools used here and there

(define-module (agentx tools))
(export ignore
        match-prefix
        match-internet-prefix
        endianness
        endianness-of-flags)

(define (ignore x) *unspecified*)

;; Returns either the rest of the string, or #f if no match occur
(define (match-prefix prefix lst)
  (cond ((null? prefix)                lst)
        ((null? lst)                   #f)
        ((eqv? (car lst) (car prefix)) (match-prefix (cdr prefix) (cdr lst)))
        (else #f)))

(define (match-internet-prefix lst) (match-prefix '(1 3 6 1) lst))

(define endianness (make-fluid))
(fluid-set! endianness 'big)

(define (endianness-of-flags flags)
  (if (memq 'network-byte-order flags)
    'big
    'little))


