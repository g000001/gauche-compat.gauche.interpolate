;;;; gauche-compat.gauche.interpolate.lisp

(cl:in-package :gauche-compat.gauche.interpolate.internal)

(def-suite gauche-compat.gauche.interpolate)

(in-suite gauche-compat.gauche.interpolate)
;;;
;;; interpolate.scm - string interpolation; to be autoloaded
;;;
;;;   Copyright (c) 2000-2012  Shiro Kawai  <shiro@acm.org>
;;;
;;;   Redistribution and use in source and binary forms, with or without
;;;   modification, are permitted provided that the following conditions
;;;   are met:
;;;
;;;   1. Redistributions of source code must retain the above copyright
;;;      notice, this list of conditions and the following disclaimer.
;;;
;;;   2. Redistributions in binary form must reproduce the above copyright
;;;      notice, this list of conditions and the following disclaimer in the
;;;      documentation and/or other materials provided with the distribution.
;;;
;;;   3. Neither the name of the authors nor the names of its contributors
;;;      may be used to endorse or promote products derived from this
;;;      software without specific prior written permission.
;;;
;;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;;   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;;   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;;   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;;   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;;   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;;;   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;;   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;;   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;;   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;;   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;;

;;;
;;; 2012-09-18: Ported to Common Lisp by CHIBA Masaomi.

;;; #`"The value is ,|foo|." => (string-append "The value is " foo ".")
;;;


(defgeneric x->string (obj))

(defmethod x->string (obj)
  (write-to-string obj))

(defmethod x->string ((obj cl:string))
  obj)

(defmethod x->string ((obj cl:symbol))
  (cl:string obj))

(defmethod x->string ((obj cl:number))
  (write-to-string obj))


(let ((rt (copy-readtable nil)))
  ;; TODO:
  ;; (setf (readtable-case  rt) :preserve)
  (set-macro-character #\| (lambda (s c) 
                             (declare (ignore c))
                             (car (read-delimited-list #\| s t)))
                       nil
                       rt)
  (defun gauche-read (&optional (stream *standard-input*))
    (let ((*readtable* rt))
      (read stream))))


(define-function (string-interpolate str)
  (if (string? str)
      (%string-interpolate str)
      (error "malformed string-interpolate: ~s"
             (list 'string-interpolate str))) )


(define-function (%string-interpolate str)
  (with-local-define-function 
    (define-function (accum c acc)
      (cond ((eof-object? c) (list (cl:get-output-stream-string acc)))
            ((char=? c #\,)
             (let ((c2 (peek-char)))
               (cond ((eof-object? c2) (write-char c acc) (accum c2 acc))
                     ((char=? c2 #\,)
                      (write-char (read-char) acc) (accum (read-char) acc))
                     ((char-set-contains? 
                       ;; #[\x00-\x20\),\;\\\]\}\x7f]
                       (load-time-value 
                        (let ((ans '() ))
                          (dotimes (i #x20)
                            (push (code-char i) ans) )
                          (setq ans (nconc (coerce "),;\\]}" 'cl:list) ans))
                          (push (code-char #x7f) ans)
                          (list->char-set ans) ))
                       c2 )
                      (write-char c acc) (accum (read-char) acc))
                     (else
                      (cons (cl:get-output-stream-string acc) (insert)) ))))
            (else
             (write-char c acc) (accum (read-char) acc))))
    (define-function (insert)
      (let* ((item
              (handler-case (gauche-read)
                ((cl:or end-of-file reader-error) (e)
                  (declare (ignore e))
                  (error "unmatched parenthesis in interpolating string: ~s" str) )))
             (rest
              (accum (read-char) (cl:make-string-output-stream)) ))
        (cons `(x->string ,item) rest) ))
    :in
    (cons 'string-append
          (cl:with-input-from-string (*standard-input* str)
            (accum (read-char) (cl:make-string-output-stream)) ))))


;;; eof
