;;;; package.lisp

(cl:in-package :cl-user)

(defpackage :gauche-compat.gauche.interpolate
  (:use)
  (:export :string-interpolate))

(defpackage :gauche-compat.gauche.interpolate.internal
  (:use :gauche-compat.gauche.interpolate :rnrs-user :named-readtables :fiveam
        :srfi-14))

