;;;; readtable.lisp

(cl:in-package :gauche-compat.gauche.interpolate.internal)
(in-readtable :common-lisp)

(defreadtable :gauche-compat.gauche.interpolate
  (:merge :standard)
  (:dispatch-macro-char #\# #\` 
                        (lambda (srm char arg)
                          (declare (ignore char arg))
                          (string-interpolate (cl:read srm t nil t))))
  (:case :upcase))
