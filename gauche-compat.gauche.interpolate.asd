;;;; gauche-compat.gauche.interpolate.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :gauche-compat.gauche.interpolate
  :serial t
  :depends-on (:fiveam
               :named-readtables
               :rnrs-compat
               :srfi-14)
  :components ((:file "package")
               (:file "gauche-compat.gauche.interpolate")
               (:file "readtable")))

(defmethod perform ((o test-op) (c (eql (find-system :gauche-compat.gauche.interpolate))))
  (load-system :gauche-compat.gauche.interpolate)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :gauche-compat.gauche.interpolate.internal :gauche-compat.gauche.interpolate))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

