(load "fetch-interface.l")
(fetch-init)

(objects (list *fetch*))

(defun shake-hand ()
  (dotimes (i 300)
    (setq dest-y (* (cos(/ i 20.0)) 20.0))
    (setq dest-z (+ 900 (* (cos (/ i 20.0)) 100.0)))
    (setq dest-pos (float-vector 800 dest-y dest-z))
    (send *fetch* :rarm  :inverse-kinematics (make-coords :pos dest-pos :degug-view t))
    (objects (list *fetch*))
    (format t "dest-pos = ~A ~%" dest-pos)
    (format t "angle-vector = ~A ~%" (send *fetch* :angle-vector))
    )
  )
