;; Copyright (c) 2008-2013 Robert Virding
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;; File    : andor_SUITE.lfe
;; Author  : Robert Virding
;; Purpose : Guard test suite.

;; This is a direct translation of andor_SUITE.erl from R14B02 except
;; for tests with guards containing ';'. We have usually removed these
;; or been careful with these as they don't handle errors the same way
;; as 'or' (which is all we have).
;;
;; Note that some of these tests are not LFE specific but more general
;; guard tests but we include them anyway for completeness.

(include-file "test_server.lfe")

(defmodule andor_SUITE
  (export (all 0) (suite 0) (groups 0) (init_per_suite 1) (end_per_suite 1)
	  (init_per_group 2) (end_per_group 2)
	  (t_case 1) (t_and_or 1) (t_andalso 1) (t_orelse 1) (inside 1)
	  (overlap 1) (combined 1) (in_case 1) (before_and_inside_if 1)
	  ))

(defmacro MODULE () `'andor_SUITE)

(defun all ()
  ;; (: test_lib recompile (MODULE))
  (list 't_case 't_and_or 't_andalso 't_orelse
	'inside 'overlap 'combined 'in_case 'before_and_inside_if))

;;(defun suite () (list (tuple 'ct_hooks (list 'ts_install_cth))))
(defun suite () ())

(defun groups () ())

(defun init_per_suite (config) config)

(defun end_per_suite (config) 'ok)

(defun init_per_group (name config) config)

(defun end_per_group (name config) config)

(defun t_case
  (['suite] ())
  (['doc] '"Test in case.")
  ([config] (when (is_list config))
   ;; We test boolean cases almost but not quite like cases
   ;; generated by andalso/orelse.
   (line (test-pat 'less (t-case-a 1 2)))
   (line (test-pat 'not_less (t-case-a 2 2)))

   (line (test-pat (tuple 'EXIT (tuple (tuple 'case_clause 'false) _))
		   (catch (t-case-b #(x y z) 2))))
   (line (test-pat (tuple 'EXIT (tuple (tuple 'case_clause 'true) _))
		   (catch (t-case-b 'a 'a))))

   (line (test-pat 'eq (t-case-c 'a 'a)))
   (line (test-pat 'ne (t-case-c 42 ())))

   (line (test-pat 't (t-case-d 'x 'x 'true)))
   (line (test-pat 'f (t-case-d 'x 'x 'false)))
   (line (test-pat 'f (t-case-d 'x 'y 'true)))
   (line (test-pat (tuple 'EXIT (tuple 'badarg _))
		   (catch (t-case-d 'x 'y 'blurf))))

   (line (test-pat 'true (catch (t-case-e #(a b) #(a b)))))
   (line (test-pat 'false (catch (t-case-e #(a b) 42))))

   (line (test-pat 'true (t-case-xy 42 100 700)))
   (line (test-pat 'true (t-case-xy 42 100 'whatever)))
   (line (test-pat 'false (t-case-xy 42 'wrong 700)))
   (line (test-pat 'false (t-case-xy 42 'wrong 'whatever)))

   (line (test-pat 'true (t-case-xy 0 'whatever 700)))
   (line (test-pat 'true (t-case-xy 0 100 700)))
   (line (test-pat 'false (t-case-xy 0 'whatever 'wrong)))
   (line (test-pat 'false (t-case-xy 0 100 'wrong)))

   'ok))

(defun t-case-a (a b)
  (case (< a b)
    ((cons _ _) 'ok)
    ('true 'less)
    ('false 'not_less)
    (#(a b c) 'ok)
    (_ 'ok)))

(defun t-case-b (a b)
  (case (=:= a b)
    ('blurf 'ok)))

(defun t-case-c (a b)
  (case (not (=:= a b))
    ('true 'ne)
    ('false 'eq)))

(defun t-case-d (a b x)
  (case (and (=:= a b) x)
    ('true 't)
    ('false 'f)))

(defun t-case-e (a b)
  (case (=:= a b)
    (bool (when (is_tuple a)) (id bool))))

(defun t-case-xy (x y z)
  (let* ((r0 (t-case-x x y z))
	 (res (when (=:= res r0)) (t-case-y x y z)))
    res))

(defun t-case-x (x y z)
  (case (=:= (abs x) 42)
    ('true (=:= y 100))
    ('false (=:= z 700))))

(defun t-case-y (x y z)
  (case (=:= (abs x) 42)
    ('false (=:= z 700))
    ('true (=:= y 100))))

(defun t_and_or
  ([config] (when (is_list config))
   (line (test-pat 'true (and 'true 'true)))
   (line (test-pat 'false (and 'true 'false)))
   (line (test-pat 'false (and 'false 'true)))
   (line (test-pat 'false (and 'false 'false)))

   (line (test-pat 'true (and (id 'true) 'true)))
   (line (test-pat 'false (and (id 'true) 'false)))
   (line (test-pat 'false (and (id 'false) 'true)))
   (line (test-pat 'false (and (id 'false) 'false)))

   (line (test-pat 'true (and 'true (id 'true))))
   (line (test-pat 'false (and 'true (id 'false))))
   (line (test-pat 'false (and 'false (id 'true))))
   (line (test-pat 'false (and 'false (id 'false))))

   (line (test-pat 'true (or 'true 'true)))
   (line (test-pat 'true (or 'true 'false)))
   (line (test-pat 'true (or 'false 'true)))
   (line (test-pat 'false (or 'false 'false)))

   (line (test-pat 'true (or (id 'true) 'true)))
   (line (test-pat 'true (or (id 'true) 'false)))
   (line (test-pat 'true (or (id 'false) 'true)))
   (line (test-pat 'false (or (id 'false) 'false)))

   (line (test-pat 'true (or 'true (id 'true))))
   (line (test-pat 'true (or 'true (id 'false))))
   (line (test-pat 'true (or 'false (id 'true))))
   (line (test-pat 'false (or 'false (id 'false))))

   'ok))

(defmacro GUARD (t)
  `(eif ,t 'true 'true 'false))

(defun t_andalso
  ([config] (when (is_list config))
   (let* ((bs '(true false))
	  (ps (lc ((<- x bs) (<- y bs))
		(tuple x y))))
     (: lists foreach (lambda (p) (t-andalso-1 p)) ps))

   (line (test-pat 'true (andalso 'true 'true)))
   (line (test-pat 'false (andalso 'true 'false)))
   (line (test-pat 'false (andalso 'false 'true)))
   (line (test-pat 'false (andalso 'false 'false)))

   (line (test-pat 'true (GUARD (andalso 'true 'true))))
   (line (test-pat 'false (GUARD (andalso 'true 'false))))
   (line (test-pat 'false (GUARD (andalso 'false 'true))))
   (line (test-pat 'false (GUARD (andalso 'false 'false))))

   (line (test-pat 'false (andalso 'false 'glurf)))
   (line (test-pat 'false (andalso 'false (exit 'exit_now))))

   (line (test-pat 'true (andalso (not (id 'false)) (not (id 'false)))))
   (line (test-pat 'false (andalso (not (id 'false)) (not (id 'true)))))
   (line (test-pat 'false (andalso (not (id 'true)) (not (id 'false)))))
   (line (test-pat 'false (andalso (not (id 'true)) (not (id 'true)))))

   (line (test-pat (tuple 'EXIT (tuple 'badarg _))
		   (catch (andalso (not (id 'glurf)) (id 'true)))))
   (line (test-pat (tuple 'EXIT (tuple 'badarg _))
		   (catch (andalso (not (id 'false)) (not (id 'glurf))))))

   (line (test-pat 'false (andalso (id 'false) (not (id 'glurf)))))
   (line (test-pat 'false (andalso 'false (not (id 'glurf)))))

   'ok))

(defun t-andalso-1
  ([(tuple x y)]
   (: lfe_io format '"(andalso ~w ~w): " (list x y))
   (let* ((v0 (andalso (echo x) (echo y)))
	  (v1 (when (=:= v0 v1))
	      (eif (andalso x y) 'true 'true 'false)))
     (check v1 (and x y)))))

(defun t_orelse
  ([config] (when (is_list config))
   (let* ((bs '(true false))
	  (ps (lc ((<- x bs) (<- y bs)) (tuple x y))))
     (: lists foreach (lambda (p) (t-orelse-1 p)) ps))

   (line (test-pat 'true (orelse 'true 'true)))
   (line (test-pat 'true (orelse 'true 'false)))
   (line (test-pat 'true (orelse 'false 'true)))
   (line (test-pat 'false (orelse 'false 'false)))

   (line (test-pat 'true (GUARD (orelse 'true 'true))))
   (line (test-pat 'true (GUARD (orelse 'true 'false))))
   (line (test-pat 'true (GUARD (orelse 'false 'true))))
   (line (test-pat 'false (GUARD (orelse 'false 'false))))

   (line (test-pat 'true (orelse 'true 'glurf)))
   (line (test-pat 'true (orelse 'true (exit 'exit_now))))

   (line (test-pat 'true (orelse (not (id 'false)) (not (id 'false)))))
   (line (test-pat 'true (orelse (not (id 'false)) (not (id 'true)))))
   (line (test-pat 'true (orelse (not (id 'true)) (not (id 'false)))))
   (line (test-pat 'false (orelse (not (id 'true)) (not (id 'true)))))

   (line (test-pat (tuple 'EXIT (tuple 'badarg _))
		   (catch (orelse (not (id 'glurf)) (id 'true)))))
   (line (test-pat (tuple 'EXIT (tuple 'badarg _))
		   (catch (orelse (not (id 'true)) (not (id 'glurf))))))

   (line (test-pat 'true (orelse (id 'true) (not (id 'glurf)))))
   (line (test-pat 'true (orelse 'true (not (id 'glurf)))))

   'ok))

(defun t-orelse-1
  ([(tuple x y)]
   (: lfe_io format '"(orelse ~w ~w): " (list x y))
   (let* ((v0 (orelse (echo x) (echo y)))
	  (v1 (when (=:= v0 v1))
	      (eif (orelse x y) 'true 'true 'false)))
     (check v1 (or x y)))))

(defun inside
  ([config] (when (is_list config))
   (line (test-pat 'true (inside -8 1)))
   (line (test-pat 'false (inside -53.5 -879798)))
   (line (test-pat 'false (inside 1.0 -879)))
   (line (test-pat 'false (inside 59 -879)))
   (line (test-pat 'false (inside -11 1.0)))
   (line (test-pat 'false (inside 100 0.2)))
   (line (test-pat 'false (inside 100 1.2)))
   (line (test-pat 'false (inside -53.5 4)))
   (line (test-pat 'false (inside 1.0 5.3)))
   (line (test-pat 'false (inside 59 879)))

   'ok))

(defun inside (xm ym)
  (let* ((x -10.0)
	 (y -2.0)
	 (w 20.0)
	 (h 4.0)
	 (r0 (inside xm ym x y w h))
	 (r1 (when (=:= r0 r1))
	     (eif (andalso (=< x xm) (< xm (+ x w)) (=< y ym) (< ym (+ y h)))
		  'true 'true 'false)))
    (case (not (id r1))
      (o0
       (let ((o1 (when (=:= o0 o1))
		 (eif (not (andalso (=< x xm) (< xm (+ x w))
				    (=< y ym) (< ym (+ y h))))
		      'true 'true 'false)))
	 o1)))
    (let (((tuple r2 xm2 ym2 x2 y2 w2 h2)
	   (when (=:= r1 r2) (=:= xm xm2) (=:= ym ym2) (=:= x x2)
		 (=:= y y2) (=:= w w2) (=:= h h2))
	   (inside-guard xm ym x y w h)))
      (: lfe_io fwrite
	'"(andalso (=< ~p ~p) (< ~p ~p) (=< ~p ~p) (< ~p ~p)) ==> ~p\n"
	(list x xm xm (+ x w) y ym ym (+ y h) r1)))
    r1))

(defun inside (xm ym x y w h)
  (andalso (=< x xm) (< xm (+ x w)) (=< y ym) (< ym (+ y h))))

(defun inside-guard
  ([xm ym x y w h]
   (when (andalso (=< x xm) (< xm (+ x w)) (=< y ym) (< ym (+ y h))))
   (tuple 'true xm ym x y w h))
  ([xm ym x y w h]
   (tuple 'false xm ym x y w h)))

(defun overlap
  ([config] (when (is_list config))
   (line (test-pat 'true (overlap 7.0 2.0 8.0 0.5)))
   (line (test-pat 'true (overlap 7.0 2.0 8.0 2.5)))
   (line (test-pat 'true (overlap 7.0 2.0 5.3 2)))
   (line (test-pat 'true (overlap 7.0 2.0 0.0 100.0)))

   (line (test-pat 'false (overlap -1 2 -35 0.5)))
   (line (test-pat 'false (overlap -1 2 777 0.5)))
   (line (test-pat 'false (overlap -1 2 2 10)))
   (line (test-pat 'false (overlap 2 10 12 55.3)))

   'ok))

(defun overlap (pos1 len1 pos2 len2)
  (let* ((r0 (case pos1
	       (pos1 (when (orelse (andalso (=< pos2 pos1)
					    (< pos1 (+ pos2 len2)))
				   (andalso (=< pos1 pos2)
					    (< pos2 (+ pos1 len1)))))
		     'true)
	       (pos1 'false)))
	 (r1 (when (=:= r0 r1))
	     (orelse (andalso (=< pos2 pos1)
			      (< pos1 (+ pos2 len2)))
		     (andalso (=< pos1 pos2)
			      (< pos2 (+ pos1 len1)))))
	 (r2 (when (=:= r2 r1))
	     (case pos1
	       (pos1 (when (orelse (andalso (=< pos2 pos1)
					    (< pos1 (+ pos2 len2)))
				   (andalso (=< pos1 pos2)
					    (< pos2 (+ pos1 len1)))))
		     'true)
	       (pos1 'false))))
    (id r2)))

;; -define(COMB(A,B,C), (A andalso B orelse C)).
(defmacro COMB (a b c)
  `(orelse (andalso ,a ,b) ,c))

(defun combined
  ([config] (when (is_list config))
   (line (test-pat 'false (comb 'false 'false 'false)))
   (line (test-pat 'true (comb 'false 'false 'true)))
   (line (test-pat 'false (comb 'false 'true 'false)))
   (line (test-pat 'true (comb 'false 'true 'true)))

   (line (test-pat 'false (comb 'true 'false 'false)))
   (line (test-pat 'true (comb 'true 'true 'false)))
   (line (test-pat 'true (comb 'true 'false 'true)))
   (line (test-pat 'true (comb 'true 'true 'true)))

   (line (test-pat 'false (comb 'false 'blurf 'false)))
   (line (test-pat 'true (comb 'false 'blurf 'true)))
   (line (test-pat 'true (comb 'true 'true 'blurf)))

   (line (test-pat 'false (COMB 'false 'false 'false)))
   (line (test-pat 'true (COMB 'false 'false 'true)))
   (line (test-pat 'false (COMB 'false 'true 'false)))
   (line (test-pat 'true (COMB 'false 'true 'true)))

   (line (test-pat 'false (COMB 'true 'false 'false)))
   (line (test-pat 'true (COMB 'true 'true 'false)))
   (line (test-pat 'true (COMB 'true 'false 'true)))
   (line (test-pat 'true (COMB 'true 'true 'true)))

   ;; This next one crashed the compiler!
   (line (test-pat (tuple 'EXIT (tuple 'if_clause _))
		   (catch (COMB 'true 'blurf 'false))))
   (line (test-pat 'false (COMB 'false 'blurf 'false)))
   (line (test-pat 'true (COMB 'false 'blurf 'true)))
   (line (test-pat 'true (COMB 'true 'true 'blurf)))

   'ok))

(defun comb (a b c)
  (let* ((r0 (orelse (andalso a b) c))
	 (r1 (when (=:= r0 r1))
	     (eif (orelse (andalso a b) c) 'true 'true 'false))
	 (n0 (eif (not (orelse (andalso a b) c)) 'true 'true 'false))
	 (n1 (when (=:= n0 n1))
	     (id (not r1)))
	 (r2 (when (=:= r1 r2))
	     (orelse (andalso a b) c))
	 (r3 (when (=:= r2 r3))
	     (eif (orelse (andalso a b) c) 'true 'true 'false))
	 (n2 (when (=:= n1 n2))
	     (id (not r3)))
	 (r4 (when (=:= r3 r4))
	     (eif (orelse (andalso a b) c) 'true 'true 'false)))
    (id r4)))

;; Test that a boolean expression in a case expression is properly
;; optimized (in particular, that the error behaviour is correct).
(defun in_case
  ([config] (when (is_list config))
   (line (test-pat 'edge_rings (in-case-1 1 1 1 1 1)))
   (line (test-pat 'not_loop (in-case-1 0.5 1 1 1 1)))
   (line (test-pat 'loop (in-case-1 0.5 0.9 1.1 1 4)))

   (line (test-pat (tuple 'EXIT (tuple 'badarith _))
		   (catch (in-case-1 1 1 1 1 0))))
   (line (test-pat (tuple 'EXIT (tuple 'badarith _))
		   (catch (in-case-1 1 1 1 1 'nan))))
   (line (test-pat (tuple 'EXIT (tuple 'badarg _))
		   (catch (in-case-1 1 1 1 'blurf 1))))
   (line (test-pat (tuple 'EXIT (tuple 'badarith _))
		   (catch (in-case-1 '(nan) 1 1 1 1))))

   'ok))

(defun in-case-1 (lenup lendw lenn rot count)
  (let* ((r0 (in-case-1-body lenup lendw lenn rot count))
	 (res (when (=:= r0 res))
	      (in-case-1-guard lenup lendw lenn rot count)))
    res))

(defun in-case-1-body (lenup lendw lenn rot count)
  ;; This is a 'cond'.
  (case (and (and (> (/ lenup count) 0.707) (> (/ lenn count) 0.707))
	     (> (abs rot) 0.707))
    ('true 'edge_rings)
    ('false
     (case (or (or (or (>= lenup 1) (>= lendw 1)) (=< lenn 1)) (> count 4))
       ('true 'not_loop)
       ('false 'loop)))))

(defun in-case-1-guard (lenup lendw lenn rot count)
  (case (andalso (> (/ lenup count) 0.707) (> (/ lenn count) 0.707)
		 (> (abs rot) 0.707))
    ('true 'edge_rings)
    ('false (when (orelse (>= lenup 1) (>= lendw 1) (=< lenn 1) (< count 4)))
	    'not_loop)
    ('false 'loop)))

(defun before_and_inside_if
  ([config] (when (is_list config))
   ;; We don't have real if's.
   (line (test-pat 'no (before-and-inside-if '(a) '(b) 'delete)))
   (line (test-pat 'no (before-and-inside-if '(a) '(b) 'x)))
   (line (test-pat 'no (before-and-inside-if '(a) '() 'delete)))
   (line (test-pat 'no (before-and-inside-if '(a) '() 'x)))
   (line (test-pat 'no (before-and-inside-if '() '() 'delete)))
   (line (test-pat 'yes (before-and-inside-if '() '() 'x)))
   (line (test-pat 'yes (before-and-inside-if '() '(b) 'delete)))
   (line (test-pat 'yes (before-and-inside-if '() '(b) 'x)))

   (line (test-pat #(ch1 ch2) (before-and-inside-if-2 '(a) '(b) 'blah)))
   (line (test-pat #(ch1 ch2) (before-and-inside-if-2 '(a) '(b) 'xx)))
   (line (test-pat #(ch1 ch2) (before-and-inside-if-2 '(a) '() 'blah)))
   (line (test-pat #(ch1 ch2) (before-and-inside-if-2 '(a) '() 'xx)))
   (line (test-pat #(no no) (before-and-inside-if-2 '() '(b) 'blah)))
   (line (test-pat #(no no) (before-and-inside-if-2 '() '(b) 'xx)))
   (line (test-pat #(ch1 no) (before-and-inside-if-2 '() '() 'blah)))
   (line (test-pat #(no ch2) (before-and-inside-if-2 '() '() 'xx)))

   'ok))

;; Thanks to Simon Cornish and Kostis Sagonas.
;; Used to crash beam_bool.
(defun before-and-inside-if (XDo1 XDo2 Do3)
  (let* ((Do1 (=/= XDo1 ()))
	 (Do2 (=/= XDo2 ())))
    (eif
     ;; This expression occurs in a try/catch (protected)
     ;; block, which cannot refer to variables outside of
     ;; the block that are boolean expressions.
     (or (=:= Do1 'true)
	 (and (and (=:= Do1 'false) (=:= Do2 'false)) (=:= Do3 'delete)))
     'no
     'true 'yes)))

;; Thanks to Simon Cornish.
;; Used to generate code that would not set {y,0} on
;; all paths before its use (and therefore fail
;; validation by the beam_validator).
(defun before-and-inside-if-2 (XDo1 XDo2 Do3)
  (let* ((Do1 (=/= XDo1 ()))
	 (Do2 (=/= XDo2 ()))
	 (CH1 (eif (or (== Do1 'true)
		       (and (and (== Do1 'false) (== Do2 'false))
			    (== Do3 'blah)))
		   'ch1
		   'true 'no))
	 (CH2 (eif (or (== Do1 'true)
		       (and (and (== Do1 'false) (== Do2 'false))
			    (== Do3 'xx)))
		   'ch2
		   'true 'no)))
    (tuple CH1 CH2)))

;; Utilities

(defun check (v1 v0)
  (eif (/= v1 v0) (progn (: lfe_io fwrite '"error: ~w.\n" (list v1))
			 (exit 'suite_failed))
       'true (: lfe_io fwrite '"ok: ~w.\n" (list v1))))

(defun echo (x)
  (: lfe_io fwrite '"(eval ~w); " (list x))
  x)

;; Call this function to turn off constant propagation.
(defun id (i) i)
